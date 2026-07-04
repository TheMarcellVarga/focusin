# App Store Metadata

## Status

This is reviewed draft copy for Focusin 0.1.0. It is not evidence of an App Store Connect listing. Support/privacy URLs, screenshots, icon assets, copyright holder, and reviewer contact remain unassigned distribution inputs.

## Listing Copy

- Name: Focusin
- Subtitle: State-aware micro-breaks
- Category: Productivity
- Minimum system: macOS 14
- Keywords: focus,timer,break,menubar,wellness,reminder,offline,productivity

### Promotional text

Take short, state-aware breaks without leaving your menu bar.

### Description

Focusin is a private menu bar focus timer that recommends a short reset based on how you feel and how much time you have.

Choose Stiff, Tired, Scattered, Anxious, or Fine, then select a break duration. Focusin suggests a concise activity and keeps the focus-to-break cycle close at hand.

Features:

- Focus and break timers in the macOS menu bar
- State-aware activities from 30 seconds to 10 minutes
- Office-safe and mindfulness preferences
- Optional notifications and quiet hours
- Optional launch at login
- Local history to reduce repeated suggestions during the day
- No account, analytics, advertising, or network access

Notifications are optional. Focusin remains fully usable from the menu bar when notification permission is denied.

Focusin provides optional general-wellness prompts, not medical advice. Skip any activity that is unsuitable for you or your surroundings.

## TestFlight “What to Test”

- Complete a focus interval with notifications allowed and denied.
- Check whether recommendations feel specific, repetitive, awkward, unsafe, or mistimed.
- Try office-safe and mindfulness preferences.
- Relaunch during a focus interval and an active break.
- Report the Focusin version/build and macOS version with every issue.

## Review Notes

Focusin is a menu bar-only macOS application, so it intentionally has no Dock icon or primary document window. Open Focusin from its menu bar item. Settings are available from the popover.

Notification permission is requested only after the user selects Allow Notifications. Denying permission does not block focus timers or break recommendations. Launch at login is optional and uses `SMAppService.mainApp`.

The application is sandboxed and local-only. It has no account, backend, analytics SDK, advertising SDK, network entitlement, or user tracking.

## Privacy Answers

Subject to inspection of the signed submitted archive:

- Data collected: None
- Tracking: No
- Tracking domains: None
- Account required: No

## Required External Inputs

- Support URL: not assigned; must resolve publicly before submission.
- Privacy-policy URL: not assigned; must resolve publicly before submission.
- Copyright: owner and year not recorded.
- Reviewer contact: not recorded.
- App icon: no production asset catalog exists.
- Screenshots: must be captured from the exact submitted signed build.
