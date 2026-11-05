# Behavioral Contract

## Purpose

This document is the Phase 1 executable specification for Focusin. Each case has a stable ID for the deterministic suites introduced in Phase 2. Unless marked **target**, the behavior describes the current implementation. Target behavior is approved product policy but is not yet shipped.

## Runtime Invariants

- Runtime mutations occur on `MainActor` and every runtime transition is persisted.
- Notification availability never controls the focus/break state machine.
- At most one break reminder, `focusin.break-due`, may be pending.
- Recommendation changes never alter runtime state.
- `Finish Break`, `Skip`, and natural break expiry start a new focus interval.
- An action with no eligible/current activity is a no-op and must not fabricate content.

## Transition Cases

| ID | Starting state | Event | Result | History and notification effect |
| --- | --- | --- | --- | --- |
| RT-01 | idle | `Start Focus` | focusing with `startedAt = now` | replace the pending reminder when permitted |
| RT-02 | idle | `Take Break` with an activity | breaking with the selected duration deadline | clear the reminder; no history entry yet |
| RT-03 | focusing | `Start Focus`/`Reset` | focusing with a fresh `startedAt` | replace the prior reminder |
| RT-04 | focusing | interval reaches or passes its exact deadline | break due | clear the reminder; no activity history entry |
| RT-05 | focusing | `Take Break` with an activity | breaking | clear the reminder |
| RT-06 | break due | `Start Break` with an activity | breaking | clear any delivered/pending reminder |
| RT-07 | break due | `Start Focus`/`Reset` | focusing with a fresh `startedAt` | schedule when permitted |
| RT-08 | breaking | `Finish Break` | focusing | record the active ID as completed; schedule when permitted |
| RT-09 | breaking | `Skip` | focusing | record the active ID as skipped; schedule when permitted |
| RT-10 | breaking | break reaches or passes its exact deadline | focusing | record the active ID as completed; schedule when permitted |
| RT-11 | any non-breaking state | `Another` | state unchanged; replace recommendation | record the displayed ID as seen |
| RT-12 | breaking | `Another` | breaking, deadline, and displayed activity unchanged | no-op; shuffle is unavailable during a break |
| RT-13 | any state | state, duration, or recommendation-filter edit | runtime state unchanged | recompute the recommendation outside a break; preserve active activity during a break; new filters apply to the next suggestion |
| RT-14 | any state | local calendar date changes | runtime state unchanged | replace history with an empty history for the new date |
| RT-15 | any state | repeated action | apply the same rules from the state observed when the action is handled | never create more than one pending reminder |

Natural expiry is completion because the full selected break interval elapsed. This is local novelty history, not a health, adherence, or productivity claim.

## Launch And Restoration Cases

| ID | Persisted input | Result |
| --- | --- | --- |
| RS-01 | no/invalid runtime payload | idle, then start focusing when auto-start is enabled |
| RS-02 | idle | start focusing by default; remain idle when auto-start is disabled |
| RS-03 | focusing before deadline | restore the original start date and schedule only the remaining delay when permitted |
| RS-04 | focusing at/after deadline | break due, independent of notification permission |
| RS-05 | break due | remain break due until an explicit action |
| RS-06 | breaking before deadline with an existing activity ID | restore that activity and derive remaining time from the persisted deadline |
| RS-07 | breaking at/after deadline with an existing activity ID | apply natural completion and start focus |
| RS-08 | breaking with a catalog ID removed by an update | transition to break due, clear the stale deadline, and present a valid new recommendation; do not record or display a different activity as the removed one |

`startFocusTimerOnLaunch` defaults to `true` on clean install and when decoding an older settings payload without that field. It only applies when the restored runtime state is idle.

## Notification And Quiet-Hour Cases

- Quiet hours suppress reminder scheduling only. Deadline-driven transition to break due still occurs.
- Start is inclusive and end is exclusive at the configured local clock hour.
- Start before end is a same-day range; start after end crosses midnight.
- Equal endpoints intentionally mean reminders are suppressed all day. **Target UI copy:** “Start and end match, so reminders are quiet all day. Timers still continue.”
- Disabling notifications clears pending/delivered Focusin reminders and never pauses a timer.
- Editing the interval or quiet hours during focus reconciles the single reminder against the original `startedAt`; an already elapsed interval becomes break due.
- Opening the Focusin reminder activates the app and marks the runtime break due. Repeated opens are idempotent.

## Permission And Error Copy Contract

These presentations are implemented Phase 3 behavior. They do not block the local workflow; signed authorization and login-item lifecycle verification remains in Phase 4.

| Condition | Required copy | Action |
| --- | --- | --- |
| notifications not determined | “Allow notifications to receive break reminders. Focusin still works without them.” | `Allow Notifications` triggers one system request |
| notifications denied or revoked | “Notifications are off in System Settings. Timers still continue in Focusin.” | `Open Notification Settings` opens the app's macOS notification settings |
| notifications disabled in Focusin | “Break reminders are off. Timers still continue in Focusin.” | settings toggle is the action; do not request authorization |
| login item requires approval/was denied | “Launch at Login needs approval in System Settings.” | `Open Login Items Settings` |
| login item registration failed | “Couldn’t update launch at login. Try again or open Focusin manually.” | `Try Again`; preserve the actual service state in the toggle |
| login item unavailable or Debug/local build | “Unavailable in this build. Open Focusin manually.” | toggle disabled; no retry action |
| catalog missing/invalid | “Activity library unavailable. Focus timers still work. Try loading the activity library again.” | `Try Again`; Settings and focus controls remain available |
| no eligible activity after hard filters | “No matching activity. Adjust your break preferences to see more options.” | `Open Break Preferences` |

Permission prompts must not repeat after denial. Platform status is refreshed on app activation and before presenting status-dependent copy.

## Settings And Invalid Data

- Work interval changes retain the focusing `startedAt`; they do not silently restart focus.
- Break duration changes do not alter an already active break deadline. State/duration selectors are disabled during a break.
- In break-due with an unavailable catalog or no eligible activity, `Start Focus` replaces the unavailable shuffle action so the user can resume focus.
- Invalid settings JSON resets settings only. Unknown selected state/duration values use documented defaults.
- Invalid runtime JSON becomes idle. Invalid or wrong-date history becomes empty current-day history.
- Hard recommendation preferences never relax, including during recovery.

## Phase 2 Test Mapping

- RT-01–RT-15 and RS-01–RS-08: state transition suite.
- Notification/quiet-hour cases: quiet-hour and notification reconciliation suites.
- Invalid-data and missing-field cases: persistence fixtures.
- Recommendation filter and empty-state cases: recommendation and catalog suites.

Exact deadline means `now >= deadline`. Test clocks and calendars must be injected; automated tests must not wait for wall-clock timers or invoke real macOS services.
