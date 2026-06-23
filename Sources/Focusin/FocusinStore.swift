import Foundation
import SwiftUI

@MainActor
final class FocusinStore: ObservableObject {
    @Published var activities: [BreakActivity] = []
    @Published var settings: FocusinSettings {
        didSet {
            persistence.save(settings: settings)
            LaunchAtLoginController.setEnabled(settings.launchAtLogin)
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

    private let persistence: FocusinPersistence
    private let engine = RecommendationEngine()
    private let notifications = NotificationScheduler.shared
    private var ticker: Timer?

    init(persistence: FocusinPersistence? = nil) {
        let resolvedPersistence = persistence ?? FocusinPersistence()
        self.persistence = resolvedPersistence

        let loadedSettings = resolvedPersistence.loadSettings()
        settings = loadedSettings
        selectedState = resolvedPersistence.loadSelectedState()
        selectedDuration = resolvedPersistence.loadSelectedDuration(defaultDuration: loadedSettings.defaultDuration)
        activityHistory = resolvedPersistence.loadActivityHistory(dateKey: DateKey.make(for: Date()))
        runtimeState = resolvedPersistence.loadRuntimeState()

        do {
            activities = try ActivityLibrary.load()
            recommend()
        } catch {
            libraryErrorMessage = "The local activity library could not be loaded."
        }

        notifications.requestAuthorization()
        notifications.onReminderOpened = { [weak self] in
            self?.markBreakDue()
        }

        startTicker()
        restoreRuntimeState()
        if runtimeState == .idle {
            startFocusTimer()
        } else {
            rescheduleReminder()
        }
    }

    var focusStatusText: String {
        switch runtimeState {
        case .breakDue:
            return "Break due"
        case .breaking:
            return "Break \(remainingBreakSeconds / 60)m"
        case .idle:
            return "Ready"
        case let .focusing(startedAt):
            let elapsed = max(0, Int(Date().timeIntervalSince(startedAt)))
            let remaining = max(settings.resolvedWorkMinutes * 60 - elapsed, 0)
            return "Focus \(remaining / 60)m"
        }
    }

    var isBreakDue: Bool {
        runtimeState == .breakDue
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
            endsAt: Date().addingTimeInterval(TimeInterval(selectedDuration.seconds))
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
        let now = Date()
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
        let dateKey = DateKey.make(for: Date())
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

    private func tick() {
        refreshHistoryIfNeeded()

        if let breakEndsAt {
            remainingBreakSeconds = max(0, Int(ceil(breakEndsAt.timeIntervalSinceNow)))
            if remainingBreakSeconds == 0 {
                completeBreak()
            }
        }

        if let focusStartedAt,
           Date().timeIntervalSince(focusStartedAt) >= TimeInterval(settings.resolvedWorkMinutes * 60) {
            markBreakDue()
        }
    }

    private func rescheduleReminder() {
        notifications.clearBreakReminder()

        guard let focusStartedAt, !isQuietTime(date: Date()) else {
            return
        }

        let elapsed = Date().timeIntervalSince(focusStartedAt)
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
            let elapsed = Date().timeIntervalSince(startedAt)
            if elapsed >= TimeInterval(settings.resolvedWorkMinutes * 60) {
                markBreakDue()
            }
        case .breakDue:
            remainingBreakSeconds = 0
        case let .breaking(activityID, endsAt):
            remainingBreakSeconds = max(0, Int(ceil(endsAt.timeIntervalSinceNow)))
            currentActivity = activities.first { $0.id == activityID } ?? currentActivity
            if remainingBreakSeconds == 0 {
                completeBreak()
            }
        }
    }

    private func isQuietTime(date: Date) -> Bool {
        guard settings.quietHoursEnabled else { return false }

        let hour = Calendar.current.component(.hour, from: date)
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
}
