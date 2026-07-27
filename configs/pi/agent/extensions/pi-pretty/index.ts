import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { createBashTool, createEditTool, createReadTool, createWriteTool } from "@earendil-works/pi-coding-agent";

import { toggleExtraDetail } from "./src/config";
import { clearLivePreview, clearThinkingStatus, updateLivePreview, updateThinkingStatus } from "./src/live";
import { registerBuiltinRenderer } from "./src/renderers/builtin";
import { registerExternalRenderer } from "./src/renderers/external";
import type { PrettyTool } from "./src/types";

export default function (pi: ExtensionAPI) {
	registerBuiltinToolRenderers(pi);
	registerExtraDetailShortcut(pi);
	registerExternalToolRenderersOnStart(pi);
	registerLivePreviewHandlers(pi);
	registerThinkingStatusHandlers(pi);
}

function registerBuiltinToolRenderers(pi: ExtensionAPI): void {
	const cwd = process.cwd();
	registerBuiltinRenderer(pi, "read", createReadTool(cwd));
	registerBuiltinRenderer(pi, "bash", createBashTool(cwd));
	registerBuiltinRenderer(pi, "edit", createEditTool(cwd));
	registerBuiltinRenderer(pi, "write", createWriteTool(cwd));
}

function registerExtraDetailShortcut(pi: ExtensionAPI): void {
	pi.registerShortcut("ctrl+shift+o", {
		description: "Toggle pi-pretty extra tool detail",
		handler: async (ctx: any) => {
			const enabled = toggleExtraDetail();
			ctx.ui?.notify?.(`pi-pretty extra detail: ${enabled ? "on" : "off"}`, "info");
		},
	});
}

function registerExternalToolRenderersOnStart(pi: ExtensionAPI): void {
	pi.on("session_start", async (_event: any, ctx: any) => {
		try {
			for (const entry of pi.getAllTools?.() || []) {
				registerExternalRenderer(pi, (entry.definition || entry) as PrettyTool);
			}
			pi.refreshTools?.();
			ctx.ui?.notify?.("pi-pretty: Claude-style tool rows enabled", "info");
		} catch (error) {
			const message = error instanceof Error ? error.message : String(error);
			ctx.ui?.notify?.(`pi-pretty: renderer registration skipped (${message})`, "warning");
		}
	});
}

function registerLivePreviewHandlers(pi: ExtensionAPI): void {
	pi.on("tool_execution_update", (event: any, ctx: any) => updateLivePreview(event, ctx));
	pi.on("tool_execution_end", (_event: any, ctx: any) => clearLivePreview(ctx));
}

function registerThinkingStatusHandlers(pi: ExtensionAPI): void {
	pi.on("message_update", (event: any, ctx: any) => updateThinkingStatus(event, ctx));
	pi.on("message_end", (_event: any, ctx: any) => clearThinkingStatus(ctx));
}
