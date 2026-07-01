# Focusin Workspace Implementation Specification

## Summary

Focusin is a local-first SwiftUI menu bar app for short, context-aware breaks. It minimizes interruption cost by asking for only two inputs—current state and available duration—then keeps the user inside a focus/break cycle.

The repository already contains a functional vertical slice. The remaining program is hardening, accessibility, lifecycle validation, catalog quality, beta evidence, and App Store preparation rather than a platform rewrite.

## Product Surfaces

### Menu bar label

Displays an icon and optional status text for idle, focusing, break due, and breaking states. It must remain legible in light/dark mode and when menu bar space is constrained.

### Popover

Contains status, state and duration selectors, recommended activity, contextual actions, Settings access, and Quit. The primary action changes with the runtime state.

### Settings

Four tabs control reminder intervals, quiet hours, recommendation filters, defaults, menu bar presentation, startup behavior, and beta-feedback copy.

### System notification

A single replaceable break-due notification is scheduled for the end of a focus interval. Opening it activates the app and marks the break due.

## Runtime Model

The state machine has four states:

1. `idle`: ready to focus or take an immediate reset.
2. `focusing(startedAt)`: countdown is derived from the persisted start date.
3. `breakDue`: focus interval ended and the user should choose a reset.
4. `breaking(activityID, endsAt)`: countdown is derived from a persisted end date.

Transitions must be idempotent, recover correctly after relaunch, and never depend on a continuously running in-memory timer for truth.

## Recommendation Model

Recommendations use a bundled catalog. Hard filters enforce office-safety and mindfulness preferences. Ordered soft passes progressively relax exact state, duration, and same-day novelty constraints. The final pass may repeat an eligible item so the user is never stranded when the filtered catalog is non-empty.

## Data Model

- `FocusinSettings`: interval, duration, quiet hours, filters, notification, menu bar, and startup preferences.
- `FocusinRuntimeState`: current focus/break lifecycle.
- `ActivityHistory`: same-day completed, skipped, and seen IDs.
- `BreakActivity`: immutable bundled activity definition.
- `FocusState`, `BreakDuration`, `ActivityCategory`, and `ActivityIntensity`: controlled vocabularies.

Persistence uses codable values and primitive raw values in `UserDefaults`. Bundled activity data is read-only JSON. No user data leaves the device.

## Architecture

- `FocusinApp` owns scenes and injects one `FocusinStore`.
- `FocusinStore` is the main-actor orchestration boundary.
- `RecommendationEngine` is stateless domain logic.
- `FocusinPersistence` owns compatibility-aware local storage.
- `NotificationScheduler` owns `UNUserNotificationCenter` interaction.
- `LaunchAtLoginController` wraps `SMAppService`.
- Views render store state and dispatch user intent.

## Reliability Requirements

- Restoring an expired focus interval produces `breakDue`.
- Restoring an expired break records completion according to the current policy and starts focus.
- Quiet hours suppress scheduling without corrupting runtime state.
- Denied notifications do not prevent in-app state transitions.
- Changing an interval while focusing reschedules against the original start time.
- Corrupt persisted data falls back to safe defaults.
- Missing or invalid activity data produces a visible, non-crashing state.

## Privacy And Safety

- No network capability in version 1.
- No account, contact, calendar, health, or screen-content access.
- No behavioral analytics or crash SDK.
- Activities must use low-risk, non-clinical language and offer user choice.
- Privacy manifest and entitlements must match actual behavior.

## Delivery Phases

### Phase 0 — control plane

Establish documentation, gap audit, status vocabulary, and release gates.

### Phase 1 — behavior lock

Lock golden path, state transitions, catalog contract, copy, and product non-goals.

### Phase 2 — domain hardening

Expand deterministic tests around recommendation fallbacks, persistence migration, quiet hours, and runtime restoration.

### Phase 3 — experience polish

Complete keyboard navigation, VoiceOver labels, reduced-motion behavior, responsive menu bar text, and all error/permission states.

### Phase 4 — platform hardening

Validate notification denial/revocation, login item status, sleep/wake, clock change, timezone change, and multi-day rollover.

### Phase 5 — catalog quality

Audit all activities for coverage, clarity, inclusivity, physical safety, and duration realism. Add catalog-level tests.

### Phase 6 — beta readiness

Complete signing, icons, App Store metadata, privacy responses, beta feedback workflow, and TestFlight QA.

### Phase 7 — release evidence

Capture screenshots, demo script, test evidence, limitations, architecture notes, and portfolio case study.

### Phase 8 — completion audit

Resolve placeholders, stale claims, temporary assets, warnings, and P0/P1 gaps. Defer remaining candidates explicitly.

## Whole-Product Definition Of Done

- Golden path works from a clean install and after relaunch.
- All supported preferences persist and normalize safely.
- Automated domain tests and manual platform checks pass.
- Accessibility and permission states have verified outcomes.
- Distribution artifacts, metadata, privacy declarations, and signing are complete.
- Documentation labels shipped and planned behavior accurately.
- No placeholder release asset or undocumented critical gap remains.

## Assumptions

- macOS 14 remains the deployment target for version 1.
- App Store/TestFlight is the primary distribution path.
- SwiftPM remains useful for tests while Xcode is authoritative for archive/signing.
- Monetization, cloud sync, mobile companions, and team features remain out of scope until post-release validation.

