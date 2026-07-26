# Rework Phase 0 Release Baseline

## Status

- **Plan:** Focusin Rework and Release Plan
- **Phase:** 0 — Release Baseline
- **Status:** Complete
- **Verified:** 2026-07-27
- **Source baseline:** `cc2a997`
- **Release-claim correction:** `8fcdc9f`
- **Product version/build:** 0.1.0 (1)

This record is the entry gate for the portfolio-focused rework plan. It does not replace the repository's original roadmap phase records, and it does not represent an unsigned build as a release candidate.

## Environment

- macOS 26.5.2 (25F84)
- Xcode 26.6 (17F113)
- Apple Swift 6.3.3
- Apple M3 Pro, arm64
- MacBook Pro (Mac15,6), 36 GB memory

Machine identifiers, signing material, and other local secrets are intentionally excluded from repository evidence.

## Automated Verification

| Check | Result | Evidence |
| --- | --- | --- |
| `./scripts/test-local.sh` | Pass | 21 bundled activities decoded and validated. |
| `./scripts/build-local.sh` | Pass | Local arm64 app bundle built, ad-hoc signed, and passed strict signature verification. |
| `./scripts/release-preflight.sh` | Pass | Unsigned Release product integrity, resources, metadata, privacy manifest, entitlements, icon compilation, and warning policy passed. |
| `swift test` | Pass | 47 tests passed with zero failures. |
| Unsigned Xcode Debug build | Pass | Build completed with no product-code warning. |
| Unsigned Xcode Release build | Pass | Covered by release preflight with no product-code warning. |

Both Xcode configurations emit the expected metadata-tool notice that App Intents extraction was skipped because Focusin does not link `AppIntents.framework`. Focusin has no App Intents feature, so this is not treated as a product warning.

## Repository Hygiene

- No derived data, local build output, `.DS_Store`, SwiftPM state, or user-specific Xcode state is tracked.
- `.gitignore` covers `.build/`, `.build-local/`, `.swiftpm/`, `DerivedData/`, `.DS_Store`, `.vscode/`, `*.xcuserdata`, and `*.xcuserstate`.
- Local ignored `.build/`, `.build-local/`, and `.DS_Store` entries were present during verification and remained untracked.
- The app icon set contains the required 16, 32, 128, 256, 512, and 1024 pixel representations with matching 1x/2x slots.

## Release-Claim Reconciliation

README now describes the repository as an unsigned, locally verified distribution foundation. It explicitly leaves signed archive and TestFlight verification open. No repository claim treats the local ad-hoc build, the unsigned Release preflight, or the debug screenshots as signed-release evidence.

## Pre-Polish Visual Baseline

Fresh window-only captures were made from deterministic debug fixtures on the source baseline after the automated gates passed:

- [`idle.png`](evidence/rework-phase-0/idle.png)
- [`focusing.png`](evidence/rework-phase-0/focusing.png)
- [`break-due.png`](evidence/rework-phase-0/break-due.png)
- [`breaking.png`](evidence/rework-phase-0/breaking.png)
- [`empty.png`](evidence/rework-phase-0/empty.png)
- [`catalog-error.png`](evidence/rework-phase-0/catalog-error.png)

These dark-appearance captures are comparison evidence for Phase 1. They are not App Store screenshots and do not replace Phase 1 checks at large text, light appearance, increased contrast, or reduced transparency.

## Baseline Findings Routed Forward

- The catalog-error card explains the failure and leaves the local focus timer usable, but it has no explicit catalog recovery action. Phase 1 must add and verify an actionable recovery path.
- Final icon approval remains a named Phase 1 gate even though all required icon sizes are present and compile successfully.
- A named human content-review owner is still unassigned. Phase 1 cannot pass its content gate until that owner reviews clarity, safety, and office suitability.
- Signed-build lifecycle verification, archive validation, beta evidence, and store submission remain later-phase gates.

## Phase Exit Decision

Phase 0 passes:

- all current automated tests pass;
- local Debug and unsigned Release builds pass;
- no unexpected build warning was found;
- build output and machine files remain untracked;
- README no longer implies signed release verification;
- the current six-state visual baseline is retained;
- newly observed polish gaps are explicitly routed to Phase 1.

