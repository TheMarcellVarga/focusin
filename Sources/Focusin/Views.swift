import AppKit
import SwiftUI

struct FocusinPopoverView: View {
    @EnvironmentObject private var store: FocusinStore
    @Environment(\.openSettings) private var openSettings
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            header

            statusPanel

            if let guidance = store.notificationGuidance, store.settings.notificationsEnabled {
                notificationNotice(guidance)
            }

            VStack(alignment: .leading, spacing: 12) {
                SegmentedPickerSection(title: "State", selection: $store.selectedState) {
                    ForEach(FocusState.allCases) { state in
                        Text(state.label).tag(state)
                    }
                }

                SegmentedPickerSection(title: "Duration", selection: $store.selectedDuration) {
                    ForEach(BreakDuration.allCases) { duration in
                        Text(duration.label).tag(duration)
                    }
                }
            }
            .padding(12)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))

            activityPanel

            footer
        }
        .padding(16)
        .frame(width: dynamicTypeSize.isAccessibilitySize ? 480 : 384)
        .background(Color(nsColor: .windowBackgroundColor))
    }

    private func notificationNotice(_ message: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(message, systemImage: "bell.slash")
                .font(.caption)

            if store.notificationPermissionStatus == .notDetermined {
                Button("Allow Notifications") {
                    store.requestNotificationPermission()
                }
            } else {
                Button("Open Notification Settings") {
                    openSystemSettings(.notifications)
                }
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.orange.opacity(0.1), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    private var header: some View {
        HStack(spacing: 10) {
            Image(systemName: "figure.mind.and.body")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 30, height: 30)
                .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 7, style: .continuous))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 1) {
                Text("Focusin")
                    .font(.headline)
                Text(store.focusStatusText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }

            Spacer()

            Button {
                store.startFocusTimer()
            } label: {
                Image(systemName: "timer")
            }
            .buttonStyle(.borderless)
            .controlSize(.small)
            .help("Restart focus timer")
            .accessibilityLabel("Restart focus timer")
            .accessibilityHint("Starts a new focus interval from now")

            Button {
                openSettings()
            } label: {
                Image(systemName: "gearshape")
            }
            .buttonStyle(.borderless)
            .controlSize(.small)
            .help("Settings")
            .accessibilityLabel("Open Settings")
        }
        .padding(.bottom, 2)
    }

    private var statusPanel: some View {
        HStack(spacing: 12) {
            Image(systemName: store.menuBarSystemImage)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(statusColor)
                .frame(width: 34, height: 34)
                .background(statusColor.opacity(0.12), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text(store.runtimeStateTitle)
                    .font(.callout.weight(.semibold))
                Text(store.runtimeStateDetail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 10)

            if store.isBreaking {
                Text(store.breakCountdownText)
                    .font(.system(.title3, design: .rounded).weight(.semibold))
                    .foregroundStyle(.primary)
                    .monospacedDigit()
                    .accessibilityHidden(true)
            }
        }
        .padding(12)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(.separator.opacity(0.35))
        }
    }

    @ViewBuilder
    private var activityPanel: some View {
        if let message = store.libraryErrorMessage {
            StateMessage(
                systemImage: "exclamationmark.triangle",
                title: "Activity library unavailable",
                message: message,
                tint: .orange,
                actionTitle: "Try Again",
                action: store.reloadActivities
            )
        } else if let activity = store.currentActivity {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .firstTextBaseline) {
                    Label(activity.category.displayName, systemImage: activity.category.systemImage)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)

                    Spacer()

                    if activity.officeSafe {
                        Label("Office safe", systemImage: "checkmark.circle")
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(.secondary)
                    }
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(activity.title)
                        .font(.title3.weight(.semibold))
                        .fixedSize(horizontal: false, vertical: true)
                    Text(activity.instruction)
                        .font(.callout)
                        .foregroundStyle(.primary)
                        .lineSpacing(2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                if let breakEndsAt = store.breakEndsAt {
                    VStack(alignment: .leading, spacing: 6) {
                        ProgressView(
                            value: Double(store.selectedDuration.seconds - store.remainingBreakSeconds),
                            total: Double(store.selectedDuration.seconds)
                        )
                        .controlSize(.small)
                        .accessibilityLabel("Break progress")
                        .accessibilityValue("In progress")

                        HStack {
                            Text("Ends at \(breakEndsAt, style: .time)")
                            Spacer()
                            Text(store.breakCountdownText)
                                .monospacedDigit()
                                .accessibilityHidden(true)
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(.separator.opacity(0.35))
            }
        } else {
            StateMessage(
                systemImage: "sparkle.magnifyingglass",
                title: "No matching activity",
                message: "Adjust your break preferences to see more options.",
                tint: .secondary,
                actionTitle: "Open Break Preferences"
            ) {
                store.presentBreakPreferences()
                openSettings()
            }
        }
    }

    private var footer: some View {
        VStack(spacing: 12) {
            actionRow

            HStack {
                SettingsLink {
                    Label("Settings", systemImage: "slider.horizontal.3")
                }
                .buttonStyle(.link)

                Spacer()

                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(.link)
                .foregroundStyle(.secondary)
            }
            .font(.caption)
        }
    }

    @ViewBuilder
    private var actionRow: some View {
        HStack(spacing: 8) {
            switch store.runtimeState {
            case .idle:
                Button {
                    store.startFocusTimer()
                } label: {
                    Label("Start Focus", systemImage: "timer")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.defaultAction)

                Button {
                    store.startBreak()
                } label: {
                    Label("Reset Now", systemImage: "play.fill")
                }
                .buttonStyle(.bordered)
                .disabled(!store.canShowRecommendation)

            case .focusing:
                Button {
                    store.startBreak()
                } label: {
                    Label("Take Break", systemImage: "play.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.defaultAction)
                .disabled(!store.canShowRecommendation)

                Button {
                    store.startFocusTimer()
                } label: {
                    Label("Reset", systemImage: "arrow.clockwise")
                }
                .buttonStyle(.bordered)

            case .breakDue:
                Button {
                    store.startBreak()
                } label: {
                    Label("Start", systemImage: "play.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.defaultAction)
                .disabled(!store.canShowRecommendation)

                Button {
                    store.anotherActivity()
                } label: {
                    Label("Another", systemImage: "shuffle")
                }
                .buttonStyle(.bordered)
                .disabled(!store.canShowRecommendation)

            case .breaking:
                Button {
                    store.completeBreak()
                } label: {
                    Label("Done", systemImage: "checkmark")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.defaultAction)
                .disabled(!store.canShowRecommendation)

                Button {
                    store.skipActivity()
                } label: {
                    Label("Skip", systemImage: "forward.end")
                }
                .buttonStyle(.bordered)
                .disabled(!store.canShowRecommendation)
            }

            if !store.isBreaking && !store.isBreakDue {
                Button {
                    store.anotherActivity()
                } label: {
                    Image(systemName: "shuffle")
                }
                .buttonStyle(.bordered)
                .disabled(!store.canShowRecommendation)
                .help("Show another activity")
                .accessibilityLabel("Show another activity")
                .accessibilityHint("Marks this suggestion as seen and shows a different match")
            }
        }
        .controlSize(.large)
    }

    private var statusColor: Color {
        if store.isBreakDue {
            return .orange
        }

        if store.isBreaking {
            return .green
        }

        return .accentColor
    }
}

struct SettingsView: View {
    @EnvironmentObject private var store: FocusinStore
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var feedbackCopied = false

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

            feedbackSettings
                .tabItem {
                    Label("Feedback", systemImage: "text.bubble")
                }
                .tag(FocusinSettingsTab.feedback)
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

                    if store.settings.notificationsEnabled && store.notificationPermissionStatus == .denied {
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

                Picker("Default break", selection: $store.settings.defaultDuration) {
                    ForEach(BreakDuration.allCases) { duration in
                        Text(duration.label).tag(duration)
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

            Section("Defaults") {
                Picker("Current state", selection: $store.selectedState) {
                    ForEach(FocusState.allCases) { state in
                        Text(state.label).tag(state)
                    }
                }

                Picker("Break duration", selection: $store.selectedDuration) {
                    ForEach(BreakDuration.allCases) { duration in
                        Text(duration.label).tag(duration)
                    }
                }
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

                if let guidance = store.launchAtLoginGuidance {
                    Text(guidance)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if store.launchAtLoginStatus == .requiresApproval {
                        SettingsActionButton(title: "Open Login Items Settings") {
                            openSystemSettings(.loginItems)
                        }
                    } else {
                        SettingsActionButton(title: "Try Again") {
                            store.retryLaunchAtLogin()
                        }
                    }
                }
            }
        }
    }

    private var feedbackSettings: some View {
        SettingsForm {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Beta feedback")
                        .font(.headline)
                    Text("Copy a short prompt you can paste into Notes, Mail, or TestFlight feedback.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }

                SettingsActionButton(title: "Copy Feedback Notes") {
                    copyFeedbackNotes()
                }

                if feedbackCopied {
                    Label("Copied to Clipboard", systemImage: "checkmark.circle")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .accessibilityLabel("Feedback notes copied to clipboard")
                }
            }
        }
    }

    private func copyFeedbackNotes() {
        NSPasteboard.general.clearContents()
        feedbackCopied = NSPasteboard.general.setString(BetaFeedbackTemplate.current, forType: .string)
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

private struct SegmentedPickerSection<Selection: Hashable, Content: View>: View {
    let title: String
    @Binding var selection: Selection
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            Picker(title, selection: $selection) {
                content
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .accessibilityLabel(title)
            .controlSize(.regular)
        }
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

private struct StateMessage: View {
    let systemImage: String
    let title: String
    let message: String
    let tint: Color
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(tint)
                    .frame(width: 32, height: 32)
                    .background(tint.opacity(0.12), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.callout.weight(.semibold))
                    Text(message)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .controlSize(.small)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.quaternary.opacity(0.7), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

private extension ActivityCategory {
    var displayName: String {
        switch self {
        case .move:
            return "Movement"
        case .mind:
            return "Mind"
        case .desk:
            return "Desk"
        case .focus:
            return "Focus"
        case .social:
            return "Social"
        }
    }

    var systemImage: String {
        switch self {
        case .move:
            return "figure.walk"
        case .mind:
            return "brain.head.profile"
        case .desk:
            return "desktopcomputer"
        case .focus:
            return "scope"
        case .social:
            return "person.2"
        }
    }
}
