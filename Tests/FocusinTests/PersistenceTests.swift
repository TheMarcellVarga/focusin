import XCTest
@testable import Focusin

@MainActor
final class PersistenceTests: XCTestCase {
    private var suiteName: String!
    private var defaults: UserDefaults!

    override func setUp() {
        super.setUp()
        suiteName = "FocusinTests.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        defaults = nil
        suiteName = nil
        super.tearDown()
    }

    func testCleanDefaultsAreDocumentedDefaults() {
        let persistence = FocusinPersistence(defaults: defaults)
        XCTAssertEqual(persistence.loadSettings(), FocusinSettings())
        XCTAssertEqual(persistence.loadSelectedState(), .fine)
        XCTAssertEqual(persistence.loadSelectedDuration(defaultDuration: .fiveMinutes), .fiveMinutes)
        XCTAssertEqual(persistence.loadActivityHistory(dateKey: "2026-7-2"), ActivityHistory(dateKey: "2026-7-2"))
        XCTAssertEqual(persistence.loadRuntimeState(), .idle)
    }

    func testCurrentPayloadsRoundTrip() {
        let persistence = FocusinPersistence(defaults: defaults)
        let settings = FocusinSettings(workInterval: .custom, customWorkMinutes: 37, notificationsEnabled: false)
        let history = ActivityHistory(dateKey: "2026-7-2", completedActivityIDs: ["done"], skippedActivityIDs: ["skip"], seenActivityIDs: ["seen"])
        let runtime = FocusinRuntimeState.breaking(activityID: "activity", endsAt: Date(timeIntervalSince1970: 42))

        persistence.save(settings: settings)
        persistence.save(selectedState: .anxious)
        persistence.save(selectedDuration: .tenMinutes)
        persistence.save(activityHistory: history)
        persistence.save(runtimeState: runtime)

        XCTAssertEqual(persistence.loadSettings(), settings)
        XCTAssertEqual(persistence.loadSelectedState(), .anxious)
        XCTAssertEqual(persistence.loadSelectedDuration(defaultDuration: .twoMinutes), .tenMinutes)
        XCTAssertEqual(persistence.loadActivityHistory(dateKey: history.dateKey), history)
        XCTAssertEqual(persistence.loadRuntimeState(), runtime)
    }

    func testMissingSettingsFieldsDecodeWithCompatibilityDefaults() throws {
        defaults.set(try XCTUnwrap("""
        {"workInterval":25,"customWorkMinutes":25,"defaultDuration":"thirtySeconds"}
        """.data(using: .utf8)), forKey: "focusin.settings")
        let settings = FocusinPersistence(defaults: defaults).loadSettings()
        XCTAssertTrue(settings.officeSafeOnly)
        XCTAssertTrue(settings.includeMindfulness)
        XCTAssertTrue(settings.notificationsEnabled)
        XCTAssertTrue(settings.startFocusTimerOnLaunch)
    }

    func testCorruptAndUnknownValuesFallBackWithoutAffectingOtherKeys() {
        defaults.set(Data("not-json".utf8), forKey: "focusin.settings")
        defaults.set("future-state", forKey: "focusin.selectedState")
        defaults.set("future-duration", forKey: "focusin.selectedDuration")
        defaults.set(Data("not-json".utf8), forKey: "focusin.activityHistory")
        defaults.set(Data("not-json".utf8), forKey: "focusin.runtimeState")
        let persistence = FocusinPersistence(defaults: defaults)

        XCTAssertEqual(persistence.loadSettings(), FocusinSettings())
        XCTAssertEqual(persistence.loadSelectedState(), .fine)
        XCTAssertEqual(persistence.loadSelectedDuration(defaultDuration: .fiveMinutes), .fiveMinutes)
        XCTAssertEqual(persistence.loadActivityHistory(dateKey: "today"), ActivityHistory(dateKey: "today"))
        XCTAssertEqual(persistence.loadRuntimeState(), .idle)
    }

    func testWrongDateHistoryResetsAllSets() {
        let persistence = FocusinPersistence(defaults: defaults)
        persistence.save(activityHistory: ActivityHistory(dateKey: "yesterday", completedActivityIDs: ["old"]))
        XCTAssertEqual(persistence.loadActivityHistory(dateKey: "today"), ActivityHistory(dateKey: "today"))
    }

    func testLegacyDailyHistoryMigratesOnlyForMatchingDate() throws {
        defaults.set(try JSONSerialization.data(withJSONObject: ["dateKey": "today", "activityIDs": ["a", "b"]]), forKey: "focusin.dailyHistory")
        let persistence = FocusinPersistence(defaults: defaults)
        XCTAssertEqual(persistence.loadActivityHistory(dateKey: "today").completedActivityIDs, ["a", "b"])
        XCTAssertEqual(persistence.loadActivityHistory(dateKey: "tomorrow"), ActivityHistory(dateKey: "tomorrow"))
    }

    func testLegacyReminderStartMigratesUnlessCurrentRuntimeExists() {
        let persistence = FocusinPersistence(defaults: defaults)
        let legacyDate = Date(timeIntervalSince1970: 100)
        persistence.save(reminderStartedAt: legacyDate)
        XCTAssertEqual(persistence.loadRuntimeState(), .focusing(startedAt: legacyDate))

        persistence.save(runtimeState: .breakDue)
        XCTAssertEqual(persistence.loadRuntimeState(), .breakDue)
    }
}
