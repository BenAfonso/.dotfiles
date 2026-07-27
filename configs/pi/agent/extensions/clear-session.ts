import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";

export default function(pi: ExtensionAPI) {
  // User types /clear → command handler catches it directly
  pi.registerCommand("clear", {
    description: "Clear the session and start fresh",
    handler: async (_args, ctx) => {
      // const ok = await ctx.ui.confirm("Clear session?", "Start a fresh session?");
      // if (!ok) return;

      ctx.ui.notify("Clearing session...", "info");
      await ctx.newSession();
    },
  });

  // LLM calls clear_session tool → queues /clear as a follow-up
  pi.registerTool({
    name: "clear_session",
    label: "Clear Session",
    description: "Clear the conversation context and start a fresh session. Use this when the user asks to clear, reset, start fresh, or wipe the conversation.",
    parameters: Type.Object({}),
    async execute() {
      pi.sendUserMessage("/clear", { deliverAs: "followUp" });
      return {
        content: [{ type: "text", text: "Queued session clear." }],
        details: {},
      };
    },
  });
}
