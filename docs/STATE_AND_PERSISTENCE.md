# State And Persistence

## Purpose

This document defines the runtime state machine, storage keys, restoration rules, and compatibility requirements. It is the equivalent of a database-schema specification for this local-only app.

## Runtime State Machine

```text
                    interval elapsed
idle --start------> focusing ----------------> breakDue
 |                     |                         |
 | reset now           | take break              | start
 v                     v                         v
breaking <----------------------------------- breaking
   |  \
   |   \ skip
   | done/expiry
   v
focusing
```

Restarting focus from `focusing` creates a new `startedAt`. Recommendation changes do not alter runtime state. `Another` marks an activity seen and requests a replacement.

## Persisted Keys

| Key | Encoding | Current use |
| --- | --- | --- |
| `focusin.settings` | JSON data | `FocusinSettings` |
| `focusin.selectedState` | string | `FocusState.rawValue` |
| `focusin.selectedDuration` | string | `BreakDuration.rawValue` |
| `focusin.activityHistory` | JSON data | current-day `ActivityHistory` |
| `focusin.runtimeState` | JSON data | `FocusinRuntimeState` |
| `focusin.dailyHistory` | JSON data | legacy read-only migration source |
| `focusin.reminderStartedAt` | date | legacy read-only runtime source |

Legacy keys should not be removed until at least one released migration window has elapsed and upgrade tests cover the supported path.

## Settings Schema

- Work interval enum and custom minutes.
- Default break duration.
- Office-safe-only and include-mindfulness filters.
- Quiet-hours enabled, start hour, and end hour.
- Launch-at-login and menu-bar-text preferences.
- Notifications enabled and auto-start-on-launch preferences.

Numeric normalization clamps custom work minutes to 1–240 and quiet-hour values to 0–23. Decoding uses per-field defaults so adding a setting does not invalidate older payloads.

## History Schema

History is scoped to a local calendar date key and contains three ID sets:

- `completedActivityIDs`: the user marked Done or the active break expired.
- `skippedActivityIDs`: the user explicitly skipped.
- `seenActivityIDs`: the user requested Another.

Their union is excluded by novelty-preferred recommendation passes. When the local date changes, history resets rather than accumulating longitudinal behavior.

## Restoration Rules

### Idle

Set the break countdown to zero. If auto-start is enabled during initial launch, start a new focus interval.

### Focusing

Compare current wall time with `startedAt + resolved interval`. If expired, transition to break due; otherwise schedule the remaining notification when permitted.

### Break due

Set break countdown to zero and wait for explicit user action.

### Breaking

Restore the catalog activity by ID and derive remaining seconds from `endsAt`. If already expired, complete the break and begin focus according to current behavior.

## Failure And Recovery Policy

- Missing values: use documented defaults.
- Unknown enum raw values: fall back at the containing load boundary.
- Invalid settings JSON: reset settings only, not unrelated values.
- Invalid runtime JSON: return idle.
- Invalid history JSON or date mismatch: create empty current-day history.
- Activity ID removed during an active break: transition to break due, clear the stale deadline, and offer a valid recommendation. Never display a replacement activity under the removed ID's timer/history identity. This behavior has a deterministic restoration test.

## Compatibility Rules

- Additive settings fields require `decodeIfPresent` defaults.
- Renaming enum raw values requires an explicit decoder migration.
- Runtime enum changes require upgrade fixtures for every old case.
- Catalog IDs are durable identifiers and should not be renamed casually.
- Never reuse a removed activity ID for semantically different content.
- A storage change must include clean-install, current-version, corrupt-data, and previous-version tests.

## Planned Hardening

- Extract clock/calendar protocols for deterministic expiry and midnight tests.
- Extract platform adapters so store initialization is testable without real notifications/login services.
- Add fixture-based migration tests for all persisted payload versions.
- Test the approved policy that automatic break expiry counts as completion.
- Remove unused legacy save helpers only after a released migration window.

## Acceptance Criteria

- Relaunch preserves active focus/break deadlines within one second of wall-clock calculation.
- Corrupt data cannot crash startup.
- Quiet-hour or interval changes cannot create multiple pending reminders.
- New settings decode from old payloads with intentional defaults.
- Daily history rolls over using the current calendar and timezone policy.
