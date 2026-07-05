# Release And Distribution

## Release Target

- Product: sandboxed macOS menu bar application.
- Minimum system: macOS 14.
- Bundle identifier: `com.marcellvarga.focusin` (verify before release).
- Primary channel: App Store Connect/TestFlight, then App Store.
- Archive authority: checked-in Xcode project and shared `Focusin` scheme.

## Preflight

- Working tree and release commit are identified.
- Automated tests and local release build pass without warnings.
- Version and build number are incremented intentionally.
- Product name, identifier, category, deployment target, and signing team are correct.
- All source/resource target memberships are correct.
- Privacy manifest and entitlements match actual binary behavior.
- Production icon replaces placeholders.
- P0/P1 audit items are closed or distribution is stopped.

## Required Archive Contents

- Executable and final `Info.plist`.
- `Activities.json` with validated release content.
- `PrivacyInfo.xcprivacy`.
- App Sandbox entitlement and no unnecessary sensitive/network entitlement.
- Complete app icon assets.
- Correct version/build metadata and hardened signing.

## TestFlight Sequence

1. Archive the Release scheme from a clean Xcode environment.
2. Install the candidate at `/Applications/Focusin.app`, run `./scripts/verify-signed-candidate.sh /Applications/Focusin.app`, then validate the archive and inspect signing/entitlements/resources.
3. Upload with a unique build number.
4. Complete export-compliance and privacy questions accurately.
5. Run internal tester smoke checks.
6. Add concise “What to Test” notes covering reminder usefulness, recommendation specificity, context fit, and permanent menu-bar value.
7. Expand to a small external cohort only after P0/P1 triage.
8. Record feedback against the exact build.

## Manual Release Matrix

- Clean install with notification allowed and denied.
- Upgrade over previous beta.
- Auto-start on/off and launch-at-login on/off.
- Menu bar text on/off.
- Same-day and overnight quiet hours.
- Relaunch during focus and break.
- Sleep across focus/break expiry.
- Light/dark, VoiceOver, Full Keyboard Access, increased contrast.
- At least the oldest and newest supported macOS versions available for testing.

## App Store Metadata

- Name, subtitle, description, keywords, category, age rating.
- Support and privacy-policy URLs.
- Screenshots generated from the submitted build.
- No-data-collected privacy answers, provided that binary inspection confirms them.
- Review notes explaining menu bar-only behavior, notifications, and launch-at-login.
- Contact path for reviewer questions.

## Rollout And Monitoring

Without analytics, monitoring relies on App Store crash/diagnostic channels, TestFlight feedback, support contact, and direct tester reports. Start with a controlled release where available. Track build number, issue severity, reproduction environment, and resolution.

## Stop-Ship Conditions

- Launch or persistent crash.
- Incorrect/incompatible runtime restoration.
- Unsafe catalog instruction or misleading medical claim.
- Privacy/entitlement declaration mismatch.
- Broken notification-denied golden path.
- Signing, archive, or login-item defect affecting normal use.
- Critical accessibility blocker without a viable path.

## Hotfix And Rollback

1. Identify affected version/build and scope.
2. Pause staged release or external testing where possible.
3. Reproduce and add regression coverage.
4. Apply the smallest safe fix, increment build/version, and rerun full release gates.
5. Update metadata/privacy declarations if behavior changed.
6. Communicate required user action and known limitations.

## Release Record Template

- Version/build and commit:
- Xcode/Swift/macOS build environment:
- Automated test result:
- Manual matrix result:
- Archive validation result:
- Entitlement/privacy inspection:
- Open known issues:
- TestFlight/App Store status:
- Approver and date:
