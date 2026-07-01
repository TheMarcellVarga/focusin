# Focusin Engineering Guide

## Purpose

This file is the operating contract for contributors and coding agents working on Focusin. Product decisions and implementation sequencing live in `docs/`; this file defines how changes are made safely.

## Product Contract

- Focusin is a native macOS 14+ menu bar utility.
- The core loop is focus interval -> break due -> recommended micro-break -> return to focus.
- Version 1 is local-only: no account, backend, analytics, advertising, or network entitlement.
- Recommendations are wellness prompts, not medical advice.
- The app must remain useful when notifications are denied.

## Source Of Truth

- Product behavior: `docs/PRODUCT_SPEC.md`
- Runtime design: `docs/ARCHITECTURE.md` and `docs/STATE_AND_PERSISTENCE.md`
- Activity selection: `docs/RECOMMENDATION_SYSTEM.md`
- Delivery order: `docs/MASTER_EXECUTION_ROADMAP.md`
- Release gates: `docs/TESTING_STRATEGY.md` and `docs/RELEASE_AND_DISTRIBUTION.md`
- Current gaps: `docs/UNFINISHED_SURFACES_AUDIT.md`

When docs and code disagree, verify the shipped behavior and update both in the same change. Do not silently describe planned behavior as implemented.

## Engineering Rules

- Preserve the `MenuBarExtra`-first interaction model.
- Keep runtime state mutations on `MainActor`.
- Keep models codable and backward-compatible with existing `UserDefaults` payloads.
- Treat `Activities.json` as product data: validate IDs, state coverage, duration coverage, and safety flags.
- Use native SwiftUI, AppKit, UserNotifications, and ServiceManagement APIs before adding dependencies.
- Avoid dependencies unless the standard library or Apple frameworks cannot reasonably solve the problem.
- Never add telemetry, networking, or sensitive data collection without a documented product and privacy decision.

## Change Workflow

1. Identify the roadmap phase and acceptance criteria affected.
2. Inspect the relevant model, store, view, persistence, and test paths.
3. Make the smallest coherent implementation and documentation change.
4. Add or update deterministic tests for logic and migrations.
5. Run `./scripts/test-local.sh` and `./scripts/build-local.sh`.
6. Perform manual menu bar QA for changes involving lifecycle, notifications, or settings.
7. Update `docs/UNFINISHED_SURFACES_AUDIT.md` if a gap is closed or discovered.

## Definition Of Done

A change is done only when behavior, tests, documentation, accessibility, persistence compatibility, and release implications agree. A successful compile alone is insufficient.

