#!/bin/bash
set -euo pipefail

# Build shuowen.store from local JSON files (Method A).
#
# Usage:
#   ./Scripts/import_entries.sh /path/to/json/folder
#   ./Scripts/import_entries.sh ./Scripts/entries

JSON_DIR="${1:-}"
if [[ -z "$JSON_DIR" || ! -d "$JSON_DIR" ]]; then
  echo "Usage: $0 /path/to/json/folder" >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
JSON_DIR="$(cd "$JSON_DIR" && pwd)"
OUTPUT_PATH="$PROJECT_ROOT/Shuowen/Resources/shuowen.store"
LOG_PATH="$SCRIPT_DIR/import.log"

mkdir -p "$(dirname "$OUTPUT_PATH")"

JSON_COUNT=$(find "$JSON_DIR" -maxdepth 1 -name '*.json' | wc -l | tr -d ' ')
if [[ "$JSON_COUNT" == "0" ]]; then
  echo "No .json files found in: $JSON_DIR" >&2
  exit 1
fi

APP_PATH=""
while IFS= read -r candidate; do
  [[ "$candidate" == *"/Index.noindex/"* ]] && continue
  executable="$candidate/Contents/MacOS/Shuowen"
  if [[ -x "$executable" ]]; then
    APP_PATH="$candidate"
    break
  fi
done < <(
  find ~/Library/Developer/Xcode/DerivedData/Shuowen-* \
    -name 'Shuowen.app' \
    -path '*/Build/Products/Debug/*' \
    2>/dev/null \
    | sort -r
)

if [[ -z "$APP_PATH" ]]; then
  echo "Shuowen.app not found. Build the Debug target in Xcode first (Product → Build)." >&2
  exit 1
fi

EXECUTABLE="$APP_PATH/Contents/MacOS/Shuowen"

# Avoid multiple instances blocking the store file.
pkill -x Shuowen 2>/dev/null || true
sleep 1

echo "Using app:    $APP_PATH"
echo "JSON files: $JSON_COUNT in $JSON_DIR"
echo "Export to:  $OUTPUT_PATH"
echo "Log file:   $LOG_PATH"
echo
echo "Import running… (first batch may take 1-2 minutes)"
echo "Export runs after the app quits (avoids incomplete WAL copies)."
echo

rm -f "$LOG_PATH"

"$EXECUTABLE" \
  --import="$JSON_DIR" \
  --log="$LOG_PATH" \
  --quit-after-import &

APP_PID=$!

while kill -0 "$APP_PID" 2>/dev/null; do
  if [[ -f "$LOG_PATH" ]]; then
    tail -n 3 "$LOG_PATH"
  else
    echo "(waiting for app to start…)"
  fi
  echo "---"
  sleep 10
done

wait "$APP_PID" || true

echo
if [[ -f "$LOG_PATH" ]] && grep -q "Import failed" "$LOG_PATH"; then
  echo "Import failed. Full log:" >&2
  cat "$LOG_PATH" >&2
  exit 1
fi

if ! command -v sqlite3 >/dev/null 2>&1; then
  echo "sqlite3 is required to export the store after import." >&2
  exit 1
fi

SOURCE_STORE=""
if [[ -f "$LOG_PATH" ]]; then
  # awk (not grep) — grep exits 1 with no match, which aborts under pipefail.
  SOURCE_STORE=$(awk -F': ' '/^Source store: / { print $2 }' "$LOG_PATH" | tail -1)
fi

if [[ -z "$SOURCE_STORE" || ! -f "$SOURCE_STORE" ]]; then
  SOURCE_STORE="$HOME/Library/Application Support/Shuowen/shuowen.store"
fi

if [[ ! -f "$SOURCE_STORE" ]]; then
  SOURCE_STORE=$(find "$HOME/Library/Containers" \
    -path '*/Application Support/Shuowen/shuowen.store' \
    2>/dev/null | head -1)
fi

DESKTOP_STORE="$HOME/Desktop/shuowen.store"
if [[ ! -f "$SOURCE_STORE" && -f "$DESKTOP_STORE" ]]; then
  SOURCE_STORE="$DESKTOP_STORE"
fi

if [[ ! -f "$SOURCE_STORE" ]]; then
  echo "Source store not found after import." >&2
  cat "$LOG_PATH" 2>/dev/null || true
  exit 1
fi

echo
echo "Exporting from: $SOURCE_STORE"
echo "Exporting to:   $OUTPUT_PATH"

rm -f "$OUTPUT_PATH" "${OUTPUT_PATH}-wal" "${OUTPUT_PATH}-shm"
sqlite3 "$SOURCE_STORE" ".backup '$OUTPUT_PATH'"
sqlite3 "$OUTPUT_PATH" "PRAGMA wal_checkpoint(TRUNCATE);" >/dev/null 2>&1 || true
rm -f "${OUTPUT_PATH}-wal" "${OUTPUT_PATH}-shm"

STORE_COUNT=$(sqlite3 "$OUTPUT_PATH" "SELECT COUNT(*) FROM ZENTRY;")
STORE_MAX_ID=$(sqlite3 "$OUTPUT_PATH" "SELECT MAX(ZENTRYID) FROM ZENTRY;")
if [[ "$STORE_COUNT" != "$JSON_COUNT" ]]; then
  echo "Error: store has $STORE_COUNT entries, expected $JSON_COUNT." >&2
  echo "Max entry id in store: $STORE_MAX_ID" >&2
  exit 1
fi

echo "Verified: $STORE_COUNT entries (max id $STORE_MAX_ID)"
echo "Success: $OUTPUT_PATH"
ls -lh "$OUTPUT_PATH"
