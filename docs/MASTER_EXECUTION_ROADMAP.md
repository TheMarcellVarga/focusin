# Master Execution Roadmap

## Purpose

This is the execution control plane for taking Focusin from a functional vertical slice to a verified macOS release. It translates the supporting specs into dependency-ordered work and prevents polish or distribution work from hiding unresolved lifecycle defects.

## Operating Model

- Complete phases in order unless a task is explicitly dependency-free.
- Keep changes small enough to verify and revert.
- A phase is complete only when its exit evidence exists.
- Update the unfinished audit whenever the current truth changes.
- Do not introduce cloud, analytics, AI, or monetization work into version 1 without revising the product boundary.

## Current Baseline

Already shipped in the repository:

- SwiftUI menu bar and Settings scenes.
- Four-state focus/break lifecycle.
- Bundled 20-item activity catalog and ordered recommendation fallback.
- Same-day completed/skipped/seen exclusions.
- Local settings and runtime persistence with legacy migration reads.
- Notifications, quiet hours, launch-at-login adapter, privacy manifest, sandbox entitlements.
- Local build/test scripts and a checked-in Xcode project.

The roadmap therefore prioritizes verifiability and release quality over new feature surface.

## Phase Status

| Phase | Status | Evidence |
| --- | --- | --- |
| 0 — Documentation And Audit | Complete | [`PHASE_0_COMPLETION.md`](PHASE_0_COMPLETION.md) |
| 1 — Behavioral Contract | Complete | [`PHASE_1_COMPLETION.md`](PHASE_1_COMPLETION.md) |
| 2 — Domain And Persistence Hardening | Complete | [`PHASE_2_COMPLETION.md`](PHASE_2_COMPLETION.md) |
| 3 — Native Experience And Accessibility | Complete | [`PHASE_3_EVIDENCE.md`](PHASE_3_EVIDENCE.md) |
| 4 — macOS Lifecycle And Integration | In progress | Automated hardening passes; signed-build matrix remains in [`PHASE_4_EVIDENCE.md`](PHASE_4_EVIDENCE.md) |
| 5 — Activity Catalog And Product Validation | In progress by explicit sequencing exception | Automated report and engineering pre-review in [`PHASE_5_EVIDENCE.md`](PHASE_5_EVIDENCE.md); owner sign-off and build-specific beta signal remain |
| 6–8 | Blocked by sequence | Begin only after the preceding phase exits |

## Phase 0: Documentation And Audit

### 0.1 Documentation control plane

**Deliverable:** complete linked Markdown planning set.

**Verify:** a new contributor can locate product, architecture, persistence, recommendation, platform, design, privacy, testing, release, demo, and portfolio decisions from README.

### 0.2 Current-state audit

**Deliverable:** severity-ranked `UNFINISHED_SURFACES_AUDIT.md`.

**Verify:** every unchecked release-critical claim has a roadmap destination.

### 0.3 Scope lock

**Deliverable:** approved version 1 inclusions and non-goals.

**Verify:** no planning document implies a backend, account, analytics, AI, or medical capability.

**Phase exit:** documentation is internally consistent and all known P0/P1 risks are routed.

## Phase 1: Behavioral Contract

### 1.1 Transition table

Document and test user actions, timer expiry, notification open, relaunch, settings changes, and invalid catalog behavior for every runtime state.

### 1.2 Policy decisions

Resolve natural break expiry history semantics, equal quiet-hour endpoints, startup timer default, and behavior when the active activity disappears after an update.

### 1.3 Permission/error copy

Specify notification denied/revoked, login-item failure, and invalid-catalog recovery copy with actionable user paths.

### 1.4 Catalog content contract

Lock ID stability, supported classifications, safety copy, coverage expectations, and removal policy.

**Phase exit:** expected behavior is unambiguous enough to write deterministic tests.

## Phase 2: Domain And Persistence Hardening

### 2.1 Dependency seams

Introduce only the seams required to fake time, calendar, notification scheduling, login service, catalog, and persistence. Preserve the simple one-store architecture.

### 2.2 State transition suite

Test idle, focusing, break due, and breaking entry/exit paths; exact expiry boundaries; repeated actions; and expired restoration.

### 2.3 Quiet-hour suite

Test same-day, overnight, all-day/equal, disabled, boundary-hour, settings-change, timezone, and daylight-saving cases.

### 2.4 Persistence fixtures

Test clean defaults, current encoding, missing new fields, corrupt values, legacy daily history, legacy reminder start, and unknown values.

### 2.5 Recommendation suite

Cover hard filters and all six soft passes, ensuring explicit preferences never relax. Assert candidate sets where selection is random.

### 2.6 Catalog validation suite

Run structural and coverage validation against the real bundled JSON in CI/local tests.

**Phase exit:** all business/lifecycle policies are testable without waiting or invoking real platform services.

## Phase 3: Native Experience And Accessibility

### 3.1 Popover state matrix

Capture and inspect idle, focusing, break due, breaking, empty, and catalog-error presentations in light and dark mode.

### 3.2 Keyboard operation

Verify opening the menu, changing selectors, invoking primary/secondary actions, opening Settings, and quitting with Full Keyboard Access.

### 3.3 VoiceOver semantics

Add labels/hints to icon-only controls, establish reading order, and prevent noisy countdown announcements.

