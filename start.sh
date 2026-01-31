#!/bin/bash
# OpenClaw Iris startup script

# === Config path migration (clawdbot → openclaw) ===
# If old config dir exists but new one doesn't, create symlink
if [ -d "$HOME/.clawdbot" ] && [ ! -e "$HOME/.openclaw" ]; then
    echo "[startup] Migrating config path: ~/.clawdbot → ~/.openclaw (symlink)"
    ln -sfn "$HOME/.clawdbot" "$HOME/.openclaw"
fi

# Start vault sync in background (if workspace exists)
if [ -f "$HOME/clawd/vault-sync.sh" ]; then
    echo "[startup] Starting vault-sync..."
    nohup "$HOME/clawd/vault-sync.sh" > /dev/null 2>&1 &
fi

# Pre-start config validation (non-blocking)
echo "[startup] Running config doctor..."
node dist/index.js doctor --non-interactive 2>&1 || echo "[startup] ⚠️  Config issues detected - gateway may fail to start"

# Start OpenClaw Gateway (foreground, no systemd)
exec node dist/index.js gateway --allow-unconfigured
