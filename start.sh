#!/bin/bash
# Clawdbot Iris startup script

# Start vault sync in background (if workspace exists)
if [ -f "$HOME/clawd/vault-sync.sh" ]; then
    echo "[startup] Starting vault-sync..."
    nohup "$HOME/clawd/vault-sync.sh" > /dev/null 2>&1 &
fi

# Pre-start config validation (non-blocking)
echo "[startup] Running config doctor..."
node dist/index.js doctor --non-interactive 2>&1 || echo "[startup] ⚠️  Config issues detected - gateway may fail to start"

# Start Clawdbot Gateway (foreground, no systemd)
exec node dist/index.js gateway --allow-unconfigured
