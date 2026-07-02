# Phase 3 Evidence

## Current Status

Phase 3 remains in progress. Phase 3.5 is implemented and automated gates pass, but the phase exit requires manual keyboard, VoiceOver, and display-accommodation evidence that cannot be recorded while assistive-device access is disabled for the test runner.

## Implemented And Verified

- Icon-only timer, Settings, and shuffle controls have explicit accessibility labels; timer and progress countdown duplicates are hidden from accessibility to avoid per-second announcement noise.
- Runtime state uses icon and text in addition to color.
- Equal quiet-hour endpoints explain that reminders are suppressed all day while timers continue.
- Notification status distinguishes not determined, denied/revoked, and authorized/provisional/ephemeral states.
- Permission prompts occur only from the explicit `Allow Notifications` action; denied status links to Notification Settings.
- Notification status refreshes when the application becomes active and does not block local timer transitions.
- Launch-at-login state reconciles to `SMAppService` status; approval, unavailable, and registration failure states expose recovery UI.
- Deterministic store tests cover denied permission, explicit authorization, scheduling after authorization, launch-at-login approval, and registration failure.
- `./scripts/test-local.sh` and `./scripts/build-local.sh` passed without warnings on 2026-07-02.

## Manual Evidence Still Required

- Capture idle, focusing, break due, breaking, empty, and catalog-error states in light and dark appearances.
- Complete the golden path using Full Keyboard Access, including selectors, primary/secondary actions, Settings, and Quit.
- Verify VoiceOver reading order and labels without noisy countdown announcements.
- Verify increased contrast, reduced transparency, accessibility text sizes, alternate accent colors, constrained menu bar space, and multiple displays.

## Environment Blocker

The locally signed build launched successfully, but macOS returned `Access for assistive devices is disabled (-1719)` when UI automation attempted to inspect the Focusin menu bar item. Grant Accessibility access to the test runner/Codex host, then execute and record the manual matrix above before marking Phase 3 complete or starting Phase 4.
