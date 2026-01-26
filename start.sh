#!/bin/bash
# Clawdbot Iris startup script

# Start vault sync in background (if workspace exists)
if [ -f "$HOME/clawd/vault-sync.sh" ]; then
    echo "[startup] Starting vault-sync..."
    nohup "$HOME/clawd/vault-sync.sh" > /dev/null 2>&1 &
fi

# Start Clawdbot Gateway (foreground, no systemd)
exec node dist/index.js
