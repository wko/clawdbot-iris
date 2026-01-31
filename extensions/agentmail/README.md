# openclaw-agentmail

AgentMail email channel plugin for [OpenClaw](https://openclaw.ai) — secure, reply-only email integration via [AgentMail](https://agentmail.to).

## Features

- **Real-time email via WebSocket** — No polling, instant message delivery
- **Reply-only mode** — Cannot send emails to arbitrary addresses (security hardening)
- **Sender filtering** — `allowFrom` whitelist for allowed senders
- **Thread context** — Full email thread loaded for AI context
- **Attachment support** — Downloads attachments and makes them available to the agent
- **Single email replies** — Batch mode ensures one coherent response per email
- **No agent tools** — Direct email API access disabled for safety

## Security

This plugin has been hardened for security:

1. **Outbound restricted to replies only** — The plugin throws an error if attempting to send a new email without a `replyToId`. Only replies to existing threads are allowed.

2. **Agent tools disabled** — The AgentMail toolkit is not exposed to the agent, preventing programmatic email sending.

3. **Sender filtering** — Only emails from addresses/domains in `allowFrom` trigger the agent.

## Installation

### Option 1: CLI Install (Recommended)

```bash
# Install from GitHub
openclaw plugins install github:wko/openclaw-agentmail

# Enable the plugin
openclaw plugins enable agentmail
```

### Option 2: Development (Linked)

For local development with live changes:

```bash
git clone https://github.com/wko/openclaw-agentmail.git
cd openclaw-agentmail
openclaw plugins install -l .
openclaw plugins enable agentmail
```

The `-l/--link` flag symlinks instead of copying — changes are reflected immediately.

### Option 3: Docker / Containerized

Add to your `package.json`:

```json
{
  "dependencies": {
    "openclaw-agentmail": "github:wko/openclaw-agentmail"
  }
}
```

Then symlink in your `Dockerfile` after `pnpm install`:

```dockerfile
RUN ln -sf /app/node_modules/openclaw-agentmail /app/extensions/agentmail
```

OpenClaw discovers plugins via the `extensions/` folder.
```

## Configuration

Add to your OpenClaw config:

```json5
{
  channels: {
    agentmail: {
      enabled: true,
      token: "am_your_agentmail_api_token",
      emailAddress: "your-inbox@agentmail.to",
      allowFrom: [
        "trusted@example.com",
        "example.org"  // allows all @example.org
      ]
    }
  }
}
```

### Environment Variables

Alternatively, use environment variables:

- `AGENTMAIL_TOKEN` — API token
- `AGENTMAIL_EMAIL_ADDRESS` — Inbox address

## Configuration Options

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `enabled` | boolean | `true` | Enable/disable the channel |
| `token` | string | — | AgentMail API token (required) |
| `emailAddress` | string | — | Inbox email address (required) |
| `allowFrom` | string[] | `[]` | Allowed sender emails/domains (empty = allow all) |
| `blockStreaming` | boolean | `false` | Send intermediate replies as separate emails. When `false` (default), only the final reply is sent as one email. |

## How It Works

1. Plugin connects to AgentMail via WebSocket on gateway start
2. Incoming emails are filtered by `allowFrom`
3. **Attachments are downloaded** and saved to temp directory
4. Full thread context is fetched for the AI
5. Agent receives email with `MediaPath`/`MediaPaths` pointing to attachments
6. Agent's reply is sent via `replyAll` to maintain threading
7. Only replies are allowed — no new emails to arbitrary addresses

## Attachment Handling

Email attachments are automatically downloaded and made available to the agent:

- **Images** (JPEG, PNG, etc.) — Agent can view via vision capabilities
- **Documents** (PDF, TXT, etc.) — Saved locally, path provided to agent
- **All files** — Downloaded to temp directory, paths in `MediaPaths` context field

The agent sees attachments the same way as other channels (Telegram, WhatsApp):

```
MediaPath: /tmp/openclaw-agentmail/<uuid>/invoice.pdf
MediaPaths: ["/tmp/.../invoice.pdf", "/tmp/.../photo.jpg"]
MediaTypes: ["application/pdf", "image/jpeg"]
```

**Note:** Attachments are saved to a temp directory and cleaned up by the OS. For persistent storage, the agent can copy files to a permanent location.

## Credits

Based on [PR #2499](https://github.com/openclaw/openclaw/pull/2499) by [@Haakam21](https://github.com/Haakam21), with security hardening.

## License

MIT
