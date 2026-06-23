# TestFlight Prep

Focusin currently builds locally through `scripts/build-local.sh` because this machine's Command Line Tools SwiftPM install cannot load package manifests. Before TestFlight, create a full Xcode macOS app wrapper that reuses the existing Swift files and resources.

## Xcode Target

- Product: macOS App
- Minimum macOS: 14.0
- Bundle identifier: `com.marcellvarga.focusin`
- Version: `0.1.0`
- Build: `1`
- App category: Productivity
- App mode: menu bar only with `LSUIElement = true`

## Required Resources

Add these to the app target:

- `Sources/Focusin/Resources/Activities.json`
- `Sources/Focusin/Resources/PrivacyInfo.xcprivacy`
- `Sources/Focusin/Resources/Info.plist`
- `Sources/Focusin/Resources/Focusin.entitlements`

## Capabilities

- Enable App Sandbox.
- Keep network access disabled for v1.
- Add launch-at-login support only through `SMAppService`.
- Do not add analytics, account login, or cloud sync in v1.

## Archive Checklist

- Run `./scripts/test-local.sh`.
- Build and launch `./scripts/build-local.sh --run`.
- Confirm fresh launch shows a menu bar item.
- Confirm notification permission flow works.
- Confirm settings persist after relaunch.
- Confirm privacy manifest is included in the archived app.
- Archive from Xcode and upload to App Store Connect for TestFlight.
