# Unfinished Surfaces Audit

## Audit Basis

Reviewed against the current Swift sources, bundled activity JSON, tests, Xcode/SwiftPM structure, README, and TestFlight notes. This is a planning audit, not a claim that every item was reproduced manually on a signed build.

## Shipped And Evidenced

- Menu bar popover and four-tab Settings UI.
- Four-state focus/break lifecycle and persisted deadlines.
- State/duration selection and recommendation fallback engine.
- Same-day seen/completed/skipped history.
- Notifications, quiet-hour scheduling logic, and reminder opening callback.
- Launch-at-login adapter.
- Bundled 20-item catalog and baseline validation.
- Codable compatibility defaults and two legacy read paths.
- Initial domain test suite.
- Sandbox/privacy resource files and Xcode archive path.

## P0 — Release Blockers

- None identified statically. A signed archive/security/privacy inspection is still required before this can be confirmed for release.

## P1 — Must Resolve Before Public Release

| Gap | Roadmap destination |
| --- | --- |
| Notification authorization result/status is ignored; denied and revoked states have no actionable UI. | Phase 3.5 permission status UI and Phase 4.2 authorization lifecycle |
| Launch-at-login errors only trigger `assertionFailure` and the UI can disagree with actual service status. | Phase 3.5 permission status UI and Phase 4.3 login item lifecycle |
| Lifecycle behavior lacks deterministic tests because clock and platform services are concrete. | Phase 2.1 dependency seams and Phase 2.2–2.4 deterministic suites |
| Sleep/wake, clock/timezone change, midnight rollover, and signed login-item behavior lack recorded evidence. | Phase 4.3–4.5 lifecycle matrices |
| Accessibility audit is not recorded; icon-only controls need explicit semantic verification. | Phase 3.1–3.4 experience and accessibility |
| Production icon/App Store screenshots, listing metadata, support URL, and privacy URL are not evidenced. | Phase 6.3 store presence |
| Activity catalog has structural validation but no recorded complete editorial/safety and coverage review. | Phase 5.1–5.4 catalog validation |

## P2 — Quality Gaps

| Gap | Roadmap destination |
| --- | --- |
| Natural break expiry automatically records completion; policy needs explicit product confirmation. | Phase 1.2 policy decisions, then Phase 2.2 transition suite |
| Equal quiet-hour endpoints mean all-day suppression but Settings does not explain it. | Phase 1.2 policy decisions and Phase 3 experience copy |
| Random recommendation selection is harder to reproduce in tests and demos. | Phase 2.1 dependency seams and Phase 2.5 recommendation suite |
| Active activity removal between app versions has no explicit migration/presentation policy. | Phase 1.2 policy decisions and Phase 2.4 persistence fixtures |
| Release evidence is not organized by build and macOS version. | Phase 4 signed-build evidence and Phase 7.1 final regression |
| UI automation and deterministic launch-state fixtures do not exist. | Phase 3.1 popover state matrix and Phase 3 accessibility verification |
| `.DS_Store` files and untracked `.vscode/` settings indicate repository hygiene cleanup is needed. | Phase 8.1 repository scan |
| Legacy reminder save methods appear unused and need migration-window review before removal. | Phase 8.1 repository scan; retain until the Phase 6.5 upgrade window is defined |

## P3 — Candidates After Version 1

- Local explicit preference feedback and category rotation.
- User-authored local activities.
- More granular accessibility/context tags.
- Optional history summary that remains local and avoids streak pressure.

## Explicit Non-Issues

- No backend/API/database: intentional local-first boundary.
- No authentication or billing: intentionally out of scope.
- No analytics: privacy decision, not missing instrumentation.
- No AI generation: catalog reviewability and safety are preferred for version 1.

## Closure Rule

Move an item to shipped only with code/test or signed-build/manual evidence. When deferring an item, name the target phase or mark it candidate/out of scope with rationale.
