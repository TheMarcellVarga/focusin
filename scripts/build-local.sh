#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="$ROOT_DIR/.build-local"
APP_DIR="$BUILD_DIR/Focusin.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"
EXECUTABLE="$MACOS_DIR/Focusin"
SOURCE_DIR="$ROOT_DIR/Sources/Focusin"
RESOURCE_SOURCE_DIR="$SOURCE_DIR/Resources"

OPEN_AFTER_BUILD=false
CLEAN_ONLY=false

usage() {
  cat <<'USAGE'
Usage: ./scripts/build-local.sh [--open|--run] [--clean] [--help]

Options:
  --open, --run  Build and open the local app bundle.
  --clean        Remove the local app bundle and exit.
  --help         Show this help text.
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --open|--run)
      OPEN_AFTER_BUILD=true
      shift
      ;;
    --clean)
      CLEAN_ONLY=true
      shift
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing required command: $1" >&2
    exit 1
  fi
}

require_file() {
  if [[ ! -f "$1" ]]; then
    echo "Missing required file: $1" >&2
    exit 1
  fi
}

require_command swiftc
require_command plutil

if [[ "$CLEAN_ONLY" == true ]]; then
  rm -rf "$APP_DIR"
  echo "Removed $APP_DIR"
  exit 0
fi

require_file "$RESOURCE_SOURCE_DIR/Info.plist"
require_file "$RESOURCE_SOURCE_DIR/Activities.json"
require_file "$RESOURCE_SOURCE_DIR/PrivacyInfo.xcprivacy"
require_file "$RESOURCE_SOURCE_DIR/Focusin.entitlements"

plutil -lint "$RESOURCE_SOURCE_DIR/Info.plist" "$RESOURCE_SOURCE_DIR/Focusin.entitlements" >/dev/null

if command -v jq >/dev/null 2>&1; then
  jq empty "$RESOURCE_SOURCE_DIR/Activities.json" "$RESOURCE_SOURCE_DIR/PrivacyInfo.xcprivacy"
fi

rm -rf "$APP_DIR"
mkdir -p "$MACOS_DIR" "$RESOURCES_DIR"

swiftc \
  -swift-version 6 \
  -parse-as-library \
  -target arm64-apple-macosx14.0 \
  "$SOURCE_DIR/Models.swift" \
  "$SOURCE_DIR/RecommendationEngine.swift" \
  "$SOURCE_DIR/ActivityLibrary.swift" \
  "$SOURCE_DIR/Persistence.swift" \
  "$SOURCE_DIR/NotificationScheduler.swift" \
  "$SOURCE_DIR/LaunchAtLoginController.swift" \
  "$SOURCE_DIR/FocusinStore.swift" \
  "$SOURCE_DIR/Views.swift" \
  "$SOURCE_DIR/FocusinApp.swift" \
  -o "$EXECUTABLE"

cp "$ROOT_DIR/Sources/Focusin/Resources/Info.plist" "$CONTENTS_DIR/Info.plist"
find "$RESOURCE_SOURCE_DIR" -maxdepth 1 -type f ! -name "Info.plist" ! -name "Focusin.entitlements" -exec cp {} "$RESOURCES_DIR/" \;

if command -v codesign >/dev/null 2>&1; then
  codesign \
    --force \
    --sign - \
    --entitlements "$RESOURCE_SOURCE_DIR/Focusin.entitlements" \
    "$APP_DIR" >/dev/null
  codesign --verify --deep --strict "$APP_DIR"
fi

plutil -lint "$CONTENTS_DIR/Info.plist" >/dev/null

echo "Built $APP_DIR"
echo "Run with: open \"$APP_DIR\""

if [[ "$OPEN_AFTER_BUILD" == true ]]; then
  open "$APP_DIR"
fi
