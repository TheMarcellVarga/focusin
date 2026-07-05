# Phase 4 Evidence

## Status

Phase 4 is in progress. Automated lifecycle and integration hardening passes. The phase exit remains blocked on the signed installed-build matrix below; an ad-hoc signature is not sufficient evidence for notification and `SMAppService.mainApp` behavior.

## Automated Evidence

Verified on 2026-07-03:

- `swift test`: 45 tests passed.
- `./scripts/test-local.sh`: passes against the current 21-item bundled catalog.
- `./scripts/build-local.sh`: produced and verified the ad-hoc-signed local app bundle.
- Reminder reconciliation tests cover launch/restoration, interval edits, notification toggles and revocation, quiet-hour edits, timer restart, break start, completion, skip/due transitions, and forward/backward clock changes. Each mutation leaves exactly zero or one modeled pending reminder.
- Runtime tests cover exact focus and break deadlines, termination-style restoration across deadlines, missing active catalog identity, local-day rollover, timezone/DST calendars, and notification-open idempotence.
- Lifecycle observers now reconcile immediately on application activation, system wake, system clock/timezone changes, and calendar-day rollover.
- Login-item tests cover enabled/disabled reconciliation, approval required, and registration failure without blocking the local workflow.

## Signed-Build Preconditions

Record all results against the same Release build installed in `/Applications`.

| Field | Required evidence |
| --- | --- |
| App version/build | Marketing version and build number |
| Commit | Full Git commit SHA |
| macOS | Exact supported macOS version and hardware |
| Signing | `codesign` identity/team and successful strict verification |
| Install location | `/Applications/Focusin.app` |

Current machine observation on 2026-07-03: `security find-identity -v -p codesigning` reported zero valid identities, and the Xcode project has no development team configured. Signed-build rows therefore remain unexecuted.

## Manual Matrix

Use Pass/Fail plus concise observations and screenshots or command output. Do not mark a row from simulator, SwiftPM, or an ad-hoc-signed bundle.

| Area | Scenario | Expected result | Result |
| --- | --- | --- | --- |
| Notifications | First explicit authorization request | One system prompt; choice is reflected in Settings | Not run |
| Notifications | Deny, then approve in System Settings | Timer remains usable; activation refreshes status and schedules one reminder | Not run |
| Notifications | Revoke with reminder pending | Pending reminder is removed after activation; focus continues | Not run |
| Notifications | Foreground delivery and notification open | Banner/sound appears; open activates Focusin and shows break due | Not run |
| Notifications | Disable app preference | Pending and delivered Focusin reminder are cleared | Not run |
| Login item | Register and relaunch session | Service reports enabled and Focusin launches at login | Not run |
| Login item | Unregister | Service reports disabled and no login launch occurs | Not run |
| Login item | Approval required/failure | Actionable status appears; focus/break loop remains usable | Not run |
| Login item | Replace app with newer signed build | Preference reconciles to actual service status | Not run |
| Time | Sleep across focus deadline | Wake immediately shows break due; no duplicate reminder | Not run |
| Time | Sleep across break deadline | Completion records once and focus resumes | Not run |
| Time | Move clock forward/backward | Runtime and the single pending reminder reconcile immediately | Not run |
| Time | Change timezone across midnight | Same-day history uses the new local day and reminder reconciles | Not run |
| Time | Cross DST boundary | Quiet-hours and deadlines remain coherent | Not run |
| Process | Clean launch and normal quit/relaunch | Persisted settings/runtime restore correctly | Not run |
| Process | Force quit and relaunch across deadline | Expired state applies once without corruption | Not run |
| Process | Crash/relaunch simulation | Same restoration result as force quit | Not run |
| Upgrade | Replace prior build with current build | Settings, history, and runtime payloads remain compatible | Not run |

## Exit Decision

Phase 4 may be marked complete only after every applicable matrix row passes on a signed installed Release build with the build-specific fields recorded above. On 2026-07-03, the owner explicitly authorized Phase 5 work to begin as a sequencing exception. That exception does not waive, defer, or mark complete any Phase 4 row; Phase 6 remains blocked by both incomplete phases.
