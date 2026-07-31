# Rework Phase 3 Accessibility And Beta

## Status

- **Plan:** Focusin Rework and Release Plan
- **Phase:** 3 — Accessibility and Beta
- **Status:** In progress — local accessibility remediation and beta preparation complete; exact-candidate VoiceOver and human beta evidence required
- **Verified:** 2026-08-01
- **Starting baseline:** `14c8e82`
- **Product version/build:** 0.1.0 (1)

This record covers the portfolio-focused rework plan. It does not turn earlier debug-fixture inspection or an ad-hoc-signed build into signed release-candidate evidence, and it does not invent tester responses.

## Implemented Changes

| Commit | Change |
| --- | --- |
| `a0b6425` | Replaced the changing break-progress accessibility value with stable “In progress” semantics and made picker group labels explicit. |
| `a890aef` | Added a versioned, privacy-minimizing beta packet with three task scenarios, copy confirmation, deterministic tests, and a 5–8 tester plan. |
| `be0bcd7` | Replaced unnamed grouped-Form action nodes with native AppKit buttons exposing explicit AX titles and standard press actions. |
| `9b4ce33` | Kept the repository's explicit local typecheck source list aligned with the Xcode and SwiftPM builds. |

## Accessibility Verification

The earlier native experience matrix remains recorded in [`PHASE_3_EVIDENCE.md`](PHASE_3_EVIDENCE.md), and the current large-text/appearance matrix remains in [`REWORK_PHASE_1_EVIDENCE.md`](REWORK_PHASE_1_EVIDENCE.md).

Fresh manual inspection on 2026-08-01 used the isolated idle debug fixture in the ad-hoc local build:

- Settings opened through the keyboard and the Feedback tab was selected through its named toolbar button.
- Grouped SwiftUI Form actions were found to expose unnamed `AXButton` nodes on macOS 26.5.2.
- Notification/login-item recovery and feedback actions were moved to native AppKit buttons.
- Accessibility hierarchy inspection then exposed `Copy Feedback Notes` and `Try Again` as named, enabled AX buttons with the standard press action.
- Activating `Copy Feedback Notes` produced the visible and accessible “Feedback notes copied to clipboard” confirmation.
- The copied packet identified version/build 0.1.0 (1), contained exactly three task scenarios, requested keyboard/VoiceOver feedback, and warned against including personal or private work information.
- No explicit animation, transition, symbol-effect, or sensory-feedback API is used, so Reduce Motion does not remove information or alter the layout.

The complete VoiceOver golden path has not been rerun on an exact signed candidate. That human verification remains open even though the AX hierarchy and earlier VoiceOver/keyboard evidence pass.

## Beta Readiness

[`BETA_TEST_PLAN.md`](BETA_TEST_PLAN.md) defines:

- a 5–8 person anonymous cohort;
- three task-based scenarios covering the core loop, restoration, and controls;
- optional normal assistive-technology use without requesting disability disclosure;
- build/macOS-specific evidence fields;
- P0–P3 triage, stop-expansion rules, retest requirements, and documented deferrals;
- a prohibition on synthetic responses and satisfaction percentages.

No tester has been recorded. Rows T01–T05 remain pending, so no beta conclusion or metric is claimed.

## Automated Verification

Verified on 2026-08-01 after commit `9b4ce337c73156d8b81aafc15cfd79bbf68acd55`:

- `swift test`: 54 tests passed with zero failures.
- `./scripts/test-local.sh`: passed; all app sources typechecked and 21 bundled activities validated.
- `./scripts/build-local.sh`: passed; the local app built and passed strict ad-hoc signature verification.
- `./scripts/release-preflight.sh`: passed; unsigned Release product integrity and warning policy verified.

## Open Acceptance Items

1. Configure signing and produce the exact external beta candidate.
2. Run the complete golden path with VoiceOver and keyboard-only input on that candidate.
3. Recruit 5–8 real testers and record anonymous results for all three scenarios.
4. Fix and retest every P0/P1 issue; document the rationale for deferred P2/P3 feedback.
5. Rerun all automated and accessibility gates against the final tested commit.

## Exit Decision

Phase 3 remains in progress. No locally observed P0/P1 accessibility blocker remains, but the phase cannot complete without exact-candidate VoiceOver evidence and real anonymous beta feedback from the required cohort.
