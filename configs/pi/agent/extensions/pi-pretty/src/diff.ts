import { config, effectivePreviewCap } from "./config";
import { diffBackground } from "./theme-colors";
import type { Theme } from "./types";
import { dim, lines, lineCount, padVisible, safeWidth, themed, truncateText } from "./text";

export function renderDiff(theme: Theme, diff = "", expanded = false, max = 18, renderWidth = 80): string {
	const width = safeWidth(renderWidth);
	const contentWidth = Math.max(16, width - 10);
	const cap = effectivePreviewCap(expanded ? Math.max(max, config().expandedPreviewLines) : max);
	const rows = [truncateText(statBar(theme, diff), contentWidth), ...diffRows(theme, diff, cap, contentWidth)];
	return frame(theme, rows, width).join("\n");
}

function diffRows(theme: Theme, diff: string, cap: number, contentWidth: number): string[] {
	const rows: string[] = [];
	for (const line of lines(diff).slice(0, cap)) {
		rows.push(formatDiffLine(theme, line, contentWidth));
	}

	const total = lineCount(diff);
	if (total > cap) {
		rows.push(dim(theme, truncateText(`╰─ diff collapsed: ${total - cap} more lines; expand for full preview`, contentWidth)));
	}
	return rows;
}

function formatDiffLine(theme: Theme, line: string, contentWidth: number): string {
	const clipped = truncateText(line, contentWidth - 2);
	if (line.startsWith("+") && !line.startsWith("+++")) {
		return diffBackground(theme, "bgAdd", themed(theme, "toolDiffAdded", `│ ${clipped}`));
	}
	if (line.startsWith("-") && !line.startsWith("---")) {
		return diffBackground(theme, "bgDel", themed(theme, "toolDiffRemoved", `│ ${clipped}`));
	}
	if (line.startsWith("@@")) return themed(theme, "accent", `│ ${clipped}`);
	return dim(theme, `│ ${clipped}`);
}

function statBar(theme: Theme, diff = ""): string {
	const stats = diffStats(diff);
	const add = themed(theme, "success", `+${stats.additions}`);
	const del = themed(theme, "error", `-${stats.removals}`);
	const meta = dim(theme, `${stats.hunks} hunk${stats.hunks === 1 ? "" : "s"}`);
	const width = Math.min(18, Math.max(4, stats.additions + stats.removals));
	const addWidth = stats.additions + stats.removals ? Math.round((width * stats.additions) / (stats.additions + stats.removals)) : 0;
	const bar = themed(theme, "success", "━".repeat(addWidth)) + themed(theme, "error", "━".repeat(width - addWidth));
	return `${add} ${del} ${bar} ${meta}`;
}

function diffStats(diff = "") {
	let additions = 0;
	let removals = 0;
	let hunks = 0;
	let files = 0;
	for (const line of lines(diff)) {
		if (line.startsWith("@@")) hunks++;
		else if (line.startsWith("diff --git") || line.startsWith("--- ")) files++;
		else if (line.startsWith("+") && !line.startsWith("+++")) additions++;
		else if (line.startsWith("-") && !line.startsWith("---")) removals++;
	}
	return { additions, removals, hunks, files: Math.max(1, files || 1) };
}

function frame(theme: Theme, rows: string[], renderWidth: number): string[] {
	const width = Math.max(24, safeWidth(renderWidth) - 4);
	const title = themed(theme, "toolTitle", "diff");
	const top = `${themed(theme, "borderMuted", "╭─")} ${title} ${themed(theme, "borderMuted", "─".repeat(Math.max(0, width - 7)) + "╮")}`;
	const bottom = themed(theme, "borderMuted", `╰${"─".repeat(Math.max(0, width))}╯`);
	const framedRows = rows.map((row) => `${themed(theme, "borderMuted", "│")} ${padVisible(row, width - 2)} ${themed(theme, "borderMuted", "│")}`);
	return [top, ...framedRows, bottom];
}
