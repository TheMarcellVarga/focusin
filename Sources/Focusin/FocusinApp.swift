import SwiftUI

@main
struct FocusinApp: App {
    @StateObject private var store = FocusinStore()

    var body: some Scene {
        MenuBarExtra {
            FocusinPopoverView()
                .environmentObject(store)
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
        }
    }
}
