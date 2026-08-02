# Rework Phase 4 Signed Distribution

## Status

- **Plan:** Focusin Rework and Release Plan
- **Phase:** 4 — Signed Distribution
- **Status:** Blocked — local distribution tooling and unsigned integrity pass; Apple signing and external release inputs unavailable
- **Verified:** 2026-08-02
- **Starting baseline:** `b8ba05d`
- **Product version/build:** 0.1.0 (1)

This record covers the portfolio-focused rework plan. It does not describe an unsigned or ad-hoc-signed app as a signed archive, installable external beta, or App Store candidate.

## Implemented Changes

| Commit | Change |
| --- | --- |
| `411638e` | Added a repeatable clean-tree signed archive workflow with explicit team, valid-identity, no-overwrite, and pre-archive gate requirements. |
| `c17965a` | Added strict signed-archive inspection and archive-side commit/build-environment provenance. |

## Distribution Workflow

`scripts/archive-signed-release.sh TEAM_ID [archive-path]`:

- rejects an invalid team identifier, dirty working tree, missing keychain identity, or existing target archive;
- runs local typecheck/catalog validation, all Swift tests, and unsigned Release preflight;
- archives the shared Release scheme using the explicit Apple Developer team;
- writes archive-side metadata for the full Git commit, team, UTC creation time, Xcode, Swift, macOS, and architecture;
- leaves existing archives untouched rather than deleting or overwriting them.

`scripts/verify-signed-archive.sh /path/to/Focusin.xcarchive`:

- performs strict deep code-signature verification;
- requires a named authority and team, rejecting ad-hoc signing;
- requires App Sandbox and rejects network, camera, microphone, personal-information, HealthKit, and debug entitlements;
- verifies the catalog, privacy manifest, app icon, compiled assets, identifier, minimum macOS, and menu-bar-only metadata;
- verifies the no-tracking/no-data-collected privacy declaration;
- requires archive provenance to match the current full Git commit and signing team;
- prints the exact version/build and build environment for the retained release record.

The existing `scripts/verify-signed-candidate.sh` remains the installed `/Applications/Focusin.app` gate before lifecycle, login-item, notification, and accessibility testing.

## Automated Verification

Verified on 2026-08-02 after commit `c17965ac152e399284217a2f6242624e00df92de`:

- all release/distribution shell scripts passed `zsh -n` syntax validation;
- archive and archive-inspection usage/refusal paths returned the expected non-success results;
- the clean-tree archive workflow stopped with “No valid Apple code-signing identity is available in the keychain” before creating an archive;
- `swift test`: 54 tests passed with zero failures;
- `./scripts/test-local.sh`: passed; all app sources typechecked and 21 activities validated;
- `./scripts/build-local.sh`: passed; the local app built and passed strict ad-hoc signature verification;
- `./scripts/release-preflight.sh`: passed; unsigned Release resources, privacy, entitlements, icon compilation, metadata, and warning policy were verified.

## Verification Environment

| Field | Value |
| --- | --- |
| Xcode | 26.6 (17F113) |
| Swift | 6.3.3 |
| macOS | 26.5.2 (25F84) |
| Hardware | arm64 Apple silicon |
| Signing identities | `0 valid identities found` |
| Development team | Not configured in the Xcode project |

## External Distribution Gates

No signed archive or installed signed candidate exists. The following remain open:

1. configure the Apple development team and a valid distribution identity;
2. create and pass inspection of the signed archive;
3. install the same candidate and pass notification, login-item, lifecycle, and accessibility matrices;
4. assign a monitored support contact and accountable release owner;
5. publish the prepared support and privacy pages and record their public URLs;
6. record copyright and reviewer contact details;
7. capture App Store screenshots from the exact submitted build and obtain final icon approval;
8. create the App Store Connect record and confirm privacy/export-compliance answers against the archive;
9. upload and install a TestFlight beta, complete the anonymous cohort, and close all P0/P1 findings;
10. verify upgrade behavior from a prior signed beta.

## Exit Decision

Phase 4 remains blocked. Repository-side archive creation, inspection, integrity checks, metadata drafts, beta protocol, and rollback preparation are ready, but the acceptance gate requires a validated signed archive, live support/privacy presence, exact-build store assets, and an externally installable beta.
