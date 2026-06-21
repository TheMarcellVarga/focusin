import XCTest
@testable import Focusin

final class RecommendationEngineTests: XCTestCase {
    private let engine = RecommendationEngine()

    func testMatchesSelectedStateAndDuration() {
        let selected = engine.recommend(
            from: [
                activity(id: "wrong-state", states: [.tired], durations: [.twoMinutes]),
                activity(id: "right", states: [.stiff], durations: [.twoMinutes])
            ],
            request: RecommendationRequest(
                state: .stiff,
                duration: .twoMinutes,
                officeSafeOnly: false,
                includeMindfulness: true
            )
        )

        XCTAssertEqual(selected?.id, "right")
    }

    func testOfficeSafeModeExcludesUnsafeActivities() {
        let selected = engine.recommend(
            from: [
                activity(id: "unsafe", states: [.stiff], durations: [.twoMinutes], officeSafe: false),
                activity(id: "safe", states: [.stiff], durations: [.twoMinutes], officeSafe: true)
            ],
            request: RecommendationRequest(
                state: .stiff,
                duration: .twoMinutes,
                officeSafeOnly: true,
                includeMindfulness: true
            )
        )

        XCTAssertEqual(selected?.id, "safe")
    }

    func testMindfulnessToggleExcludesMindfulActivitiesWhenDisabled() {
        let selected = engine.recommend(
            from: [
                activity(id: "mindful", states: [.anxious], durations: [.twoMinutes], mindfulness: true),
                activity(id: "plain", states: [.anxious], durations: [.twoMinutes], mindfulness: false)
            ],
            request: RecommendationRequest(
                state: .anxious,
                duration: .twoMinutes,
                officeSafeOnly: false,
                includeMindfulness: false
            )
        )

        XCTAssertEqual(selected?.id, "plain")
    }

    func testAvoidsRepeatedActivitiesWhenAlternativesExist() {
        let selected = engine.recommend(
            from: [
                activity(id: "seen", states: [.fine], durations: [.thirtySeconds]),
                activity(id: "fresh", states: [.fine], durations: [.thirtySeconds])
            ],
            request: RecommendationRequest(
                state: .fine,
                duration: .thirtySeconds,
                officeSafeOnly: false,
                includeMindfulness: true,
                excludedActivityIDs: ["seen"]
            )
        )

        XCTAssertEqual(selected?.id, "fresh")
    }

    func testFallsBackToBroaderMatchWhenExactMatchIsUnavailable() {
        let selected = engine.recommend(
            from: [
                activity(id: "fallback", states: [.fine], durations: [.fiveMinutes])
            ],
            request: RecommendationRequest(
                state: .fine,
                duration: .thirtySeconds,
                officeSafeOnly: false,
                includeMindfulness: true
            )
        )

        XCTAssertEqual(selected?.id, "fallback")
    }

    func testDateKeyIgnoresTimeOfDay() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!

        let morning = DateComponents(calendar: calendar, year: 2026, month: 6, day: 21, hour: 8).date!
        let evening = DateComponents(calendar: calendar, year: 2026, month: 6, day: 21, hour: 20).date!

        XCTAssertEqual(DateKey.make(for: morning, calendar: calendar), DateKey.make(for: evening, calendar: calendar))
    }

    private func activity(
        id: String,
        states: [FocusState],
        durations: [BreakDuration],
        officeSafe: Bool = true,
        mindfulness: Bool = false
    ) -> BreakActivity {
        BreakActivity(
            id: id,
            title: id,
            instruction: "Instruction",
            category: .move,
            states: states,
            durations: durations,
            officeSafe: officeSafe,
            mindfulness: mindfulness,
            intensity: .low
        )
    }
}
