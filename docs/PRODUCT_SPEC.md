# Product Specification

## Product Statement

Focusin is a macOS menu bar companion that turns a quick self-check into a short, practical break and then returns the user to focus.

## Problem

Desk workers often notice discomfort, fatigue, scattered attention, or anxiety only after performance has degraded. Existing timers can signal that a break is due but usually make the user decide what to do. That decision cost makes dismissing the reminder easier than acting on it.

## Target Users

### Primary

- Individual knowledge workers who spend long periods at a Mac.
- Students and independent creators who want lightweight structure.
- Users who prefer private, local utilities over account-based wellness products.

### Secondary

- Remote workers with inconsistent break habits.
- People who find full Pomodoro/task systems too heavy.

## Jobs To Be Done

- When I lose track of time, remind me to reset without taking over my screen.
- When I have little time, give me one concrete action that fits it.
- When my body or attention feels off, adapt the suggestion to that state.
- When I finish a break, return me to work without another setup ritual.

## Golden Path

1. User launches Focusin and sees the menu bar status.
2. Focus timer begins automatically or through `Start Focus`.
3. At interval end, runtime becomes break due and a notification appears if allowed.
4. User opens the popover, selects a state and duration, and reviews the suggestion.
5. User starts the break and sees a countdown.
6. User completes or skips it.
7. Focusin records same-day history and starts the next focus interval.

## Functional Requirements

### Focus cycle

- Support 25, 45, 60, and custom 1–240 minute intervals.
- Derive countdowns from wall-clock dates so relaunch does not reset progress.
- Allow restarting focus at any time.
- Transition focus to break due even when notification delivery is unavailable.

### Break cycle

- Support 30-second, 2-minute, 5-minute, and 10-minute durations.
- Preserve the active activity and break deadline across relaunch.
- Allow early completion or skipping.
- Keep the active activity fixed until completion or skip; disable state/duration selectors during a break.
- Start the next focus interval after completion or skip.
- Treat natural break expiry as completion for same-day novelty history, without implying a wellness outcome.

### Recommendation

- Accept Stiff, Tired, Scattered, Anxious, and Fine states.
- Respect office-safe-only and mindfulness settings as hard filters.
- Prefer exact state/duration and unseen-today matches.
- Broaden gracefully when the ideal match does not exist.
- Present a clear unavailable state if no eligible activity exists.

### Preferences

- Persist all user-editable settings. Break state/duration are chosen in the popover; the persisted legacy default-duration field remains compatible but has no separate Settings editor.
- Normalize user-editable numbers to supported bounds.
- Support quiet hours that cross midnight.
- Treat matching quiet-hour endpoints as all-day reminder suppression while timers continue.
- Support optional launch at login and optional menu bar text. Launch-at-login configuration is disabled in Debug/local builds and when unavailable on the platform.
- Default auto-start-on-launch to enabled for clean installs and older settings payloads missing that field.

## Experience Requirements

- Opening the popover should expose the current state and primary action immediately.
- Default actions must be keyboard accessible.
- Status cannot rely on color alone.
- Copy must be concise enough for a 384-point popover.
- Settings should use familiar native macOS controls.
- Notification denial must produce a usable in-app experience.

## Success Criteria

Version 1 success is qualitative and operational because analytics are intentionally absent:

- Beta users understand the state/duration model without onboarding.
- Most testers can complete the golden path without assistance.
- Testers report that suggestions are actionable in their normal environment.
- Notification frequency feels controllable rather than coercive.
- The app earns a permanent menu bar position for a meaningful subset of testers.
- No P0 data-loss, crash, or lifecycle defect remains at release.

## Product Boundaries

### Version 1 includes

- Native menu bar app and Settings scene.
- Local recommendation catalog and same-day repeat avoidance.
- Focus/break timers, notifications, quiet hours, persistence, and login item.
- TestFlight/App Store distribution preparation.

### Explicitly out of scope

- Accounts, cloud sync, social graphs, teams, leaderboards, and streak pressure.
- Medical diagnosis, treatment claims, HealthKit, or biometric inference.
- Task management, website blocking, keystroke/screen monitoring, or employer reporting.
- AI-generated health advice or network-fetched recommendations.
- Payments and subscriptions for version 1.

## Product Risks

- Notification fatigue: controlled through interval choice, quiet hours, and opt-out.
- Repetitive catalog: mitigated by daily exclusions and future catalog expansion.
- Physical suitability: mitigated by low-intensity language and user-controlled skipping.
- Menu bar crowding: mitigated by optional text.
- Apparent timer drift: mitigated by date-derived state rather than tick counting.

## Acceptance Checklist

- [x] Functional menu bar vertical slice exists.
- [x] Four-state lifecycle is persisted.
- [x] Bundled recommendation catalog and fallback selection exist.
- [x] Reminder and quiet-hour controls exist.
- [x] Permission-denied experience has dedicated copy and deterministic verification.
- [x] Local accessibility audit is complete; exact signed-candidate smoke testing remains a release gate.
- [x] Catalog safety/content review is signed off for 0.1.0 (1).
- [ ] TestFlight beta evidence is recorded.
- [ ] App Store assets and listing are complete.
