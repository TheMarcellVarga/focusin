import AppKit
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: FocusinStore
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        TabView(selection: $store.selectedSettingsTab) {
            reminderSettings
                .tabItem {
                    Label("Reminder", systemImage: "bell")
                }
                .tag(FocusinSettingsTab.reminder)

            recommendationSettings
                .tabItem {
                    Label("Activities", systemImage: "figure.walk")
                }
                .tag(FocusinSettingsTab.activities)

            systemSettings
                .tabItem {
                    Label("System", systemImage: "macwindow")
                }
                .tag(FocusinSettingsTab.system)

        }
        .scenePadding()
        .frame(
            width: dynamicTypeSize.isAccessibilitySize ? 840 : 540,
            height: dynamicTypeSize.isAccessibilitySize ? 560 : 500
        )
    }

    private var reminderSettings: some View {
        SettingsForm {
            Section("Timer") {
                Toggle("Start focus timer on launch", isOn: $store.settings.startFocusTimerOnLaunch)
                Toggle("Enable notifications", isOn: $store.settings.notificationsEnabled)

                if let guidance = store.notificationGuidance {
                    Text(guidance)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if store.settings.notificationsEnabled && store.notificationPermissionStatus == .notDetermined {
                        SettingsActionButton(title: "Allow Notifications") {
                            store.requestNotificationPermission()
                        }
                    } else if store.settings.notificationsEnabled && store.notificationPermissionStatus == .denied {
                        SettingsActionButton(title: "Open Notification Settings") {
                            openSystemSettings(.notifications)
                        }
                    }
                }

                Picker("Work interval", selection: $store.settings.workInterval) {
                    ForEach(WorkInterval.allCases) { interval in
                        Text(interval.label).tag(interval)
                    }
                }

                if store.settings.workInterval == .custom {
                    Stepper(value: $store.settings.customWorkMinutes, in: 1...240) {
                        Text("\(store.settings.customWorkMinutes) minutes")
                    }
                }

            }

            Section("Quiet Hours") {
                Toggle("Suppress reminders", isOn: $store.settings.quietHoursEnabled)

                Stepper(value: $store.settings.quietStartHour, in: 0...23) {
                    Text("Start \(store.settings.quietStartHour):00")
                }
                .disabled(!store.settings.quietHoursEnabled)

                Stepper(value: $store.settings.quietEndHour, in: 0...23) {
                    Text("End \(store.settings.quietEndHour):00")
                }
                .disabled(!store.settings.quietHoursEnabled)

                if store.settings.quietHoursEnabled,
                   store.settings.quietStartHour == store.settings.quietEndHour {
                    Text("Start and end match, so reminders are quiet all day. Timers still continue.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var recommendationSettings: some View {
        SettingsForm {
            Section("Recommendations") {
                Toggle("Office-safe activities only", isOn: $store.settings.officeSafeOnly)
                Toggle("Include mindfulness", isOn: $store.settings.includeMindfulness)
            }

        }
    }

    private var systemSettings: some View {
        SettingsForm {
            Section("Menu Bar") {
                Toggle("Show menu bar text", isOn: $store.settings.showMenuBarText)
            }

            Section("Startup") {
                Toggle("Launch at login", isOn: $store.settings.launchAtLogin)
                    .disabled(!store.canConfigureLaunchAtLogin)

                if !store.canConfigureLaunchAtLogin {
                    Text("Unavailable in this build. Open Focusin manually.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else if let guidance = store.launchAtLoginGuidance {
                    Text(guidance)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if store.launchAtLoginStatus == .requiresApproval {
                        SettingsActionButton(title: "Open Login Items Settings") {
                            openSystemSettings(.loginItems)
                        }
                    } else if store.launchAtLoginStatus == .failed {
                        SettingsActionButton(title: "Try Again") {
                            store.retryLaunchAtLogin()
                        }
                    }
                }
            }
        }
    }

}

private enum SystemSettingsDestination {
    case notifications
    case loginItems
}

private func openSystemSettings(_ destination: SystemSettingsDestination) {
    let value: String
    switch destination {
    case .notifications:
        value = "x-apple.systempreferences:com.apple.Notifications-Settings.extension"
    case .loginItems:
        value = "x-apple.systempreferences:com.apple.LoginItems-Settings.extension"
    }
    if let url = URL(string: value) {
        NSWorkspace.shared.open(url)
    }
}

private struct SettingsForm<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        Form {
            content
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
    }
}

private struct SettingsActionButton: NSViewRepresentable {
    let title: String
    let action: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(action: action)
    }

    func makeNSView(context: Context) -> NSButton {
        let button = NSButton(
            title: title,
            target: context.coordinator,
            action: #selector(Coordinator.performAction)
        )
        button.bezelStyle = .rounded
        button.setAccessibilityLabel(title)
        return button
    }

    func updateNSView(_ button: NSButton, context: Context) {
        context.coordinator.action = action
        button.title = title
        button.setAccessibilityLabel(title)
    }

    final class Coordinator: NSObject {
        var action: () -> Void

        init(action: @escaping () -> Void) {
            self.action = action
        }

        @objc func performAction() {
            action()
        }
    }
}
