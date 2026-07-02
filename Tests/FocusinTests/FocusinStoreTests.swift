import XCTest
@testable import Focusin

@MainActor
final class FocusinStoreTests: XCTestCase {
    func testIdleCanStartFocusAndImmediateBreak() {
        let clock = TestClock(now: Date(timeIntervalSince1970: 1_000))
        let persistence = TestPersistence(settings: FocusinSettings(startFocusTimerOnLaunch: false), runtimeState: .idle)
        let notifications = TestNotifications()
        let store = makeStore(persistence: persistence, notifications: notifications, clock: clock)

        store.startFocusTimer()
        XCTAssertEqual(store.focusStartedAt, clock.now)
        XCTAssertEqual(notifications.scheduledDelays.last, 1_500)

        store.startBreak()
        XCTAssertTrue(store.isBreaking)
        XCTAssertEqual(store.breakEndsAt, clock.now.addingTimeInterval(120))
    }

    func testRestartingFocusUsesFreshStartAndReplacesReminder() {
        let clock = TestClock(now: Date(timeIntervalSince1970: 2_000))
        let persistence = TestPersistence(settings: FocusinSettings(startFocusTimerOnLaunch: false), runtimeState: .focusing(startedAt: clock.now.addingTimeInterval(-100)))
        let notifications = TestNotifications()
        let store = makeStore(persistence: persistence, notifications: notifications, clock: clock)
        let clearsBeforeRestart = notifications.clearCount

        store.startFocusTimer()
        XCTAssertEqual(store.focusStartedAt, clock.now)
        XCTAssertEqual(notifications.scheduledDelays.last, 1_500)
        XCTAssertGreaterThan(notifications.clearCount, clearsBeforeRestart)
    }

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

    func testBreakDueStartsBreakAndRepeatedReminderOpenIsIdempotent() {
        let clock = TestClock(now: Date(timeIntervalSince1970: 21_000))
        let persistence = TestPersistence(settings: FocusinSettings(startFocusTimerOnLaunch: false), runtimeState: .breakDue)
        let notifications = TestNotifications()
        let store = makeStore(persistence: persistence, notifications: notifications, clock: clock)

        notifications.onReminderOpened?()
        notifications.onReminderOpened?()
        XCTAssertTrue(store.isBreakDue)
        store.startBreak()
        XCTAssertTrue(store.isBreaking)
    }

    func testDoneAndSkipRecordActiveIdentityAndStartFocus() {
        let now = Date(timeIntervalSince1970: 22_000)
        let donePersistence = TestPersistence(settings: FocusinSettings(startFocusTimerOnLaunch: false), runtimeState: .breaking(activityID: "available", endsAt: now.addingTimeInterval(60)))
        let doneStore = makeStore(persistence: donePersistence, clock: TestClock(now: now))
        doneStore.completeBreak()
        XCTAssertEqual(doneStore.activityHistory.completedActivityIDs, ["available"])
        XCTAssertTrue(doneStore.isFocusing)

        let skipPersistence = TestPersistence(settings: FocusinSettings(startFocusTimerOnLaunch: false), runtimeState: .breaking(activityID: "available", endsAt: now.addingTimeInterval(60)))
        let skipStore = makeStore(persistence: skipPersistence, clock: TestClock(now: now))
        skipStore.skipActivity()
        XCTAssertEqual(skipStore.activityHistory.skippedActivityIDs, ["available"])
        XCTAssertTrue(skipStore.isFocusing)
    }

    func testNaturalBreakExpiryAtDeadlineRecordsCompletion() {
        let now = Date(timeIntervalSince1970: 23_000)
        let clock = TestClock(now: now)
        let persistence = TestPersistence(settings: FocusinSettings(startFocusTimerOnLaunch: false), runtimeState: .breaking(activityID: "available", endsAt: now.addingTimeInterval(1)))
        let store = makeStore(persistence: persistence, clock: clock)
        clock.now = now.addingTimeInterval(1)
        store.reconcileRuntimeState()
        XCTAssertEqual(store.activityHistory.completedActivityIDs, ["available"])
        XCTAssertTrue(store.isFocusing)
    }

    func testAnotherDuringBreakPreservesActiveIdentityAndDeadline() {
        let now = Date(timeIntervalSince1970: 24_000)
        let clock = TestClock(now: now)
        let persistence = TestPersistence(settings: FocusinSettings(startFocusTimerOnLaunch: false), runtimeState: .breaking(activityID: "available", endsAt: now.addingTimeInterval(60)))
        let store = makeStore(persistence: persistence, clock: clock, activities: TestActivityLoader.twoActivities)
        let deadline = store.breakEndsAt
        store.anotherActivity()
        XCTAssertEqual(store.breakEndsAt, deadline)
        store.completeBreak()
        XCTAssertEqual(store.activityHistory.completedActivityIDs, ["available"])
    }

