#!/bin/zsh

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

if [[ $# -lt 1 || $# -gt 2 ]]; then
    print -u2 "Usage: $0 TEAM_ID [archive-path]"
    exit 64
fi

TEAM_ID="$1"
ARCHIVE_PATH="${2:-$ROOT/.build/Focusin.xcarchive}"
ARCHIVE_PATH="${ARCHIVE_PATH:A}"

if [[ ! "$TEAM_ID" =~ '^[A-Z0-9]{10}$' ]]; then
    print -u2 "TEAM_ID must be the 10-character Apple Developer team identifier."
    exit 64
fi

cd "$ROOT"

if [[ -n "$(git status --porcelain)" ]]; then
    print -u2 "Refusing to archive from a dirty working tree. Commit or stash changes first."
    exit 1
fi

IDENTITY_COUNT="$(security find-identity -v -p codesigning | sed -n 's/^ *\([0-9][0-9]*\) valid identities found$/\1/p')"
if [[ -z "$IDENTITY_COUNT" || "$IDENTITY_COUNT" -eq 0 ]]; then
    print -u2 "No valid Apple code-signing identity is available in the keychain."
    exit 1
fi

if [[ -e "$ARCHIVE_PATH" ]]; then
    print -u2 "Archive path already exists: $ARCHIVE_PATH"
    print -u2 "Choose a new path or remove the existing archive deliberately."
    exit 1
fi

mkdir -p "${ARCHIVE_PATH:h}"

./scripts/test-local.sh
swift test
./scripts/release-preflight.sh

xcodebuild \
    -project Focusin.xcodeproj \
    -scheme Focusin \
    -configuration Release \
    -destination "generic/platform=macOS" \
    -archivePath "$ARCHIVE_PATH" \
    DEVELOPMENT_TEAM="$TEAM_ID" \
    CODE_SIGN_STYLE=Automatic \
    archive

APP="$ARCHIVE_PATH/Products/Applications/Focusin.app"
test -x "$APP/Contents/MacOS/Focusin"

print "Signed archive created: $ARCHIVE_PATH"
print "Archived app: $APP"
print "Next: ./scripts/verify-signed-archive.sh \"$ARCHIVE_PATH\""
