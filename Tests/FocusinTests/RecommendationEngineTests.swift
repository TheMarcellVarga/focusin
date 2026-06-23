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

    func testActivityHistoryCombinesRecommendationExclusions() {
        let history = ActivityHistory(
            dateKey: "2026-6-23",
            completedActivityIDs: ["completed"],
            skippedActivityIDs: ["skipped"],
            seenActivityIDs: ["seen"]
        )

        XCTAssertEqual(history.excludedForRecommendations, ["completed", "skipped", "seen"])
    }

    func testSettingsNormalizeClampsUserEditableNumbers() {
        let settings = FocusinSettings(customWorkMinutes: 999, quietStartHour: -4, quietEndHour: 40).normalized

        XCTAssertEqual(settings.customWorkMinutes, 240)
        XCTAssertEqual(settings.quietStartHour, 0)
        XCTAssertEqual(settings.quietEndHour, 23)
    }

    func testSettingsDecodeMissingNewFieldsWithDefaults() throws {
        let data = """
        {
          "workInterval": 25,
          "customWorkMinutes": 25,
          "defaultDuration": "twoMinutes"
        }
        """.data(using: .utf8)!

        let settings = try JSONDecoder().decode(FocusinSettings.self, from: data)

        XCTAssertTrue(settings.showMenuBarText)
        XCTAssertTrue(settings.notificationsEnabled)
        XCTAssertTrue(settings.startFocusTimerOnLaunch)
    }

    func testRuntimeStateCodableRoundTrip() throws {
        let state = FocusinRuntimeState.breaking(activityID: "window-breath-30", endsAt: Date(timeIntervalSince1970: 1_800))
        let data = try JSONEncoder().encode(state)
        let decoded = try JSONDecoder().decode(FocusinRuntimeState.self, from: data)

        XCTAssertEqual(decoded, state)
    }

    func testActivityLibraryValidationRejectsDuplicateIDs() {
        let duplicated = [
            activity(id: "duplicate", states: [.fine], durations: [.twoMinutes]),
            activity(id: "duplicate", states: [.fine], durations: [.fiveMinutes])
        ]

        XCTAssertThrowsError(try ActivityLibrary.validate(duplicated))
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
