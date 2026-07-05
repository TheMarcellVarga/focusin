# Focusin

Focusin is a native SwiftUI macOS menu bar app that recommends short, state-aware micro-breaks and helps users return to focus with one click.

## Portfolio Summary

Focusin is designed as a small but complete macOS product:

- Menu bar-first workflow with a native popover and Settings scene.
- Local recommendation engine backed by a curated activity library.
- Break timers, reminders, quiet hours, launch-at-login, and daily history.
- Distribution-oriented structure with sandboxing, a privacy manifest, and entitlement support; signing, archive validation, and store assets remain release gates.
- Local-only by design: no account, no analytics, and no cloud dependency.

## Release Foundation

The repository already contains several prerequisites for a real release:

- A stable macOS 14+ target.
- Persistent settings and runtime state.
- Notification-based break reminders.
- Launch-at-login support.
- Privacy manifest and sandbox entitlement files for distribution.
- A checked-in Xcode project path for archive and signing.

The app is not yet release-ready. Signed-build integration checks, human catalog sign-off, beta feedback, and App Store assets remain tracked in [`docs/UNFINISHED_SURFACES_AUDIT.md`](docs/UNFINISHED_SURFACES_AUDIT.md).

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

## Planning And Technical Documentation

The repository includes a full product-to-release planning system:

- [`FocusinWorkspacePlan.md`](FocusinWorkspacePlan.md) - consolidated implementation specification and phased outcome.
- [`FocusinMarkdownDocsPlan.md`](FocusinMarkdownDocsPlan.md) - documentation inventory, status vocabulary, and maintenance policy.
- [`AGENTS.md`](AGENTS.md) - contributor operating contract.
- [`docs/PRODUCT_SPEC.md`](docs/PRODUCT_SPEC.md) - users, golden path, requirements, boundaries, and risks.
- [`docs/BEHAVIORAL_CONTRACT.md`](docs/BEHAVIORAL_CONTRACT.md) - named runtime transitions, restoration policy, and exact recovery copy.
- [`docs/CATALOG_CONTENT_CONTRACT.md`](docs/CATALOG_CONTENT_CONTRACT.md) - catalog identity, coverage, editorial, safety, and removal rules.
- [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) - system boundary, components, startup/event flows, and decisions.
- [`docs/STATE_AND_PERSISTENCE.md`](docs/STATE_AND_PERSISTENCE.md) - runtime state machine, storage schema, migration, and recovery.
- [`docs/RECOMMENDATION_SYSTEM.md`](docs/RECOMMENDATION_SYSTEM.md) - activity contract, hard filters, fallback order, and content rules.
- [`docs/PLATFORM_INTEGRATIONS.md`](docs/PLATFORM_INTEGRATIONS.md) - notifications, quiet hours, login item, sandbox, and lifecycle.
- [`docs/DESIGN_SYSTEM.md`](docs/DESIGN_SYSTEM.md) - native UI language, states, components, copy, and accessibility.
- [`docs/SECURITY_PRIVACY_AND_SAFETY.md`](docs/SECURITY_PRIVACY_AND_SAFETY.md) - data inventory, threat model, privacy, and wellness safety.
- [`docs/ENVIRONMENT.md`](docs/ENVIRONMENT.md) - toolchain, commands, project layout, resources, and troubleshooting.
- [`docs/TESTING_STRATEGY.md`](docs/TESTING_STRATEGY.md) - automated/manual layers, matrices, severity, and release gates.
- [`docs/IMPLEMENTATION_PLAN.md`](docs/IMPLEMENTATION_PLAN.md) - phase backlog and task contract.
- [`docs/MASTER_EXECUTION_ROADMAP.md`](docs/MASTER_EXECUTION_ROADMAP.md) - dependency-ordered execution control plane.
- [`docs/UNFINISHED_SURFACES_AUDIT.md`](docs/UNFINISHED_SURFACES_AUDIT.md) - current shipped evidence and ranked gaps.
- [`docs/PHASE_5_EVIDENCE.md`](docs/PHASE_5_EVIDENCE.md) - activity coverage, editorial pre-review, and remaining sign-off gates.
- [`docs/PHASE_6_EVIDENCE.md`](docs/PHASE_6_EVIDENCE.md) - distribution preflight evidence and remaining external gates.
- [`docs/PHASE_7_EVIDENCE.md`](docs/PHASE_7_EVIDENCE.md) - regression, demo, portfolio, and support preparation evidence.
- [`docs/PHASE_8_EVIDENCE.md`](docs/PHASE_8_EVIDENCE.md) - repository scan, reconciliation, gap disposition, and final-sign-off status.
- [`docs/APP_STORE_METADATA.md`](docs/APP_STORE_METADATA.md) - reviewed draft listing, TestFlight, review, and privacy copy.
- [`docs/SUPPORT_AND_ROLLBACK.md`](docs/SUPPORT_AND_ROLLBACK.md) - support triage, stop-ship, hotfix, rollback, and incident procedure.
- [`docs/PRIVACY_POLICY.md`](docs/PRIVACY_POLICY.md) - publishable local-only privacy policy.
- [`docs/SUPPORT.md`](docs/SUPPORT.md) - publishable support guidance awaiting a monitored contact.
- [`docs/RELEASE_NOTES.md`](docs/RELEASE_NOTES.md) - version-aligned product and catalog changes.
- [`docs/RELEASE_AND_DISTRIBUTION.md`](docs/RELEASE_AND_DISTRIBUTION.md) - archive, TestFlight, App Store, and rollback plan.
- [`docs/DEMO_WALKTHROUGH.md`](docs/DEMO_WALKTHROUGH.md) - repeatable release-candidate demo.
- [`docs/PORTFOLIO_CASE_STUDY.md`](docs/PORTFOLIO_CASE_STUDY.md) - evidence-based case-study structure.
- [`docs/BRAND_AND_MEDIA.md`](docs/BRAND_AND_MEDIA.md) - brand position, asset plan, and claim guardrails.
- [`docs/testflight-prep.md`](docs/testflight-prep.md) - concise machine-specific archive checklist.

## Build and Run

### With Xcode

Open `Focusin.xcodeproj`, select the `Focusin` scheme, and run the app normally.

### With the local scripts

This repository includes scripts for local verification:

```sh
./scripts/build-local.sh --run
./scripts/test-local.sh
./scripts/release-preflight.sh
```

Use both local scripts for the repository gates. The build script creates an ad-hoc-signed local bundle; it does not replace signed Release-build verification.

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

No license file is currently included. Unless one is added, the repository does not grant reuse or redistribution rights.
