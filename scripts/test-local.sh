#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_DIR="$ROOT_DIR/Sources/Focusin"
RESOURCE_DIR="$SOURCE_DIR/Resources"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing required command: $1" >&2
    exit 1
  fi
}

require_command swiftc
require_command plutil

plutil -lint "$RESOURCE_DIR/Info.plist" "$RESOURCE_DIR/Focusin.entitlements" >/dev/null

if command -v jq >/dev/null 2>&1; then
  jq empty "$RESOURCE_DIR/Activities.json" "$RESOURCE_DIR/PrivacyInfo.xcprivacy"
fi

swiftc \
  -swift-version 6 \
  -typecheck \
  -parse-as-library \
  "$SOURCE_DIR/Models.swift" \
  "$SOURCE_DIR/RecommendationEngine.swift" \
  "$SOURCE_DIR/ActivityLibrary.swift" \
  "$SOURCE_DIR/Persistence.swift" \
  "$SOURCE_DIR/NotificationScheduler.swift" \
  "$SOURCE_DIR/LaunchAtLoginController.swift" \
  "$SOURCE_DIR/FocusinStore.swift" \
  "$SOURCE_DIR/Views.swift" \
  "$SOURCE_DIR/FocusinApp.swift"

HARNESS="$TMP_DIR/main.swift"
cat > "$HARNESS" <<'SWIFT'
import Foundation

func makeActivity(
    id: String,
    states: [FocusState],
    durations: [BreakDuration],
    officeSafe: Bool = true,
    mindfulness: Bool = false
) -> BreakActivity {
    BreakActivity(
        id: id,
        title: id,
        instruction: "Instruction",
        category: .move,
        states: states,
        durations: durations,
        officeSafe: officeSafe,
        mindfulness: mindfulness,
        intensity: .low
    )
}

let engine = RecommendationEngine()

let exact = engine.recommend(
    from: [
        makeActivity(id: "wrong-state", states: [.tired], durations: [.twoMinutes]),
        makeActivity(id: "right", states: [.stiff], durations: [.twoMinutes])
    ],
    request: RecommendationRequest(state: .stiff, duration: .twoMinutes, officeSafeOnly: false, includeMindfulness: true)
)
precondition(exact?.id == "right")

let safe = engine.recommend(
    from: [
        makeActivity(id: "unsafe", states: [.stiff], durations: [.twoMinutes], officeSafe: false),
        makeActivity(id: "safe", states: [.stiff], durations: [.twoMinutes])
    ],
    request: RecommendationRequest(state: .stiff, duration: .twoMinutes, officeSafeOnly: true, includeMindfulness: true)
)
precondition(safe?.id == "safe")

let plain = engine.recommend(
    from: [
        makeActivity(id: "mindful", states: [.anxious], durations: [.twoMinutes], mindfulness: true),
        makeActivity(id: "plain", states: [.anxious], durations: [.twoMinutes])
    ],
    request: RecommendationRequest(state: .anxious, duration: .twoMinutes, officeSafeOnly: false, includeMindfulness: false)
)
precondition(plain?.id == "plain")

let fresh = engine.recommend(
    from: [
        makeActivity(id: "seen", states: [.fine], durations: [.thirtySeconds]),
        makeActivity(id: "fresh", states: [.fine], durations: [.thirtySeconds])
    ],
    request: RecommendationRequest(
        state: .fine,
        duration: .thirtySeconds,
        officeSafeOnly: false,
        includeMindfulness: true,
        excludedActivityIDs: ["seen"]
    )
)
precondition(fresh?.id == "fresh")

let fallback = engine.recommend(
    from: [makeActivity(id: "fallback", states: [.fine], durations: [.fiveMinutes])],
    request: RecommendationRequest(state: .fine, duration: .thirtySeconds, officeSafeOnly: false, includeMindfulness: true)
)
precondition(fallback?.id == "fallback")

let resourceURL = URL(fileURLWithPath: CommandLine.arguments[1])
let data = try Data(contentsOf: resourceURL)
let library = try JSONDecoder().decode([BreakActivity].self, from: data)
precondition(library.count >= 20)
precondition(Set(library.map(\.id)).count == library.count)
print("Local tests passed: \(library.count) activities")
SWIFT

swiftc \
  -swift-version 6 \
  "$SOURCE_DIR/Models.swift" \
  "$SOURCE_DIR/RecommendationEngine.swift" \
  "$HARNESS" \
  -o "$TMP_DIR/focusin-local-tests"

"$TMP_DIR/focusin-local-tests" "$RESOURCE_DIR/Activities.json"
