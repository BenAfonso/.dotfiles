import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { execFile } from "node:child_process";
import { existsSync } from "node:fs";
import path from "node:path";
import { promisify } from "node:util";

const execFileAsync = promisify(execFile);
const STATE_TYPE = "nvim-bridge-state";
const STATUS_ID = "nvim";

type NvimBridgeState = {
	address?: string;
};

type QuickfixItem = {
	filename: string;
	lnum: number;
	col: number;
	text: string;
};

function isObject(value: unknown): value is Record<string, unknown> {
	return typeof value === "object" && value !== null;
}

function isState(value: unknown): value is NvimBridgeState {
	return isObject(value) && (value.address === undefined || typeof value.address === "string");
}

function quoteVimString(s: string): string {
	return `'${s.replaceAll("'", "''")}'`;
}

function parseQuickfixArgs(args: string, cwd: string): { title: string; items: QuickfixItem[] } {
	let title = "pi quickfix";
	const lines = args.split("\n").map((line) => line.trim()).filter(Boolean);
	if (lines[0]?.startsWith("title=")) title = lines.shift()!.slice("title=".length).trim() || title;
	const items = lines.map((line) => {
		const match = line.match(/^(.+?):(\d+)(?::(\d+))?:(.*)$/);
		if (!match) throw new Error(`Invalid quickfix item: ${line}\nFormat: file:line:col:text or file:line:text`);
		const filename = path.isAbsolute(match[1]!) ? match[1]! : path.resolve(cwd, match[1]!);
		return {
			filename,
			lnum: Number(match[2]),
			col: match[3] ? Number(match[3]) : 1,
			text: match[4]?.trim() || "pi quickfix item",
		};
	});
	return { title, items };
}

function displayAddress(address: string): string {
	return address.length > 32 ? `…/${path.basename(address)}` : address;
}

function addressExists(address: string): boolean {
	// TCP addresses (host:port) cannot be checked with existsSync. Let nvr verify them.
	if (/^\d+\.\d+\.\d+\.\d+:\d+$/.test(address) || /^localhost:\d+$/.test(address) || /^127\.0\.0\.1:\d+$/.test(address)) return true;
	return existsSync(address);
}

async function getTmuxSessionName(): Promise<string | undefined> {
	if (!process.env.TMUX) return undefined;
	try {
		const { stdout } = await execFileAsync("tmux", ["display-message", "-p", "#S"], { timeout: 1000 });
		return stdout.trim() || undefined;
	} catch {
		return undefined;
	}
}

async function tmuxSessionAddress(): Promise<string | undefined> {
	const session = await getTmuxSessionName();
	if (!session) return undefined;
	return `/tmp/nvim-server-${session}`;
}

