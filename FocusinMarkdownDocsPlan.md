# Focusin Markdown Documentation Plan

## Objective

Maintain a planning system as broad and operational as the `ai-finance` reference project while adapting it to a local-first native macOS utility. Extensiveness means complete coverage and traceability, not copying web, backend, billing, or AI concerns that Focusin does not have.

## Documentation Set

### Repository control

- `README.md`: public overview, setup, project map, and documentation index.
- `AGENTS.md`: contributor constraints and definition of done.
- `FocusinWorkspacePlan.md`: consolidated implementation specification.
- `FocusinMarkdownDocsPlan.md`: documentation inventory and maintenance policy.

### Product and experience

- `docs/PRODUCT_SPEC.md`: users, jobs, scope, golden path, and success criteria.
- `docs/DESIGN_SYSTEM.md`: native visual language, layout, states, and accessibility.
- `docs/RECOMMENDATION_SYSTEM.md`: catalog contract and fallback algorithm.
- `docs/BRAND_AND_MEDIA.md`: naming, tone, icon, screenshots, and App Store assets.

### Engineering

- `docs/ARCHITECTURE.md`: boundaries, components, data flow, and non-goals.
- `docs/STATE_AND_PERSISTENCE.md`: state machine, stored keys, migrations, and recovery.
- `docs/PLATFORM_INTEGRATIONS.md`: notifications, launch at login, sandbox, and lifecycle.
- `docs/ENVIRONMENT.md`: tools, builds, repository layout, and troubleshooting.
- `docs/SECURITY_PRIVACY_AND_SAFETY.md`: data inventory, threats, privacy, and wellness claims.
- `docs/TESTING_STRATEGY.md`: automated, manual, lifecycle, accessibility, and release testing.

### Delivery and evidence

- `docs/IMPLEMENTATION_PLAN.md`: phased backlog.
- `docs/MASTER_EXECUTION_ROADMAP.md`: dependency-ordered execution control plane.
- `docs/UNFINISHED_SURFACES_AUDIT.md`: honest current-state gap register.
- `docs/RELEASE_AND_DISTRIBUTION.md`: signing, TestFlight, App Store, and rollback gates.
- `docs/DEMO_WALKTHROUGH.md`: repeatable product demo.
- `docs/PORTFOLIO_CASE_STUDY.md`: evidence-based narrative structure.

## Status Vocabulary

- **Shipped**: present in the repository and verifiable now.
- **Planned**: accepted future work with a roadmap phase.
- **Candidate**: an idea requiring validation before scheduling.
- **Out of scope**: intentionally excluded from the current product boundary.

## Content Rules

- Every behavioral claim must be traceable to code, a test, or a labeled plan.
- Roadmap tasks need an owner role, dependencies, deliverable, verification, and exit criteria.
- Planned analytics must not contradict the local-only privacy promise.
- A native app does not need artificial API or database documents; platform integration and persistence documents cover those responsibilities.
- Dates are optional; dependency order and acceptance criteria are mandatory.

## Maintenance Cadence

- Update the unfinished audit during each material feature change.
- Review the master roadmap at the start and end of each phase.
- Review privacy, release, and testing documents before each external beta.
- Refresh demo and portfolio evidence only after the underlying behavior is verified.
- Perform a quarterly stale-link and shipped-versus-planned audit while the product is active.

## Completeness Standard

The planning set is complete when a new contributor can explain the product boundary, run it, identify current gaps, implement the next phase, verify it, and prepare a release without relying on undocumented project knowledge.

