# TestFlight Prep

Focusin builds locally through `scripts/build-local.sh` because this machine's Command Line Tools SwiftPM install cannot load package manifests. For TestFlight, open the checked-in `Focusin.xcodeproj` and archive the shared `Focusin` scheme.

## Xcode Target

- Project: `Focusin.xcodeproj`
- Scheme: `Focusin`
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
- Open `Focusin.xcodeproj` in Xcode and select the `Focusin` scheme.
- Select the Apple Developer team for automatic signing if Xcode has not already resolved it.
- Build the `Focusin` scheme in Debug.
- Confirm fresh launch shows a menu bar item.
- Confirm notification permission flow works.
- Confirm settings persist after relaunch.
- Confirm privacy manifest is included in the archived app.
- Archive the `Focusin` scheme from Xcode and upload to App Store Connect for TestFlight.
