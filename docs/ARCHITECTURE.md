# Architecture

## System Boundary

Focusin is a single-process, sandboxed macOS application. The executable, bundled activity catalog, local preferences, notification center, and login-item service form the complete version 1 system. There is no server or runtime network dependency.

## Component Map

```text
MenuBarExtra / Settings
          |
          v
    FocusinStore  <------ 1-second UI ticker
     /    |    \
    v     v     v
Engine Persistence NotificationScheduler
  |         |              |
JSON     UserDefaults   macOS Notification Center

FocusinStore ----------> LaunchAtLoginController
                              |
                         SMAppService
```

## Component Responsibilities

### `FocusinApp`

- Creates the sole `FocusinStore` as a `StateObject`.
- Defines `MenuBarExtra` and Settings scenes.
- Selects menu bar icon and optional text from observable state.
- Does not contain business rules.

### Views

- Render observable state and dispatch user intent.
- Own no durable state beyond view presentation.
- Use native SwiftUI materials, controls, and settings structure.
- May bridge to AppKit for application termination and clipboard behavior.

### `FocusinStore`

- Main-actor application coordinator and single mutable domain-state owner.
- Loads persistence and catalog data at startup.
- Drives state transitions, recommendations, history, and reminders.
- Derives status copy and timer presentation.
- Restores expired focus and break states after relaunch.

### `RecommendationEngine`

- Pure, stateless selector over an activity collection and request.
- Applies hard eligibility filters before ordered fallback passes.
- Contains no persistence, UI, time, or platform calls.

### `ActivityLibrary`

- Loads and decodes bundled JSON.
- Validates uniqueness and minimum state fallback coverage.
- Fails closed to a visible UI error rather than partial catalog behavior.

### `FocusinPersistence`

- Encodes structured values in `UserDefaults`.
- Supplies safe defaults when values are absent or corrupt.
- Supports the legacy daily-history and reminder-start keys.
- Keeps persistence mechanics out of views and domain selection.

### Platform adapters

- `NotificationScheduler` owns authorization, one reminder identifier, delivery, and response activation.
- `LaunchAtLoginController` reconciles the preference with `SMAppService.mainApp`.

## Startup Flow

1. Construct persistence and load normalized settings.
2. Load selected state, selected duration, same-day history, and runtime state.
3. Load and validate the activity catalog.
4. Produce an initial recommendation or a library error.
5. Request notification authorization when enabled.
6. Attach the notification-open callback.
7. Start the display ticker and restore runtime deadlines.
8. If idle and configured, start the first focus interval; otherwise reconcile the reminder.

## Event Flow

User actions mutate the store synchronously on the main actor. `didSet` observers persist settings, selection, and runtime state. A one-second timer refreshes display countdowns, checks wall-clock deadlines, and resets daily history. Platform notification delivery is supplemental; the store independently recognizes an elapsed interval.

## Architectural Decisions

- One observable store is appropriate for the small graph and prevents split lifecycle truth.
- Persist deadlines, not countdown integers, to survive process suspension and timer coalescing.
- Keep the catalog bundled to preserve privacy, offline operation, and reviewable content.
- Use hard filters for explicit user preferences; only relevance and novelty may relax.
- Use Apple frameworks directly to minimize supply-chain and binary-size risk.

## Constraints And Known Tradeoffs

- `UserDefaults` is sufficient for compact preferences/history but not long-term event analytics.
- Random selection improves variety but requires injected randomness or candidate-set assertions for fully deterministic tests.
- Store construction performs reconciliation through injected persistence, notification, login-item, catalog, clock, and calendar boundaries; tests use deterministic adapters while production construction supplies Apple-framework implementations.
- A main-thread ticker is acceptable at this scale but must never be the source of elapsed-time truth.

## Non-Goals

- Client/server architecture, database, API, authentication, or sync.
- Plugin ecosystem or remote catalog updates.
- Background daemon that evades macOS lifecycle controls.
- General-purpose task or calendar management.

## Evolution Triggers

Introduce a stronger abstraction only when evidence requires it:

- Split the main store only if product complexity creates independently evolving state graphs or the existing injected boundaries stop providing clear deterministic tests.
- File or database storage only when durable longitudinal history becomes an approved feature.
- Shared package targets only when another Apple-platform client is scheduled.
- Network layer only after an explicit privacy and entitlement review.
