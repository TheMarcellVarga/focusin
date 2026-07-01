# Development Environment

## Supported Baseline

- macOS capable of running macOS 14 SDK applications.
- Xcode with Swift 5.9+ / Swift 6-compatible compiler.
- Apple Developer account only for signing, TestFlight, and App Store workflows.
- No external package dependencies or services.

## Repository Shape

```text
Focusin.xcodeproj/               archive/signing project
Package.swift                    SwiftPM executable and test definition
Sources/Focusin/                 application source
Sources/Focusin/Resources/       catalog, plist, privacy, entitlements
Tests/FocusinTests/              XCTest domain tests
scripts/                         local build/test helpers
docs/                            product and engineering control plane
```

## Common Commands

```sh
./scripts/test-local.sh
./scripts/build-local.sh
./scripts/build-local.sh --run
swift test
swift run Focusin
```

The checked-in scripts are the repository-supported fallback when the local Command Line Tools SwiftPM installation cannot load manifests. Xcode remains authoritative for archive, signing, capabilities, resource membership, and distribution.

## First Run

1. Open `Focusin.xcodeproj`.
2. Select the `Focusin` scheme and My Mac destination.
3. Resolve signing only if platform features under test require it.
4. Run and locate the Focusin icon in the menu bar; there is no Dock icon.
5. Exercise notification permission and Settings persistence.

## Resource Requirements

The application target must include:

- `Activities.json`.
- `Info.plist`.
- `PrivacyInfo.xcprivacy`.
- `Focusin.entitlements`.

A build that compiles but omits one of these is not release-valid. The SwiftPM resource bundle and Xcode app target must both be verified after project changes.

## Configuration

Focusin has no `.env` files, API keys, secrets, remote services, build-time feature flags, or environment-specific endpoints. Version, build number, bundle identifier, team, signing, and distribution settings live in the Xcode project/App Store workflow.

## Troubleshooting

### No visible window

Expected: Focusin is a menu bar agent. Look for the status icon rather than a Dock icon.

### Activity library unavailable

Confirm `Activities.json` is copied into the relevant bundle and passes decoding/validation.

### Notifications do not appear

Check app preference, macOS authorization, quiet hours, current runtime state, and pending notification requests. The in-app state should still become break due.

### Launch at login fails

Test a correctly signed application installed in `/Applications`, inspect `SMAppService.mainApp.status`, and do not use an assertion as the only diagnostic.

### SwiftPM manifest failure

Confirm `xcode-select`, `swift --version`, and SDK compatibility. Use checked-in scripts or Xcode while repairing the toolchain; record environment-specific limitations rather than changing app behavior to accommodate a broken toolchain.

## Repository Hygiene

- Do not commit `.DS_Store`, derived data, archives, signing certificates, provisioning profiles, or local IDE state.
- Keep resources source-controlled and human-reviewable.
- Update project and package definitions together when source/resource membership changes.
- Keep build warnings at zero for release candidates.

