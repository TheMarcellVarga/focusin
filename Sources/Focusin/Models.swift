import Foundation

enum FocusinSettingsTab: Hashable {
    case reminder
    case activities
    case system
    case feedback
}

public enum FocusState: String, CaseIterable, Codable, Hashable, Identifiable, Sendable {
    case stiff
    case tired
    case scattered
    case anxious
    case fine

    public var id: String { rawValue }

    public var label: String {
        switch self {
        case .stiff: "Stiff"
        case .tired: "Tired"
        case .scattered: "Scattered"
        case .anxious: "Anxious"
        case .fine: "Fine"
        }
    }
}

public enum BreakDuration: String, CaseIterable, Codable, Hashable, Identifiable, Sendable {
    case thirtySeconds
    case twoMinutes
    case fiveMinutes
    case tenMinutes

    public var id: String { rawValue }

    public var label: String {
        switch self {
        case .thirtySeconds: "30s"
        case .twoMinutes: "2m"
        case .fiveMinutes: "5m"
        case .tenMinutes: "10m"
        }
    }

    public var seconds: Int {
        switch self {
        case .thirtySeconds: 30
        case .twoMinutes: 120
        case .fiveMinutes: 300
        case .tenMinutes: 600
        }
    }
}

public enum ActivityCategory: String, Codable, CaseIterable, Hashable, Identifiable, Sendable {
    case move
    case mind
    case desk
    case focus
    case social

    public var id: String { rawValue }
}

public enum ActivityIntensity: String, Codable, CaseIterable, Hashable, Sendable {
    case low
    case medium
}

public struct BreakActivity: Codable, Identifiable, Equatable, Sendable {
    public let id: String
    public let title: String
    public let instruction: String
    public let category: ActivityCategory
    public let states: [FocusState]
    public let durations: [BreakDuration]
    public let officeSafe: Bool
    public let mindfulness: Bool
    public let intensity: ActivityIntensity

    public init(
        id: String,
        title: String,
        instruction: String,
        category: ActivityCategory,
        states: [FocusState],
        durations: [BreakDuration],
        officeSafe: Bool,
        mindfulness: Bool,
        intensity: ActivityIntensity
    ) {
        self.id = id
        self.title = title
        self.instruction = instruction
        self.category = category
        self.states = states
        self.durations = durations
        self.officeSafe = officeSafe
        self.mindfulness = mindfulness
        self.intensity = intensity
    }
}

public enum WorkInterval: Int, CaseIterable, Codable, Identifiable, Sendable {
    case twentyFive = 25
    case fortyFive = 45
    case sixty = 60
    case custom = -1

    public var id: Int { rawValue }

    public var label: String {
        switch self {
        case .twentyFive: "25m"
        case .fortyFive: "45m"
        case .sixty: "60m"
        case .custom: "Custom"
        }
    }
}

public struct FocusinSettings: Codable, Equatable, Sendable {
    public var workInterval: WorkInterval
    public var customWorkMinutes: Int
    public var defaultDuration: BreakDuration
    public var officeSafeOnly: Bool
    public var includeMindfulness: Bool
    public var quietHoursEnabled: Bool
    public var quietStartHour: Int
    public var quietEndHour: Int
    public var launchAtLogin: Bool
    public var showMenuBarText: Bool
    public var notificationsEnabled: Bool
    public var startFocusTimerOnLaunch: Bool

