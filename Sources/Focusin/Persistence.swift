import Foundation

@MainActor
final class FocusinPersistence {
    private enum Key {
        static let settings = "focusin.settings"
        static let selectedState = "focusin.selectedState"
        static let selectedDuration = "focusin.selectedDuration"
        static let dailyHistory = "focusin.dailyHistory"
        static let activityHistory = "focusin.activityHistory"
        static let reminderStartedAt = "focusin.reminderStartedAt"
        static let runtimeState = "focusin.runtimeState"
    }

    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func loadSettings() -> FocusinSettings {
        guard let data = defaults.data(forKey: Key.settings),
              let settings = try? decoder.decode(FocusinSettings.self, from: data) else {
            return FocusinSettings()
        }
        return settings.normalized
    }

    func save(settings: FocusinSettings) {
        guard let data = try? encoder.encode(settings.normalized) else { return }
        defaults.set(data, forKey: Key.settings)
    }

    func loadSelectedState() -> FocusState {
        guard let rawValue = defaults.string(forKey: Key.selectedState),
              let state = FocusState(rawValue: rawValue) else {
            return .fine
        }
        return state
    }

    func save(selectedState: FocusState) {
        defaults.set(selectedState.rawValue, forKey: Key.selectedState)
    }

    func loadSelectedDuration(defaultDuration: BreakDuration) -> BreakDuration {
        guard let rawValue = defaults.string(forKey: Key.selectedDuration),
              let duration = BreakDuration(rawValue: rawValue) else {
            return defaultDuration
        }
        return duration
    }

    func save(selectedDuration: BreakDuration) {
        defaults.set(selectedDuration.rawValue, forKey: Key.selectedDuration)
    }

    func loadActivityHistory(dateKey: String) -> ActivityHistory {
        if let data = defaults.data(forKey: Key.activityHistory),
           var history = try? decoder.decode(ActivityHistory.self, from: data) {
            if history.dateKey != dateKey {
                history = ActivityHistory(dateKey: dateKey)
            }
            return history
        }

        if let data = defaults.data(forKey: Key.dailyHistory),
           let legacyHistory = try? decoder.decode(LegacyDailyActivityHistory.self, from: data),
           legacyHistory.dateKey == dateKey {
            return ActivityHistory(dateKey: dateKey, completedActivityIDs: legacyHistory.activityIDs)
        }

        return ActivityHistory(dateKey: dateKey)
    }

    func save(activityHistory: ActivityHistory) {
        guard let data = try? encoder.encode(activityHistory) else { return }
        defaults.set(data, forKey: Key.activityHistory)
    }

    func loadReminderStartedAt() -> Date? {
        defaults.object(forKey: Key.reminderStartedAt) as? Date
    }

    func save(reminderStartedAt: Date?) {
        if let reminderStartedAt {
            defaults.set(reminderStartedAt, forKey: Key.reminderStartedAt)
        } else {
            defaults.removeObject(forKey: Key.reminderStartedAt)
        }
    }

    func loadRuntimeState() -> FocusinRuntimeState {
        if let data = defaults.data(forKey: Key.runtimeState),
           let state = try? decoder.decode(FocusinRuntimeState.self, from: data) {
            return state
        }

        if let legacyStartedAt = loadReminderStartedAt() {
            return .focusing(startedAt: legacyStartedAt)
        }

        return .idle
    }

    func save(runtimeState: FocusinRuntimeState) {
        guard let data = try? encoder.encode(runtimeState) else { return }
        defaults.set(data, forKey: Key.runtimeState)
    }
}

private struct LegacyDailyActivityHistory: Codable {
    var dateKey: String
    var activityIDs: Set<String>
}
