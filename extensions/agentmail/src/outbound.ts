import type { AgentMailClient } from "agentmail";
import type { ChannelOutboundAdapter } from "openclaw/plugin-sdk";

import { getClientAndInbox } from "./client.js";
import { getAgentMailRuntime } from "./runtime.js";

/** Sends a reply-all to an email message via AgentMail. */
export async function sendAgentMailReply(params: {
  client: AgentMailClient;
  inboxId: string;
  messageId: string;
  text: string;
  html?: string;
}): Promise<{ messageId: string; threadId: string }> {
  return params.client.inboxes.messages.replyAll(params.inboxId, params.messageId, {
    text: params.text,
    html: params.html,
  });
}

/** Sends a message (reply-only for security). */
async function sendMessage(params: {
  to: string;
  text: string;
  html?: string;
  replyToId?: string;
}): Promise<{ channel: "agentmail"; messageId: string; threadId: string }> {
  const { client, inboxId } = getClientAndInbox();
  
  // SECURITY: Only allow replies, never send new emails to arbitrary addresses
  if (!params.replyToId) {
    throw new Error("AgentMail: Only replies are allowed. Cannot send new emails to arbitrary addresses.");
  }
  
  const result = await client.inboxes.messages.replyAll(inboxId, params.replyToId, { 
    text: params.text, 
    html: params.html 
  });
  return { channel: "agentmail", ...result };
}

/** Outbound adapter for the AgentMail channel. */
export const agentmailOutbound: ChannelOutboundAdapter = {
  // Use batch mode: collect all content, send as single email at the end
  deliveryMode: "batch",
  
  // No chunking for email - send complete response as one message
  // Email has no practical length limit like chat messages do
  textChunkLimit: 100000,

  sendText: ({ to, text, replyToId }) =>
    sendMessage({ to, text, replyToId: replyToId ?? undefined }),

  sendMedia: ({ to, text, mediaUrl, replyToId }) => {
    const fullText = mediaUrl ? `${text}\n\nAttachment: ${mediaUrl}` : text;
    return sendMessage({
      to,
      text: fullText,
      replyToId: replyToId ?? undefined,
    });
  },
};
