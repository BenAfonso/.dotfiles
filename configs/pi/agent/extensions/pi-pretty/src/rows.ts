import type { Theme } from "./types";
import { dim, themed, truncateText, visibleLen, safeWidth } from "./text";

const FILE_ICONS: Record<string, string> = {
	ts: "󰛦",
	tsx: "󰜈",
	js: "󰌞",
	jsx: "󰜈",
	json: "󰘦",
	md: "󰍔",
	py: "󰌠",
	rs: "󱘗",
	go: "󰟓",
	sh: "󰆍",
	css: "󰌜",
	html: "󰌝",
	yml: "󰈙",
	yaml: "󰈙",
};

type Status = "run" | "ok" | "err" | "wait";

export function branch(theme: Theme, last = false): string {
	return dim(theme, last ? "└─" : "├─");
}

export function toolRow(theme: Theme, status: Status, label: string, meta = "", extra = ""): string {
	const title = themed(theme, "toolTitle", theme.bold(label));
	const suffix = meta ? ` ${dim(theme, "›")} ${meta}` : "";
	return `${statusDot(theme, status)} ${title}${suffix}${extra ? `\n${extra}` : ""}`;
}

export function callLine(name: string, args: any, theme: Theme, status: Status = "run", width = 80): string {
	const maxMeta = Math.max(12, safeWidth(width) - visibleLen(name) - 8);
	return toolRow(theme, status, name, callMeta(name, args, maxMeta));
}

function callMeta(name: string, args: any, maxWidth: number): string {
	if (name === "bash") return `$ ${truncateText(args?.command || "", maxWidth - 2)}`;
	if (/search/i.test(name) && args?.query) return ` ${truncateText(args.query, maxWidth - 2)}`;

	const path = pathFromArgs(args);
	return path ? `${fileIcon(path)} ${truncateText(path, maxWidth - 2)}` : "";
}

function pathFromArgs(args: any): string {
	return args?.path || args?.file_path || args?.filePath || args?.filename || args?.url || "";
}

function fileIcon(pathLike = ""): string {
	const ext = pathLike.split(".").pop()?.toLowerCase() || "";
	return FILE_ICONS[ext] || "󰈔";
}

function statusDot(theme: Theme, status: Status): string {
	const color = status === "ok" ? "success" : status === "err" ? "error" : status === "run" ? "warning" : "muted";
	const dot = status === "run" || status === "ok" || status === "err" ? "●" : "○";
	return themed(theme, color, dot);
}
