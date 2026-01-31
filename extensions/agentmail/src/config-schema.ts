import { z } from "zod";

/**
 * Zod schema for AgentMail channel configuration.
 * Validates user-provided config at runtime.
 */
export const AgentMailConfigSchema = z.object({
  /** Account name for identifying this AgentMail configuration. */
  name: z.string().optional(),
  /** If false, do not start AgentMail channel. Default: true. */
  enabled: z.boolean().optional(),
  /** AgentMail API token (required). */
  token: z.string().optional(),
  /** AgentMail inbox email address to monitor (required). */
  emailAddress: z.string().optional(),
  /** Allowed sender emails/domains. Empty = allow all. */
  allowFrom: z.array(z.string()).optional(),
  /** 
   * Enable block streaming (send intermediate replies as separate emails).
   * Default: false (only send final reply as one email).
   */
  blockStreaming: z.boolean().optional(),
});
