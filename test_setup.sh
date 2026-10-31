#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$PROJECT_DIR/config.env"
LOG_DIR="$PROJECT_DIR/logs"
TEST_LOG="$LOG_DIR/test-service.log"
BACKUP_FILE="$(mktemp)"
SERVER_PID=""
CONFIG_EXISTED=false

mkdir -p "$LOG_DIR"

if [[ -f "$CONFIG_FILE" ]]; then
    cp "$CONFIG_FILE" "$BACKUP_FILE"
    CONFIG_EXISTED=true
fi

cleanup() {
    if [[ -n "$SERVER_PID" ]]; then
        kill "$SERVER_PID" 2>/dev/null || true
        wait "$SERVER_PID" 2>/dev/null || true
    fi

    if [[ "$CONFIG_EXISTED" == true ]]; then
        cp "$BACKUP_FILE" "$CONFIG_FILE"
    else
        rm -f "$CONFIG_FILE"
    fi

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
