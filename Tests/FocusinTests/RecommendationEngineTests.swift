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

    func testAllSixFallbackPassesReturnTheExpectedCandidateSet() {
        func ids(_ catalog: [BreakActivity], excluding excluded: Set<String> = []) -> [String] {
            engine.candidates(
                from: catalog,
                request: RecommendationRequest(
                    state: .stiff,
                    duration: .twoMinutes,
                    officeSafeOnly: false,
                    includeMindfulness: true,
                    excludedActivityIDs: excluded
                )
            ).map(\.id)
        }

        let exact = [
            activity(id: "a-exact", states: [.stiff], durations: [.twoMinutes]),
            activity(id: "b-exact", states: [.stiff], durations: [.twoMinutes])
        ]
        XCTAssertEqual(ids(exact), ["a-exact", "b-exact"]) // pass 1
        XCTAssertEqual(ids(exact, excluding: ["a-exact", "b-exact"]), ["a-exact", "b-exact"]) // pass 2

        let stateOnly = [activity(id: "state", states: [.stiff], durations: [.fiveMinutes])]
        XCTAssertEqual(ids(stateOnly), ["state"]) // pass 3

        let durationOnly = [activity(id: "duration", states: [.tired], durations: [.twoMinutes])]
        XCTAssertEqual(ids(durationOnly), ["duration"]) // pass 4

        let broad = [activity(id: "broad", states: [.tired], durations: [.fiveMinutes])]
        XCTAssertEqual(ids(broad), ["broad"]) // pass 5
        XCTAssertEqual(ids(broad, excluding: ["broad"]), ["broad"]) // pass 6
    }

    func testHardPreferencesNeverRelaxAcrossFallbacks() {
        let candidates = engine.candidates(
            from: [
                activity(id: "unsafe", states: [.stiff], durations: [.twoMinutes], officeSafe: false),
                activity(id: "mindful", states: [.stiff], durations: [.twoMinutes], mindfulness: true)
            ],
            request: RecommendationRequest(
                state: .fine,
                duration: .tenMinutes,
                officeSafeOnly: true,
                includeMindfulness: false,
                excludedActivityIDs: ["unsafe", "mindful"]
            )
        )
        XCTAssertTrue(candidates.isEmpty)
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

    func testActivityLibraryRejectsMissingStateAndDurationCoverage() {
        XCTAssertThrowsError(try ActivityLibrary.validate([
            activity(id: "empty-state", states: [], durations: [.twoMinutes])
        ]))
        XCTAssertThrowsError(try ActivityLibrary.validate([
            activity(id: "empty-duration", states: FocusState.allCases, durations: [])
        ]))
        XCTAssertThrowsError(try ActivityLibrary.validate([
            activity(id: "unsafe-only", states: FocusState.allCases, durations: BreakDuration.allCases, officeSafe: false)
        ]))
        XCTAssertThrowsError(try ActivityLibrary.validate([
            activity(id: "mindful-only", states: FocusState.allCases, durations: BreakDuration.allCases, mindfulness: true)
        ]))
    }

    func testActivityLibraryRejectsInvalidIdentityAndCopy() {
        let validCoverage = completeCoverageActivities()

        XCTAssertThrowsError(try ActivityLibrary.validate(
            validCoverage + [activity(id: "Invalid ID", states: [.fine], durations: [.twoMinutes])]
        ))
        XCTAssertThrowsError(try ActivityLibrary.validate(
            validCoverage + [activity(id: "blank-title", title: "  ", states: [.fine], durations: [.twoMinutes])]
        ))
        XCTAssertThrowsError(try ActivityLibrary.validate(
            validCoverage + [activity(id: "blank-instruction", instruction: "\n", states: [.fine], durations: [.twoMinutes])]
        ))
    }

    func testActivityLibraryRejectsMissingDefaultFilterIntersection() {
        let catalog = completeCoverageActivities().map { activity in
            guard activity.id == "coverage-0-0" else { return activity }
            return self.activity(
                id: activity.id,
                states: activity.states,
                durations: activity.durations,
                officeSafe: false
            )
        }

        XCTAssertThrowsError(try ActivityLibrary.validate(catalog))
    }

    func testRealBundledCatalogPassesStructuralAndCoverageValidation() throws {
        let activities = try ActivityLibrary.load()
        XCTAssertGreaterThanOrEqual(activities.count, 21)
        XCTAssertEqual(Set(activities.map(\.id)).count, activities.count)
        XCTAssertNoThrow(try ActivityLibrary.validate(activities))

        for state in FocusState.allCases {
            XCTAssertTrue(activities.contains { $0.states.contains(state) && $0.officeSafe })
            XCTAssertTrue(activities.contains { $0.states.contains(state) && !$0.mindfulness })
        }
        for duration in BreakDuration.allCases {
            XCTAssertTrue(activities.contains { $0.durations.contains(duration) })
        }

        let report = ActivityLibrary.coverageReport(for: activities)
        XCTAssertEqual(report.totalActivities, 21)
        XCTAssertTrue(report.countsByState.values.allSatisfy { $0 > 0 })
        XCTAssertTrue(report.countsByDuration.values.allSatisfy { $0 > 0 })
        XCTAssertTrue(report.countsByCategory.values.allSatisfy { $0 > 0 })
        XCTAssertTrue(report.countsByIntensity.values.allSatisfy { $0 > 0 })
        XCTAssertTrue(report.defaultFilterMatrix.values.allSatisfy { $0 > 0 })
        XCTAssertTrue(report.sparseDefaultFilterIntersections.isEmpty)
    }

    private func activity(
        id: String,
        title: String? = nil,
        instruction: String = "Instruction",
        states: [FocusState],
        durations: [BreakDuration],
        category: ActivityCategory = .move,
        officeSafe: Bool = true,
        mindfulness: Bool = false
    ) -> BreakActivity {
        BreakActivity(
            id: id,
            title: title ?? id,
            instruction: instruction,
            category: category,
            states: states,
            durations: durations,
            officeSafe: officeSafe,
            mindfulness: mindfulness,
            intensity: .low
        )
    }

    private func completeCoverageActivities() -> [BreakActivity] {
        FocusState.allCases.enumerated().flatMap { stateIndex, state in
            BreakDuration.allCases.enumerated().map { durationIndex, duration in
                activity(
                    id: "coverage-\(stateIndex)-\(durationIndex)",
                    states: [state],
                    durations: [duration]
                )
            }
        } + [
            BreakActivity(
                id: "coverage-social-medium",
                title: "Social coverage",
                instruction: "Send a message.",
                category: .social,
                states: [.fine],
                durations: [.twoMinutes],
                officeSafe: true,
                mindfulness: false,
                intensity: .medium
            ),
            BreakActivity(
                id: "coverage-mind",
                title: "Mind coverage",
                instruction: "Notice a sound.",
                category: .mind,
                states: [.fine],
                durations: [.twoMinutes],
                officeSafe: true,
                mindfulness: true,
                intensity: .low
            ),
            activity(id: "coverage-desk", states: [.fine], durations: [.twoMinutes], category: .desk),
            activity(id: "coverage-focus", states: [.fine], durations: [.twoMinutes], category: .focus)
        ]
    }
}
