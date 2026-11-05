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

            VStack(alignment: .leading, spacing: 12) {
                SegmentedPickerSection(title: "How do you feel?", selection: $store.selectedState) {
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
            .disabled(store.isBreaking)
            .help(store.isBreaking ? "Finish or skip this break to change your next suggestion." : "Choose your next break")

            if store.isBreaking {
                Text("Finish or skip to choose your next break.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            activityPanel

            footer
        }
        .padding(16)
        .frame(width: dynamicTypeSize.isAccessibilitySize ? 480 : 384)
        .background(Color(nsColor: .windowBackgroundColor))
    }

    private var header: some View {
        HStack(spacing: 10) {
            Image(systemName: "figure.mind.and.body")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 30, height: 30)
                .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 7, style: .continuous))
                .accessibilityHidden(true)

            Text("Focusin")
                .font(.headline)

            Spacer()
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
                if store.isFocusing {
                    Text(store.focusStatusText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }
            }

            Spacer(minLength: 10)

            if store.isBreaking {
                Text(store.breakCountdownText)
                    .font(.system(.title3, design: .rounded).weight(.semibold))
                    .foregroundStyle(.primary)
                    .monospacedDigit()
                    .accessibilityLabel("Time remaining: \(store.breakCountdownText)")
            }
        }
        .padding(.vertical, 4)
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
                Label(activity.category.displayName, systemImage: activity.category.systemImage)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)

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

            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .focusinPanel(cornerRadius: 14)
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
                    Label("Take Break", systemImage: "play.fill")
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
                    Label("Start Break", systemImage: "play.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.defaultAction)
                .disabled(!store.canShowRecommendation)

                if store.canShowRecommendation {
                    Button {
                        store.anotherActivity()
                    } label: {
                        Label("Another", systemImage: "shuffle")
                    }
                    .buttonStyle(.bordered)
                } else {
                    Button("Start Focus") {
                        store.startFocusTimer()
                    }
                    .buttonStyle(.bordered)
                }

            case .breaking:
                Button {
                    store.completeBreak()
                } label: {
                    Label("Finish Break", systemImage: "checkmark")
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
        .focusinPanel(cornerRadius: 14)
    }
}

private extension View {
    func focusinPanel(cornerRadius: CGFloat) -> some View {
        background(
            Color(nsColor: .controlBackgroundColor),
            in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .strokeBorder(.separator.opacity(0.32), lineWidth: 0.5)
        }
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
