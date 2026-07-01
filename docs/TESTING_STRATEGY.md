# Testing Strategy

## Objective

Prove that Focusin’s recommendation logic, persisted lifecycle, platform integrations, and compact native UI remain reliable across relaunch, permission changes, and wall-clock transitions.

## Test Layers

### Unit tests

Current tests cover exact recommendation matching, office-safe and mindfulness filters, repeat avoidance, fallback behavior, date keys, history union, settings normalization/default decoding, runtime codability, and duplicate catalog IDs.

Required additions:

- Every recommendation fallback pass and empty eligible set.
- Real catalog validation and coverage matrix.
- Quiet-hour ranges including equal and overnight endpoints.
- Focus and break expiry at exact boundaries.
- Restoration for every runtime state.
- Corrupt and previous-version persistence fixtures.
- Interval/settings changes during active focus.
- Midnight and timezone rollover with an injected clock/calendar.

### Store integration tests

Introduce injectable clock, persistence, notification, login-item, random-selection, and catalog dependencies. Verify store initialization and transitions without macOS permission prompts or wall-clock sleeps.

### UI tests

Add a launch configuration with deterministic catalog, time, permission, and runtime fixtures. Cover:

- Golden path from idle through next focus interval.
- State and duration changes.
- Another, Done, Skip, and Reset actions.
- Settings persistence.
- Empty and invalid-catalog states.
- Notification-denied guidance.
- Keyboard-only operation.

### Manual platform tests

Some behavior must be validated on signed builds:

- Notification authorization, delivery, opening, revocation, and foreground presentation.
- Login item registration and removal.
- Sleep/wake and application relaunch.
- System clock, timezone, and local midnight changes.
- Multiple displays, spaces, full screen, and menu bar auto-hide.
- VoiceOver, Full Keyboard Access, contrast, transparency, and appearance settings.

## Golden Path Matrix

| Scenario | Expected result |
| --- | --- |
| Clean launch, auto-start on | Focus interval begins and reminder reconciles |
| Clean launch, auto-start off | Idle state waits for action |
| Focus expires, notifications on | Break due plus one notification |
| Focus expires, notifications denied | Break due in app; no functional dead end |
| Start break then relaunch | Same activity and derived countdown restore |
| Break expires while closed | Completion policy applies once and focus resumes |
| Skip break | Skip recorded and next focus begins |
| New local day | Same-day exclusions reset |

## Catalog Test Matrix

For every state, verify at least one default-filter candidate and at least one non-mindfulness fallback. For every item, validate a unique stable ID, non-empty copy, supported values, plausible durations, and reviewed safety flags.

## Release Gates

### Pull request gate

- Relevant unit tests pass.
- Local build passes.
- No new warning is introduced.
- Behavior and planning docs remain aligned.

### Beta gate

- Full automated suite passes on the release toolchain.
- Manual golden path passes from clean preferences.
- Signed notification and login item tests pass.
- Accessibility smoke test passes.
- Crash-free launch/relaunch evidence is recorded across supported macOS versions.

### App Store gate

- All P0/P1 issues closed.
- Archive/resource/privacy checks pass.
- Upgrade test from latest beta passes.
- Metadata and screenshots reflect the shipped build.
- Rollback and support contacts are ready.

## Defect Severity

- **P0**: data/privacy breach, unsafe instruction, launch blocker, persistent crash, or broken signing.
- **P1**: golden-path failure, incorrect timer restoration, unusable permissions state, or critical accessibility blocker.
- **P2**: degraded secondary behavior with workaround.
- **P3**: cosmetic or low-impact polish issue.

## Evidence

Record command output, tested build number, macOS version, permission state, and manual results for release candidates. A checklist without build-specific evidence is not sufficient for final release approval.

