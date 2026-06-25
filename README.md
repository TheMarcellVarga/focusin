# Focusin

Focusin is a native SwiftUI macOS menu bar app that recommends short, state-aware micro-breaks and helps users return to focus with one click.

## Portfolio Summary

Focusin is designed as a small but complete macOS product:

- Menu bar-first workflow with a native popover and Settings scene.
- Local recommendation engine backed by a curated activity library.
- Break timers, reminders, quiet hours, launch-at-login, and daily history.
- App Store / TestFlight ready structure with sandboxing, privacy manifest, and entitlement support.
- Local-only by design: no account, no analytics, and no cloud dependency.

## Why It Is Shippable

The app already covers the pieces a real release needs:

- A stable macOS 14+ target.
- Persistent settings and runtime state.
- Notification-based break reminders.
- Launch-at-login support.
- Privacy manifest and sandbox entitlement files for distribution.
- A checked-in Xcode project path for archive and signing.

## What It Does

- Tracks the current focus state: Stiff, Tired, Scattered, Anxious, or Fine.
- Lets the user pick a break length: 30s, 2m, 5m, or 10m.
- Recommends a micro-break from a local activity library.
- Filters recommendations by state, duration, office-safe mode, mindfulness, and daily repeat history.
- Runs focus and break timers from the menu bar.
- Persists preferences locally with `UserDefaults`.
- Schedules gentle macOS reminders when focus time ends.

## Product Notes

The interface is intentionally native macOS rather than web-like:

- Menu bar extra with a compact popover.
- Standard SwiftUI controls and grouped settings panes.
- Native materials, system colors, and SF Symbols.
- Clear empty, error, and active states.

## Tech Stack

- Swift 6
- SwiftUI
- macOS 14 minimum
- Swift Package Manager
- Xcode project for archive and distribution

## Project Structure

- `Sources/Focusin/FocusinApp.swift` - app entry point and menu bar scene.
- `Sources/Focusin/Views.swift` - menu bar popover and settings UI.
- `Sources/Focusin/FocusinStore.swift` - app state, timers, persistence, and reminders.
- `Sources/Focusin/RecommendationEngine.swift` - activity recommendation logic.
- `Sources/Focusin/ActivityLibrary.swift` - local activity loading.
- `Sources/Focusin/Resources/Activities.json` - curated break activity data.
- `Sources/Focusin/Resources/Info.plist` - app metadata for distribution.
- `Sources/Focusin/Resources/PrivacyInfo.xcprivacy` - privacy manifest.
- `Sources/Focusin/Resources/Focusin.entitlements` - sandbox entitlements.

## Build and Run

### With Xcode

Open `Focusin.xcodeproj`, select the `Focusin` scheme, and run the app normally.

### With the local scripts

This repository includes scripts for local verification:

```sh
./scripts/build-local.sh --run
./scripts/test-local.sh
```

On this machine, SwiftPM currently fails while loading package manifests, so the local scripts and direct Swift compiler checks are the reliable verification path.

### With SwiftPM

If your SwiftPM / Xcode install is healthy:

```sh
swift test
swift run Focusin
```

## TestFlight / App Store Path

Use the checked-in Xcode project for archiving and distribution:

1. Open `Focusin.xcodeproj`.
2. Select the shared `Focusin` scheme.
3. Confirm the app target includes the resources in `Sources/Focusin/Resources/`.
4. Archive the app from Xcode.
5. Upload the archive to App Store Connect for TestFlight.

## Manual QA Checklist

- Fresh launch shows Focusin in the macOS menu bar.
- Popover opens from the menu bar item.
- Settings opens from the popover and persists changes after relaunch.
- `Start Focus` begins a focus interval.
- `Take Break` starts the current recommendation immediately.
- `Another` rotates recommendations without marking one completed.
- `Done` records completion and starts the next focus interval.
- `Skip` records a skip and starts the next focus interval.
- Quiet hours suppress notifications.
- Disabling notifications prevents scheduling new break reminders.
- Relaunch restores active focus or break state.
- Quit exits the Focusin process.

## Portfolio Use

Short description for a portfolio page:

> Focusin is a SwiftUI macOS menu bar app that recommends short, state-aware micro-breaks, keeps users in a focused workflow, and ships with TestFlight-ready distribution files.

Suggested talking points:

- Native macOS UI with menu bar, popover, and Settings scene.
- Lightweight product scope with real distribution concerns handled.
- Thoughtful recommendation logic instead of a generic timer.
- Local-first architecture with no backend overhead.

## License

Add your preferred license here if you want to publish the repository publicly.
