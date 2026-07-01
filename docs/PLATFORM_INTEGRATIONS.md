# Platform Integrations

## Scope

Focusin integrates with macOS Notification Center, ServiceManagement login items, application activation, the clipboard, menu bar scenes, and the App Sandbox. Each integration must degrade safely and match App Store declarations.

## Notifications

### Current behavior

- Requests alert and sound authorization when notifications are enabled.
- Schedules one non-repeating notification under `focusin.break-due`.
- Replaces prior pending requests before scheduling.
- Clears pending and delivered reminders when no longer relevant.
- Shows banner and sound while the app is active.
- Activates the application and marks break due when opened.

### Required hardening

- Inspect authorization status before presenting setting-dependent copy.
- Distinguish not-determined, denied, provisional, and authorized states.
- Explain how to re-enable notifications in System Settings after denial.
- Verify revocation while a reminder is pending.
- Confirm that in-app elapsed-time handling works with notifications off.
- Avoid repeatedly requesting permission after denial.

## Quiet Hours

Quiet hours suppress notification scheduling, not the focus state transition. Equal start/end currently means quiet all day. A range with start before end is same-day; start after end crosses midnight.

Equal endpoints are an intentional all-day-reminder-suppression policy. The target Settings explanation is: “Start and end match, so reminders are quiet all day. Timers still continue.” Exact permission and recovery copy is specified in [`BEHAVIORAL_CONTRACT.md`](BEHAVIORAL_CONTRACT.md).

Required edge tests include 18:00–08:00, 08:00–18:00, equal endpoints, timezone changes, daylight-saving changes, and enabling quiet hours during an active focus interval.

## Launch At Login

`SMAppService.mainApp` registers or unregisters the app when the preference changes. Required production behavior:

- Reflect actual service status rather than assuming requested state succeeded.
- Handle approval-required, denied, and not-found states visibly.
- Avoid assertion-only error handling in release builds.
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

Deadlines are wall-clock dates, so the app recalculates on its next tick after wake. Planned lifecycle hardening should observe significant time changes or application activation so UI and notifications reconcile immediately rather than waiting for incidental updates.

Test:

- Sleep across focus expiry.
- Sleep across break expiry.
- Move system clock forward and backward.
- Change timezone across local midnight.
- Resume after several days with stale daily history.

## Failure Policy

Platform integration failures must not crash the app or corrupt domain state. Expose actionable status where user intervention is possible; otherwise log in development and retain a usable local workflow.