    func testSelectionAndFilterEditsDoNotChangeRuntimeState() {
        let now = Date(timeIntervalSince1970: 25_000)
        let clock = TestClock(now: now)
        let persistence = TestPersistence(settings: FocusinSettings(startFocusTimerOnLaunch: false), runtimeState: .focusing(startedAt: now))
        let store = makeStore(persistence: persistence, clock: clock)
        let original = store.runtimeState
        store.selectedState = .tired
        store.selectedDuration = .fiveMinutes
        store.settings.officeSafeOnly = false
        XCTAssertEqual(store.runtimeState, original)
    }

    func testCalendarDayRolloverClearsHistoryWithoutChangingState() {
        let clock = TestClock(now: Self.utcDate(year: 2026, month: 7, day: 2, hour: 23))
        let persistence = TestPersistence(
            settings: FocusinSettings(startFocusTimerOnLaunch: false),
            runtimeState: .breakDue,
            activityHistory: ActivityHistory(dateKey: "2026-7-2", completedActivityIDs: ["available"])
        )
        let store = makeStore(persistence: persistence, clock: clock)
        clock.now = Self.utcDate(year: 2026, month: 7, day: 3, hour: 0)
        store.reconcileRuntimeState()
        XCTAssertEqual(store.activityHistory, ActivityHistory(dateKey: "2026-7-3"))
        XCTAssertTrue(store.isBreakDue)
    }

    func testAutoStartDefaultOnlyAppliesToRestoredIdle() {
        let now = Date(timeIntervalSince1970: 30_000)
        let clock = TestClock(now: now)
        let persistence = TestPersistence(settings: FocusinSettings(), runtimeState: .idle)
        let store = makeStore(persistence: persistence, clock: clock)

        XCTAssertEqual(store.focusStartedAt, now)
    }

    func testRestoresUnexpiredFocusWithRemainingReminderAndBreakDueWithoutAutostart() {
        let now = Date(timeIntervalSince1970: 31_000)
        let clock = TestClock(now: now)
        let notifications = TestNotifications()
        let focusing = TestPersistence(settings: FocusinSettings(startFocusTimerOnLaunch: true), runtimeState: .focusing(startedAt: now.addingTimeInterval(-300)))
        let focusStore = makeStore(persistence: focusing, notifications: notifications, clock: clock)
        XCTAssertEqual(focusStore.focusStartedAt, now.addingTimeInterval(-300))
        XCTAssertEqual(notifications.scheduledDelays.last, 1_200)

        let due = TestPersistence(settings: FocusinSettings(startFocusTimerOnLaunch: true), runtimeState: .breakDue)
        let dueStore = makeStore(persistence: due, clock: clock)
        XCTAssertTrue(dueStore.isBreakDue)
    }

    func testRestoresUnexpiredBreakAndExpiredBreakCompletes() {
        let now = Date(timeIntervalSince1970: 32_000)
        let active = TestPersistence(settings: FocusinSettings(startFocusTimerOnLaunch: false), runtimeState: .breaking(activityID: "available", endsAt: now.addingTimeInterval(61)))
        let activeStore = makeStore(persistence: active, clock: TestClock(now: now))
        XCTAssertEqual(activeStore.remainingBreakSeconds, 61)
        XCTAssertEqual(activeStore.currentActivity?.id, "available")

        let expired = TestPersistence(settings: FocusinSettings(startFocusTimerOnLaunch: false), runtimeState: .breaking(activityID: "available", endsAt: now))
        let expiredStore = makeStore(persistence: expired, clock: TestClock(now: now))
        XCTAssertTrue(expiredStore.isFocusing)
        XCTAssertEqual(expiredStore.activityHistory.completedActivityIDs, ["available"])
    }

    func testQuietHoursSameDayOvernightEqualDisabledAndBoundaries() {
        assertScheduling(hour: 9, enabled: true, start: 9, end: 17, expected: false)
        assertScheduling(hour: 16, enabled: true, start: 9, end: 17, expected: false)
        assertScheduling(hour: 17, enabled: true, start: 9, end: 17, expected: true)
        assertScheduling(hour: 22, enabled: true, start: 18, end: 8, expected: false)
        assertScheduling(hour: 7, enabled: true, start: 18, end: 8, expected: false)
        assertScheduling(hour: 8, enabled: true, start: 18, end: 8, expected: true)
        assertScheduling(hour: 12, enabled: true, start: 8, end: 8, expected: false)
        assertScheduling(hour: 12, enabled: false, start: 8, end: 8, expected: true)
    }

