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

- Fixed baseline width: 384 points.
- Outer padding: 16 points.
- Major vertical gap: 14 points.
- Panel padding: 12–14 points.
- Corner radii: 12–14 points for cards and 7–8 points for icon tiles.
- Primary content order: identity -> runtime status -> input selectors -> activity -> actions.

The popover may grow vertically for accessibility text sizes but should avoid horizontal scrolling and clipped primary actions.

### Settings

- Baseline window: 540 x 430 points.
- Use a native tab view and grouped forms.
- Group settings by reminder, activities, system, and feedback.
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
- Use regular/thin materials sparingly to separate functional groups.
- Borders use semantic separators at low opacity.
- Verify increased-contrast and reduce-transparency settings.

## Components

### Status panel

Contains semantic icon, state title, one-line explanation, and break countdown when active. It is the visual source of truth for lifecycle state.

### Segmented selection

State and duration selectors use segmented pickers. Each segment needs an accessible label and must remain usable through keyboard navigation.

### Activity card

Shows category, office-safe metadata, title, instruction, and progress only during an active break. Instructions should remain readable without truncation.

### Action row

Exactly one visually primary action per runtime state. Secondary actions may reset, shuffle, or skip. Default keyboard action must match the visible primary action.

### State message

Error and empty states use icon, title, and resolution-oriented message. They cannot rely on a tooltip or console output.

## Interaction States

Required states are idle, focusing, break due, breaking, no eligible activity, invalid catalog, notifications denied, login-item failure, and loading/startup reconciliation. Disabled controls require an understandable reason in nearby context or help text.

## Accessibility Checklist

- Logical VoiceOver reading and keyboard focus order.
- Descriptive labels for icon-only timer, gear, and shuffle controls.
- No essential information conveyed only by color or animation.
- Full Keyboard Access supports the golden path.
- Text remains legible with increased contrast and larger accessibility sizes.
- Reduce Motion and Reduce Transparency produce stable layouts.
- Timer announcements do not update every second through VoiceOver.
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

