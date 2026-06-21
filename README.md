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

```sh
swift test
swift run Focusin
```

On this machine, Apple Command Line Tools report Swift 6.3.1 but SwiftPM cannot load even a freshly generated package manifest. The source has been verified with direct Swift 6 compiler type-checking and an ad hoc compiled test harness.

## App Store Notes

For TestFlight/App Store submission, open or wrap the package in a full Xcode macOS app target and apply:

- `Sources/Focusin/Resources/Focusin.entitlements`
- `Sources/Focusin/Resources/PrivacyInfo.xcprivacy`
- `Sources/Focusin/Resources/Info.plist`

The app is local-only in v1: no account, no analytics, no network requirement.