    func testQuietHoursUseInjectedTimezoneAcrossDSTDates() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "America/Los_Angeles")!
        for date in [
            Self.localDate(year: 2026, month: 3, day: 8, hour: 7, calendar: calendar),
            Self.localDate(year: 2026, month: 11, day: 1, hour: 7, calendar: calendar)
        ] {
            let clock = TestClock(now: date, calendar: calendar)
            let settings = FocusinSettings(quietHoursEnabled: true, quietStartHour: 18, quietEndHour: 8, startFocusTimerOnLaunch: false)
            let notifications = TestNotifications()
            _ = makeStore(persistence: TestPersistence(settings: settings, runtimeState: .focusing(startedAt: date)), notifications: notifications, clock: clock)
            XCTAssertTrue(notifications.scheduledDelays.isEmpty)
        }
    }

    func testSettingsChangesReconcileReminderAndExpiredIntervalBecomesDue() {
        let now = Date(timeIntervalSince1970: 40_000)
        let clock = TestClock(now: now)
        let notifications = TestNotifications()
        let persistence = TestPersistence(settings: FocusinSettings(workInterval: .fortyFive, startFocusTimerOnLaunch: false), runtimeState: .focusing(startedAt: now.addingTimeInterval(-1_800)))
        let store = makeStore(persistence: persistence, notifications: notifications, clock: clock)
        store.settings.workInterval = .twentyFive
        XCTAssertTrue(store.isBreakDue)
        XCTAssertGreaterThanOrEqual(notifications.clearCount, 1)
    }

    private func makeStore(
        persistence: TestPersistence,
        notifications: TestNotifications? = nil,
        clock: TestClock,
        activities: [BreakActivity] = TestActivityLoader.oneActivity
    ) -> FocusinStore {
        FocusinStore(
            persistence: persistence,
            notifications: notifications ?? TestNotifications(),
            launchAtLogin: TestLaunchAtLogin(),
            activityLoader: TestActivityLoader(activities: activities),
            clock: clock,
            runsTicker: false
        )
    }

    private func assertScheduling(hour: Int, enabled: Bool, start: Int, end: Int, expected: Bool) {
        let now = Self.utcDate(year: 2026, month: 7, day: 2, hour: hour)
        let settings = FocusinSettings(quietHoursEnabled: enabled, quietStartHour: start, quietEndHour: end, startFocusTimerOnLaunch: false)
        let notifications = TestNotifications()
        _ = makeStore(persistence: TestPersistence(settings: settings, runtimeState: .focusing(startedAt: now)), notifications: notifications, clock: TestClock(now: now))
        XCTAssertEqual(!notifications.scheduledDelays.isEmpty, expected, "hour=\(hour), range=\(start)-\(end)")
    }

    private static func utcDate(year: Int, month: Int, day: Int, hour: Int) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return localDate(year: year, month: month, day: day, hour: hour, calendar: calendar)
    }

    private static func localDate(year: Int, month: Int, day: Int, hour: Int, calendar: Calendar) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour))!
    }
}

private final class TestClock: FocusinClock {
    var now: Date
    var calendar: Calendar

    init(now: Date, calendar: Calendar? = nil) {
        self.now = now
        var resolved = calendar ?? Calendar(identifier: .gregorian)
        if calendar == nil { resolved.timeZone = TimeZone(secondsFromGMT: 0)! }
        self.calendar = resolved
    }
}

@MainActor
private final class TestPersistence: FocusinPersisting {
    var settings: FocusinSettings
    var selectedState: FocusState = .fine
    var selectedDuration: BreakDuration = .twoMinutes
    var activityHistory: ActivityHistory
    var runtimeState: FocusinRuntimeState

    init(settings: FocusinSettings, runtimeState: FocusinRuntimeState, activityHistory: ActivityHistory = ActivityHistory(dateKey: "1970-1-1")) {
        self.settings = settings
        self.runtimeState = runtimeState
        self.activityHistory = activityHistory
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
    let activities: [BreakActivity]

    static let oneActivity = [makeActivity(id: "available")]
    static let twoActivities = [makeActivity(id: "available"), makeActivity(id: "alternate")]

    func load() throws -> [BreakActivity] {
        activities
    }

    private static func makeActivity(id: String) -> BreakActivity {
        BreakActivity(id: id, title: id, instruction: "Pause briefly.", category: .focus, states: FocusState.allCases, durations: BreakDuration.allCases, officeSafe: true, mindfulness: false, intensity: .low)
    }
}
