import AppKit
import SwiftUI

struct FocusinPopoverView: View {
    @EnvironmentObject private var store: FocusinStore
    @Environment(\.openSettings) private var openSettings

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header

            Divider()

            statusPanel

            PickerSection(title: "State") {
                ChipGrid(items: FocusState.allCases, selected: $store.selectedState) { state in
                    Text(state.label)
                }
            }

            PickerSection(title: "Time") {
                ChipGrid(items: BreakDuration.allCases, selected: $store.selectedDuration) { duration in
                    Text(duration.label)
                }
            }

            activityPanel

            footer
        }
        .padding(18)
        .frame(width: 360)
    }

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 3) {
                Text("Focusin")
                    .font(.title3.weight(.semibold))
            }

            Spacer()

            Button {
                store.startFocusTimer()
            } label: {
                Image(systemName: "timer")
            }
            .buttonStyle(.borderless)
            .help("Restart focus timer")

            Button {
                openSettings()
            } label: {
                Image(systemName: "gearshape")
            }
            .buttonStyle(.borderless)
            .help("Settings")
        }
    }

    private var statusPanel: some View {
        HStack(spacing: 12) {
            Image(systemName: store.menuBarSystemImage)
                .font(.title2)
                .foregroundStyle(store.isBreakDue ? Color.orange : Color.accentColor)
                .frame(width: 30)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 3) {
                Text(store.runtimeStateTitle)
                    .font(.headline)
                Text(store.runtimeStateDetail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            if store.isBreaking {
                Text(store.breakCountdownText)
                    .font(.system(.title3, design: .monospaced).weight(.semibold))
                    .foregroundStyle(.primary)
            }
        }
        .padding(12)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
    }

    @ViewBuilder
    private var activityPanel: some View {
        if let message = store.libraryErrorMessage {
            Text(message)
                .font(.callout)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
        } else if let activity = store.currentActivity {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(activity.title)
                        .font(.headline)
                    Spacer()
                    Text(activity.category.rawValue.capitalized)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                }

                Text(activity.instruction)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)

                if let breakEndsAt = store.breakEndsAt {
                    ProgressView(value: Double(store.selectedDuration.seconds - store.remainingBreakSeconds), total: Double(store.selectedDuration.seconds))
                    Text("Ends at \(breakEndsAt, style: .time)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
        } else {
            Text("No activity matches these settings yet.")
                .font(.callout)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
        }
    }

    private var footer: some View {
        VStack(spacing: 10) {
            actionRow

            HStack {
                SettingsLink {
                    Label("Settings", systemImage: "slider.horizontal.3")
                }

                Spacer()

                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
            }
            .font(.caption)
        }
    }

    @ViewBuilder
    private var actionRow: some View {
        HStack {
            switch store.runtimeState {
            case .idle:
                Button {
                    store.startFocusTimer()
                } label: {
                    Label("Start Focus", systemImage: "timer")
                }
                .keyboardShortcut(.defaultAction)

                Button {
                    store.startBreak()
                } label: {
                    Label("Reset Now", systemImage: "play.fill")
                }
                .disabled(!store.canShowRecommendation)

            case .focusing:
                Button {
                    store.startBreak()
                } label: {
                    Label("Take Break Now", systemImage: "play.fill")
                }
                .keyboardShortcut(.defaultAction)
                .disabled(!store.canShowRecommendation)

                Button {
                    store.startFocusTimer()
                } label: {
                    Label("Reset Timer", systemImage: "arrow.clockwise")
                }

            case .breakDue:
                Button {
                    store.startBreak()
                } label: {
                    Label("Start", systemImage: "play.fill")
                }
                .keyboardShortcut(.defaultAction)
                .disabled(!store.canShowRecommendation)

                Button {
                    store.anotherActivity()
                } label: {
                    Label("Another", systemImage: "shuffle")
                }
                .disabled(!store.canShowRecommendation)

            case .breaking:
                Button {
                    store.completeBreak()
                } label: {
                    Label("Done", systemImage: "checkmark")
                }
                .keyboardShortcut(.defaultAction)
                .disabled(!store.canShowRecommendation)

                Button {
                    store.skipActivity()
                } label: {
                    Label("Skip", systemImage: "forward.end")
                }
                .disabled(!store.canShowRecommendation)
            }

            Spacer()

            if !store.isBreaking && !store.isBreakDue {
                Button {
                    store.anotherActivity()
                } label: {
                    Label("Another", systemImage: "shuffle")
                }
                .disabled(!store.canShowRecommendation)
            }
        }
    }
}

struct SettingsView: View {
    @EnvironmentObject private var store: FocusinStore

    var body: some View {
        Form {
            Section("Reminder") {
                Toggle("Start focus timer on launch", isOn: $store.settings.startFocusTimerOnLaunch)
                Toggle("Enable notifications", isOn: $store.settings.notificationsEnabled)

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

            Section("Recommendations") {
                Toggle("Office-safe activities only", isOn: $store.settings.officeSafeOnly)
                Toggle("Include mindfulness", isOn: $store.settings.includeMindfulness)
            }

            Section("Quiet Hours") {
                Toggle("Suppress reminders", isOn: $store.settings.quietHoursEnabled)

                Stepper(value: $store.settings.quietStartHour, in: 0...23) {
                    Text("Start \(store.settings.quietStartHour):00")
                }

                Stepper(value: $store.settings.quietEndHour, in: 0...23) {
                    Text("End \(store.settings.quietEndHour):00")
                }
            }

            Section("System") {
                Toggle("Show menu bar text", isOn: $store.settings.showMenuBarText)
                Toggle("Launch at login", isOn: $store.settings.launchAtLogin)
            }
        }
        .formStyle(.grouped)
        .padding(20)
        .frame(width: 460)
    }
}

private struct PickerSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            content
        }
    }
}

private struct ChipGrid<Item: Identifiable & Hashable, Label: View>: View {
    let items: [Item]
    @Binding var selected: Item
    let label: (Item) -> Label

    init(
        items: [Item],
        selected: Binding<Item>,
        @ViewBuilder label: @escaping (Item) -> Label
    ) {
        self.items = items
        _selected = selected
        self.label = label
    }

    var body: some View {
        FlowLayout(spacing: 8) {
            ForEach(items) { item in
                Button {
                    selected = item
                } label: {
                    label(item)
                        .font(.callout.weight(.medium))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .frame(minWidth: 48)
                }
                .buttonStyle(.plain)
                .foregroundStyle(selected == item ? .white : .primary)
                .background(selected == item ? Color.accentColor : Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 8))
                .help("Select \(String(describing: item.id))")
            }
        }
    }
}

private struct FlowLayout: Layout {
    var spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? 320
        var rowWidth: CGFloat = 0
        var rowHeight: CGFloat = 0
        var totalHeight: CGFloat = 0
        var widestRow: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if rowWidth > 0, rowWidth + spacing + size.width > maxWidth {
                totalHeight += rowHeight + spacing
                widestRow = max(widestRow, rowWidth)
                rowWidth = 0
                rowHeight = 0
            }

            rowWidth += rowWidth == 0 ? size.width : size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }

        totalHeight += rowHeight
        widestRow = max(widestRow, rowWidth)

        return CGSize(width: min(maxWidth, widestRow), height: totalHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var origin = bounds.origin
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if origin.x > bounds.minX, origin.x + size.width > bounds.maxX {
                origin.x = bounds.minX
                origin.y += rowHeight + spacing
                rowHeight = 0
            }

            subview.place(at: origin, proposal: ProposedViewSize(size))
            origin.x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}
