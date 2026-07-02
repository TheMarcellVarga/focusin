# Platform Integrations

## Scope

Focusin integrates with macOS Notification Center, ServiceManagement login items, application activation, the clipboard, menu bar scenes, and the App Sandbox. Each integration must degrade safely and match App Store declarations.

## Notifications

### Current behavior

- Reads authorization status when notifications are enabled and requests alert/sound permission only from the explicit `Allow Notifications` action.
- Distinguishes not-determined, denied/revoked, and usable authorization (authorized/provisional/ephemeral) for in-app guidance.
- Refreshes status on app activation and links denied users to Notification Settings.
- Schedules one non-repeating notification under `focusin.break-due`.
- Replaces prior pending requests before scheduling.
- Clears pending and delivered reminders when no longer relevant.
- Shows banner and sound while the app is active.
- Activates the application and marks break due when opened.

### Required signed-build verification

- Verify revocation while a reminder is pending.
- Confirm that in-app elapsed-time handling works with notifications off.

## Quiet Hours

Quiet hours suppress notification scheduling, not the focus state transition. Equal start/end currently means quiet all day. A range with start before end is same-day; start after end crosses midnight.

Equal endpoints are an intentional all-day-reminder-suppression policy. The target Settings explanation is: “Start and end match, so reminders are quiet all day. Timers still continue.” Exact permission and recovery copy is specified in [`BEHAVIORAL_CONTRACT.md`](BEHAVIORAL_CONTRACT.md).

Required edge tests include 18:00–08:00, 08:00–18:00, equal endpoints, timezone changes, daylight-saving changes, and enabling quiet hours during an active focus interval.

## Launch At Login

`SMAppService.mainApp` registers or unregisters the app when the preference changes. Required production behavior:

- The toggle reconciles to actual service status rather than assuming the request succeeded.
- Approval-required and unavailable/failure states are visible with System Settings or retry actions.
- Registration errors preserve a usable local workflow without assertion-only handling.
- Verify registration from a signed app in `/Applications`; development builds are not sufficient evidence.

## Menu Bar And Activation

- `MenuBarExtra` uses window style and the app is configured as an agent (`LSUIElement`).
- Menu bar text is optional to handle constrained space.
- Notification actions call `NSApplication.activate()` before store mutation.
- Quit explicitly terminates the process.

Manual QA must cover multiple displays, full-screen spaces, menu bar auto-hide, light/dark appearance, accent colors, and relaunch after force quit.

## Clipboard

The beta feedback tab writes a static template to the general pasteboard only after explicit user action. Focusin does not read clipboard contents.

## Sandbox And Entitlements

Version 1 should require only App Sandbox. Network client/server, files, contacts, calendars, camera, microphone, location, and HealthKit entitlements are intentionally absent. Login-item behavior must use supported APIs and code signing.

## Sleep, Wake, And Clock Changes

Deadlines are wall-clock dates. Focusin immediately reconciles runtime state, daily history, notification permission, login-item status, and the pending reminder on application activation, system wake, significant clock/timezone change, and calendar-day rollover. The one-second ticker remains a fallback while the process is active.

Test:

- Sleep across focus expiry.
- Sleep across break expiry.
- Move system clock forward and backward.
- Change timezone across local midnight.
- Resume after several days with stale daily history.

## Failure Policy

Platform integration failures must not crash the app or corrupt domain state. Expose actionable status where user intervention is possible; otherwise log in development and retain a usable local workflow.
