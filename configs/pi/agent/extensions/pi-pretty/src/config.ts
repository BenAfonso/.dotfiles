import { existsSync, readFileSync, statSync } from "node:fs";
import { join } from "node:path";
import type { Config, OutputMode } from "./types";

export const DEFAULT_CONFIG: Required<Config> = {
	mode: "border",
	readMode: "summary",
	searchMode: "preview",
	bashMode: "preview",
	mcpMode: "summary",
	groupToolCalls: true,
	themeAdaptive: true,
	previewLines: 6,
	expandedPreviewLines: 28,
	wideDiffAt: 110,
	diffColors: {
		bgAdd: "toolDiffAddedBg",
		bgDel: "toolDiffRemovedBg",
		bgAddHighlight: "toolDiffAddedBg",
		bgDelHighlight: "toolDiffRemovedBg",
	},
};

let cachedConfigPath: string | undefined;
let cachedConfigMtime = 0;
let cachedConfig: Required<Config> = DEFAULT_CONFIG;
let extraDetail = false;

export function config(): Required<Config> {
	for (const path of settingsCandidates()) {
		const loaded = loadConfigFrom(path);
		if (loaded) return loaded;
	}
	return DEFAULT_CONFIG;
}

export function effectivePreviewCap(cap: number): number {
	return extraDetail ? Math.max(cap, config().expandedPreviewLines) : cap;
}

export function toggleExtraDetail(): boolean {
	extraDetail = !extraDetail;
	return extraDetail;
}

export function modeForTool(name: string): OutputMode {
	const current = config();
	if (/read/i.test(name)) return current.readMode;
	if (/grep|find|search|rg/i.test(name)) return current.searchMode;
	if (/mcp|ctx_|context/i.test(name)) return current.mcpMode;
	return "summary";
}

function settingsCandidates(): string[] {
	return [join(process.env.HOME || "", ".pi/agent/settings.json"), join(process.cwd(), ".pi/settings.json")];
}

function loadConfigFrom(path: string): Required<Config> | undefined {
	try {
		if (!existsSync(path)) return undefined;
		const mtime = statSync(path).mtimeMs;
		if (cachedConfigPath === path && cachedConfigMtime === mtime) return cachedConfig;

		const settings = JSON.parse(readFileSync(path, "utf8"));
		cachedConfigPath = path;
		cachedConfigMtime = mtime;
		cachedConfig = {
			...DEFAULT_CONFIG,
			...(settings.piPretty || {}),
			diffColors: {
				...DEFAULT_CONFIG.diffColors,
				...(settings.diffColors || {}),
				...(settings.piPretty?.diffColors || {}),
			},
		};
		return cachedConfig;
	} catch {
		return undefined;
	}
}
