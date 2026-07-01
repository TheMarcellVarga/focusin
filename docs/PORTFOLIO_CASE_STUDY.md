# Portfolio Case Study

## Working Title

Focusin: Designing a local-first macOS micro-break companion

## One-Line Summary

A native menu bar app that combines persisted focus intervals with a transparent, state-aware micro-break recommendation system.

## Problem

Break reminders often fail at the moment of action: a user receives an interruption but still has to choose a useful, context-appropriate activity. Focusin reduces that decision to current state and available time, then provides one action without opening a full productivity workspace.

## Constraints

- Menu bar-first, compact native UI.
- macOS 14+ and Apple platform frameworks.
- No account, backend, analytics, or network dependency.
- Low-risk wellness language without medical positioning.
- Runtime must survive relaunch, sleep, and timer coalescing.
- Recommendation content must remain inspectable and testable.

## Key Decisions

### Persist dates, not ticks

Focus and break states store `startedAt`/`endsAt`. The one-second timer updates presentation, while wall-clock dates remain truth. This supports restoration and avoids accumulated tick drift.

### Transparent fallback recommendations

Explicit office/mindfulness preferences are hard filters. State, duration, and novelty are relaxed through a documented order only when needed. This makes the behavior explainable and prevents empty results where an eligible alternative exists.

### Bundled content over remote generation

A reviewed JSON catalog preserves offline use, privacy, stable behavior, and content accountability. It is a better fit for version 1 than generative or network-fetched wellness advice.

### One application store

A main-actor `FocusinStore` coordinates the small state graph, persistence, and platform adapters. This avoids premature architecture while keeping pure recommendation logic isolated.

## Product Flow

1. Begin or restore a focus interval.
2. Reconcile a single optional notification.
3. Mark the break due based on elapsed wall time.
4. Recommend from state, duration, preferences, and same-day history.
5. Run or skip the break.
6. Persist history and begin focus again.

## Engineering Highlights

- SwiftUI `MenuBarExtra` and Settings scene.
- Codable settings/runtime/history with compatibility defaults and legacy migration reads.
- Validated resource catalog and pure recommendation engine.
- UserNotifications and `SMAppService` adapters.
- App Sandbox/privacy manifest and Xcode distribution project.
- Tests for selection policy, normalization, compatibility, history, and identifiers.

## Quality Story

The release program adds deterministic time/platform seams, full transition and migration coverage, accessibility validation, signed lifecycle testing, catalog editorial review, and archive/privacy verification. Evidence should cite exact test builds rather than claiming completion from source inspection alone.

## Honest Limitations

- Current catalog is intentionally small and requires beta feedback for variety.
- No cross-device sync or long-term insights.
- Platform permission and login-item failure UX needs completion before public release.
- A complete accessibility and signed lifecycle matrix must be recorded.
- The app provides general wellness prompts, not medical guidance.

## Outcome Evidence Template

Complete only with real data:

- Beta cohort and tested builds:
- Golden-path completion observations:
- Most/least useful states or activities:
- Notification usefulness feedback:
- Defects found through lifecycle testing:
- Accessibility changes made:
- App Store/TestFlight status:

## Suggested Portfolio Assets

- Hero popover with a representative recommendation.
- Four-state lifecycle diagram.
- Recommendation fallback diagram.
- Active break and Settings screenshots.
- Short code excerpts for deadline persistence and selection policy.
- Release/test evidence summary.

## Interview Talking Points

- Why a native menu bar utility fit the interaction better than a web app.
- How local-only architecture reduced privacy and operational complexity.
- Why deadline persistence is more reliable than tick-count persistence.
- How hard and soft recommendation constraints were separated.
- Which release risks remain platform-specific despite a small codebase.

