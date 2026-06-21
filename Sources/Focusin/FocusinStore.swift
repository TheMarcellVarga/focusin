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
    @Published var dailyHistory: DailyActivityHistory
    @Published var isBreakDue = false
    @Published var focusStartedAt: Date?
    @Published var breakEndsAt: Date?
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
        dailyHistory = resolvedPersistence.loadDailyHistory(dateKey: DateKey.make(for: Date()))
        focusStartedAt = resolvedPersistence.loadReminderStartedAt()

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
        if focusStartedAt == nil {
            startFocusTimer()
        } else {
            rescheduleReminder()
        }
    }

    var focusStatusText: String {
        if isBreakDue {
            return "Break due"
        }

        guard let focusStartedAt else {
            return "Ready"
        }

        let elapsed = max(0, Int(Date().timeIntervalSince(focusStartedAt)))
        let remaining = max(settings.resolvedWorkMinutes * 60 - elapsed, 0)
        return "Focus \(remaining / 60)m"
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
            excludedActivityIDs: dailyHistory.activityIDs
        )

        currentActivity = engine.recommend(from: activities, request: request)
    }

    func anotherActivity() {
        recordCurrentActivity()
        recommend()
    }

    func startBreak() {
        guard currentActivity != nil else { return }
        isBreakDue = false
        focusStartedAt = nil
        persistence.save(reminderStartedAt: nil)
        notifications.clearBreakReminder()
        remainingBreakSeconds = selectedDuration.seconds
        breakEndsAt = Date().addingTimeInterval(TimeInterval(selectedDuration.seconds))
    }

    func completeBreak() {
        recordCurrentActivity()
        breakEndsAt = nil
        remainingBreakSeconds = 0
        startFocusTimer()
        recommend()
    }

    func skipActivity() {
        recordCurrentActivity()
        breakEndsAt = nil
        remainingBreakSeconds = 0
        startFocusTimer()
        recommend()
    }

    func startFocusTimer() {
        let now = Date()
        focusStartedAt = now
        isBreakDue = false
        persistence.save(reminderStartedAt: now)
        rescheduleReminder()
    }

    func markBreakDue() {
        isBreakDue = true
        focusStartedAt = nil
        persistence.save(reminderStartedAt: nil)
        notifications.clearBreakReminder()
    }

    private func recordCurrentActivity() {
        refreshHistoryIfNeeded()
        guard let currentActivity else { return }
        dailyHistory.activityIDs.insert(currentActivity.id)
        persistence.save(dailyHistory: dailyHistory)
    }

    private func refreshHistoryIfNeeded() {
        let dateKey = DateKey.make(for: Date())
        if dailyHistory.dateKey != dateKey {
            dailyHistory = DailyActivityHistory(dateKey: dateKey)
            persistence.save(dailyHistory: dailyHistory)
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
