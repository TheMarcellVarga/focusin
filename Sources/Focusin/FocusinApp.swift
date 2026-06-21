import SwiftUI

@main
struct FocusinApp: App {
    @StateObject private var store = FocusinStore()

    var body: some Scene {
        MenuBarExtra {
            FocusinPopoverView()
                .environmentObject(store)
        } label: {
            Label(store.focusStatusText, systemImage: store.isBreakDue ? "bell.badge" : "sparkle.magnifyingglass")
        }
        .menuBarExtraStyle(.window)

        Settings {
            SettingsView()
                .environmentObject(store)
        }
    }
}