    public init(
        workInterval: WorkInterval = .twentyFive,
        customWorkMinutes: Int = 25,
        defaultDuration: BreakDuration = .twoMinutes,
        officeSafeOnly: Bool = true,
        includeMindfulness: Bool = true,
        quietHoursEnabled: Bool = false,
        quietStartHour: Int = 18,
        quietEndHour: Int = 8,
        launchAtLogin: Bool = false,
        showMenuBarText: Bool = true,
        notificationsEnabled: Bool = true,
        startFocusTimerOnLaunch: Bool = true
    ) {
        self.workInterval = workInterval
        self.customWorkMinutes = customWorkMinutes
        self.defaultDuration = defaultDuration
        self.officeSafeOnly = officeSafeOnly
        self.includeMindfulness = includeMindfulness
        self.quietHoursEnabled = quietHoursEnabled
        self.quietStartHour = quietStartHour
        self.quietEndHour = quietEndHour
        self.launchAtLogin = launchAtLogin
        self.showMenuBarText = showMenuBarText
        self.notificationsEnabled = notificationsEnabled
        self.startFocusTimerOnLaunch = startFocusTimerOnLaunch
    }

    public var resolvedWorkMinutes: Int {
        switch workInterval {
        case .custom:
            min(max(customWorkMinutes, 1), 240)
        default:
            workInterval.rawValue
        }
    }

    public var normalized: FocusinSettings {
        var copy = self
        copy.customWorkMinutes = min(max(copy.customWorkMinutes, 1), 240)
        copy.quietStartHour = min(max(copy.quietStartHour, 0), 23)
        copy.quietEndHour = min(max(copy.quietEndHour, 0), 23)
        return copy
    }

    private enum CodingKeys: String, CodingKey {
        case workInterval
        case customWorkMinutes
        case defaultDuration
        case officeSafeOnly
        case includeMindfulness
        case quietHoursEnabled
        case quietStartHour
        case quietEndHour
        case launchAtLogin
        case showMenuBarText
        case notificationsEnabled
        case startFocusTimerOnLaunch
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            workInterval: try container.decodeIfPresent(WorkInterval.self, forKey: .workInterval) ?? .twentyFive,
            customWorkMinutes: try container.decodeIfPresent(Int.self, forKey: .customWorkMinutes) ?? 25,
            defaultDuration: try container.decodeIfPresent(BreakDuration.self, forKey: .defaultDuration) ?? .twoMinutes,
            officeSafeOnly: try container.decodeIfPresent(Bool.self, forKey: .officeSafeOnly) ?? true,
            includeMindfulness: try container.decodeIfPresent(Bool.self, forKey: .includeMindfulness) ?? true,
            quietHoursEnabled: try container.decodeIfPresent(Bool.self, forKey: .quietHoursEnabled) ?? false,
            quietStartHour: try container.decodeIfPresent(Int.self, forKey: .quietStartHour) ?? 18,
            quietEndHour: try container.decodeIfPresent(Int.self, forKey: .quietEndHour) ?? 8,
            launchAtLogin: try container.decodeIfPresent(Bool.self, forKey: .launchAtLogin) ?? false,
            showMenuBarText: try container.decodeIfPresent(Bool.self, forKey: .showMenuBarText) ?? true,
            notificationsEnabled: try container.decodeIfPresent(Bool.self, forKey: .notificationsEnabled) ?? true,
            startFocusTimerOnLaunch: try container.decodeIfPresent(Bool.self, forKey: .startFocusTimerOnLaunch) ?? true
        )
    }
}

public enum FocusinRuntimeState: Codable, Equatable, Sendable {
    case idle
    case focusing(startedAt: Date)
    case breakDue
    case breaking(activityID: String, endsAt: Date)
}

public struct ActivityHistory: Codable, Equatable, Sendable {
    public var dateKey: String
    public var completedActivityIDs: Set<String>
    public var skippedActivityIDs: Set<String>
    public var seenActivityIDs: Set<String>

    public init(
        dateKey: String,
        completedActivityIDs: Set<String> = [],
        skippedActivityIDs: Set<String> = [],
        seenActivityIDs: Set<String> = []
    ) {
        self.dateKey = dateKey
        self.completedActivityIDs = completedActivityIDs
        self.skippedActivityIDs = skippedActivityIDs
        self.seenActivityIDs = seenActivityIDs
    }

    public var excludedForRecommendations: Set<String> {
        completedActivityIDs
            .union(skippedActivityIDs)
            .union(seenActivityIDs)
    }
}
