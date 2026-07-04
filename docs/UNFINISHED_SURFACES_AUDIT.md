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
- Complete Phase 2 domain suite covering lifecycle transitions/restoration, quiet hours, persistence compatibility, recommendation passes, and real catalog validation.
- Sandbox/privacy resource files and Xcode archive path.
- Injectable clock/calendar, notification, login-item, catalog, and persistence boundaries; random selection is separated from deterministic candidate policy.
- Actionable notification permission and launch-at-login status UI, including System Settings recovery actions and deterministic adapter/store tests.
- Phase 3 native experience matrix covering all six popover presentations in light/dark appearance, keyboard operation, accessibility semantics, increased contrast, reduced transparency, large text, and alternate accent color.
- Debug-only deterministic UI launch fixtures for idle, focusing, break due, breaking, empty, and catalog-error presentations.
- Phase 4 automated lifecycle hardening: activation, wake, clock/timezone changes, and day rollover trigger immediate runtime/platform reconciliation; reminder mutations deterministically leave zero or one pending request.
- Phase 5 measurable catalog validation and coverage reporting, including every default-filter state-duration intersection, category, intensity, and context-flag counts.
- Phase 5 engineering editorial pre-review removed a breath-holding prompt, strengthened movement safety copy, and filled sparse stiff/ten-minute and social-category coverage.
- Phase 6 unsigned Release product integrity: final metadata, bundled catalog/privacy manifest, sandbox-only entitlements, shared scheme, and Release warnings are inspected by a repeatable preflight script.

## Resolved Product Contracts

- Phase 1 transition/restoration behavior and exact deadline semantics are locked in `BEHAVIORAL_CONTRACT.md`.
- Natural break expiry counts as completion; equal quiet endpoints suppress reminders all day; startup auto-focus defaults on.
- Active catalog removal recovers to break due without identity substitution.
- Permission/error copy and catalog identity, coverage, editorial, safety, and removal policies are locked for later implementation/verification.

## P0 — Release Blockers

- None identified statically. A signed archive/security/privacy inspection is still required before this can be confirmed for release.

## P1 — Must Resolve Before Public Release

| Gap | Roadmap destination |
| --- | --- |
| Signed-build notification, login-item, sleep/wake, clock/timezone, midnight, termination, and update scenarios lack recorded manual evidence. | Phase 4.2–4.5 lifecycle matrix in `PHASE_4_EVIDENCE.md` |
| Production icon/App Store screenshots, public support/privacy URLs, copyright, reviewer contact, and App Store Connect listing are not evidenced; listing copy is drafted locally. | Phase 6.3 store presence in `PHASE_6_EVIDENCE.md` |
| Activity catalog engineering pre-review is recorded, but named human owner sign-off and build-specific beta feedback are not complete. | Phase 5.2–5.3 evidence in `PHASE_5_EVIDENCE.md` |

## P2 — Quality Gaps

| Gap | Roadmap destination |
| --- | --- |
| Release evidence is not organized by build and macOS version. | Phase 4 signed-build evidence and Phase 7.1 final regression |
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
