import Foundation

public struct RecommendationRequest: Sendable {
    public let state: FocusState
    public let duration: BreakDuration
    public let officeSafeOnly: Bool
    public let includeMindfulness: Bool
    public let excludedActivityIDs: Set<String>

    public init(
        state: FocusState,
        duration: BreakDuration,
        officeSafeOnly: Bool,
        includeMindfulness: Bool,
        excludedActivityIDs: Set<String> = []
    ) {
        self.state = state
        self.duration = duration
        self.officeSafeOnly = officeSafeOnly
        self.includeMindfulness = includeMindfulness
        self.excludedActivityIDs = excludedActivityIDs
    }
}

public struct RecommendationEngine: Sendable {
    public init() {}

    public func recommend(from activities: [BreakActivity], request: RecommendationRequest) -> BreakActivity? {
        candidates(from: activities, request: request).randomElement()
    }

    /// Returns the first non-empty fallback pass. Keeping selection separate makes
    /// the recommendation policy deterministic to test while preserving random
    /// choice among equally eligible activities in the app.
    public func candidates(from activities: [BreakActivity], request: RecommendationRequest) -> [BreakActivity] {
        let eligible = activities.filter { activity in
            (!request.officeSafeOnly || activity.officeSafe)
                && (request.includeMindfulness || !activity.mindfulness)
        }

        let passes: [(BreakActivity) -> Bool] = [
            { activity in
                activity.states.contains(request.state)
                    && activity.durations.contains(request.duration)
                    && !request.excludedActivityIDs.contains(activity.id)
            },
            { activity in
                activity.states.contains(request.state)
                    && activity.durations.contains(request.duration)
            },
            { activity in
                activity.states.contains(request.state)
                    && !request.excludedActivityIDs.contains(activity.id)
            },
            { activity in
                activity.durations.contains(request.duration)
                    && !request.excludedActivityIDs.contains(activity.id)
            },
            { activity in
                !request.excludedActivityIDs.contains(activity.id)
            },
            { _ in true }
        ]

        for pass in passes {
            let candidates = eligible.filter(pass).sorted { lhs, rhs in
                lhs.title.localizedCaseInsensitiveCompare(rhs.title) == .orderedAscending
            }

            if !candidates.isEmpty {
                return candidates
            }
        }

        return []
    }
}

public enum DateKey {
    public static func make(for date: Date, calendar: Calendar = .current) -> String {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return "\(components.year ?? 0)-\(components.month ?? 0)-\(components.day ?? 0)"
    }
}
