import Foundation

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
        let ids = activities.map(\.id)
        guard Set(ids).count == ids.count else {
            throw ActivityLibraryError.invalidLibrary("Activity IDs must be unique.")
        }

        for activity in activities {
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
        }
    }
}

public enum ActivityLibraryError: Error, Equatable {
    case missingResource
    case invalidLibrary(String)
}
