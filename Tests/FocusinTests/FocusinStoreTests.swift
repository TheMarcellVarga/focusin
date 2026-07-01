import XCTest
@testable import Focusin

@MainActor
final class FocusinStoreTests: XCTestCase {
    func testFocusTransitionsAtExactDeadlineWithoutWaiting() {
        let now = Date(timeIntervalSince1970: 10_000)
        let clock = TestClock(now: now)
        let persistence = TestPersistence(
            settings: FocusinSettings(workInterval: .twentyFive, startFocusTimerOnLaunch: false),
            runtimeState: .focusing(startedAt: now.addingTimeInterval(-1_499))
        )
        let notifications = TestNotifications()
        let store = makeStore(persistence: persistence, notifications: notifications, clock: clock)

        XCTAssertTrue(store.isFocusing)

        clock.now = now.addingTimeInterval(1)
        store.reconcileRuntimeState()

        XCTAssertTrue(store.isBreakDue)
        XCTAssertEqual(persistence.runtimeState, .breakDue)
        XCTAssertGreaterThanOrEqual(notifications.clearCount, 1)
    }

    func testRemovedActiveActivityRecoversToBreakDueWithoutIdentitySubstitution() {
        let now = Date(timeIntervalSince1970: 20_000)
        let clock = TestClock(now: now)
        let persistence = TestPersistence(
            settings: FocusinSettings(startFocusTimerOnLaunch: false),
            runtimeState: .breaking(activityID: "retired-id", endsAt: now.addingTimeInterval(120))
        )
        let store = makeStore(persistence: persistence, clock: clock)

        XCTAssertTrue(store.isBreakDue)
        XCTAssertEqual(store.currentActivity?.id, "available")
        XCTAssertEqual(store.remainingBreakSeconds, 0)
        XCTAssertTrue(store.activityHistory.completedActivityIDs.isEmpty)
        XCTAssertTrue(store.activityHistory.skippedActivityIDs.isEmpty)
    }

    func testAutoStartDefaultOnlyAppliesToRestoredIdle() {
        let now = Date(timeIntervalSince1970: 30_000)
        let clock = TestClock(now: now)
        let persistence = TestPersistence(settings: FocusinSettings(), runtimeState: .idle)
        let store = makeStore(persistence: persistence, clock: clock)

        XCTAssertEqual(store.focusStartedAt, now)
    }

    private func makeStore(
        persistence: TestPersistence,
        notifications: TestNotifications? = nil,
        clock: TestClock
    ) -> FocusinStore {
        FocusinStore(
            persistence: persistence,
            notifications: notifications ?? TestNotifications(),
            launchAtLogin: TestLaunchAtLogin(),
            activityLoader: TestActivityLoader(),
            clock: clock,
            runsTicker: false
        )
    }
}

private final class TestClock: FocusinClock {
    var now: Date
    var calendar: Calendar

    init(now: Date) {
        self.now = now
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        self.calendar = calendar
    }
}

@MainActor
private final class TestPersistence: FocusinPersisting {
    var settings: FocusinSettings
    var selectedState: FocusState = .fine
    var selectedDuration: BreakDuration = .twoMinutes
    var activityHistory: ActivityHistory
    var runtimeState: FocusinRuntimeState

    init(settings: FocusinSettings, runtimeState: FocusinRuntimeState) {
        self.settings = settings
        self.runtimeState = runtimeState
        activityHistory = ActivityHistory(dateKey: "1970-1-1")
    }

    func loadSettings() -> FocusinSettings { settings }
    func save(settings: FocusinSettings) { self.settings = settings }
    func loadSelectedState() -> FocusState { selectedState }
    func save(selectedState: FocusState) { self.selectedState = selectedState }
    func loadSelectedDuration(defaultDuration: BreakDuration) -> BreakDuration { selectedDuration }
    func save(selectedDuration: BreakDuration) { self.selectedDuration = selectedDuration }
    func loadActivityHistory(dateKey: String) -> ActivityHistory {
        activityHistory.dateKey = dateKey
        return activityHistory
    }
    func save(activityHistory: ActivityHistory) { self.activityHistory = activityHistory }
    func loadRuntimeState() -> FocusinRuntimeState { runtimeState }
    func save(runtimeState: FocusinRuntimeState) { self.runtimeState = runtimeState }
}

@MainActor
private final class TestNotifications: NotificationScheduling {
    var onReminderOpened: (() -> Void)?
    var authorizationRequestCount = 0
    var scheduledDelays: [TimeInterval] = []
    var clearCount = 0

    func requestAuthorization() { authorizationRequestCount += 1 }
    func scheduleBreakReminder(after seconds: TimeInterval) { scheduledDelays.append(seconds) }
    func clearBreakReminder() { clearCount += 1 }
}

@MainActor
private struct TestLaunchAtLogin: LaunchAtLoginControlling {
    func setEnabled(_ enabled: Bool) {}
}

private struct TestActivityLoader: ActivityLoading {
    func load() throws -> [BreakActivity] {
        [
            BreakActivity(
                id: "available",
                title: "Available",
                instruction: "Pause briefly.",
                category: .focus,
                states: FocusState.allCases,
                durations: BreakDuration.allCases,
                officeSafe: true,
                mindfulness: false,
                intensity: .low
            )
        ]
    }
}
