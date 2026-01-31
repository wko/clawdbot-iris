#!/bin/bash
# OpenClaw Iris startup script

# === Config path migration (clawdbot → openclaw) ===
# If old config dir exists but new one doesn't, create symlink
if [ -d "$HOME/.clawdbot" ] && [ ! -e "$HOME/.openclaw" ]; then
    echo "[startup] Migrating config path: ~/.clawdbot → ~/.openclaw (symlink)"
    ln -sfn "$HOME/.clawdbot" "$HOME/.openclaw"
fi

# Start cron daemon
echo "[startup] Starting cron daemon..."
cron

# Load user crontab if it exists in workspace
if [ -f "$HOME/clawd/crontab" ]; then
    echo "[startup] Loading crontab from workspace..."
    crontab "$HOME/clawd/crontab"
fi

# Start vault sync in background (if workspace exists)
if [ -f "$HOME/clawd/vault-sync.sh" ]; then
    echo "[startup] Starting vault-sync..."
    nohup "$HOME/clawd/vault-sync.sh" > /dev/null 2>&1 &
fi

# Pre-start config validation (non-blocking)
echo "[startup] Running config doctor..."
node dist/index.js doctor --non-interactive 2>&1 || echo "[startup] ⚠️  Config issues detected - gateway may fail to start"

# === Resilient gateway startup ===
# If gateway crashes (e.g. invalid config), keep container alive for SSH debugging
MAX_FAST_RESTARTS=3
FAST_RESTART_WINDOW=30
restart_count=0
last_restart=0

while true; do
    now=$(date +%s)
    
    # Reset counter if enough time passed since last restart
    if [ $((now - last_restart)) -gt $FAST_RESTART_WINDOW ]; then
        restart_count=0
    fi
    
    echo "[startup] Starting OpenClaw Gateway..."
    node dist/index.js gateway --allow-unconfigured
    exit_code=$?
    last_restart=$(date +%s)
    restart_count=$((restart_count + 1))
    
    echo "[startup] Gateway exited with code $exit_code (restart $restart_count/$MAX_FAST_RESTARTS)"
    
    # If crashing too fast, go into recovery mode
    if [ $restart_count -ge $MAX_FAST_RESTARTS ]; then
        echo ""
        echo "╔════════════════════════════════════════════════════════════════╗"
        echo "║  🛑 RECOVERY MODE - Gateway crashed $MAX_FAST_RESTARTS times in ${FAST_RESTART_WINDOW}s          ║"
        echo "║                                                                ║"
        echo "║  Container kept alive for SSH debugging.                       ║"
        echo "║  Config: ~/.clawdbot/openclaw.json                             ║"
        echo "║                                                                ║"
        echo "║  Fix config, then: pkill -f 'sleep infinity' to restart        ║"
        echo "╚════════════════════════════════════════════════════════════════╝"
        echo ""
        sleep infinity
    fi
    
    # Brief pause before restart
    sleep 2
done
