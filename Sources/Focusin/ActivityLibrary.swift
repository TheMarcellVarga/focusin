import Foundation

protocol ActivityLoading {
    func load() throws -> [BreakActivity]
}

struct BundledActivityLoader: ActivityLoading {
    func load() throws -> [BreakActivity] {
        try ActivityLibrary.load()
    }
}

public enum ActivityLibrary {
    public static func load(bundle: Bundle = defaultBundle) throws -> [BreakActivity] {
        guard let url = bundle.url(forResource: "Activities", withExtension: "json") else {
            throw ActivityLibraryError.missingResource
        }

        let data = try Data(contentsOf: url)
        let activities = try JSONDecoder().decode([BreakActivity].self, from: data)
        try validate(activities)
        return activities
    }

    public static var defaultBundle: Bundle {
        #if SWIFT_PACKAGE
        .module
        #else
        .main
        #endif
    }

    public static func validate(_ activities: [BreakActivity]) throws {
        guard !activities.isEmpty else {
            throw ActivityLibraryError.invalidLibrary("The activity library must not be empty.")
        }

        let ids = activities.map(\.id)
        guard Set(ids).count == ids.count else {
            throw ActivityLibraryError.invalidLibrary("Activity IDs must be unique.")
        }

        for activity in activities {
            guard isValidID(activity.id) else {
                throw ActivityLibraryError.invalidLibrary("\(activity.id) must use a lowercase kebab-case ID.")
            }

            guard !activity.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                throw ActivityLibraryError.invalidLibrary("\(activity.id) must include a title.")
            }

            guard !activity.instruction.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                throw ActivityLibraryError.invalidLibrary("\(activity.id) must include an instruction.")
            }

            if activity.states.isEmpty {
                throw ActivityLibraryError.invalidLibrary("\(activity.id) must include at least one state.")
            }

            if activity.durations.isEmpty {
                throw ActivityLibraryError.invalidLibrary("\(activity.id) must include at least one duration.")
            }
        }

        for state in FocusState.allCases {
            let activitiesForState = activities.filter { $0.states.contains(state) }
            if !activitiesForState.contains(where: \.officeSafe) {
                throw ActivityLibraryError.invalidLibrary("\(state.rawValue) needs an office-safe activity.")
            }

            if !activitiesForState.contains(where: { !$0.mindfulness }) {
                throw ActivityLibraryError.invalidLibrary("\(state.rawValue) needs a non-mindfulness fallback.")
            }

            for duration in BreakDuration.allCases {
                guard activitiesForState.contains(where: {
                    $0.durations.contains(duration) && $0.officeSafe
                }) else {
                    throw ActivityLibraryError.invalidLibrary(
                        "\(state.rawValue)/\(duration.rawValue) needs a default-filter activity."
                    )
                }
            }
        }

        for category in ActivityCategory.allCases {
            guard activities.contains(where: { $0.category == category }) else {
                throw ActivityLibraryError.invalidLibrary("The catalog needs a \(category.rawValue) activity.")
            }
        }

        for intensity in ActivityIntensity.allCases {
            guard activities.contains(where: { $0.intensity == intensity }) else {
                throw ActivityLibraryError.invalidLibrary("The catalog needs a \(intensity.rawValue)-intensity activity.")
            }
        }
    }

    public static func coverageReport(for activities: [BreakActivity]) -> ActivityCatalogCoverageReport {
        ActivityCatalogCoverageReport(
            totalActivities: activities.count,
            countsByState: Dictionary(uniqueKeysWithValues: FocusState.allCases.map { state in
                (state, activities.count { $0.states.contains(state) })
            }),
            countsByDuration: Dictionary(uniqueKeysWithValues: BreakDuration.allCases.map { duration in
                (duration, activities.count { $0.durations.contains(duration) })
            }),
            countsByCategory: Dictionary(uniqueKeysWithValues: ActivityCategory.allCases.map { category in
                (category, activities.count { $0.category == category })
            }),
            officeSafeCount: activities.count(where: \.officeSafe),
            mindfulnessCount: activities.count(where: \.mindfulness),
            countsByIntensity: Dictionary(uniqueKeysWithValues: ActivityIntensity.allCases.map { intensity in
                (intensity, activities.count { $0.intensity == intensity })
            }),
            defaultFilterMatrix: Dictionary(uniqueKeysWithValues: FocusState.allCases.flatMap { state in
                BreakDuration.allCases.map { duration in
                    (ActivityCatalogCoverageReport.Intersection(state: state, duration: duration), activities.count {
                        $0.states.contains(state) && $0.durations.contains(duration) && $0.officeSafe
                    })
                }
            })
        )
    }

    private static func isValidID(_ id: String) -> Bool {
        guard !id.isEmpty, id == id.lowercased() else { return false }
        let parts = id.split(separator: "-", omittingEmptySubsequences: false)
        return parts.allSatisfy { part in
            !part.isEmpty && part.allSatisfy { $0.isASCII && ($0.isLetter || $0.isNumber) }
        }
    }
}

public struct ActivityCatalogCoverageReport: Equatable, Sendable {
    public struct Intersection: Hashable, Sendable {
        public let state: FocusState
        public let duration: BreakDuration

        public init(state: FocusState, duration: BreakDuration) {
            self.state = state
            self.duration = duration
        }
    }

    public let totalActivities: Int
    public let countsByState: [FocusState: Int]
    public let countsByDuration: [BreakDuration: Int]
    public let countsByCategory: [ActivityCategory: Int]
    public let officeSafeCount: Int
    public let mindfulnessCount: Int
    public let countsByIntensity: [ActivityIntensity: Int]
    public let defaultFilterMatrix: [Intersection: Int]

    public var sparseDefaultFilterIntersections: [Intersection] {
        defaultFilterMatrix
            .filter { $0.value < 2 }
            .map(\.key)
            .sorted {
                let leftState = FocusState.allCases.firstIndex(of: $0.state) ?? 0
                let rightState = FocusState.allCases.firstIndex(of: $1.state) ?? 0
                if leftState != rightState { return leftState < rightState }
                let leftDuration = BreakDuration.allCases.firstIndex(of: $0.duration) ?? 0
                let rightDuration = BreakDuration.allCases.firstIndex(of: $1.duration) ?? 0
                return leftDuration < rightDuration
            }
    }
}

public enum ActivityLibraryError: Error, Equatable {
    case missingResource
    case invalidLibrary(String)
}
