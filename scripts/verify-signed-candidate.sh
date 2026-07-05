#!/bin/zsh

set -euo pipefail

if [[ $# -ne 1 ]]; then
    print -u2 "Usage: $0 /Applications/Focusin.app"
    exit 64
fi

APP="${1:A}"

if [[ "$APP" != "/Applications/Focusin.app" ]]; then
    print -u2 "Candidate must be installed at /Applications/Focusin.app."
    exit 1
fi

test -x "$APP/Contents/MacOS/Focusin"
test -f "$APP/Contents/Resources/Activities.json"
test -f "$APP/Contents/Resources/PrivacyInfo.xcprivacy"
test -f "$APP/Contents/Resources/AppIcon.icns"

codesign --verify --deep --strict --verbose=2 "$APP"

SIGNING_DETAILS="$(codesign -d --verbose=4 "$APP" 2>&1)"
TEAM_ID="$(print -r -- "$SIGNING_DETAILS" | sed -n 's/^TeamIdentifier=//p')"
AUTHORITY="$(print -r -- "$SIGNING_DETAILS" | sed -n 's/^Authority=//p' | head -1)"

if [[ -z "$TEAM_ID" || "$TEAM_ID" = "not set" || -z "$AUTHORITY" ]]; then
    print -u2 "A named signing authority and team identifier are required; ad-hoc signing is insufficient."
    exit 1
fi

INFO="$APP/Contents/Info.plist"
IDENTIFIER="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$INFO")"
VERSION="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$INFO")"
BUILD="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' "$INFO")"

test "$IDENTIFIER" = "com.marcellvarga.focusin"

print "Signed candidate verification passed."
print "Version/build: $VERSION ($BUILD)"
print "Bundle identifier: $IDENTIFIER"
print "Authority: $AUTHORITY"
print "Team: $TEAM_ID"
print "Commit: $(git -C "${0:A:h}/.." rev-parse HEAD)"
print "macOS: $(sw_vers -productVersion) ($(sw_vers -buildVersion))"
print "Hardware: $(uname -m)"
