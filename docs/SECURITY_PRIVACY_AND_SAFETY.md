# Security, Privacy, And Safety

## Security Posture

Focusin deliberately minimizes its attack surface. It has no network client, server, account, third-party SDK, executable plugin, document import, or user-generated scripting. The principal risks are inaccurate declarations, unsafe bundled content, persistence corruption, and misuse of macOS integrations.

## Data Inventory

Stored locally in `UserDefaults`:

- Reminder and recommendation preferences.
- Selected state and duration.
- Current runtime state and timestamps.
- Same-day activity IDs marked completed, skipped, or seen.

Bundled in the app:

- Activity titles, instructions, classification, and duration metadata.

Not collected:

- Identity, email, contacts, files, browsing, screen contents, keystrokes, location, health data, biometrics, payment data, or device analytics.

## Data Flow

User choices flow from SwiftUI controls to the main-actor store and then to local `UserDefaults`. The only outbound system call with user-visible data is scheduling static notification copy through macOS Notification Center. No product data is transmitted over a network.

## Threat Model

### In scope

- Corrupt or incompatible local payloads causing crashes or bad runtime state.
- Over-broad entitlements creating unnecessary access.
- Third-party dependency compromise (currently minimized by having none).
- Misclassified activity content causing physical discomfort or inappropriate workplace prompts.
- Notification content exposing sensitive inferred state on a shared screen.
- Release artifacts diverging from privacy declarations.

### Out of scope but documented

- An attacker with full access to the user’s macOS account can inspect `UserDefaults`.
- macOS and Apple Developer account compromise are controlled outside the repository.

## Controls

- App Sandbox enabled for distribution.
- No network or sensitive-resource entitlements.
- Codable decoding failures return safe defaults.
- Catalog validates structural invariants before use.
- Notification body does not include the selected emotional/physical state.
- Activity catalog is reviewable source-controlled content.
- Apple system frameworks are preferred over dependencies.

## Wellness Safety Rules

- Describe general wellness breaks, never treatment.
- Do not diagnose anxiety, pain, fatigue, attention conditions, or disability.
- Avoid guaranteed outcomes and medical efficacy claims.
- Physical actions remain low/medium intensity and optional.
- Instructions should allow stopping if uncomfortable.
- Office-safe labeling must account for privacy, space, clothing, sound, and social context.
- Users can skip any recommendation without penalty.

## Privacy Manifest And App Store Answers

Before every release, verify `PrivacyInfo.xcprivacy`, entitlements, linked SDKs, and App Store Connect answers against the binary. The intended version 1 declaration is no data collection and no tracking. This must change if telemetry, crash reporting, remote configuration, or networking is later added.

## Security Review Gates

- Diff entitlements and privacy manifest against the last release.
- Inspect linked libraries and package dependencies.
- Verify no debug logging includes local state/history.
- Test malformed settings and activity payload recovery.
- Review notification copy on a locked/shared screen.
- Review every new activity for content safety.
- Confirm signing identity, hardened runtime, and archive contents.

## Incident Response

For a safety, privacy, or release-integrity issue:

1. Stop distribution or remove the affected build from testing.
2. Document affected versions and conditions.
3. Patch content or code and add a regression test.
4. Reconcile declarations and release notes.
5. Notify testers/users when their action is required.
6. Preserve a concise postmortem in the repository for material incidents.

## Future Change Rule

Any proposal involving networking, analytics, cloud sync, AI, user accounts, or sensitive permissions requires a new data-flow diagram, threat-model update, product justification, user-facing disclosure, and explicit release approval before implementation.

