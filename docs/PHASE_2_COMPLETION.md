# Phase 2 Completion Record

## Scope

- Roadmap phase: 2 — Domain And Persistence Hardening
- Evidence date: 2026-07-02 (Asia/Singapore)
- Product scope: domain, persistence, recommendation, catalog, and platform boundaries only

## Acceptance Evidence

| Task | Evidence |
| --- | --- |
| 2.1 Dependency seams | `FocusinStore` accepts clock/calendar, persistence, notification, login-item, and activity-loader adapters. Recommendation candidate calculation is independently deterministic while production selection remains random. |
| 2.2 State transition suite | `FocusinStoreTests` covers idle, focusing, break due, and breaking actions; exact focus/break deadlines; repeated reminder opens; history identity; calendar rollover; and RS-02–RS-08 restoration outcomes. |
| 2.3 Quiet-hour suite | Store tests cover disabled, same-day, overnight, equal/all-day, inclusive start, exclusive end, settings reconciliation, injected timezone, and spring/fall daylight-saving dates. |
| 2.4 Persistence fixtures | `PersistenceTests` uses isolated `UserDefaults` suites for clean/current payloads, missing fields, corrupt JSON, unknown enums, wrong-date history, legacy daily history, and legacy reminder start. |
| 2.5 Recommendation suite | `RecommendationEngineTests` asserts the candidate set produced by each of the six ordered passes and verifies office-safety and mindfulness preferences never relax. |
| 2.6 Catalog validation suite | Tests load the real bundled `Activities.json` and assert decoding, unique IDs, state coverage, duration coverage, office-safe coverage, and non-mindfulness fallbacks. |

## Verification

- `swift test` compiled the app and expanded XCTest bundle successfully. On this host, the SwiftPM XCTest helper then stalled while loading the bundle in `dyld` before test discovery; no test case started. This is recorded as a host-runner limitation, not a passing XCTest run.
- `./scripts/test-local.sh` passed with 20 bundled activities.
- `./scripts/build-local.sh` produced and ad-hoc signed `.build-local/Focusin.app`; strict signature verification passed.
- No manual menu bar QA was required because this phase changes policy seams and automated coverage, not user-visible lifecycle, notification, or settings behavior.

## Exit Decision

All Phase 2 policies are isolated from wall-clock and real platform services, represented by deterministic tests, and compile in the test target. The repository-required local test and build gates pass. Phase 3 is now the next phase.
