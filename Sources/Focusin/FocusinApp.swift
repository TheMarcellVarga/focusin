import SwiftUI

@main
struct FocusinApp: App {
    @StateObject private var store: FocusinStore

    init() {
        #if DEBUG
        if let fixture = FocusinUIFixture.current {
            _store = StateObject(wrappedValue: fixture.makeStore())
            return
        }
        #endif

        _store = StateObject(wrappedValue: FocusinStore())
    }

    var body: some Scene {
        MenuBarExtra {
            FocusinPopoverView()
                .environmentObject(store)
                .focusinUIFixtureEnvironment()
        } label: {
            if store.settings.showMenuBarText {
                Label(store.focusStatusText, systemImage: store.menuBarSystemImage)
            } else {
                Image(systemName: store.menuBarSystemImage)
            }
        }
        .menuBarExtraStyle(.window)

        Settings {
            SettingsView()
                .environmentObject(store)
                .focusinUIFixtureEnvironment()
        }
    }
}

private extension View {
    @ViewBuilder
    func focusinUIFixtureEnvironment() -> some View {
        #if DEBUG
        if ProcessInfo.processInfo.environment["FOCUSIN_UI_LARGE_TEXT"] == "1" {
            environment(\.dynamicTypeSize, .accessibility3)
        } else {
            self
        }
        #else
        self
        #endif
    }
}

#if DEBUG
private enum FocusinUIFixture: String {
    case idle
    case focusing
    case breakDue = "break-due"
    case breaking
    case empty
    case catalogError = "catalog-error"

    static var current: Self? {
        ProcessInfo.processInfo.environment["FOCUSIN_UI_FIXTURE"].flatMap(Self.init(rawValue:))
    }

    @MainActor
    func makeStore() -> FocusinStore {
        let now = Date()
        let runtimeState: FocusinRuntimeState
        let loader: any ActivityLoading

        switch self {
        case .idle, .empty, .catalogError:
            runtimeState = .idle
        case .focusing:
            runtimeState = .focusing(startedAt: now.addingTimeInterval(-60))
        case .breakDue:
            runtimeState = .breakDue
        case .breaking:
            runtimeState = .breaking(
                activityID: "window-breath-30",
                endsAt: now.addingTimeInterval(30)
            )
        }

        switch self {
        case .empty:
            loader = FixtureActivityLoader(result: .success([]))
        case .catalogError:
            loader = FixtureActivityLoader(result: .failure(ActivityLibraryError.missingResource))
        default:
            loader = BundledActivityLoader()
        }

        return FocusinStore(
            persistence: FixturePersistence(runtimeState: runtimeState),
            activityLoader: loader,
            runsTicker: false
        )
    }
}

@MainActor
private final class FixturePersistence: FocusinPersisting {
    private var settings = FocusinSettings(
        notificationsEnabled: false,
        startFocusTimerOnLaunch: false
    )
    private var selectedState = FocusState.fine
    private var selectedDuration = BreakDuration.twoMinutes
    private var activityHistory = ActivityHistory(dateKey: "")
    private var runtimeState: FocusinRuntimeState

    init(runtimeState: FocusinRuntimeState) {
        self.runtimeState = runtimeState
    }

    func loadSettings() -> FocusinSettings { settings }
    func save(settings: FocusinSettings) { self.settings = settings }
    func loadSelectedState() -> FocusState { selectedState }
    func save(selectedState: FocusState) { self.selectedState = selectedState }
    func loadSelectedDuration(defaultDuration: BreakDuration) -> BreakDuration { selectedDuration }
    func save(selectedDuration: BreakDuration) { self.selectedDuration = selectedDuration }
    func loadActivityHistory(dateKey: String) -> ActivityHistory {
        if activityHistory.dateKey != dateKey {
            activityHistory = ActivityHistory(dateKey: dateKey)
        }
        return activityHistory
    }
    func save(activityHistory: ActivityHistory) { self.activityHistory = activityHistory }
    func loadRuntimeState() -> FocusinRuntimeState { runtimeState }
    func save(runtimeState: FocusinRuntimeState) { self.runtimeState = runtimeState }
}

private struct FixtureActivityLoader: ActivityLoading {
    let result: Result<[BreakActivity], Error>

    func load() throws -> [BreakActivity] {
        try result.get()
    }
}
#endif
