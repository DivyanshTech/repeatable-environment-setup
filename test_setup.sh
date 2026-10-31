#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$PROJECT_DIR/config.env"
TEST_LOG="$PROJECT_DIR/logs/test-service.log"
BACKUP_FILE="$(mktemp)"
SERVER_PID=""

cp "$CONFIG_FILE" "$BACKUP_FILE"

cleanup() {
    if [[ -n "$SERVER_PID" ]]; then
        kill "$SERVER_PID" 2>/dev/null || true
        wait "$SERVER_PID" 2>/dev/null || true
    fi
    cp "$BACKUP_FILE" "$CONFIG_FILE"
    rm -f "$BACKUP_FILE"
}
trap cleanup EXIT

pass() {
    echo "PASS: $1"
}

echo "Test 1: Create default configuration"
rm -f "$CONFIG_FILE"
"$PROJECT_DIR/setup.sh" >/dev/null
grep -qx 'APP_ENV=development' "$CONFIG_FILE"
grep -qx 'APP_HOST=127.0.0.1' "$CONFIG_FILE"
grep -qx 'APP_PORT=8000' "$CONFIG_FILE"
pass "Default configuration created correctly"

echo "Test 2: Preserve existing configuration"
printf 'APP_ENV=testing\n' > "$CONFIG_FILE"
"$PROJECT_DIR/setup.sh" >/dev/null
grep -qx 'APP_ENV=testing' "$CONFIG_FILE"
pass "Existing configuration preserved"

echo "Test 3: Repeat runs"
"$PROJECT_DIR/setup.sh" >/dev/null
"$PROJECT_DIR/setup.sh" >/dev/null
grep -qx 'APP_ENV=testing' "$CONFIG_FILE"
pass "Repeated setup runs succeeded"

echo "Test 4: HTTP service response"
python3 "$PROJECT_DIR/service/server.py" >"$TEST_LOG" 2>&1 &
SERVER_PID=$!

HTTP_OK=false
for attempt in {1..20}; do
    if curl --silent --fail http://127.0.0.1:8000/ | grep -q 'Sample Service is Running'; then
        HTTP_OK=true
        break
    fi
    sleep 0.25
done

if [[ "$HTTP_OK" != true ]]; then
    echo "FAIL: HTTP service did not return expected content."
    cat "$TEST_LOG"
    exit 1
fi
pass "HTTP service returned expected page"

echo "All tests passed."
