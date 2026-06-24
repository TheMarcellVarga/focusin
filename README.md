# Focusin

Focusin is a native SwiftUI macOS menu bar app for state-based micro-break recommendations.

## What is implemented

- Menu bar app shell using `MenuBarExtra`.
- State chips: Stiff, Tired, Scattered, Anxious, Fine.
- Duration chips: 30s, 2m, 5m, 10m.
- Curated local activity library in `Sources/Focusin/Resources/Activities.json`.
- Recommendation filtering by state, duration, office-safe mode, mindfulness, and daily repeat history.
- Break timer actions: Start, Another, Done, Skip.
- Settings window for interval presets, custom interval, default break length, quiet hours, launch at login, office-safe mode, and mindfulness.
- Gentle macOS notifications for break reminders.
- Local persistence with `UserDefaults`.
- App Store support assets: sandbox entitlement and privacy manifest.

## Development

The project is set up as a Swift Package with a macOS 14 minimum target.

### Run without Xcode or SwiftPM

This machine's SwiftPM currently fails while loading package manifests. Use the direct local builder:

```sh
./scripts/build-local.sh --run
```

Focusin is a menu bar app, so look for it in the macOS top bar rather than expecting a normal app window.

To verify the app without SwiftPM:

```sh
./scripts/test-local.sh
```

### Run with a working SwiftPM/Xcode install

If SwiftPM is working:

```sh
swift test
swift run Focusin
```

On this machine, Apple Command Line Tools report Swift 6.3.1 but SwiftPM cannot load even a freshly generated package manifest. The source has been verified with direct Swift 6 compiler type-checking, a direct local app build, and an ad hoc compiled test harness.

## App Store Notes

For TestFlight/App Store submission, open `Focusin.xcodeproj` and archive the `Focusin` scheme. The checked-in Xcode target reuses the existing Swift files and applies:

- `Sources/Focusin/Resources/Focusin.entitlements`
- `Sources/Focusin/Resources/PrivacyInfo.xcprivacy`
- `Sources/Focusin/Resources/Info.plist`

The app is local-only in v1: no account, no analytics, no network requirement.

## Manual QA Checklist

- Fresh launch shows Focusin in the macOS menu bar.
- Popover opens from the menu bar item.
- Settings opens from the popover and persists changes after relaunch.
- `Start Focus` begins a focus interval.
- `Take Break Now` starts the current recommendation immediately.
- `Another` rotates recommendations without marking one completed.
- `Done` records completion and starts the next focus interval.
- `Skip` records a skip and starts the next focus interval.
- Quiet hours suppress notifications.
- Disabling notifications prevents scheduling new break reminders.
- Relaunch restores active focus or break state.
- Quit exits the Focusin process.
