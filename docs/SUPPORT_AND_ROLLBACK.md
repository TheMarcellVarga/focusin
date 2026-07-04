# Support And Rollback Runbook

## Status

The operational procedure is ready. A public support address and accountable release owner must be assigned before external distribution; until then, distribution is blocked.

## Support Intake

Every report must capture:

- Focusin version/build and installation source.
- macOS version, hardware architecture, and clean-install or upgrade status.
- Runtime state and expected/actual behavior.
- Notification authorization, Focusin notification preference, quiet-hours state, and launch-at-login state when relevant.
- Reproduction steps, frequency, timestamp/timezone, and screenshot or crash diagnostic when available.
- Whether the issue involves unsafe wording, privacy, data loss/corruption, launch failure, or an inaccessible golden path.

Do not request unrelated personal data, activity history exports, notification contents, or broad system diagnostics. Focusin has no server-side user record to inspect.

## Triage And Response

1. Acknowledge receipt and assign the severity from `TESTING_STRATEGY.md`.
2. Record the affected build and environment; do not merge evidence across builds.
3. For P0/P1, stop beta expansion or public rollout and notify the release owner immediately.
4. Reproduce with the smallest local fixture or signed-build scenario that preserves the reported conditions.
5. Add deterministic regression coverage where the behavior is testable without platform services.
6. Respond with confirmed behavior, workaround if safe, and the target build or explicit non-fix rationale.

Never provide medical advice in support responses. For activity discomfort or unsafe surroundings, advise stopping/skipping the optional prompt and record the exact activity ID for safety review.

## Stop-Ship And Removal Criteria

Pause submission, TestFlight expansion, or staged rollout for:

- Any P0 issue.
- A reproducible P1 golden-path, restoration, permissions, login-item, or critical accessibility failure.
- Unsafe catalog instruction or misleading medical claim.
- Privacy manifest, entitlement, signing, or binary-content mismatch.
- Upgrade corruption or incompatible persisted state.
- A material claim in store/demo/portfolio media that does not match the binary.

Remove or expire an affected beta/public build when continued installation or use creates privacy, safety, corruption, persistent crash, or launch risk. A cosmetic issue with a safe workaround does not justify emergency removal by itself.

## Hotfix Procedure

1. Freeze unrelated changes and identify the last known good and affected version/build/commit.
2. Reproduce and classify the issue; preserve minimal diagnostics without adding telemetry.
3. Implement the smallest coherent fix and update tests, documentation, catalog release notes, privacy answers, or metadata as applicable.
4. Increment the build number; increment the marketing version when public behavior or compatibility warrants it.
5. Run `swift test`, `./scripts/test-local.sh`, `./scripts/build-local.sh`, and `./scripts/release-preflight.sh`.
6. Repeat every affected signed lifecycle, accessibility, upgrade, and archive check on the exact hotfix candidate.
7. Validate/upload the new archive, update release notes, and distribute first to the smallest internal cohort.
8. Resume rollout only after the triggering P0/P1 is verified closed and no new P0/P1 is open.

## Rollback Constraints

App Store binaries cannot be replaced in place. Pause phased release where available, remove an unsafe build from sale/testing when warranted, and submit a higher build/version containing the fix. Do not instruct users to delete preferences as a default workaround because that destroys local state and can hide migration defects.

## Incident Record

For a material incident, record:

- Incident owner, date, affected builds, severity, and user impact.
- Detection source and exact reproduction conditions.
- Distribution action and communication timeline.
- Root cause, fix commit/build, and verification evidence.
- Privacy/safety/metadata implications.
- Follow-up actions with owners and deadlines.
