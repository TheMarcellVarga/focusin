# Phase 6 Evidence

## Status

Phase 6 is in progress under an owner-authorized sequencing exception. Phases 4 and 5 remain incomplete, and this work does not waive their gates.

## 6.1 Project Integrity

Verified on 2026-07-03 using Xcode 26.6 on macOS 26.5.1 (Apple silicon):

- Shared `Focusin` scheme and Debug/Release configurations exist.
- Product identifier is `com.marcellvarga.focusin`; version/build is 0.1.0 (1).
- Deployment target is macOS 14.0 and Swift language mode is 6.
- Final `Info.plist` identifies a Productivity-category menu bar agent with `LSUIElement = true`.
- The Release product contains `Activities.json` and `PrivacyInfo.xcprivacy`.
- The privacy manifest declares no tracking, collected data, accessed API categories, or tracking domains.
- The only entitlement is App Sandbox; no network or sensitive-resource entitlement is present.
- An unsigned Release build succeeded. The only warning was Xcode’s metadata tool reporting that extraction was skipped because the app does not link AppIntents; this is expected for a target with no App Intents.
- `scripts/release-preflight.sh` reproduces the unsigned product-integrity inspection and fails on unexpected build warnings, missing compiled app-icon assets, or resource/metadata drift.

Project integrity is locally verified.

## 6.2 Signing And Archive

Blocked. `security find-identity -v -p codesigning` reports zero valid identities and the project has no development team. No signed archive, Apple validation, notarization/distribution inspection, or retained signed-build evidence exists. `scripts/verify-signed-candidate.sh` is ready to reject ad-hoc or incorrectly installed candidates and print the exact version, authority, team, commit, macOS, and hardware evidence once a signed build exists.

## 6.3 Store Presence

Draft listing copy, TestFlight instructions, review notes, and conditional privacy answers are recorded in `APP_STORE_METADATA.md`.

Open inputs:

- Final human brand approval of the source-controlled production icon.
- Exact-build App Store screenshots.
- Publication of the prepared support/privacy pages and assignment of a monitored support contact.
- Copyright and reviewer contact.
- App Store Connect entry and final privacy answers verified against the signed archive.

## 6.4 TestFlight Cohort

Not started. `BETA_TEST_PLAN.md` defines the anonymous cohort, task scenarios, evidence fields, and triage rules. A signed uploaded build, App Store Connect access, 5–8 real testers, version notes, feedback record, and P0/P1 triage are still required.

## 6.5 Upgrade Verification

Not started. This requires a prior signed beta and a current signed candidate installed in sequence.

## Exit Decision

Phase 6 remains in progress. It cannot exit until the signed archive validates, store presence is complete, an external beta has no open P0/P1 issue, and upgrade verification passes.
