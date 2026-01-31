# Changelog

## 1.1.0 (2026-01-31)

### Features

- **Attachment support** — Downloads email attachments and provides paths to agent
- **Batch delivery mode** — Single coherent email reply instead of chunked messages

## 1.0.0 (2026-01-31)

Initial release with security hardening.

### Features

- WebSocket-based real-time email reception
- Reply-only mode (cannot send to arbitrary addresses)
- Sender filtering via `allowFrom`
- Full thread context for AI
- Reply-all for proper email threading

### Security

- Outbound restricted to replies only
- Agent tools disabled
- Based on PR #2499 with additional hardening