export default function (pi: ExtensionAPI) {
	let address: string | undefined = process.env.NVIM_LISTEN_ADDRESS || undefined;

	function persist() {
		pi.appendEntry<NvimBridgeState>(STATE_TYPE, { address });
	}

	async function restore(ctx: { sessionManager: { getBranch(): any[] } }) {
		let saved: NvimBridgeState | undefined;
		for (const entry of ctx.sessionManager.getBranch()) {
			if (entry.type === "custom" && entry.customType === STATE_TYPE && isState(entry.data)) saved = entry.data;
		}
		const tmuxAddress = await tmuxSessionAddress();
		address = (saved?.address && addressExists(saved.address))
			? saved.address
			: process.env.NVIM_LISTEN_ADDRESS || (tmuxAddress && addressExists(tmuxAddress) ? tmuxAddress : undefined);
	}

	async function listServers(): Promise<string[]> {
		try {
			const { stdout } = await execFileAsync("nvr", ["--serverlist"], { timeout: 1500 });
			return stdout.split("\n").map((line) => line.trim()).filter(Boolean);
		} catch {
			return [];
		}
	}

	async function resolveAddress(input: string): Promise<string | undefined> {
		if (!input || input === "env") return process.env.NVIM_LISTEN_ADDRESS || await tmuxSessionAddress();
		if (input === "tmux" || input === "session") return tmuxSessionAddress();
		if (input === "auto") {
			const tmuxAddress = await tmuxSessionAddress();
			if (tmuxAddress && addressExists(tmuxAddress)) return tmuxAddress;
			const servers = await listServers();
			return servers.length === 1 ? servers[0] : undefined;
		}
		const servers = await listServers();
		return servers.find((server) => server === input || path.basename(server) === input || server.endsWith(input)) ?? input;
	}

	async function ping(): Promise<{ ok: boolean; detail: string }> {
		if (!address) return { ok: false, detail: "no NVIM_LISTEN_ADDRESS / no binding" };
		if (!addressExists(address)) return { ok: false, detail: `socket missing: ${address}` };
		try {
			const { stdout } = await execFileAsync("nvr", ["--nostart", "--servername", address, "--remote-expr", "v:servername"], { timeout: 1500 });
			return { ok: true, detail: stdout.trim() || address };
		} catch (err) {
			const msg = err instanceof Error ? err.message : String(err);
			return { ok: false, detail: msg };
		}
	}

	async function updateStatus(ctx: { ui: any }) {
		const theme = ctx.ui.theme;
		if (!address) {
			ctx.ui.setStatus(STATUS_ID, theme.fg("dim", "nvim: unbound"));
			return;
		}
		const check = await ping();
		const label = check.ok ? theme.fg("success", "nvim: bound ") : theme.fg("warning", "nvim: stale ");
		ctx.ui.setStatus(STATUS_ID, label + theme.fg("dim", displayAddress(address)));
	}

	async function execNvim(command: string): Promise<string> {
		if (!address) throw new Error("No Neovim binding. Use /nvim:bind or export NVIM_LISTEN_ADDRESS.");
		if (!command.trim()) throw new Error("Usage: /nvim:exec {vim-command}");
		const expr = `execute(${quoteVimString(command.trim())})`;
		const { stdout, stderr } = await execFileAsync("nvr", ["--nostart", "--servername", address, "--remote-expr", expr], { timeout: 5000 });
		return [stdout.trim(), stderr.trim()].filter(Boolean).join("\n");
	}

	async function commandNvim(commands: string[]): Promise<string> {
		if (!address) throw new Error("No Neovim binding. Use /nvim:bind or export NVIM_LISTEN_ADDRESS.");
		const args = ["--nostart", "--servername", address];
		for (const command of commands) args.push("-c", command);
		const { stdout, stderr } = await execFileAsync("nvr", args, { timeout: 5000 });
		return [stdout.trim(), stderr.trim()].filter(Boolean).join("\n");
	}

	async function setQuickfix(title: string, items: QuickfixItem[]): Promise<void> {
		if (!items.length) throw new Error("No quickfix items. Format: file:line:col:text, one per line.");
		const json = JSON.stringify(items);
		await commandNvim([
			`call setqflist([], 'r', {'title': ${quoteVimString(title)}, 'items': json_decode(${quoteVimString(json)})})`,
			"copen",
		]);
	}

	pi.on("session_start", async (_event, ctx) => {
		await restore(ctx);
		await updateStatus(ctx);
	});

	pi.on("session_tree", async (_event, ctx) => {
		await restore(ctx);
		await updateStatus(ctx);
	});

	pi.registerCommand("nvim:status", {
		description: "Show whether this Pi session is bound to a Neovim RPC server",
		handler: async (_args, ctx) => {
			const check = await ping();
			await updateStatus(ctx);
			ctx.ui.notify(address ? `Neovim ${check.ok ? "bound" : "not reachable"}: ${address}\n${check.detail}` : check.detail, check.ok ? "info" : "warning");
		},
	});

	pi.registerCommand("nvim:list", {
		description: "List Neovim RPC servers visible to nvr",
		handler: async (_args, ctx) => {
			const servers = await listServers();
			ctx.ui.notify(servers.length ? `Neovim servers:\n${servers.join("\n")}` : "No Neovim servers found by nvr --serverlist", servers.length ? "info" : "warning");
		},
	});

	pi.registerCommand("nvim:bind", {
		description: "Bind this Pi session to Neovim. Args: address | basename | env | tmux | auto | clear",
		handler: async (args, ctx) => {
			const next = args.trim();
			if (next === "clear" || next === "none" || next === "off") address = undefined;
			else {
				address = await resolveAddress(next);
				if (next === "auto" && !address) {
					const servers = await listServers();
					const tmuxName = await getTmuxSessionName();
					ctx.ui.notify(`Auto-bind found no /tmp/nvim-server-${tmuxName ?? "<tmux-session>"} and requires exactly one fallback server; found ${servers.length}:\n${servers.join("\n")}`, "warning");
					return;
				}
			}
			persist();
			await updateStatus(ctx);
			const check = await ping();
			ctx.ui.notify(address ? `Neovim binding set: ${address}\n${check.ok ? "reachable" : check.detail}` : "Neovim binding cleared", check.ok || !address ? "info" : "warning");
		},
	});

	pi.registerCommand("nvim:exec", {
		description: "Execute a Vim command in the bound Neovim instance",
		handler: async (args, ctx) => {
			try {
				const output = await execNvim(args);
				await updateStatus(ctx);
				ctx.ui.notify(output || `Executed in Neovim: ${args.trim()}`, "info");
			} catch (err) {
				ctx.ui.notify(err instanceof Error ? err.message : String(err), "error");
			}
		},
	});

	pi.registerCommand("nvim:qf", {
		description: "Replace Neovim quickfix list. Lines: [title=...] then file:line:col:text",
		handler: async (args, ctx) => {
			try {
				const { title, items } = parseQuickfixArgs(args, ctx.cwd);
				await setQuickfix(title, items);
				await updateStatus(ctx);
				ctx.ui.notify(`Loaded ${items.length} quickfix item(s) into Neovim: ${title}`, "info");
			} catch (err) {
				ctx.ui.notify(err instanceof Error ? err.message : String(err), "error");
			}
		},
	});

	pi.registerCommand("nvim:qf-clear", {
		description: "Clear Neovim quickfix list",
		handler: async (_args, ctx) => {
			try {
				await commandNvim(["call setqflist([], 'r', {'title': 'pi quickfix', 'items': []})", "cclose"]);
				await updateStatus(ctx);
				ctx.ui.notify("Cleared Neovim quickfix list", "info");
			} catch (err) {
				ctx.ui.notify(err instanceof Error ? err.message : String(err), "error");
			}
		},
	});

	pi.registerCommand("nvim:unbind", {
		description: "Clear Neovim binding for this Pi session",
		handler: async (_args, ctx) => {
			address = undefined;
			persist();
			await updateStatus(ctx);
			ctx.ui.notify("Neovim binding cleared", "info");
		},
	});
}
