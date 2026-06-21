import Foundation

@MainActor
final class FocusinPersistence {
    private enum Key {
        static let settings = "focusin.settings"
        static let selectedState = "focusin.selectedState"
        static let selectedDuration = "focusin.selectedDuration"
        static let dailyHistory = "focusin.dailyHistory"
        static let reminderStartedAt = "focusin.reminderStartedAt"
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
        return settings
    }

    func save(settings: FocusinSettings) {
        guard let data = try? encoder.encode(settings) else { return }
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

    func loadDailyHistory(dateKey: String) -> DailyActivityHistory {
        guard let data = defaults.data(forKey: Key.dailyHistory),
              var history = try? decoder.decode(DailyActivityHistory.self, from: data) else {
            return DailyActivityHistory(dateKey: dateKey)
        }

        if history.dateKey != dateKey {
            history = DailyActivityHistory(dateKey: dateKey)
        }

        return history
    }

    func save(dailyHistory: DailyActivityHistory) {
        guard let data = try? encoder.encode(dailyHistory) else { return }
        defaults.set(data, forKey: Key.dailyHistory)
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
}
