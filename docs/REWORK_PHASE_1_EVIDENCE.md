# Rework Phase 1 Native Product Polish

## Status

- **Plan:** Focusin Rework and Release Plan
- **Phase:** 1 — Native Product Polish
- **Status:** In progress — implementation and engineering verification complete; named human content owner required
- **Verified:** 2026-07-27
- **Starting baseline:** `045e292`
- **Product version/build:** 0.1.0 (1)

This record covers the portfolio-focused rework plan. It does not replace the repository's original roadmap phase records or represent debug-fixture captures as signed release media.

## Implemented Changes

| Commit | Change |
| --- | --- |
| `f38e114` | Added `Try Again` recovery for catalog load failures, direct Activities-tab recovery for empty recommendations, and deterministic tests. |
| `d754f8f` | Made the Settings window expand for accessibility text sizes. |
| `5710725` | Made the popover expand from its 384-point baseline to 480 points at accessibility text sizes. |
| `2b6ae7d` | Kept all four Settings tabs simultaneously visible at accessibility text sizes. |
| `2f312a8` | Increased the normal Settings height so the Reminder tab no longer clips its final quiet-hours row. |
| `83cec69` | Clarified the stopping points for Shoulder Reset and Window Walk without changing stable IDs or classifications. |

## Recovery Verification

- Catalog failure now explains that focus timers still work and provides `Try Again`.
- Retrying replaces the failed state with a loaded recommendation without changing an active focus timer.
- No eligible activity now provides `Open Break Preferences`.
- The recovery action selects the Activities tab before opening Settings.
- The local focus workflow, Settings, and Quit remain available in both failure states.
- Two deterministic store tests cover retry behavior and direct tab selection.

## Visual Matrix

The checked-in [`evidence/rework-phase-1`](evidence/rework-phase-1) directory contains:

- 24 popover captures: `{light|dark}-{normal|large}-{idle|focusing|break-due|breaking|empty|catalog-error}.png`;
- 16 Settings captures: `{light|dark}-{normal|large}-settings-{reminder|activities|system|feedback}.png`;
- one fresh increased-contrast/reduced-transparency capture: `dark-contrast-transparency-breaking.png`.

The matrix was captured from deterministic debug fixtures after the implementation commits. Contact-sheet and full-resolution inspection confirmed:

- all state, selector, activity, recovery, progress, and action text remains visible;
- the normal 384-point popover stays compact;
- the accessibility-size 480-point popover preserves all header and button labels;
- the 540-by-500-point normal Settings window shows every Reminder row;
- the 840-by-560-point accessibility Settings window keeps all four tabs and form labels visible;
- light and dark appearances preserve hierarchy and semantic status colors;
- increased contrast adds explicit control outlines and reduced transparency produces opaque panels without losing hierarchy.

The host's original dark appearance and disabled contrast/transparency accommodations were restored after capture.

## Icon And Menu Bar Review

- The existing reset-ring app icon was retained after inspection at 16 and 1024 pixels.
- All required macOS 1x/2x slots from 16 through 512 points are present with correct pixel dimensions.
- The unsigned Release preflight compiles both `AppIcon.icns` and `Assets.car`.
- The four runtime symbols — `pause.circle`, `timer`, `bell.badge`, and `figure.mind.and.body` — resolve through AppKit and remain paired with text status, so state does not depend on icon or color alone.
- The menu bar continues to use monochrome SF Symbols rather than a colored raster asset.

This is engineering verification of asset completeness and legibility. Exact-candidate App Store screenshots and release-owner approval remain distribution gates.

## Activity Copy Review

All 21 activities were re-read against the catalog contract for:

- one plain-language action and an observable stopping point;
- conditional movement language and low-risk surroundings;
- realistic office-safety classification;
- non-medical, non-judgmental wording;
- accurate mindfulness and intensity flags.

The engineering review retained all IDs and classifications. It replaced “hold briefly” with a clearer pause-and-release instruction in Shoulder Reset and made the return step explicit in Window Walk. Automated structural and coverage validation still passes.

## Automated Verification

- `swift test`: 49 tests passed with zero failures.
- `./scripts/test-local.sh`: passed; 21 bundled activities validated.
- `./scripts/build-local.sh`: passed; local app built and passed strict ad-hoc signature verification.
- `./scripts/release-preflight.sh`: passed; unsigned Release product integrity and warning policy verified.

These gates must be rerun after the human-owner disposition and before a Phase 1 completion checkpoint.

## Remaining Acceptance Item

The supplied plan requires the content review to have a named human owner. No human owner has been explicitly assigned, so this record does not invent one and Phase 1 is not marked complete.

The owner must provide:

- reviewer name;
- review date;
- reviewed version/build;
- Pass/Fail result and any required copy changes.

After that entry is recorded, rerun the full test/build/preflight gates and create the Phase 1 completion commit.
