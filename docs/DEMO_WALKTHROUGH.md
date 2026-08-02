# Demo Walkthrough

## Goal

Demonstrate Focusin’s complete value loop in three to five minutes using only shipped behavior. The demo should emphasize low interaction cost, native integration, local privacy, and lifecycle reliability.

## 30–45 Second Portfolio Cut

Use edited cuts from one exact signed candidate; do not wait through a real focus interval on screen.

| Time | Visual | Narration |
| --- | --- | --- |
| 0–5s | Menu bar → popover | “Break timers tell you when to stop. Focusin also gives you one practical thing to do.” |
| 5–14s | Change state and duration; recommendation updates | “Choose how you feel and how much time you have. The bundled catalog matches state, duration, and preferences locally.” |
| 14–23s | Break due → Start | “At the deadline, Focusin offers the reset even when notifications are unavailable.” |
| 23–31s | Active break → Done | “Complete or skip it, and the next focus interval starts immediately.” |
| 31–39s | Reminder and Activities Settings | “Quiet hours, office-safe activities, and reminders stay under the user’s control.” |
| 39–45s | Menu bar status plus privacy card/title | “No account, analytics, network dependency, or generated wellness advice.” |

End on the product, not a documentation or test-count screen.

## Preparation

- Use the exact release-candidate build.
- Reset preferences or prepare a documented demo fixture.
- Set a short/custom interval suitable for demonstration.
- Enable menu bar text and notifications.
- Choose a visually clear state/duration combination.
- Remove unrelated personal notification/menu bar content from capture.
- Verify the activity shown is safe and representative.

## Script

### 1. Problem and positioning — 20 seconds

“Break timers tell you when to stop, but usually leave you deciding what to do. Focusin asks how you feel and how much time you have, then suggests one small reset. Everything stays on the Mac.”

### 2. Menu bar workflow — 35 seconds

Open the popover. Point out the current focus status, compact native layout, state selector, duration selector, and one recommendation. Avoid touring every setting before showing value.

### 3. State-aware recommendation — 40 seconds

Switch between Stiff and Scattered, then between 30 seconds and 2 minutes. Show that the suggestion adapts. Use Another to demonstrate same-day variety and mention that explicit office-safe/mindfulness preferences remain hard filters.

### 4. Focus-to-break transition — 45 seconds

Show focus running, then use a prepared short interval or controlled fixture to reach break due. Show the system notification and menu bar/status change. State that the app also recognizes elapsed time if notifications are disabled.

### 5. Active break — 35 seconds

Start the recommendation. Show persisted activity instructions, progress, countdown, Done, and Skip. Choose Done and show the next focus interval begin automatically.

### 6. Control and privacy — 45 seconds

Open Settings. Briefly show work interval, quiet hours, office-safe/mindfulness filters, menu bar text, and launch at login. Explain that settings and same-day history use local preferences, with no account, analytics, or network requirement.

### 7. Engineering close — 30 seconds

Summarize the date-derived persisted state machine, validated bundled catalog, ordered fallback algorithm, platform adapters, and TestFlight/App Store structure.

## Evidence To Capture

- Popover in a clear focus state.
- Recommendation changing with state or duration.
- Break-due notification and status.
- Active break progress.
- Settings control surface.
- Optional relaunch during a break to prove restoration.

For every capture, retain a manifest containing the app version/build, full commit SHA, macOS version, appearance/accessibility settings, capture filename, and whether a debug fixture was used. Store release evidence under a version/build-specific directory; do not mix Phase 3 fixture captures with release-candidate media.

Use [`CASE_STUDY_CAPTURE_MANIFEST.md`](CASE_STUDY_CAPTURE_MANIFEST.md) as the exact-candidate inventory and sign-off record.

## Demo Guardrails

- Do not claim scientific validation, treatment, AI, cloud sync, or behavioral analytics.
- Do not hide permission or login-item recovery states when they are relevant to the demonstrated path.
- Do not use a debug-only flow without labeling it.
- Do not stage screenshots from a UI version different from the candidate.
- If a system integration fails during the demo, explain the exact permission/environment state rather than masking it.

## Success Criteria

The audience can explain who the product is for, complete the focus/break loop, understand why the recommendation differs from a generic timer, and identify the privacy/architecture constraint within five minutes.
