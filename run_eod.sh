#!/bin/bash
# EOD Trading Cycle — запуск каждый будний день в 18:00 ET
# Запускается автоматически через cron

set -euo pipefail

PROJECT_DIR="/Users/macbook/mcp-alpaca-trading"
LOG_DIR="$PROJECT_DIR/logs"
DATE=$(TZ=America/New_York date +%Y-%m-%d)
LOG_FILE="$LOG_DIR/eod_${DATE}.log"

mkdir -p "$LOG_DIR"

echo "=== EOD START: $(TZ=America/New_York date) ===" >> "$LOG_FILE"

cd "$PROJECT_DIR"

# Запуск Claude Code в non-interactive режиме
# --dangerously-skip-permissions — разрешить авто-выполнение без подтверждений
/Users/macbook/.local/bin/claude \
    --dangerously-skip-permissions \
    --print \
    "run eod" \
    >> "$LOG_FILE" 2>&1

echo "=== EOD END: $(TZ=America/New_York date) ===" >> "$LOG_FILE"
