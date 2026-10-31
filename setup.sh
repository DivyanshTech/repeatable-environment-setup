#!/usr/bin/env bash

set -Eeuo pipefail

PROJECT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="$PROJECT_DIR/logs"
LOG_FILE="$LOG_DIR/setup.log"
CONFIG_FILE="$PROJECT_DIR/config.env"
SERVICE_FILE="$PROJECT_DIR/service/server.py"
HTML_FILE="$PROJECT_DIR/service/index.html"

mkdir -p "$LOG_DIR"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

on_error() {
    local exit_code=$?
    trap - ERR
    log "ERROR: Setup failed at line $1 (exit code $exit_code)."
    exit "$exit_code"
}

trap 'on_error $LINENO' ERR

check_command() {
    local command_name="$1"

    if command -v "$command_name" >/dev/null 2>&1; then
        log "OK: Required command '$command_name' is installed."
    else
        log "ERROR: Required command '$command_name' is missing."
        return 1
    fi
}

ensure_config() {
    if [[ -f "$CONFIG_FILE" ]]; then
        log "Existing configuration preserved."
    else
        printf 'APP_ENV=development\nAPP_HOST=127.0.0.1\nAPP_PORT=8000\n' > "$CONFIG_FILE"
        log "Created default configuration."
    fi
}

log "Starting environment setup."

check_command bash
check_command python3
check_command git

if [[ ! -f "$SERVICE_FILE" ]]; then
    log "ERROR: Service file not found: $SERVICE_FILE"
    exit 1
fi

if [[ ! -f "$HTML_FILE" ]]; then
    log "ERROR: HTML page not found: $HTML_FILE"
    exit 1
fi

log "Service files verified."

ensure_config

log "Environment setup completed successfully."
