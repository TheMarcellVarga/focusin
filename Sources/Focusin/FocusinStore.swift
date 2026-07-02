import Foundation
import SwiftUI

protocol FocusinClock {
    var now: Date { get }
    var calendar: Calendar { get }
}

struct SystemFocusinClock: FocusinClock {
    var now: Date { Date() }
    var calendar: Calendar { .current }
}

@MainActor
final class FocusinStore: ObservableObject {
    @Published var activities: [BreakActivity] = []
    @Published var settings: FocusinSettings {
        didSet {
            let normalized = settings.normalized
            if settings != normalized {
                settings = normalized
                return
            }
            persistence.save(settings: settings)
            if settings.launchAtLogin != oldValue.launchAtLogin && !isSynchronizingLaunchAtLoginPreference {
                reconcileLaunchAtLogin()
            }
            if settings.notificationsEnabled != oldValue.notificationsEnabled {
                if settings.notificationsEnabled {
                    refreshNotificationPermission()
                } else {
                    notificationPermissionStatus = .notDetermined
                    notifications.clearBreakReminder()
                }
            } else if !settings.notificationsEnabled {
                notifications.clearBreakReminder()
            }
            rescheduleReminder()
        }
    }
    @Published var selectedState: FocusState {
        didSet {
            persistence.save(selectedState: selectedState)
            recommend()
        }
    }
    @Published var selectedDuration: BreakDuration {
        didSet {
            persistence.save(selectedDuration: selectedDuration)
            recommend()
        }
    }
    @Published var currentActivity: BreakActivity?
    @Published var activityHistory: ActivityHistory
    @Published var runtimeState: FocusinRuntimeState {
        didSet {
            persistence.save(runtimeState: runtimeState)
        }
    }
    @Published var remainingBreakSeconds = 0
    @Published var libraryErrorMessage: String?
    @Published private(set) var notificationPermissionStatus: NotificationPermissionStatus = .notDetermined
    @Published private(set) var launchAtLoginStatus: LaunchAtLoginStatus = .disabled

    private let persistence: any FocusinPersisting
    private let engine: RecommendationEngine
    private let notifications: any NotificationScheduling
    private let launchAtLogin: any LaunchAtLoginControlling
    private let activityLoader: any ActivityLoading
    private let clock: any FocusinClock
    private let runsTicker: Bool
    private var ticker: Timer?
    private var isSynchronizingLaunchAtLoginPreference = false

    init(
        persistence: (any FocusinPersisting)? = nil,
        engine: RecommendationEngine = RecommendationEngine(),
        notifications: (any NotificationScheduling)? = nil,
        launchAtLogin: (any LaunchAtLoginControlling)? = nil,
        activityLoader: any ActivityLoading = BundledActivityLoader(),
        clock: any FocusinClock = SystemFocusinClock(),
        runsTicker: Bool = true
    ) {
        let resolvedPersistence = persistence ?? FocusinPersistence()
        self.persistence = resolvedPersistence
        self.engine = engine
        self.notifications = notifications ?? NotificationScheduler.shared
        self.launchAtLogin = launchAtLogin ?? LaunchAtLoginController()
        self.activityLoader = activityLoader
        self.clock = clock
        self.runsTicker = runsTicker

        let loadedSettings = resolvedPersistence.loadSettings()
        settings = loadedSettings
        selectedState = resolvedPersistence.loadSelectedState()
        selectedDuration = resolvedPersistence.loadSelectedDuration(defaultDuration: loadedSettings.defaultDuration)
        activityHistory = resolvedPersistence.loadActivityHistory(dateKey: DateKey.make(for: clock.now, calendar: clock.calendar))
        runtimeState = resolvedPersistence.loadRuntimeState()

        do {
            activities = try activityLoader.load()
            recommend()
        } catch {
            libraryErrorMessage = "The local activity library could not be loaded."
        }

        refreshPlatformStatus()
        self.notifications.onReminderOpened = { [weak self] in
            self?.markBreakDue()
        }

        if runsTicker {
            startTicker()
        }
        restoreRuntimeState()
        if runtimeState == .idle && settings.startFocusTimerOnLaunch {
            startFocusTimer()
        } else {
            rescheduleReminder()
        }
    }

    var focusStatusText: String {
        switch runtimeState {
        case .breakDue:
            return "Break"
        case .breaking:
            return "Reset \(formatted(seconds: remainingBreakSeconds))"
        case .idle:
            return "Ready"
        case let .focusing(startedAt):
            let elapsed = max(0, Int(clock.now.timeIntervalSince(startedAt)))
            let remaining = max(settings.resolvedWorkMinutes * 60 - elapsed, 0)
            return "Focus \(remaining / 60)m"
        }
    }

