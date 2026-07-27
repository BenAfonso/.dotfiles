import { existsSync, readFileSync, statSync } from "node:fs";
import { join } from "node:path";
import { config } from "./config";
import type { Config, Theme } from "./types";

let cachedThemeFile: string | undefined;
let cachedThemeMtime = 0;
let cachedThemeJson: any;

export function diffBackground(theme: Theme, key: keyof Required<Config>["diffColors"], text: string): string {
	const value = config().diffColors[key];
	if (!value) return text;
	if (value.startsWith("#")) return bgHex(value, text);

	const themedHex = activeThemeColor(value);
	if (themedHex) return bgHex(themedHex, text);

	try {
		return theme.bg?.(value, text) || text;
	} catch {
		return text;
	}
}

function bgHex(hex: string | undefined, text: string): string {
	if (!hex || !/^#[0-9a-fA-F]{6}$/.test(hex)) return text;
	const r = Number.parseInt(hex.slice(1, 3), 16);
	const g = Number.parseInt(hex.slice(3, 5), 16);
	const b = Number.parseInt(hex.slice(5, 7), 16);
	return `\x1b[48;2;${r};${g};${b}m${text}\x1b[49m`;
}

function activeThemeColor(token: string): string | undefined {
	try {
		const settingsPath = join(process.env.HOME || "", ".pi/agent/settings.json");
		const settings = JSON.parse(readFileSync(settingsPath, "utf8"));
		const themeName = settings.theme;
		const dirs = [join(process.env.HOME || "", ".pi/agent/themes"), join(process.cwd(), ".pi/themes")];

		for (const dir of dirs) {
			const file = join(dir, `${themeName}.json`);
			if (!existsSync(file)) continue;
			loadThemeFile(file);
			return resolveThemeToken(token);
		}
	} catch {
		return undefined;
	}
	return undefined;
}

function loadThemeFile(file: string): void {
	const mtime = statSync(file).mtimeMs;
	if (cachedThemeFile === file && cachedThemeMtime === mtime) return;
	cachedThemeFile = file;
	cachedThemeMtime = mtime;
	cachedThemeJson = JSON.parse(readFileSync(file, "utf8"));
}

function resolveThemeToken(token: string): string | undefined {
	const raw = cachedThemeJson?.colors?.[token] ?? cachedThemeJson?.vars?.[token];
	if (typeof raw !== "string") return undefined;
	if (raw.startsWith("#")) return raw;
	const resolved = cachedThemeJson?.vars?.[raw];
	return typeof resolved === "string" && resolved.startsWith("#") ? resolved : undefined;
}
