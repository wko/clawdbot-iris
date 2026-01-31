# AGENTS.md — openclaw-agentmail

OpenClaw plugin for AgentMail email channel integration.

## Project Overview

This is a channel plugin that enables OpenClaw to receive and reply to emails via [AgentMail](https://agentmail.to).

## Architecture

```
src/
├── channel.ts      # Main plugin definition, capabilities, config
├── monitor.ts      # WebSocket listener, message handling, attachment download
├── outbound.ts     # Reply sending (reply-only, no arbitrary sends)
├── filtering.ts    # allowFrom sender filtering
├── client.ts       # AgentMail API client singleton
├── thread.ts       # Thread fetching and formatting
├── attachment.ts   # Attachment metadata formatting
├── onboarding.ts   # Interactive setup flow
├── accounts.ts     # Account resolution
├── tools.ts        # Agent tools (disabled for security)
├── utils.ts        # Helper functions
└── *.test.ts       # Unit tests for each module
```

## Security Model

**This plugin is hardened for security:**

1. **Reply-only mode** — `outbound.ts` throws if no `replyToId`. Cannot send to arbitrary addresses.
2. **No agent tools** — `tools.ts` returns empty array. Agent cannot programmatically send emails.
3. **Sender filtering** — Only emails from `allowFrom` addresses/domains trigger the agent.

## Key Decisions

- **Batch delivery mode** — Emails are sent as single complete messages, not chunked like chat.
- **Attachments downloaded locally** — Saved to temp dir, paths passed to agent via `MediaPath`/`MediaPaths`.
- **WebSocket for real-time** — No polling needed; instant email delivery.

## Development

```bash
# Install dependencies
pnpm install

# Run tests
pnpm test

# Type check
pnpm typecheck

# Lint
pnpm lint
```

## Testing

Tests use vitest. Each module has corresponding `.test.ts` file.

```bash
pnpm test           # Run all tests
pnpm test:watch     # Watch mode
```

## Deployment

Published to npm as `openclaw-agentmail`. Users install via:

```bash
openclaw plugins install openclaw-agentmail
```

## Related

- [AgentMail API Docs](https://docs.agentmail.to)
- [OpenClaw Plugin Docs](https://docs.openclaw.ai/plugin)
- Based on [PR #2499](https://github.com/openclaw/openclaw/pull/2499)
