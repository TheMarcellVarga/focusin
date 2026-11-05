# Interview UI QA — 5 November 2026

## Method

Native computer-use inspection on macOS 27.0.1, against the current working-tree SwiftUI views. The original menu-bar-only app runs successfully, but the automation service cannot attach to its windowless process. A temporary copy under `/tmp/focusin-native-qa` used a regular Dock app and a content-sized WindowGroup hosting the actual FocusinPopoverView, unchanged SettingsView, store, and bundled catalog. Only the temporary host and LSUIElement value differed; no QA window or Dock behavior was added to the repository.

The first pass used real local state. The second used existing DEBUG fixtures (`FOCUSIN_UI_FIXTURE=breaking`, `FOCUSIN_UI_APPEARANCE=dark`, `FOCUSIN_UI_LARGE_TEXT=1`) with in-memory persistence. Fixture state does not prove elapsed timer behavior. Screenshots and accessibility trees were inspected in the chat; no release media was captured.

## Observed Checks

| Check | Result |
| --- | --- |
| Select state and duration | Native segmented controls update their selected values. |
| Start a break | Active break, instructions, countdown, Finish Break, and Skip appear. |
| Active-break selectors | Both groups and all segments are disabled; explanatory text is visible. |
| Finish Break | Focus starts at 25 minutes and selectors enable again. |
| Return key while focusing | Invokes Take Break, matching the visible primary action. |
| Skip | Returns to focus and enables selectors again. |
| Settings link | Opens the native Settings window. |
| Settings tabs | Reminder, Activities, and System open; no Feedback tab remains. |
| Notification denial | Reminder Settings shows denial guidance and a named Open Notification Settings button; no permission change was made. |
| Launch at login | System Settings shows a disabled switch and the unavailable-build explanation. |
| Quiet hours | Endpoints are disabled when suppression is off and enable when it is on (fixture-only change). |
| Appearance | Light surfaces and dark active-break/Settings surfaces inspected. Dark accessibility-size layout keeps controls, instructions, and footer visible. |

The initial real-state selection was restored to Stiff/30s. Completing/skipping test breaks naturally updated same-day local history and restarted focus. The QA process was quit; the original `.build-local/Focusin.app` was reopened and its process path verified.

## Remaining Boundaries

This is native view and interaction evidence, not a signed-candidate or exact menu-bar-presentation sign-off. The original menu-bar click/open behavior, full keyboard traversal, VoiceOver speech, increased contrast, reduced transparency, notification delivery, login registration, and signed lifecycle matrix remain separate checks. No new automated test run was needed: repository runtime/UI code did not change during this QA pass; the preceding 58 passing tests and local build remain the code verification baseline.

A transient disk-space shortage interrupted screenshot capture. `swift package clean` removed regenerable Focusin build output, and native capture resumed. The local app bundle was retained.
