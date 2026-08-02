# TestFlight Prep

Focusin builds and tests through SwiftPM, the local app script, and the checked-in Xcode project. For TestFlight, archive the shared `Focusin` scheme with a configured Apple Developer team and valid signing identity.

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
- Select the Apple Developer team for automatic signing in Xcode and ensure `security find-identity -v -p codesigning` reports a valid identity.
- Build the `Focusin` scheme in Debug.
- Confirm fresh launch shows a menu bar item.
- Confirm notification permission flow works.
- Confirm settings persist after relaunch.
- Confirm privacy manifest is included in the archived app.
- From a clean committed tree, run `./scripts/archive-signed-release.sh TEAM_ID` or archive the same Release scheme in Xcode.
- Run `./scripts/verify-signed-archive.sh .build/Focusin.xcarchive` before installing or uploading the candidate.
- Install that archived app at `/Applications/Focusin.app`, run `./scripts/verify-signed-candidate.sh /Applications/Focusin.app`, and complete the signed lifecycle/accessibility matrices.
- Validate and upload the same archive to App Store Connect for TestFlight.
