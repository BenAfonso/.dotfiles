import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { config } from "../config";
import { DynamicText } from "../components/dynamic-text";
import { renderDiff } from "../diff";
import { previewText } from "../preview";
import { callLine, toolRow } from "../rows";
import type { Theme, ToolResult } from "../types";
import { dim, isErrorOutput, lineCount, outputText, safeWidth, truncateText } from "../text";

export function registerBuiltinRenderer(pi: ExtensionAPI, name: "read" | "bash" | "edit" | "write", original: any): void {
	pi.registerTool({
		name,
		label: name,
		description: original.description,
		parameters: original.parameters,
		renderShell: "self",
		async execute(toolCallId: string, params: any, signal: AbortSignal, onUpdate: any, ctx: any) {
			return original.execute(toolCallId, params, signal, onUpdate, ctx);
		},
		renderCall(args: any, theme: Theme) {
			return new DynamicText((width) => callLine(name, args, theme, "run", width));
		},
		renderResult(result: ToolResult, options: { expanded?: boolean; isPartial?: boolean }, theme: Theme) {
			if (options.isPartial) return new DynamicText((width) => callLine(name, {}, theme, "run", width));
			return new DynamicText((width) => renderBuiltinResult(name, result, !!options.expanded, theme, width));
		},
	});
}

function renderBuiltinResult(name: "read" | "bash" | "edit" | "write", result: ToolResult, expanded: boolean, theme: Theme, width: number): string {
	const output = outputText(result);
	const head = resultHeader(name, isErrorOutput(output), theme);
	const body = resultBody(name, result, output, expanded, theme, width);
	return body ? `${head}\n${body}` : head;
}

function resultHeader(name: string, isError: boolean, theme: Theme): string {
	const meta = name === "read" ? "read complete" : name === "bash" ? "command complete" : "file updated";
	return toolRow(theme, isError ? "err" : "ok", name, meta);
}

function resultBody(name: string, result: ToolResult, output: string, expanded: boolean, theme: Theme, width: number): string {
	if (name === "edit" || name === "write") return editWriteBody(result, output, expanded, theme, width);
	if (name === "bash") return bashBody(output, expanded, theme, width);
	if (name === "read") return readBody(output, expanded, theme, width);
	return "";
}

function editWriteBody(result: ToolResult, output: string, expanded: boolean, theme: Theme, width: number): string {
	const diff = result.details?.diff || result.details?.patch || "";
	if (diff) return renderDiff(theme, diff, expanded, config().previewLines + 8, width);
	return dim(theme, truncateText(output.split("\n")[0] || "applied", safeWidth(width) - 4));
}

function bashBody(output: string, expanded: boolean, theme: Theme, width: number): string {
	const cap = expanded ? config().expandedPreviewLines : config().previewLines;
	return config().bashMode === "preview" ? previewText(theme, output, cap, width) : dim(theme, `${lineCount(output)} lines`);
}

function readBody(output: string, expanded: boolean, theme: Theme, width: number): string {
	const cap = expanded ? config().expandedPreviewLines : Math.min(4, config().previewLines);
	return config().readMode === "preview" ? previewText(theme, output, cap, width) : dim(theme, `${lineCount(output)} lines read`);
}
