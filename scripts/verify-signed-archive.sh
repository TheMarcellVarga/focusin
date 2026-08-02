#!/bin/zsh

set -euo pipefail

if [[ $# -ne 1 ]]; then
    print -u2 "Usage: $0 /path/to/Focusin.xcarchive"
    exit 64
fi

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ARCHIVE="${1:A}"
APP="$ARCHIVE/Products/Applications/Focusin.app"
INFO="$APP/Contents/Info.plist"
PRIVACY="$APP/Contents/Resources/PrivacyInfo.xcprivacy"
METADATA="$ARCHIVE/FocusinBuildMetadata.plist"
ENTITLEMENTS="$(mktemp /tmp/focusin-archive-entitlements.XXXXXX.plist)"

cleanup() {
    rm -f "$ENTITLEMENTS"
}
trap cleanup EXIT

test -d "$ARCHIVE"
test -f "$ARCHIVE/Info.plist"
test -f "$METADATA"
test -x "$APP/Contents/MacOS/Focusin"
test -f "$APP/Contents/Resources/Activities.json"
test -f "$PRIVACY"
test -f "$APP/Contents/Resources/AppIcon.icns"
test -f "$APP/Contents/Resources/Assets.car"

codesign --verify --deep --strict --verbose=2 "$APP"

SIGNING_DETAILS="$(codesign -d --verbose=4 "$APP" 2>&1)"
TEAM_ID="$(print -r -- "$SIGNING_DETAILS" | sed -n 's/^TeamIdentifier=//p')"
AUTHORITY="$(print -r -- "$SIGNING_DETAILS" | sed -n 's/^Authority=//p' | head -1)"

if [[ -z "$TEAM_ID" || "$TEAM_ID" = "not set" || -z "$AUTHORITY" ]]; then
    print -u2 "A named signing authority and team identifier are required; ad-hoc signing is insufficient."
    exit 1
fi

codesign -d --entitlements :- "$APP" >"$ENTITLEMENTS" 2>/dev/null
plutil -lint "$ENTITLEMENTS" >/dev/null
test "$(/usr/libexec/PlistBuddy -c 'Print :com.apple.security.app-sandbox' "$ENTITLEMENTS")" = "true"

FORBIDDEN_ENTITLEMENTS=(
    com.apple.security.network.client
    com.apple.security.network.server
    com.apple.security.device.audio-input
    com.apple.security.device.camera
    com.apple.security.personal-information.addressbook
    com.apple.security.personal-information.calendars
    com.apple.security.personal-information.location
    com.apple.security.personal-information.photos-library
    com.apple.developer.healthkit
    get-task-allow
)

for entitlement in "${FORBIDDEN_ENTITLEMENTS[@]}"; do
    if /usr/libexec/PlistBuddy -c "Print :$entitlement" "$ENTITLEMENTS" >/dev/null 2>&1; then
        print -u2 "Unexpected entitlement in signed archive: $entitlement"
        exit 1
    fi
done

IDENTIFIER="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$INFO")"
VERSION="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$INFO")"
BUILD="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' "$INFO")"
MINIMUM_SYSTEM="$(/usr/libexec/PlistBuddy -c 'Print :LSMinimumSystemVersion' "$INFO")"
MENU_BAR_ONLY="$(/usr/libexec/PlistBuddy -c 'Print :LSUIElement' "$INFO")"

test "$IDENTIFIER" = "com.marcellvarga.focusin"
test "$MINIMUM_SYSTEM" = "14.0"
test "$MENU_BAR_ONLY" = "true"

test "$(plutil -extract NSPrivacyTracking raw "$PRIVACY")" = "false"
test "$(plutil -extract NSPrivacyTrackingDomains json -o - "$PRIVACY")" = "[]"
test "$(plutil -extract NSPrivacyCollectedDataTypes json -o - "$PRIVACY")" = "[]"
test "$(plutil -extract NSPrivacyAccessedAPITypes json -o - "$PRIVACY")" = "[]"

ARCHIVE_COMMIT="$(plutil -extract Commit raw "$METADATA")"
ARCHIVE_TEAM="$(plutil -extract TeamIdentifier raw "$METADATA")"
CURRENT_COMMIT="$(git -C "$ROOT" rev-parse HEAD)"

if [[ ${#ARCHIVE_COMMIT} -ne 40 || "$ARCHIVE_COMMIT" = *[^0-9a-f]* ]]; then
    print -u2 "Archive metadata does not contain a full Git commit SHA."
    exit 1
fi

test "$ARCHIVE_COMMIT" = "$CURRENT_COMMIT"
test "$ARCHIVE_TEAM" = "$TEAM_ID"

print "Signed archive verification passed."
print "Version/build: $VERSION ($BUILD)"
print "Bundle identifier: $IDENTIFIER"
print "Authority: $AUTHORITY"
print "Team: $TEAM_ID"
print "Commit: $ARCHIVE_COMMIT"
print "Created: $(plutil -extract CreatedAtUTC raw "$METADATA")"
print "Xcode: $(plutil -extract Xcode raw "$METADATA")"
print "Swift: $(plutil -extract Swift raw "$METADATA")"
print "macOS: $(plutil -extract macOS raw "$METADATA")"
print "Hardware: $(plutil -extract Hardware raw "$METADATA")"
