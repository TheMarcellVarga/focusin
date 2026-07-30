# Rework Phase 2 Lifecycle And Platform Verification

## Status

- **Plan:** Focusin Rework and Release Plan
- **Phase:** 2 — Lifecycle and Platform Verification
- **Status:** Blocked — automated verification complete; signed installed-build matrix unavailable
- **Verified:** 2026-07-30
- **Starting baseline:** `a10195e`
- **Product version/build:** 0.1.0 (1)

This record covers the portfolio-focused rework plan. It does not represent an ad-hoc-signed local build as a signed release candidate. The canonical manual matrix remains in [`PHASE_4_EVIDENCE.md`](PHASE_4_EVIDENCE.md).

## Implemented Changes

| Commit | Change |
| --- | --- |
| `3d5a410` | Added the dedicated macOS timezone-change lifecycle hook and a deterministic timezone/across-midnight reconciliation test. |
| `228e5db` | Added privacy-safe unified logging for notification authorization/scheduling and login-item registration failures. |
| `09f2eff` | Added deterministic coverage for notification approval and login-item status changed externally in System Settings. |

## Automated Lifecycle Coverage

The deterministic suite now covers:

- notification authorization denied, granted after an explicit request, granted externally, and revoked externally;
- actionable login-item failure and approval states plus externally enabled/disabled reconciliation;
- sleep/wake-equivalent forward deadline reconciliation for focus and break states;
- forward and backward clock changes;
- a timezone change across local midnight, including daily-history rollover and quiet-hours rescheduling;
- same-day, overnight, equal/all-day, disabled, start-inclusive, and end-exclusive quiet-hour boundaries;
- daylight-saving dates with an injected calendar;
- termination-style restoration before and after focus and break deadlines;
- removal of an active catalog identity during an update;
- zero-or-one pending reminder behavior after every reminder mutation.

The app now observes application activation, system wake, significant clock change, dedicated timezone change, and calendar-day rollover. Each event invokes the same `MainActor` reconciliation path.

## Automated Verification

Verified on 2026-07-30 against commit `09f2efff3a6d108c37fa287f4836c845f1ad2250`:

- `swift test`: 52 tests passed with zero failures.
- `./scripts/test-local.sh`: passed; 21 bundled activities validated.
- `./scripts/build-local.sh`: passed; the local app built and passed strict ad-hoc signature verification.
- `./scripts/release-preflight.sh`: passed; unsigned Release product integrity and warning policy verified.

## Verification Environment

| Field | Value |
| --- | --- |
| Xcode | 26.6 (17F113) |
| Swift | 6.3.3 |
| macOS | 26.5.2 (25F84) |
| Hardware | MacBook Pro (Mac15,6), Apple M3 Pro, arm64 |
| Signing identities | `0 valid identities found` |
| Development team | Not configured in the Xcode project |

## Signed-Build Matrix

No signed-build row was run. The machine has no valid code-signing identity, the project has no development team, and no named-team Release build is installed at `/Applications/Focusin.app`. An ad-hoc-signed local build cannot validate Notification Center or `SMAppService.mainApp` production behavior.

The complete build-specific matrix is maintained in [`PHASE_4_EVIDENCE.md`](PHASE_4_EVIDENCE.md). Every row remains `Not run`; this is a precondition block, not a test failure.

For a failed row, capture:

1. exact timestamp, scenario, expected result, and observed result;
2. relevant Console output using subsystem `com.marcellvarga.focusin`;
3. screenshot or command output;
4. resolution, retest result, and fixing commit when applicable.

## Exit Decision

Phase 2 remains in progress. To complete it:

1. configure an Apple development team and valid signing identity;
2. archive and install the same signed Release build at `/Applications/Focusin.app`;
3. pass `./scripts/verify-signed-candidate.sh /Applications/Focusin.app`;
4. execute every applicable row in `PHASE_4_EVIDENCE.md` against that build;
5. record Pass/Fail, evidence, logs and resolution for failures, and confirm no duplicate reminders;
6. rerun all automated gates and create the Phase 2 completion commit.