    var menuBarSystemImage: String {
        switch runtimeState {
        case .idle:
            return "pause.circle"
        case .focusing:
            return "timer"
        case .breakDue:
            return "bell.badge"
        case .breaking:
            return "figure.mind.and.body"
        }
    }

    var isBreakDue: Bool {
        runtimeState == .breakDue
    }

    var isFocusing: Bool {
        if case .focusing = runtimeState {
            return true
        }
        return false
    }

    var isBreaking: Bool {
        if case .breaking = runtimeState {
            return true
        }
        return false
    }

    var runtimeStateTitle: String {
        switch runtimeState {
        case .idle:
            return "Ready"
        case .focusing:
            return "Focus running"
        case .breakDue:
            return "Break due"
        case .breaking:
            return "Break active"
        }
    }

    var runtimeStateDetail: String {
        switch runtimeState {
        case .idle:
            return "Choose a reset or start a focus timer."
        case .focusing:
            return "A gentle reminder will appear when this interval ends."
        case .breakDue:
            return "Start the suggested reset or pick another one."
        case .breaking:
            return "Finish early or skip when you are ready."
        }
    }

    var breakCountdownText: String {
        formatted(seconds: remainingBreakSeconds)
    }

    var focusStartedAt: Date? {
        if case let .focusing(startedAt) = runtimeState {
            return startedAt
        }
        return nil
    }

    var breakEndsAt: Date? {
        if case let .breaking(_, endsAt) = runtimeState {
            return endsAt
        }
        return nil
    }

    var canShowRecommendation: Bool {
        currentActivity != nil && libraryErrorMessage == nil
    }

    var notificationGuidance: String? {
        guard settings.notificationsEnabled else {
            return "Break reminders are off. Timers still continue in Focusin."
        }
        switch notificationPermissionStatus {
        case .notDetermined:
            return "Allow notifications to receive break reminders. Focusin still works without them."
        case .denied:
            return "Notifications are off in System Settings. Timers still continue in Focusin."
        case .authorized:
            return nil
        }
    }

    var launchAtLoginGuidance: String? {
        switch launchAtLoginStatus {
        case .requiresApproval:
            return "Launch at Login needs approval in System Settings."
        case .unavailable, .failed:
            return "Focusin couldn’t update Launch at Login. You can keep using the app."
        case .disabled, .enabled:
            return nil
        }
    }

    func refreshPlatformStatus() {
        refreshNotificationPermission()
        launchAtLoginStatus = launchAtLogin.status()
        synchronizeLaunchAtLoginPreference()
    }

    /// Reconciles wall-clock state and platform integrations after macOS lifecycle
    /// events such as activation, wake, a clock/timezone change, or day rollover.
    func handleLifecycleEvent() {
        reconcileRuntimeState()
        rescheduleReminder()
        refreshPlatformStatus()
    }

    func requestNotificationPermission() {
        guard settings.notificationsEnabled else { return }
        notifications.requestAuthorization { [weak self] status in
            self?.notificationPermissionStatus = status
            self?.rescheduleReminder()
        }
    }

    func retryLaunchAtLogin() {
        reconcileLaunchAtLogin()
    }

    private func refreshNotificationPermission() {
        guard settings.notificationsEnabled else { return }
        notifications.authorizationStatus { [weak self] status in
            self?.notificationPermissionStatus = status
            self?.rescheduleReminder()
        }
    }

    private func reconcileLaunchAtLogin() {
        launchAtLoginStatus = launchAtLogin.setEnabled(settings.launchAtLogin)
        synchronizeLaunchAtLoginPreference()
    }

    private func synchronizeLaunchAtLoginPreference() {
        guard launchAtLoginStatus != .failed else { return }
        let actualEnabled = launchAtLoginStatus == .enabled
        if settings.launchAtLogin != actualEnabled {
            isSynchronizingLaunchAtLoginPreference = true
            settings.launchAtLogin = actualEnabled
            isSynchronizingLaunchAtLoginPreference = false
        }
    }

    func recommend() {
        refreshHistoryIfNeeded()

        let request = RecommendationRequest(
            state: selectedState,
            duration: selectedDuration,
            officeSafeOnly: settings.officeSafeOnly,
            includeMindfulness: settings.includeMindfulness,
            excludedActivityIDs: activityHistory.excludedForRecommendations
        )

        currentActivity = engine.recommend(from: activities, request: request)
    }

    func anotherActivity() {
        recordCurrentActivityAsSeen()
        recommend()
    }

    func startBreak() {
        guard let currentActivity else { return }
        notifications.clearBreakReminder()
        remainingBreakSeconds = selectedDuration.seconds
        runtimeState = .breaking(
            activityID: currentActivity.id,
            endsAt: clock.now.addingTimeInterval(TimeInterval(selectedDuration.seconds))
        )
    }

