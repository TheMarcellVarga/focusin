# Phase 8 Evidence

## Status

Phase 8 is in progress under an owner-authorized sequencing exception. The locally actionable no-placeholder pass is complete. Final sign-off remains blocked by the same external evidence preventing Phases 4–7 from exiting.

## 8.1 Repository Scan

Scanned source, tests, scripts, project configuration, resources, and documentation for TODO/FIXME markers, placeholder/sample copy, stale claims, dead compatibility paths, `.DS_Store`, editor state, build warnings, and untracked release resources.

Resolved:

- Removed three `.DS_Store` files and added `.vscode/` to `.gitignore`; removed the tracked empty VS Code settings file.
- Reconciled stale 20-item catalog claims to the current validated 21-item catalog.
- Replaced the obsolete architecture claim that injectable platform boundaries were only planned.
- Updated the local build bundle to compile the source-controlled app icon into `AppIcon.icns`.
- Tightened the fallback local catalog harness to require at least 21 activities.

The Xcode Release build emits one tool-generated notice classified as a warning: App Intents metadata extraction is skipped because Focusin does not link AppIntents. The preflight permits only that exact warning and fails on any other warning.

## Compatibility Disposition

The legacy daily-history and reminder-start reads are not dead code. They are covered by persistence fixtures and remain required for backward-compatible `UserDefaults` payloads. The reminder-start save helper is retained solely to construct a legacy fixture. Removal is prohibited until a released migration window has elapsed and Phase 6.5 verifies upgrade behavior.

## 8.2 Documentation Reconciliation

Current docs distinguish implemented local behavior from signed/manual/external evidence. Version remains 0.1.0 (1), deployment target remains macOS 14, the catalog contains 21 activities, and privacy claims match the no-network entitlement and local persistence implementation.

Phase 3 images remain labeled debug-fixture evidence. No existing screenshot is represented as an App Store or exact signed-candidate capture.

## 8.3 Remaining Gap Disposition

No local placeholder implementation or untracked release resource remains known. Open release-significant gaps are explicit:

- Phase 4: signed lifecycle/manual matrix.
- Phase 5: named human catalog approval and build-specific beta feedback.
- Phase 6: signing/archive validation, published URLs/contact, final icon approval, exact-build screenshots, App Store Connect/TestFlight, and upgrade verification.
- Phase 7: exact-candidate regression/media/outcome evidence and accountable support ownership.

These are external evidence gates, not local code placeholders. Candidate-after-v1 ideas remain listed as non-commitments in `UNFINISHED_SURFACES_AUDIT.md`.

## 8.4 Final Sign-off

Not complete. Product, engineering, accessibility, content safety, privacy, and distribution sign-offs must name an approver and reference one exact signed release build. No such build exists yet.

## Exit Decision

Phase 8 remains in progress. The workspace is locally reconciled, but the whole-project definition of done cannot be satisfied until the external P1 gates and named final sign-offs are complete.
