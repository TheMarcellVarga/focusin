# Recommendation System

## Goal

Produce one useful micro-break with minimal input while respecting explicit safety/context preferences. The system is intentionally deterministic in policy and lightweight in implementation; it is not machine learning.

## Inputs

- Current state: Stiff, Tired, Scattered, Anxious, or Fine.
- Available duration: 30 seconds, 2 minutes, 5 minutes, or 10 minutes.
- Office-safe-only preference.
- Include-mindfulness preference.
- Same-day activity IDs already completed, skipped, or seen.

## Activity Contract

The normative identity, vocabulary, coverage, editorial, safety, and removal rules are in [`CATALOG_CONTENT_CONTRACT.md`](CATALOG_CONTENT_CONTRACT.md).

Every catalog item includes:

- Stable unique ID.
- Short title and one actionable instruction.
- Category: movement, mind, desk, focus, or social.
- One or more relevant states.
- One or more plausible durations.
- Office-safety boolean.
- Mindfulness boolean.
- Low or medium intensity.

## Eligibility And Ranking

Hard filters run first:

1. When office-safe-only is on, remove non-office-safe items.
2. When mindfulness is off, remove mindfulness items.

The engine then tries these passes in order:

1. Exact state + exact duration + unseen today.
2. Exact state + exact duration, allowing repeats.
3. Exact state + unseen today, relaxing duration.
4. Exact duration + unseen today, relaxing state.
5. Any unseen eligible item.
6. Any eligible item.

Candidates within the first non-empty pass are selected randomly. Explicit preferences never relax. Relevance, duration, and novelty may relax to preserve availability.

## Catalog Validation

Shipped validation currently enforces unique IDs, non-empty state/duration arrays, and at least one office-safe and non-mindfulness fallback per state.

Planned validation should also enforce:

- Non-empty trimmed title and instruction.
- Known controlled-vocabulary values.
- Coverage matrix for every state-duration pair where feasible.
- At least one eligible item per state under default filters.
- Reasonable instruction length for the popover.
- No unsafe absolutes, diagnosis, pain-treatment, or outcome guarantees.
- Duration realism and consistency with activity intensity.

## Content Guidelines

- Use one action, plain language, and a clear stopping point.
- Prefer invitations such as “gently” or “if comfortable” for physical movement.
- Avoid breath-holding, extreme range of motion, or instructions requiring unsafe surroundings.
- Avoid productivity shame, streak pressure, or claims that a reset will cure anxiety or pain.
- Make office-safe classification conservative.
- Ensure non-mindfulness alternatives exist for users who opt out.

## Empty And Error States

- Empty after hard filters: show “No matching activity” and direct the user to adjust state, duration, or settings.
- Missing/invalid JSON: show “Activity library unavailable”; do not silently fabricate content.
- Removed active ID after update: cancel the stale active break into break due and select a valid recommendation without substituting identities.

## Testing Strategy

- Verify every ordered fallback with controlled candidate sets.
- Verify hard filters are never relaxed.
- Verify same-day exclusions are preferred but cannot make the system unusable.
- Validate the real JSON catalog in tests.
- Add matrix tests for states, durations, and preference combinations.
- Avoid asserting one randomly selected ID when multiple candidates are valid; assert membership in the expected pass.

## Future Candidates

Candidate changes require product validation and are not roadmap commitments:

- Weighted selection based on explicit thumbs-up/down feedback stored locally.
- Category rotation to increase variety.
- User-authored local activities.
- Accessibility tags for seated-only or no-vision-required activities.

Remote content, generative AI, and inferred health state remain out of scope for version 1.
