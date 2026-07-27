import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { config, modeForTool } from "../config";
import { DynamicText } from "../components/dynamic-text";
import { renderDiff } from "../diff";
import { previewText } from "../preview";
import { callLine, toolRow } from "../rows";
import type { PrettyTool, Theme, ToolResult } from "../types";
import { dim, isErrorOutput, lineCount, outputText } from "../text";

const BUILT_IN_TOOLS = new Set(["read", "bash", "edit", "write"]);
const wrappedToolNames = new Set<string>();

export function registerExternalRenderer(pi: ExtensionAPI, tool: PrettyTool): void {
	if (!shouldWrap(tool)) return;
	pi.registerTool({
		...tool,
		__piPrettyWrapped: true,
		renderShell: "self",
		renderCall(args: any, theme: Theme) {
			return new DynamicText((width) => renderExternalCall(tool.name, args, theme, width));
		},
		renderResult(result: ToolResult, options: { expanded?: boolean; isPartial?: boolean }, theme: Theme) {
			if (options.isPartial) return new DynamicText((width) => callLine(tool.name, {}, theme, "run", width));
			return new DynamicText((width) => renderExternalResult(tool.name, result, !!options.expanded, theme, width));
		},
	});
	wrappedToolNames.add(tool.name);
}

function shouldWrap(tool: PrettyTool): boolean {
	if (!tool?.name || tool.__piPrettyWrapped || wrappedToolNames.has(tool.name)) return false;
	if (BUILT_IN_TOOLS.has(tool.name)) return false;
	return typeof tool.execute === "function";
}

function renderExternalCall(name: string, args: any, theme: Theme, width: number): string {
	const head = callLine(name, args, theme, "run", width);
	if (name !== "apply_patch") return head;

	const patch = args?.patch || args?.input || args?.diff || "";
	return patch ? `${head}\n${renderDiff(theme, patch, false, config().previewLines + 10, width)}` : head;
}

function renderExternalResult(name: string, result: ToolResult, expanded: boolean, theme: Theme, width: number): string {
	const output = outputText(result);
	const isError = isErrorOutput(output);
	const mode = modeForTool(name);
	const head = toolRow(theme, isError ? "err" : "ok", name, isError ? "failed" : "done");
	if (mode === "hidden") return head;

	const cap = expanded ? config().expandedPreviewLines : config().previewLines;
	const body = mode === "preview" ? previewText(theme, output, cap, width) : dim(theme, `${lineCount(output)} lines`);
	return `${head}\n${body}`;
}
