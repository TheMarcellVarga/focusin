# Implementation Plan

## Planning Model

Work is organized by dependency, not aspirational dates. Each phase has a deliverable and exit gate. Keep `UNFINISHED_SURFACES_AUDIT.md` synchronized as tasks close or new gaps appear.

## Phase 0: Control Plane

**Outcome:** contributors can distinguish shipped behavior, planned work, and release blockers.

- Maintain the product spec, architecture, state model, recommendation policy, design system, security posture, and test plan.
- Establish a documentation index and contributor operating contract.
- Inventory placeholders and gaps by severity.
- Record macOS target, distribution path, and explicit non-goals.

**Exit:** all core concerns have an owner document and contradictory claims are resolved.

## Phase 1: Product And Behavior Lock

**Outcome:** version 1 behavior can be tested without design ambiguity.

- Confirm golden path and primary action per state.
- Decide whether natural break expiry counts as completion.
- Specify notification-denied and login-item-failure behavior.
- Lock quiet-hours semantics, including equal endpoints.
- Review setting defaults and first-launch behavior.
- Freeze version 1 activity schema and content rules.

**Exit:** every runtime transition and exceptional state has approved expected behavior.

## Phase 2: Testable Domain Core

**Outcome:** time and platform-dependent behavior is deterministic under test.

- Introduce minimal protocols for clock/calendar, notifications, login items, and persistence where necessary.
- Avoid over-generalizing the small architecture.
- Add fixture-based runtime restoration and persistence migration tests.
- Test all recommendation fallback passes against expected candidate sets.
- Test quiet hours, interval changes, midnight rollover, and corrupt data.
- Validate the real activity JSON during tests.

**Exit:** domain/store behavior can be verified without real delays or system permission prompts.

## Phase 3: Experience And Accessibility

**Outcome:** the complete golden path is understandable and operable through supported macOS access modes.

- Add accessible labels for icon-only controls.
- Verify keyboard focus order and default/cancel actions.
- Prevent per-second countdown changes from overwhelming VoiceOver.
- Verify larger text, contrast, reduce transparency, and dark mode.
- Add actionable permission and platform-error states.
- Review popover copy for width, truncation, and translation readiness.
- Add deterministic UI launch fixtures where practical.

**Exit:** accessibility checklist and UI-state matrix pass without P1 issues.

## Phase 4: Platform Lifecycle Hardening

**Outcome:** the app reconciles accurately with macOS lifecycle and integration state.

- Query and display notification authorization status.
- Reconcile the single pending reminder after settings changes and activation.
- Replace assertion-only login-item failures with user-visible status.
- Observe activation/significant-time changes when needed.
- Test sleep/wake, forward/backward clock change, timezone shift, and relaunch.
- Verify login at startup from an installed signed build.

**Exit:** manual platform matrix passes on supported macOS versions.

## Phase 5: Catalog Quality

**Outcome:** the catalog is sufficiently varied, safe, and structurally guaranteed.

- Audit all current entries for clarity, realistic timing, context, inclusivity, and safety.
- Generate and review state-duration/filter coverage reports.
- Add missing office-safe and non-mindfulness fallbacks.
- Decide whether category rotation is necessary based on beta feedback.
- Document stable-ID and deprecation rules.

**Exit:** automated catalog checks pass and a human content review is recorded.

## Phase 6: Beta And Distribution

**Outcome:** a signed build is ready for external TestFlight evaluation.

- Produce final icon and screenshot source assets.
- Verify Xcode target resources, sandbox, privacy manifest, version/build, and signing.
- Complete App Store Connect record, privacy answers, category, support URL, and beta notes.
- Run clean-install and upgrade QA.
- Distribute to a small tester cohort with the built-in feedback prompt.
- Triage beta feedback by severity and product evidence.

**Exit:** external beta build passes release gates and no P0/P1 defect remains open.

## Phase 7: Release And Evidence

**Outcome:** version 1 is supportable and accurately represented.

- Complete final metadata, screenshots, support/privacy pages, and review notes.
- Record test evidence by build and macOS version.
- Run demo walkthrough and capture portfolio media from the release candidate.
- Document limitations and post-release candidates.
- Prepare rollback, hotfix, and tester communication steps.

**Exit:** submitted build, documentation, metadata, and evidence all refer to the same version.

## Phase 8: Completion Audit

**Outcome:** no hidden placeholder or ambiguous half-feature remains.

- Search for TODO/FIXME, placeholder metadata/assets, debug copy, stale comments, warnings, and dead files.
- Reconcile roadmap, implementation, audit, README, and code.
- Close or explicitly defer every open item.
- Confirm public claims against the archive.

**Exit:** whole-product definition of done in `FocusinWorkspacePlan.md` is satisfied.

## Task Template

Every non-trivial task should state:

- Phase and problem.
- Current evidence.
- Intended behavior and non-goals.
- Files/components likely affected.
- Dependencies and migration impact.
- Automated and manual verification.
- Documentation and release implications.
- Acceptance criteria.

