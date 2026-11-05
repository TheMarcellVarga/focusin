# Design System

## Design Direction

Focusin should feel like a quiet macOS utility: immediate, compact, native, and trustworthy. It should not resemble a dashboard, meditation content platform, or gamified habit tracker.

## Principles

- State before decoration: the current lifecycle and next action dominate.
- One-decision interactions: ask only for state and available time.
- Native familiarity: use standard controls, materials, typography, and Settings structure.
- Calm without vagueness: copy is brief but operational.
- Accessible by construction: semantics, focus order, contrast, and non-color indicators ship with features.

## Layout

### Popover

- Baseline width: 384 points; expand to 480 points at accessibility text sizes so native labels are not compressed away.
- Outer padding: 16 points.
- Major vertical gap: 14 points.
- Panel padding: 12–14 points.
- Corner radii: 12–14 points for cards and 7–8 points for icon tiles.
- Primary content order: identity -> compact runtime status -> input selectors -> activity -> actions. Only the activity/error uses a panel; status and selectors sit directly on the window background.

The popover may grow vertically for accessibility text sizes but should avoid horizontal scrolling and clipped primary actions.

### Settings

- Baseline window: 540 x 500 points.
- Accessibility text window: 840 x 560 points so all tab labels and form rows remain visible.
- Use a native tab view and grouped forms.
- Group settings by reminder, activities, and system. Beta feedback stays in the written beta packet, outside the product UI.
- Reveal custom interval controls only when relevant.
- Disable rather than hide quiet-hour endpoints when suppression is off, preserving discoverability.

## Typography

- App name: `.headline`.
- Activity title: `.title3.weight(.semibold)`.
- Runtime title and primary body: `.callout`.
- Metadata/help: `.caption` or `.caption2` with sufficient contrast.
- Countdowns: rounded or title style with monospaced digits.

Do not hard-code font sizes for body copy when semantic styles can preserve accessibility behavior.

## Color And Material

- Use system window background and semantic primary/secondary foreground styles.
- Use accent color for neutral focus state, orange for break due, and green for active break.
- Always pair status color with an icon and label.
- Popover panels use opaque semantic `controlBackgroundColor` surfaces so unrelated desktop color cannot bleed through in light or dark appearance.
- Reserve translucency for system-owned window chrome; product surfaces do not use gradients or decorative material washes.
- Borders use semantic separators at low opacity.
- Verify increased-contrast and reduce-transparency settings.
- Verify that dark appearance remains tonally uniform when the desktop behind the popover contains bright or saturated content.

## Components

### Status panel

Contains a semantic icon and state title, focus time remaining when focusing, and one break countdown when active. It is the visual source of truth for lifecycle state. Explanatory lifecycle prose and duplicate header status are omitted.

### Segmented selection

State and duration selectors use segmented pickers. Both are disabled during a break, with a short explanation; finish or skip unlocks them. Each segment needs an accessible label and must remain usable through keyboard navigation.

### Activity card

Shows category, title, and instruction. Instructions remain readable without truncation. Office-safe filtering remains in Settings. Progress and end-time duplicates are omitted; the status area owns the countdown.

### Action row

Exactly one visually primary action per runtime state. Settings appears only in the footer; restarting focus appears only in the focusing action row. Secondary actions may reset, shuffle, or skip. Default keyboard action must match the visible primary action.

### State message

Error and empty states use icon, title, and resolution-oriented message. They cannot rely on a tooltip or console output.

## Interaction States

Launch at login is disabled in Debug/local builds and when the platform reports it unavailable, with an explanation. Notification permission and recovery actions live in Reminder Settings.

Required states are idle, focusing, break due, breaking, no eligible activity, invalid catalog, notifications denied, login-item failure, and loading/startup reconciliation. Disabled controls require an understandable reason in nearby context or help text.

## Accessibility Checklist

- Logical VoiceOver reading and keyboard focus order.
- Descriptive labels for icon-only timer, gear, and shuffle controls.
- Settings action buttons expose a named AX button and standard press action.
- No essential information conveyed only by color or animation.
- Full Keyboard Access supports the golden path.
- Text remains legible with increased contrast and larger accessibility sizes.
- Reduce Motion and Reduce Transparency produce stable layouts.
- The countdown exposes a readable accessibility label without a live announcement.
- Target controls meet comfortable macOS hit-area expectations.

## Copy Style

- Use verbs: Start, Take Break, Done, Skip, Reset.
- Avoid moral judgments such as failed, lazy, or missed.
- Avoid clinical promises and diagnosis.
- Explain consequences precisely: quiet hours suppress reminders, not runtime transitions.
- Keep error messages specific and recoverable where possible.

## Visual QA Matrix

- Light and dark appearance.
- Default and non-default accent colors.
- Increased contrast and reduced transparency.
- Small and large text settings.
- Menu bar text on and off.
- Every runtime, empty, permission, and error state.
- 13-inch display and external-display menu bars.
