import type { ChannelAgentTool } from "openclaw/plugin-sdk";

/**
 * AgentMail agent tools are DISABLED for security.
 * 
 * The toolkit would give the agent direct API access to send emails
 * to arbitrary addresses. For safety, we only allow automatic replies
 * to incoming emails (handled by the monitor + outbound adapter).
 */
export function createAgentMailTools(): ChannelAgentTool[] {
  // SECURITY: No direct email tools for agent - reply-only mode
  return [];
}
