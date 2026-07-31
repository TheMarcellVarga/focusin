# Phase 3 Evidence

## Current Status

Phase 3 is complete. The golden path is keyboard-operable, critical state and actions are exposed through macOS accessibility APIs, countdown duplication is suppressed, and the full popover presentation matrix has been inspected in light and dark appearances.

## Environment Under Test

- Date: 2026-07-02
- macOS 26.5.1 (25F80), Apple silicon
- Built-in Liquid Retina XDR display, 3024 x 1964 Retina
- Focusin 0.1.0 (1), arm64, locally ad hoc signed
- Bundle identifier: `com.marcellvarga.focusin`
- Source baseline: `73aa502` plus the Phase 3 fixture/evidence changes in this worktree
- Assistive access: granted to the Codex test host

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

## Manual Matrix Results

### 3.1 Popover state matrix

Idle, focusing, break due, breaking, no matching activity, and catalog error were launched from isolated debug fixtures and inspected in light and dark appearances. Each presentation remained within the 384-point popover, retained readable hierarchy, used text and symbols in addition to color, and exposed the correct enabled/disabled actions.

Window-only captures are stored in [`docs/evidence/phase-3`](evidence/phase-3). The files are named `{light|dark}-{idle|focusing|break-due|breaking|empty|catalog-error}.png`.

### 3.2 Keyboard operation

- Full Keyboard Access traversed state, duration, primary/secondary actions, Settings, and Quit.
- Return invoked the default primary action and moved idle to focusing.
- Settings opened from its keyboard-focused link.
- Quit terminated Focusin from keyboard focus.
- The menu bar item exposes keyboard focus and the standard press action; no pointer-only application action remains.

The host's original `AppleKeyboardUIMode` value was restored after the check.

### 3.3 VoiceOver semantics

- VoiceOver launched successfully against the running build.
- Accessibility inspection exposed labels for Restart focus timer, Open Settings, every state-specific action, Show another activity, Settings, and Quit.
- Restart and shuffle expose concise action hints.
- State and duration are exposed as named radio groups and radio buttons with selected values.
- Runtime title/detail, activity title/instruction, office-safe status, empty state, and catalog error are exposed as text.
- Decorative status/category images and changing countdown duplicates are hidden; the break-progress label and its stable “In progress” value remain exposed without a per-second numeric update.
- Settings recovery and feedback actions use native AppKit buttons because grouped SwiftUI forms exposed unnamed AX button nodes on the current macOS toolchain; manual hierarchy inspection confirms explicit titles and press actions.

### 3.4 Display accommodations

- Increased Contrast and Reduce Transparency produced opaque, high-contrast panels with visible control outlines and no lost content.
- Accessibility text-size injection kept all critical content and controls within the popover without clipping.
- A purple system accent preserved selection and action contrast; break-due and breaking states remained distinguishable by icon and text.
- Icon-only menu bar presentation remained usable under constrained menu bar space.
- The test host had one physical display. Focusin uses native `MenuBarExtra` placement and contains no custom screen-coordinate or multi-display positioning code; the popover remained within the active display's visible frame.

Additional window-only captures are `accessibility-text.png`, `increased-contrast-reduced-transparency.png`, and `alternate-accent.png` in the evidence directory. Temporary appearance, contrast, transparency, accent, and keyboard-access settings were restored after verification.

### 3.5 Permission status UI

Notification denial/revocation and launch-at-login failure/approval recovery remain implemented and deterministically covered by store tests. Neither condition blocks local timers or break actions.

## Exit Decision

Phase 3 exit criteria are met: the golden path is usable without pointer input, critical state is conveyed non-visually and without color dependence, failure presentations remain actionable, and deterministic fixtures make the matrix repeatable. Phase 4 is now the next roadmap phase.
