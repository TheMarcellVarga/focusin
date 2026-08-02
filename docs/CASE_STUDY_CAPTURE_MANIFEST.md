# Case Study Capture Manifest

## Candidate Identity

Complete this section once, then use the same candidate for every final asset.

| Field | Value |
| --- | --- |
| Version/build | Not recorded |
| Full Git commit | Not recorded |
| Signing authority/team | Not recorded |
| Archive verification | Not run |
| Install location | `/Applications/Focusin.app` required |
| macOS/build | Not recorded |
| Hardware/display | Not recorded |
| Appearance/accommodations | Not recorded |
| Capture owner/date | Not recorded |

## Six Screenshot Assets

| File | Product moment | Required visible proof | Status |
| --- | --- | --- | --- |
| `01-ready-recommendation.png` | Ready with state/time selection | Immediate value, one recommendation, native menu bar context | Pending signed candidate |
| `02-focus-running.png` | Active focus interval | Persisted focus status and available early break | Pending signed candidate |
| `03-break-due.png` | Break due | Clear state change and one primary action | Pending signed candidate |
| `04-break-active.png` | Active recommendation | Instruction, stable progress, Done and Skip | Pending signed candidate |
| `05-reminder-settings.png` | Reminder/quiet-hour Settings | User control, native settings, notification independence | Pending signed candidate |
| `06-recovery-state.png` | Permission or catalog recovery | Actionable recovery without blocking the local loop | Pending signed candidate |

Capture the app/window only where possible. Remove unrelated personal notifications, menu bar items, filenames, accounts, and private desktop content. Do not composite a state that the candidate cannot produce.

## 30–45 Second Recording

| Field | Value |
| --- | --- |
| Filename | `focusin-portfolio-loop.mov` |
| Target duration | 30–45 seconds |
| Script | `DEMO_WALKTHROUGH.md` portfolio cut |
| Resolution/frame rate | Not recorded |
| Audio/captions | Not recorded |
| Debug fixture used | Must be `No` for final media |
| Status | Pending signed candidate |

The recording must show selection → recommendation → break due → active break → return to focus, with a brief Settings/privacy close. Edited time compression is allowed; debug-only controls or fabricated notifications are not.

## Engineering Supporting Asset

The Mermaid state diagram in `PORTFOLIO_CASE_STUDY.md` is the canonical source. Export it to `focusin-state-machine.svg` for the portfolio only after checking that labels match the current behavioral contract.

## Asset Verification

- [ ] Every file uses the candidate recorded above.
- [ ] `verify-signed-archive.sh` and `verify-signed-candidate.sh` pass for that candidate.
- [ ] No debug fixture, placeholder, or earlier-build UI is presented as final media.
- [ ] Screenshot copy, icon, metadata, privacy, and accessibility claims match the binary.
- [ ] The video is understandable with captions and without audio.
- [ ] The six images and video disclose no personal or private information.
- [ ] Release owner approves the complete asset set and records name/date below.

## Final Approval

| Approver | Date | Result | Notes |
| --- | --- | --- | --- |
| Not recorded | — | Not run | Required for Phase 5 exit |
