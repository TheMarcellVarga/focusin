# Catalog Content Contract

## Schema And Identity

Every bundled activity must have a unique, non-empty, lowercase kebab-case ID that is stable across releases. IDs are persistence keys: edit copy under the same ID only when the activity's meaning and completion action remain materially the same. Never reuse a retired ID.

The controlled vocabulary is:

- states: `stiff`, `tired`, `scattered`, `anxious`, `fine`;
- durations: `thirtySeconds`, `twoMinutes`, `fiveMinutes`, `tenMinutes`;
- categories: `move`, `mind`, `desk`, `focus`, `social`;
- intensity: `low`, `medium`;
- context flags: `officeSafe` and `mindfulness` booleans.

Each activity has a concise title, one actionable instruction, at least one state, and at least one realistic duration. Unknown fields may be added only with backward-compatible decoding and fixtures; unknown enum values invalidate the catalog rather than being guessed.

## Coverage

The release catalog must provide:

- at least one activity for every state-duration pair;
- at least one office-safe activity for every state;
- at least one non-mindfulness activity for every state;
- at least one eligible default-filter activity for every state-duration pair;
- representation across every category and both supported intensity levels.

Automated validation enforces structural and measurable coverage rules. Phase 5 records the human review; passing validation is not editorial or safety sign-off.

## Editorial And Safety Rules

- Use one action, plain language, and an observable stopping point.
- Keep instructions realistic for every tagged duration.
- Use conditional language such as “gently” and “if comfortable” for movement.
- Do not prescribe breath holding, extreme range of motion, balance challenges without support, or action requiring unsafe surroundings.
- Do not diagnose, treat, cure, guarantee outcomes, or tell users to work through pain, dizziness, or distress.
- Do not use productivity shame, streak pressure, body judgment, or ableist assumptions.
- Classify `officeSafe` conservatively for ordinary clothing, shared space, and a desk-side footprint.
- Mark mindfulness accurately and retain non-mindfulness alternatives.
- Recommendations are optional wellness prompts; users can skip any activity.

## Change And Removal Policy

Catalog changes require validation plus an entry in release notes when an ID is added, retired, or materially revised. Retire an ID instead of reusing it. Same-day history may retain retired IDs harmlessly until date rollover.

If an update removes the activity referenced by an active break, restoration follows RS-08 in `BEHAVIORAL_CONTRACT.md`: cancel the stale active break into break due and offer a valid recommendation. Focusin must never put replacement copy under the removed activity's timer/history identity.

## Failure Policy

A missing, undecodable, or invalid bundled catalog produces the catalog-error state. Focusin must not invent remote or generated content, weaken explicit filters, or crash. Focus timers, Settings, and Quit remain available.
