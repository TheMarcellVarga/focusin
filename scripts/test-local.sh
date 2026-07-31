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
  "$SOURCE_DIR/BetaFeedbackTemplate.swift" \
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
try ActivityLibrary.validate(library)
precondition(library.count >= 21)
precondition(Set(library.map(\.id)).count == library.count)

for state in FocusState.allCases {
    let activitiesForState = library.filter { $0.states.contains(state) }
    precondition(activitiesForState.contains(where: \.officeSafe))
    precondition(activitiesForState.contains { !$0.mindfulness })
}

let history = ActivityHistory(
    dateKey: "2026-6-23",
    completedActivityIDs: ["completed"],
    skippedActivityIDs: ["skipped"],
    seenActivityIDs: ["seen"]
)
precondition(history.excludedForRecommendations == ["completed", "skipped", "seen"])

let clamped = FocusinSettings(customWorkMinutes: 999, quietStartHour: -10, quietEndHour: 99).normalized
precondition(clamped.customWorkMinutes == 240)
precondition(clamped.quietStartHour == 0)
precondition(clamped.quietEndHour == 23)

let legacySettingsJSON = """
{
  "workInterval": 25,
  "customWorkMinutes": 25,
  "defaultDuration": "twoMinutes"
}
""".data(using: .utf8)!
let legacySettings = try JSONDecoder().decode(FocusinSettings.self, from: legacySettingsJSON)
precondition(legacySettings.showMenuBarText)
precondition(legacySettings.notificationsEnabled)
precondition(legacySettings.startFocusTimerOnLaunch)

let runtimeState = FocusinRuntimeState.breaking(activityID: "window-breath-30", endsAt: Date(timeIntervalSince1970: 1_800))
let runtimeData = try JSONEncoder().encode(runtimeState)
let decodedRuntimeState = try JSONDecoder().decode(FocusinRuntimeState.self, from: runtimeData)
precondition(decodedRuntimeState == runtimeState)

print("Local tests passed: \(library.count) activities")
SWIFT

swiftc \
  -swift-version 6 \
  "$SOURCE_DIR/Models.swift" \
  "$SOURCE_DIR/RecommendationEngine.swift" \
  "$SOURCE_DIR/ActivityLibrary.swift" \
  "$HARNESS" \
  -o "$TMP_DIR/focusin-local-tests"

"$TMP_DIR/focusin-local-tests" "$RESOURCE_DIR/Activities.json"
