#!/bin/zsh

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DERIVED_DATA="$(mktemp -d /tmp/focusin-release-preflight.XXXXXX)"
LOG="$DERIVED_DATA/xcodebuild.log"
APP="$DERIVED_DATA/Build/Products/Release/Focusin.app"

cleanup() {
    rm -rf "$DERIVED_DATA"
}
trap cleanup EXIT

cd "$ROOT"

plutil -lint Sources/Focusin/Resources/Info.plist >/dev/null
plutil -lint Sources/Focusin/Resources/Focusin.entitlements >/dev/null
test "$(plutil -extract NSPrivacyTracking raw Sources/Focusin/Resources/PrivacyInfo.xcprivacy)" = "false"
test "$(plutil -extract NSPrivacyTrackingDomains json -o - Sources/Focusin/Resources/PrivacyInfo.xcprivacy)" = "[]"
test "$(plutil -extract NSPrivacyCollectedDataTypes json -o - Sources/Focusin/Resources/PrivacyInfo.xcprivacy)" = "[]"
test "$(plutil -extract NSPrivacyAccessedAPITypes json -o - Sources/Focusin/Resources/PrivacyInfo.xcprivacy)" = "[]"

xcodebuild \
    -project Focusin.xcodeproj \
    -scheme Focusin \
    -configuration Release \
    -destination "platform=macOS" \
    -derivedDataPath "$DERIVED_DATA" \
    CODE_SIGNING_ALLOWED=NO \
    build >"$LOG" 2>&1

test -x "$APP/Contents/MacOS/Focusin"
test -f "$APP/Contents/Resources/Activities.json"
test -f "$APP/Contents/Resources/PrivacyInfo.xcprivacy"
test -f "$APP/Contents/Resources/AppIcon.icns"
test -f "$APP/Contents/Resources/Assets.car"

test "$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$APP/Contents/Info.plist")" = "com.marcellvarga.focusin"
test "$(/usr/libexec/PlistBuddy -c 'Print :LSMinimumSystemVersion' "$APP/Contents/Info.plist")" = "14.0"
test "$(/usr/libexec/PlistBuddy -c 'Print :LSUIElement' "$APP/Contents/Info.plist")" = "true"
test "$(/usr/libexec/PlistBuddy -c 'Print :com.apple.security.app-sandbox' Sources/Focusin/Resources/Focusin.entitlements)" = "true"

if /usr/libexec/PlistBuddy -c 'Print :com.apple.security.network.client' Sources/Focusin/Resources/Focusin.entitlements >/dev/null 2>&1; then
    print -u2 "Unexpected network-client entitlement."
    exit 1
fi

unexpected_warnings="$(rg 'warning:' "$LOG" | rg -v 'Metadata extraction skipped\. No AppIntents\.framework dependency found\.' || true)"
if [[ -n "$unexpected_warnings" ]]; then
    print -u2 "$unexpected_warnings"
    exit 1
fi

print "Release preflight passed: unsigned Release product integrity verified."
print "Signing, archive validation, screenshots, and App Store submission are separate release gates."
