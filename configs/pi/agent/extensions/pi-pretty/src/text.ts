import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";
import type { Theme, ToolResult } from "./types";

export function truncateText(text = "", width = 88): string {
	return truncateToWidth(text, Math.max(1, width), "…");
}

export function safeWidth(width: number): number {
	return Math.max(24, Math.min(width || 80, 120));
}

export function outputText(result?: ToolResult): string {
	return result?.content?.find((content) => content.type === "text")?.text || "";
}

export function lines(text = ""): string[] {
	return text.replace(/\r\n/g, "\n").split("\n");
}

export function lineCount(text = ""): number {
	return text ? lines(text).length : 0;
}

export function visibleLen(text: string): number {
	return visibleWidth(text);
}

export function padVisible(text: string, width: number): string {
	return text + " ".repeat(Math.max(0, width - visibleWidth(text)));
}

export function themed(theme: Theme, name: string, text: string): string {
	try {
		return theme.fg(name, text);
	} catch {
		return text;
	}
}

export function dim(theme: Theme, text: string): string {
	return themed(theme, "dim", text);
}

export function isErrorOutput(output: string): boolean {
	return /^error\b/i.test(output) || /exit code: [1-9]/.test(output) || /error|failed|exception/i.test(output);
}
