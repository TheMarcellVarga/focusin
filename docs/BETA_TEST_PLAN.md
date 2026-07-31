# Beta Test Plan

## Scope

Run this plan with 5–8 testers against one exact signed build. Focusin remains local-only and collects no analytics; feedback is volunteered through the tester's chosen communication channel.

Do not record names, email addresses, private work details, selected state, or activity history in the repository. Assign anonymous IDs such as `T01` through `T08` and retain only the minimum environment and issue information needed to reproduce a report.

## Tester Packet

Before starting, give each tester:

- the exact Focusin version/build and installation instructions;
- the three scenarios below;
- the built-in feedback notes from Settings > Feedback;
- a monitored feedback destination outside the app;
- the reminder that wellness prompts are optional and are not medical advice.

## Task Scenarios

1. **Core loop:** choose a current state and available time, review the suggestion, start it, then choose Done or Skip.
2. **Restoration:** start a focus interval, quit Focusin, reopen it, and confirm the focus state resumes correctly.
3. **Controls:** change reminder or quiet-hour settings, then complete the core loop using only the keyboard if comfortable.

Testers who use VoiceOver or another assistive technology should use their normal setup and report unclear labels, order, values, or announcements. Do not ask testers to disclose a disability.

## Evidence Record

Record results against the same build in the Phase 3 rework evidence.

| Tester ID | macOS | Scenarios completed | P0/P1 issues | P2/P3 issues | Disposition |
| --- | --- | --- | --- | --- | --- |
| T01 | Not recorded | Not run | — | — | Pending |
| T02 | Not recorded | Not run | — | — | Pending |
| T03 | Not recorded | Not run | — | — | Pending |
| T04 | Not recorded | Not run | — | — | Pending |
| T05 | Not recorded | Not run | — | — | Pending |

Add `T06`–`T08` only when those testers participate. Do not create synthetic responses or satisfaction percentages.

## Triage

- P0: privacy/data loss, unsafe instruction, launch blocker, persistent crash, or broken signing. Stop distribution immediately.
- P1: golden-path, restoration, notification/login-item, or critical accessibility blocker. Stop cohort expansion until fixed and retested.
- P2: degraded secondary behavior with a safe workaround.
- P3: cosmetic or low-impact polish issue.

For every issue, record the anonymous tester ID, build, macOS version, reproduction steps, expected and observed behavior, severity, fixing/deferred decision, and verification result. Explain deferrals; never reinterpret missing feedback as approval.

## Exit Gate

The beta portion passes only when 5–8 real testers have attempted all three scenarios on the exact signed build, responses are summarized anonymously, all P0/P1 findings are resolved and retested, and P2/P3 deferrals have documented rationale.