### 3.4 Display accommodations

Test increased contrast, reduced transparency, accessibility text, different accent colors, constrained menu bar space, and multiple displays.

### 3.5 Permission status UI

Surface denied/revoked notification status and login-item failures without blocking the local focus/break workflow.

**Phase exit:** golden path is usable without pointer input and all critical state is conveyed non-visually or without color dependence.

## Phase 4: macOS Lifecycle And Integration

### 4.1 Notification reconciliation

Ensure exactly one or zero pending requests after launch, interval edits, toggles, quiet-hour edits, timer restart, break start, completion, and skip.

### 4.2 Authorization lifecycle

Verify first request, denial, later System Settings approval, revocation, foreground delivery, notification open, and disabled preference.

### 4.3 Login item lifecycle

Verify registration, unregister, approval-required/failure states, app replacement/update, and preference reconciliation from a signed installed build.

### 4.4 Time lifecycle

Verify sleep across deadlines, app termination across deadlines, clock forward/backward, timezone change, DST, and local date rollover.

### 4.5 Process lifecycle

Verify clean launch, normal quit, force quit, crash/relaunch simulation, and update preserving preferences/runtime compatibility.

**Phase exit:** signed-build manual matrix passes with build-specific evidence.

## Phase 5: Activity Catalog And Product Validation

### 5.1 Automated coverage report

Report counts by state, duration, category, office-safe, mindfulness, and intensity. Flag sparse intersections.

### 5.2 Editorial review

Review every activity for concise instruction, clear completion, realistic duration, low-risk motion, inclusive wording, and correct context tags.

### 5.3 Beta signal

Ask whether suggestions felt specific, repetitive, awkward, unsafe, or mistimed using the feedback template. Do not add analytics to answer these questions.

### 5.4 Catalog revision

Fix demonstrated gaps, preserve stable IDs where meaning is unchanged, and document removals. Re-run matrix tests.

**Phase exit:** catalog passes automated validation and recorded human safety/editorial review.

## Phase 6: Distribution Readiness

### 6.1 Project integrity

Verify target membership, shared scheme, bundle ID, macOS target, versions, Info.plist, privacy manifest, entitlements, and release build warnings.

### 6.2 Signing/archive

Select distribution team, archive Release, validate archive contents, run Apple validation, and retain build/version evidence.

### 6.3 Store presence

Complete icon, screenshots, description, keywords, category, support/privacy URLs, copyright, review notes, and accurate privacy answers.

### 6.4 TestFlight cohort

Start internal, then small external beta. Provide focus questions, version notes, and a triage path. Block expansion on P0/P1 issues.

### 6.5 Upgrade verification

Install over the prior beta and confirm settings, runtime state, catalog history, login item, and notification behavior remain safe.

**Phase exit:** a validated external beta has no open P0/P1 issue and all declarations match the binary.

## Phase 7: Release, Demo, And Portfolio Evidence

### 7.1 Final regression

Run automated suite, clean-install golden path, upgrade path, accessibility smoke test, platform matrix, and archive inspection on the exact candidate.

### 7.2 Demo capture

Use `DEMO_WALKTHROUGH.md` with deterministic settings and real product behavior. Capture concise screenshots/video without staging nonexistent functionality.

### 7.3 Case study

Complete the portfolio narrative with problem, constraints, architecture, decisions, verification, and honest limitations.

### 7.4 Support and rollback

Prepare support response path, known issues, hotfix build procedure, and criteria for pausing/removing distribution.

**Phase exit:** the released/submitted build and all public evidence are version-aligned and supportable.

## Phase 8: No-Placeholder Completion Pass

### 8.1 Repository scan

Search TODO, FIXME, placeholder, sample identifiers, dead code, stale migration helpers, accidental `.DS_Store`, IDE files, warnings, and untracked release resources.

### 8.2 Documentation reconciliation

Verify checked boxes, shipped/planned labels, commands, paths, version numbers, privacy claims, and screenshots.

### 8.3 Gap disposition

Close each remaining audit item or mark it candidate/out of scope with rationale. Never leave release-significant ambiguity hidden in prose.

### 8.4 Final sign-off

Product, engineering, accessibility, content safety, privacy, and distribution gates each have named evidence.

**Phase exit:** the workspace definition of done is fully satisfied.

## Dependency Rules

- Behavioral decisions precede test expectations.
- Test seams precede lifecycle hardening.
- Lifecycle and accessibility gates precede external beta expansion.
- Catalog safety review precedes marketing capture.
- Signed archive verification precedes App Store claims.
- Portfolio evidence follows the release candidate; it does not define product truth.

## Task Completion Record

For each task record:

- Roadmap ID and owner role.
- Commit/build under test.
- Automated commands and results.
- Manual environment and result.
- Screenshots/log evidence where relevant.
- Docs updated.
- Follow-up risks or explicit deferrals.

## Whole-Project Done Definition

- Runtime and persistence policies are deterministic and tested.
- macOS integrations degrade safely and pass signed-build checks.
- Golden path is accessible and visually verified.
- Catalog is structurally valid and human-reviewed for safety.
- Release archive, metadata, privacy answers, and screenshots agree.
- No open P0/P1 defect, placeholder release asset, or undocumented critical gap remains.