    func completeBreak() {
        recordCurrentActivityAsCompleted()
        remainingBreakSeconds = 0
        startFocusTimer()
        recommend()
    }

    func skipActivity() {
        recordCurrentActivityAsSkipped()
        remainingBreakSeconds = 0
        startFocusTimer()
        recommend()
    }

    func startFocusTimer() {
        let now = clock.now
        runtimeState = .focusing(startedAt: now)
        rescheduleReminder()
    }

    func markBreakDue() {
        runtimeState = .breakDue
        notifications.clearBreakReminder()
    }

    private func recordCurrentActivityAsSeen() {
        refreshHistoryIfNeeded()
        guard let currentActivity else { return }
        activityHistory.seenActivityIDs.insert(currentActivity.id)
        persistence.save(activityHistory: activityHistory)
    }

    private func recordCurrentActivityAsCompleted() {
        refreshHistoryIfNeeded()
        guard let activityID = activeOrCurrentActivityID else { return }
        activityHistory.completedActivityIDs.insert(activityID)
        persistence.save(activityHistory: activityHistory)
    }

    private func recordCurrentActivityAsSkipped() {
        refreshHistoryIfNeeded()
        guard let activityID = activeOrCurrentActivityID else { return }
        activityHistory.skippedActivityIDs.insert(activityID)
        persistence.save(activityHistory: activityHistory)
    }

    private var activeOrCurrentActivityID: String? {
        if case let .breaking(activityID, _) = runtimeState {
            return activityID
        }

        return currentActivity?.id
    }

    private func refreshHistoryIfNeeded() {
        let dateKey = DateKey.make(for: clock.now, calendar: clock.calendar)
        if activityHistory.dateKey != dateKey {
            activityHistory = ActivityHistory(dateKey: dateKey)
            persistence.save(activityHistory: activityHistory)
        }
    }

    private func startTicker() {
        ticker?.invalidate()
        ticker = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.tick()
            }
        }
    }

    func reconcileRuntimeState() {
        refreshHistoryIfNeeded()

        if let breakEndsAt {
            remainingBreakSeconds = max(0, Int(ceil(breakEndsAt.timeIntervalSince(clock.now))))
            if remainingBreakSeconds == 0 {
                completeBreak()
            }
        }

        if let focusStartedAt,
           clock.now.timeIntervalSince(focusStartedAt) >= TimeInterval(settings.resolvedWorkMinutes * 60) {
            markBreakDue()
        }
    }

    private func tick() {
        reconcileRuntimeState()
    }

    private func rescheduleReminder() {
        notifications.clearBreakReminder()

        guard settings.notificationsEnabled,
              notificationPermissionStatus == .authorized,
              let focusStartedAt,
              !isQuietTime(date: clock.now) else {
            return
        }

        let elapsed = clock.now.timeIntervalSince(focusStartedAt)
        let remaining = TimeInterval(settings.resolvedWorkMinutes * 60) - elapsed
        if remaining <= 0 {
            markBreakDue()
        } else {
            notifications.scheduleBreakReminder(after: remaining)
        }
    }

    private func restoreRuntimeState() {
        switch runtimeState {
        case .idle:
            remainingBreakSeconds = 0
        case let .focusing(startedAt):
            let elapsed = clock.now.timeIntervalSince(startedAt)
            if elapsed >= TimeInterval(settings.resolvedWorkMinutes * 60) {
                markBreakDue()
            }
        case .breakDue:
            remainingBreakSeconds = 0
        case let .breaking(activityID, endsAt):
            guard let restoredActivity = activities.first(where: { $0.id == activityID }) else {
                remainingBreakSeconds = 0
                runtimeState = .breakDue
                notifications.clearBreakReminder()
                recommend()
                return
            }
            remainingBreakSeconds = max(0, Int(ceil(endsAt.timeIntervalSince(clock.now))))
            currentActivity = restoredActivity
            if remainingBreakSeconds == 0 {
                completeBreak()
            }
        }
    }

    private func isQuietTime(date: Date) -> Bool {
        guard settings.quietHoursEnabled else { return false }

        let hour = clock.calendar.component(.hour, from: date)
        let start = settings.quietStartHour
        let end = settings.quietEndHour

        if start == end {
            return true
        }

        if start < end {
            return hour >= start && hour < end
        }

        return hour >= start || hour < end
    }

    private func formatted(seconds: Int) -> String {
        let clamped = max(seconds, 0)
        let minutes = clamped / 60
        let seconds = clamped % 60

        if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        }

        return "\(seconds)s"
    }
}
