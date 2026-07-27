/**
 * Minimal subagents extension.
 *
 * Registers a single `subagent` tool with three agents: scout, researcher, worker.
 * Supports single and parallel execution. Output is verbal only (no file handoff).
 */
import { spawn, spawnSync } from "node:child_process";
import * as fs from "node:fs";
import * as os from "node:os";
import * as path from "node:path";
import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { getMarkdownTheme, parseFrontmatter, truncateHead, withFileMutationQueue, DEFAULT_MAX_BYTES, DEFAULT_MAX_LINES } from "@earendil-works/pi-coding-agent";
import { Container, Key, Markdown, Spacer, Text, matchesKey, truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";
import { Type } from "typebox";

// ── Types ──────────────────────────────────────────────────────────────

export interface AgentConfig {
	name: string;
	description: string;
	tools: string[];
	model: string;
	systemPrompt: string;
	filePath: string;
}

interface ToolEvent {
	tool: string;
	args: string;
}

interface AgentProgress {
	agent: string;
	status: "pending" | "running" | "completed" | "failed";
	task: string;
	currentTool?: string;
	currentToolArgs?: string;
	recentTools: ToolEvent[];
	toolCount: number;
	tokens: number;
	durationMs: number;
	lastMessage: string;
	error?: string;
}

interface AgentResult {
	agent: string;
	task: string;
	output: string;
	exitCode: number;
	progress: AgentProgress;
	model?: string;
	usage: { input: number; output: number; cacheRead: number; cacheWrite: number; cost: number; turns: number };
}

interface Details {
	mode: "single" | "parallel";
	results: AgentResult[];
}

type TaskStatus = "pending" | "running" | "completed" | "failed";
interface TaskRecord {
	id: string;
	agent: string;
	task: string;
	cwd: string;
	status: TaskStatus;
	createdAt: number;
	updatedAt: number;
	sessionDir?: string;
	tmuxSession?: string;
	tmuxWindowId?: string;
	progress?: AgentProgress;
	result?: AgentResult;
	error?: string;
}
interface PersistedTasks { tasks: TaskRecord[] }
const TASKS_STATE_TYPE = "pi-subagent-tasks";

// ── Config ─────────────────────────────────────────────────────────────

interface ExtensionConfig {
	maxConcurrency?: number;
	piDevCommand?: string;
}

const EXT_DIR = path.dirname(new URL(import.meta.url).pathname);
const AGENTS_DIR = path.join(EXT_DIR, "agents");
const TOOLS_DIR = path.join(EXT_DIR, "tools");
const CONFIG_PATH = path.join(EXT_DIR, "config.json");
const DEFAULT_MAX_CONCURRENCY = 4;

function loadConfig(): ExtensionConfig {
	try {
		if (fs.existsSync(CONFIG_PATH)) {
			return JSON.parse(fs.readFileSync(CONFIG_PATH, "utf-8")) as ExtensionConfig;
		}
	} catch { }
	return {};
}

// Built-in tools that pi provides natively (no extension needed)
const BUILTIN_TOOLS = new Set(["read", "write", "edit", "bash", "grep", "find", "ls"]);

// Custom tools that require loading an extension into the subagent process
const EXT_BASE = path.join(process.env.HOME || "~", ".pi", "agent", "extensions");
const CUSTOM_TOOL_EXTENSIONS: Record<string, string> = {
	web_search: path.join(EXT_BASE, "web-search", "index.ts"),
	web_fetch: path.join(EXT_BASE, "web-fetch", "index.ts"),
	safe_bash: path.join(TOOLS_DIR, "safe-bash.ts"),
	video_extract: path.join(EXT_BASE, "video-extract", "index.ts"),
	youtube_search: path.join(EXT_BASE, "youtube-search", "index.ts"),
	google_image_search: path.join(EXT_BASE, "google-image-search", "index.ts"),
};

// ── Agent Discovery & Registration ────────────────────────────────────

let agents: AgentConfig[] = [];

export function registerAgent(config: AgentConfig): void {
	if (agents.find((a) => a.name === config.name)) {
		throw new Error(`Agent already registered: ${config.name}`);
	}
	agents.push(config);
}

export function unregisterAgent(name: string): void {
	agents = agents.filter((a) => a.name !== name);
}

// Expose registration functions globally so other extensions loaded via jiti
// (which creates separate module instances) can access the shared agents array.
(globalThis as any).__pi_subagents = { registerAgent, unregisterAgent };

function loadAgents(): AgentConfig[] {
	const agents: AgentConfig[] = [];
	if (!fs.existsSync(AGENTS_DIR)) return agents;
	for (const entry of fs.readdirSync(AGENTS_DIR)) {
		if (!entry.endsWith(".md")) continue;
		const filePath = path.join(AGENTS_DIR, entry);
		const content = fs.readFileSync(filePath, "utf-8");
		const { frontmatter, body } = parseFrontmatter<Record<string, string>>(content);
		if (!frontmatter.name) continue;
		const tools = (frontmatter.tools || "")
			.split(",")
			.map((t) => t.trim())
			.filter(Boolean);
		agents.push({
			name: frontmatter.name,
			description: frontmatter.description || "",
			tools,
			model: frontmatter.model || "openai-codex/gpt-5.3-codex",
			systemPrompt: body,
			filePath,
		});
	}
	return agents;
}

// ── Pi Binary Resolution ──────────────────────────────────────────────

function resolvePiBinary(): { command: string; baseArgs: string[] } {
	// Resolve the pi entry point from process.argv[1]
	const entry = process.argv[1];
	if (entry) {
		try {
			const realEntry = fs.realpathSync(entry);
			if (/\.(?:mjs|cjs|js)$/i.test(realEntry)) {
				return { command: process.execPath, baseArgs: [realEntry] };
			}
		} catch { }
	}
	return { command: "pi", baseArgs: [] };
}

// ── Formatting Utilities ──────────────────────────────────────────────

function formatTokens(n: number): string {
	return n < 1000 ? String(n) : n < 10000 ? `${(n / 1000).toFixed(1)}k` : `${Math.round(n / 1000)}k`;
}

function formatDuration(ms: number): string {
	if (ms < 1000) return `${ms}ms`;
	if (ms < 60000) return `${(ms / 1000).toFixed(1)}s`;
	return `${Math.floor(ms / 60000)}m${Math.floor((ms % 60000) / 1000)}s`;
}

function formatToolPreview(name: string, args: Record<string, unknown>): string {
	switch (name) {
		case "bash":
		case "safe_bash":
			return `$ ${((args.command as string) || "").slice(0, 80)}`;
		case "read":
			return `read ${(args.path as string) || ""}`;
		case "write":
			return `write ${(args.path as string) || ""}`;
		case "edit":
			return `edit ${(args.path as string) || ""}`;
		case "grep":
			return `grep ${(args.pattern as string) || ""}`;
		case "find":
			return `find ${(args.pattern as string) || ""}`;
		case "ls":
			return `ls ${(args.path as string) || "."}`;
		case "web_search":
			return `search "${(args.query as string) || ""}"`;
		case "web_fetch":
			return `fetch ${(args.url as string) || ""}`;
		default: {
			const s = JSON.stringify(args);
			return `${name} ${s.slice(0, 60)}`;
		}
	}
}

function truncLine(text: string, maxWidth: number): string {
	if (visibleWidth(text) <= maxWidth) return text;
	// Simple truncation - strip to fit
	let result = "";
	let width = 0;
	for (let i = 0; i < text.length; i++) {
		const ch = text[i];
		// Skip ANSI escape sequences
		if (ch === "\x1b") {
			const match = text.slice(i).match(/^\x1b\[[0-9;]*m/);
			if (match) {
				result += match[0];
				i += match[0].length - 1;
				continue;
			}
		}
		if (width >= maxWidth - 1) {
			return result + "…";
		}
		result += ch;
		width++;
	}
	return result;
}

// ── Subagent Execution ────────────────────────────────────────────────

async function buildPiArgs(
	agent: AgentConfig,
	task: string,
	cwd: string,
	sessionDir?: string,
): Promise<{ args: string[]; tempDir: string }> {
	const piBin = resolvePiBinary();
	const tempDir = await fs.promises.mkdtemp(path.join(os.tmpdir(), "pi-sub-"));

	// Write system prompt to temp file
	const promptPath = path.join(tempDir, `${agent.name}.md`);
	await withFileMutationQueue(promptPath, async () => {
		await fs.promises.writeFile(promptPath, agent.systemPrompt, { encoding: "utf-8", mode: 0o600 });
	});

	const args = [...piBin.baseArgs, "--mode", "json", "-p", "--no-skills"];
	if (sessionDir) args.push("--session-dir", sessionDir);
	else args.push("--no-session");

	// Separate builtin tools from custom tools
	const builtinTools: string[] = [];
	const extensionPaths = new Set<string>();

	for (const tool of agent.tools) {
		if (BUILTIN_TOOLS.has(tool)) {
			builtinTools.push(tool);
		} else if (CUSTOM_TOOL_EXTENSIONS[tool]) {
			extensionPaths.add(CUSTOM_TOOL_EXTENSIONS[tool]);
		}
	}

	// Use --no-extensions then add only what we need
	args.push("--no-extensions");

	if (builtinTools.length > 0) {
		args.push("--tools", builtinTools.join(","));
	} else {
		// No builtin tools needed — disable defaults so only extension tools are available
		args.push("--no-tools");
	}

	for (const extPath of extensionPaths) {
		args.push("--extension", extPath);
	}

	args.push("--models", agent.model);
	args.push("--append-system-prompt", promptPath);

	// Handle long tasks by writing to file
	const TASK_LIMIT = 8000;
	if (task.length > TASK_LIMIT) {
		const taskPath = path.join(tempDir, "task.md");
		await withFileMutationQueue(taskPath, async () => {
			await fs.promises.writeFile(taskPath, `Task: ${task}`, { encoding: "utf-8", mode: 0o600 });
		});
		args.push(`@${taskPath}`);
	} else {
		args.push(`Task: ${task}`);
	}

	return { args: [piBin.command, ...args], tempDir };
}

function extractTextFromContent(content: unknown): string {
	if (!content) return "";
	if (typeof content === "string") return content;
	if (Array.isArray(content)) {
		return content
			.filter((c: any) => c.type === "text")
			.map((c: any) => c.text)
			.join("\n");
	}
	return "";
}

function extractToolArgsPreview(args: Record<string, unknown>): string {
	if (args.command) return String(args.command).slice(0, 100);
	if (args.path) return String(args.path);
	if (args.query) return `"${String(args.query).slice(0, 80)}"`;
	if (args.url) return String(args.url);
	if (args.pattern) return String(args.pattern);
	const s = JSON.stringify(args);
	return s.length > 80 ? s.slice(0, 80) + "…" : s;
}

function shellQuote(s: string): string {
	return `'${s.replace(/'/g, `'\\''`)}'`;
}

function hasTmux(): boolean {
	return spawnSync("tmux", ["-V"], { stdio: "ignore" }).status === 0;
}

function currentTmuxArgs(args: string[]): string[] {
	// If Pi is already running inside tmux, force all tmux commands to use that
	// exact server socket. Otherwise a default-server attach can detach/switch the
	// wrong client or create a separate server.
	const socketPath = process.env.TMUX?.split(",")[0];
	return socketPath ? ["-S", socketPath, ...args] : args;
}

function tmuxHasSession(name: string): boolean {
	return spawnSync("tmux", currentTmuxArgs(["has-session", "-t", name]), { stdio: "ignore" }).status === 0;
}

function tmuxTargetExists(target: string): boolean {
	return spawnSync("tmux", currentTmuxArgs(["display-message", "-p", "-t", target, "#{window_id}"]), { stdio: "ignore" }).status === 0;
}

function selectTmuxWindow(target: string): boolean {
	return spawnSync("tmux", currentTmuxArgs(["select-window", "-t", target]), { stdio: "ignore" }).status === 0;
}

function killTmuxWindow(target: string): boolean {
	return spawnSync("tmux", currentTmuxArgs(["kill-window", "-t", target]), { stdio: "ignore" }).status === 0;
}

function killTmuxSession(target: string): boolean {
	return spawnSync("tmux", currentTmuxArgs(["kill-session", "-t", target]), { stdio: "ignore" }).status === 0;
}

function attachTmuxSessionOutsideTmux(name: string): boolean {
	// Only attach when Pi is not already running inside tmux. Attaching/switching
	// from inside Pi's own tmux client can make the current client detach/exit.
	if (process.env.TMUX) return false;
	const attached = spawnSync("tmux", currentTmuxArgs(["attach-session", "-t", name]), { stdio: "inherit" });
	return attached.status === 0;
}

function buildInteractivePiDevArgs(agent: AgentConfig, record: TaskRecord, config: ExtensionConfig, includeTask = true): string[] {
	const sessionDir = record.sessionDir ?? path.join(os.homedir(), ".pi", "sessions-subagents", record.id);
	fs.mkdirSync(sessionDir, { recursive: true });
	const promptPath = path.join(sessionDir, `${agent.name}-system.md`);
	fs.writeFileSync(promptPath, agent.systemPrompt, { encoding: "utf-8", mode: 0o600 });

	const piBin = resolvePiBinary();
	const args = ["--session-dir", sessionDir, "--no-skills", "--no-extensions"];
	const builtinTools = agent.tools.filter((tool) => BUILTIN_TOOLS.has(tool));
	if (builtinTools.length > 0) args.push("--tools", builtinTools.join(","));
	else args.push("--no-tools");
	for (const tool of agent.tools) {
		const extPath = CUSTOM_TOOL_EXTENSIONS[tool];
		if (extPath) args.push("--extension", extPath);
	}
	args.push("--models", agent.model, "--append-system-prompt", promptPath);
	if (includeTask) args.push(`Task: ${record.task}`);
	return config.piDevCommand ? [config.piDevCommand, ...args] : [piBin.command, ...piBin.baseArgs, ...args];
}

function ensureTaskTmuxSession(record: TaskRecord, config: ExtensionConfig): string {
	if (!hasTmux()) throw new Error("tmux not found; install tmux or open session dir manually.");
	const agent = agents.find((a) => a.name === record.agent);
	if (!agent) throw new Error(`Unknown agent: ${record.agent}`);
	const name = record.tmuxSession ?? `pi-subagent-${record.id}`.replace(/[^a-zA-Z0-9_.:-]+/g, "-");
	record.tmuxSession = name;
	if (!tmuxHasSession(name)) {
		const cmd = buildInteractivePiDevArgs(agent, record, config).map(shellQuote).join(" ");
		const created = spawnSync("tmux", currentTmuxArgs(["new-session", "-d", "-s", name, "-c", record.cwd, cmd]), { stdio: "ignore" });
		if (created.status !== 0) throw new Error(`Failed to create tmux session ${name}. Is pi.dev on PATH?`);
	}
	return name;
}

function ensureTaskTmuxWindow(record: TaskRecord, config: ExtensionConfig, select: boolean): string {
	if (!hasTmux()) throw new Error("tmux not found; install tmux or open session dir manually.");
	const agent = agents.find((a) => a.name === record.agent);
	if (!agent) throw new Error(`Unknown agent: ${record.agent}`);
	const name = `pi-task-${record.id}`.replace(/[^a-zA-Z0-9_.:-]+/g, "-").slice(0, 80);
	if (process.env.TMUX && record.tmuxWindowId && tmuxTargetExists(record.tmuxWindowId)) {
		if (select && !selectTmuxWindow(record.tmuxWindowId)) throw new Error(`Failed to select tmux window ${record.tmuxWindowId}.`);
		return select ? `Selected tmux window ${record.tmuxWindowId}` : `Task window already exists ${record.tmuxWindowId}`;
	}
	const firstInteractiveStart = !record.tmuxWindowId;
	const rawCmd = buildInteractivePiDevArgs(agent, record, config, firstInteractiveStart).map(shellQuote).join(" ");
	const logPath = path.join(record.sessionDir ?? os.tmpdir(), "interactive-tmux.log");
	const wrappedCmd = [
		"set -o pipefail",
		`echo ${shellQuote(`$ ${rawCmd}`)}`,
		`${rawCmd} 2>&1 | tee -a ${shellQuote(logPath)}`,
		"code=$?",
		`echo ${shellQuote("\n[pi task exited with code ")}$code${shellQuote(`; log: ${logPath}]`)}`,
		"printf 'Press Enter to close...'",
		"read _",
	].join("; ");
	const shellCmd = `bash -lc ${shellQuote(wrappedCmd)}`;
	if (process.env.TMUX) {
		const args = ["new-window", "-P", "-F", "#{window_id}", "-n", name, "-c", record.cwd];
		if (!select) args.push("-d");
		args.push(shellCmd);
		const created = spawnSync("tmux", currentTmuxArgs(args), { encoding: "utf8" });
		if (created.status !== 0) throw new Error(`Failed to create tmux window ${name}: ${created.stderr || "unknown error"}`);
		record.tmuxWindowId = String(created.stdout || "").trim() || undefined;
		return record.tmuxWindowId ? `${select ? "Opened" : "Spawned"} tmux window ${record.tmuxWindowId}` : `${select ? "Opened" : "Spawned"} tmux window ${name}`;
	}
	const session = ensureTaskTmuxSession(record, config);
	if (select && !attachTmuxSessionOutsideTmux(session)) return `Created tmux session ${session}; attach with: tmux attach -t ${session}`;
	return `${select ? "Attached" : "Spawned"} tmux session ${session}`;
}

function openTaskInCurrentTmux(record: TaskRecord, config: ExtensionConfig): string {
	return ensureTaskTmuxWindow(record, config, true);
}

function deleteTaskRuntime(record: TaskRecord): void {
	// Killing the tmux window/session kills the shell and child pi process inside it.
	if (record.tmuxWindowId && tmuxTargetExists(record.tmuxWindowId)) killTmuxWindow(record.tmuxWindowId);
	if (record.tmuxSession && tmuxHasSession(record.tmuxSession)) killTmuxSession(record.tmuxSession);
	record.tmuxWindowId = undefined;
	record.tmuxSession = undefined;
}

async function runSubagent(
	agent: AgentConfig,
	task: string,
	cwd: string,
	signal: AbortSignal | undefined,
	onUpdate?: (progress: AgentProgress) => void,
	sessionDir?: string,
): Promise<AgentResult> {
	const { args, tempDir } = await buildPiArgs(agent, task, cwd, sessionDir);
	const command = args[0];
	const spawnArgs = args.slice(1);

	const result: AgentResult = {
		agent: agent.name,
		task,
		output: "",
		exitCode: 0,
		model: agent.model,
		usage: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0, cost: 0, turns: 0 },
		progress: {
			agent: agent.name,
			status: "running",
			task,
			recentTools: [],
			toolCount: 0,
			tokens: 0,
			durationMs: 0,
			lastMessage: "",
		},
	};

	const startTime = Date.now();
	const progress = result.progress;

	const fireUpdate = throttle(() => {
		progress.durationMs = Date.now() - startTime;
		onUpdate?.(progress);
	}, 150);

	const exitCode = await new Promise<number>((resolve) => {
		const proc = spawn(command, spawnArgs, {
			cwd,
			stdio: ["ignore", "pipe", "pipe"],
		});

		let buf = "";
		let stderrBuf = "";

		const processLine = (line: string) => {
			if (!line.trim()) return;
			try {
				const evt = JSON.parse(line) as any;
				progress.durationMs = Date.now() - startTime;

				if (evt.type === "tool_execution_start") {
					progress.toolCount++;
					progress.currentTool = evt.toolName;
					progress.currentToolArgs = extractToolArgsPreview((evt.args || {}) as Record<string, unknown>);
					fireUpdate();
				}

				if (evt.type === "tool_execution_end") {
					if (progress.currentTool) {
						progress.recentTools.push({
							tool: progress.currentTool,
							args: progress.currentToolArgs || "",
						});
						// Keep last 20
						if (progress.recentTools.length > 20) {
							progress.recentTools.splice(0, progress.recentTools.length - 20);
						}
					}
					progress.currentTool = undefined;
					progress.currentToolArgs = undefined;
					fireUpdate();
				}

				if (evt.type === "tool_result_end") {
					fireUpdate();
				}

				if (evt.type === "message_end" && evt.message) {
					if (evt.message.role === "assistant") {
						result.usage.turns++;
						const u = evt.message.usage;
						if (u) {
							result.usage.input += u.input || 0;
							result.usage.output += u.output || 0;
							result.usage.cacheRead += u.cacheRead || 0;
							result.usage.cacheWrite += u.cacheWrite || 0;
							result.usage.cost += u.cost?.total || 0;
							progress.tokens = result.usage.input + result.usage.output;
						}
						if (evt.message.model) result.model = evt.message.model;
						if (evt.message.errorMessage) progress.error = evt.message.errorMessage;

						const text = extractTextFromContent(evt.message.content);
						if (text) {
							result.output = text;
							// Extract just the prose "thinking" text — skip code blocks
							const proseLines: string[] = [];
							let inCodeBlock = false;
							for (const line of text.split("\n")) {
								if (line.trimStart().startsWith("```")) {
									inCodeBlock = !inCodeBlock;
									continue;
								}
								if (!inCodeBlock && line.trim()) {
									proseLines.push(line.trim());
								}
							}
							if (proseLines.length > 0) {
								progress.lastMessage = proseLines.slice(0, 3).join(" ");
							}
						}
					}

					fireUpdate();
				}
			} catch {
				// Non-JSON lines are expected
			}
		};

		proc.stdout.on("data", (d: Buffer) => {
			buf += d.toString();
			const lines = buf.split("\n");
			buf = lines.pop() || "";
			lines.forEach(processLine);
		});

		proc.stderr.on("data", (d: Buffer) => {
			stderrBuf += d.toString();
		});

		proc.on("close", (code) => {
			if (buf.trim()) processLine(buf);
			if (code !== 0 && stderrBuf.trim() && !progress.error) {
				progress.error = stderrBuf.trim();
			}
			resolve(code ?? 1);
		});

		proc.on("error", () => resolve(1));

		if (signal) {
			const kill = () => {
				proc.kill("SIGTERM");
				setTimeout(() => !proc.killed && proc.kill("SIGKILL"), 3000);
			};
			if (signal.aborted) kill();
			else signal.addEventListener("abort", kill, { once: true });
		}
	});

	// Cleanup temp dir
	try {
		fs.rmSync(tempDir, { recursive: true, force: true });
	} catch { }

	result.exitCode = exitCode;
	progress.status = exitCode === 0 && !progress.error ? "completed" : "failed";
	progress.durationMs = Date.now() - startTime;
	if (progress.error) result.output = result.output || `Error: ${progress.error}`;

	// Truncate output if very large
	if (result.output.length > DEFAULT_MAX_BYTES) {
		const trunc = truncateHead(result.output, { maxLines: DEFAULT_MAX_LINES, maxBytes: DEFAULT_MAX_BYTES });
		result.output = trunc.content;
		if (trunc.truncated) {
			result.output += "\n\n[Output truncated]";
		}
	}

	return result;
}

// ── Throttle ──────────────────────────────────────────────────────────

function throttle<T extends (...args: any[]) => void>(fn: T, ms: number): T {
	let lastCall = 0;
	let timer: ReturnType<typeof setTimeout> | undefined;
	return ((...args: any[]) => {
		const now = Date.now();
		const remaining = ms - (now - lastCall);
		if (remaining <= 0) {
			lastCall = now;
			if (timer) { clearTimeout(timer); timer = undefined; }
			fn(...args);
		} else if (!timer) {
			timer = setTimeout(() => {
				lastCall = Date.now();
				timer = undefined;
				fn(...args);
			}, remaining);
		}
	}) as T;
}

// ── Parallel Execution with Concurrency Limit ─────────────────────────

async function mapConcurrent<T, R>(
	items: T[],
	concurrency: number,
	fn: (item: T, index: number) => Promise<R>,
): Promise<R[]> {
	const results: R[] = new Array(items.length);
	let nextIndex = 0;

	async function worker() {
		while (nextIndex < items.length) {
			const i = nextIndex++;
			results[i] = await fn(items[i], i);
		}
	}

	const workers = Array.from({ length: Math.min(concurrency, items.length) }, () => worker());
	await Promise.all(workers);
	return results;
}

// ── Rendering ─────────────────────────────────────────────────────────

type Theme = ExtensionContext["ui"]["theme"];
type Component = ReturnType<typeof Text.prototype.render> extends string[] ? Text : any;

function getTermWidth(): number {
	return process.stdout.columns || 120;
}

function textFromContent(content: unknown, max = 1200): string {
	const text = extractTextFromContent(content).replace(/\s+\n/g, "\n").trim();
	return text.length > max ? `${text.slice(0, max)}…` : text;
}

function summarizeParentSession(ctx: ExtensionContext): { summary: string; rawEntries: unknown[] } {
	const branch = ctx.sessionManager.getBranch();
	const recent = branch.slice(-40);
	const lines: string[] = [
		`cwd: ${ctx.cwd}`,
		`session: ${ctx.sessionManager.getSessionFile?.() ?? "ephemeral"}`,
		"",
		"Recent parent conversation (truncated):",
	];
	for (const entry of recent as any[]) {
		if (entry.type === "message") {
			const m = entry.message;
			if (!m) continue;
			if (m.role === "toolResult") {
				const name = m.toolName ?? "tool";
				const txt = textFromContent(m.content, 500);
				lines.push(`- toolResult ${name}: ${txt || JSON.stringify(m.details ?? {}).slice(0, 500)}`);
			} else {
				const txt = textFromContent(m.content, m.role === "assistant" ? 1600 : 1200);
				if (txt) lines.push(`- ${m.role}: ${txt}`);
			}
		} else if (entry.type === "custom" && entry.customType && entry.customType !== TASKS_STATE_TYPE) {
			lines.push(`- custom ${entry.customType}: ${JSON.stringify(entry.data ?? {}).slice(0, 500)}`);
		}
	}
	let summary = lines.join("\n");
	const max = 20_000;
	if (summary.length > max) summary = `...[older context omitted]\n${summary.slice(summary.length - max)}`;
	return { summary, rawEntries: branch };
}

function withParentContext(task: string, summary: string, rawPath: string): string {
	return [
		"Parent session context snapshot:",
		summary,
		"",
		"Full raw parent session snapshot is available at:",
		`@${rawPath}`,
		"",
		"User task:",
		task,
	].join("\n");
}

function renderAgentProgress(
	r: AgentResult,
	theme: Theme,
	expanded: boolean,
	w: number,
): Container {
	const c = new Container();
	const prog = r.progress;
	const isRunning = prog.status === "running";
	const isPending = prog.status === "pending";

	// Header: icon + agent + stats (always one line, truncated)
	const icon = isRunning
		? theme.fg("warning", "⟳")
		: isPending
			? theme.fg("dim", "○")
			: r.exitCode === 0
				? theme.fg("success", "✓")
				: theme.fg("error", "✗");
	const stats = `${prog.toolCount} tools · ${formatTokens(prog.tokens)} tok · ${formatDuration(prog.durationMs)}`;
	const modelStr = r.model ? theme.fg("dim", ` (${r.model})`) : "";
	c.addChild(
		new Text(
			truncLine(`${icon} ${theme.fg("toolTitle", theme.bold(r.agent))}${modelStr} — ${theme.fg("dim", stats)}`, w),
			0, 0,
		),
	);

	// Task
	if (expanded) {
		// Full task, Text wraps naturally
		c.addChild(new Text(theme.fg("dim", `Task: ${r.task}`), 0, 0));
	} else {
		// Truncate to one line
		const flat = r.task.replace(/\n/g, " ");
		c.addChild(
			new Text(truncLine(theme.fg("dim", `Task: ${flat}`), w), 0, 0),
		);
	}

	// Current tool (running state)
	if (isRunning && prog.currentTool) {
		const toolLine = prog.currentToolArgs
			? `${prog.currentTool}: ${prog.currentToolArgs}`
			: prog.currentTool;
		if (expanded) {
			c.addChild(new Text(theme.fg("warning", `▸ ${toolLine}`), 0, 0));
		} else {
			c.addChild(new Text(truncLine(theme.fg("warning", `▸ ${toolLine}`), w), 0, 0));
		}
	}

	// Recent tools (always all)
	const toolsToShow = prog.recentTools;
	for (const t of toolsToShow) {
		const line = `  ${t.tool}: ${t.args}`;
		if (expanded) {
			c.addChild(new Text(theme.fg("muted", line), 0, 0));
		} else {
			c.addChild(new Text(truncLine(theme.fg("muted", line), w), 0, 0));
		}
	}

	// Latest assistant message — the prose "thinking" text, always visible
	if (prog.lastMessage) {
		c.addChild(new Spacer(1));
		if (expanded) {
			c.addChild(new Text(theme.fg("text", prog.lastMessage), 0, 0));
		} else {
			c.addChild(new Text(truncLine(theme.fg("text", prog.lastMessage), w), 0, 0));
		}
	}

	// Expanded: full final output
	if (!isRunning && r.output && expanded) {
		c.addChild(new Spacer(1));
		const mdTheme = getMarkdownTheme();
		c.addChild(new Markdown(r.output, 0, 0, mdTheme));
	}

	// Usage breakdown
	c.addChild(new Spacer(1));
	const usageParts: string[] = [];
	if (r.usage.turns) usageParts.push(`${r.usage.turns} turn${r.usage.turns > 1 ? "s" : ""}`);
	if (r.usage.input) usageParts.push(`in:${formatTokens(r.usage.input)}`);
	if (r.usage.output) usageParts.push(`out:${formatTokens(r.usage.output)}`);
	if (r.usage.cacheRead) usageParts.push(`cR:${formatTokens(r.usage.cacheRead)}`);
	if (r.usage.cacheWrite) usageParts.push(`cW:${formatTokens(r.usage.cacheWrite)}`);
	if (r.usage.cost) usageParts.push(`$${r.usage.cost.toFixed(4)}`);
	if (usageParts.length) {
		c.addChild(new Text(theme.fg("dim", usageParts.join(" · ")), 0, 0));
	}


	// Error
	if (prog.error) {
		if (expanded) {
			c.addChild(new Text(theme.fg("error", `Error: ${prog.error}`), 0, 0));
		} else {
			c.addChild(new Text(truncLine(theme.fg("error", `Error: ${prog.error}`), w), 0, 0));
		}
	}

	return c;
}

// ── Extension ─────────────────────────────────────────────────────────

export default function(pi: ExtensionAPI) {
	const config = loadConfig();
	const maxConcurrency = config.maxConcurrency ?? DEFAULT_MAX_CONCURRENCY;
	agents = loadAgents();
	let tasks: TaskRecord[] = [];

	function persistTasks() {
		pi.appendEntry<PersistedTasks>(TASKS_STATE_TYPE, { tasks });
	}

	function restoreTasks(ctx: ExtensionContext) {
		let saved: PersistedTasks | undefined;
		for (const entry of ctx.sessionManager.getBranch()) {
			if (entry.type === "custom" && entry.customType === TASKS_STATE_TYPE && entry.data?.tasks) saved = entry.data as PersistedTasks;
		}
		if (saved) tasks = saved.tasks ?? [];
		// After reload, orphaned in-flight subprocesses are gone from this extension's perspective.
		for (const t of tasks) {
			if (t.status === "pending" || t.status === "running") {
				t.status = "failed";
				t.error = t.error || "Task interrupted by extension reload/session switch.";
				t.updatedAt = Date.now();
			}
		}
	}

	function launchTask(record: TaskRecord, signal?: AbortSignal) {
		const agent = agents.find((a) => a.name === record.agent);
		if (!agent) {
			record.status = "failed";
			record.error = `Unknown agent: ${record.agent}`;
			record.updatedAt = Date.now();
			persistTasks();
			return;
		}
		record.status = "running";
		record.updatedAt = Date.now();
		persistTasks();
		void runSubagent(agent, record.task, record.cwd, signal, (progress) => {
			record.progress = { ...progress };
			record.status = progress.status;
			record.updatedAt = Date.now();
		}, record.sessionDir).then((result) => {
			record.result = result;
			record.progress = result.progress;
			record.status = result.exitCode === 0 && !result.progress.error ? "completed" : "failed";
			record.error = result.progress.error;
			record.updatedAt = Date.now();
			persistTasks();
		}).catch((err) => {
			record.status = "failed";
			record.error = err instanceof Error ? err.message : String(err);
			record.updatedAt = Date.now();
			persistTasks();
		});
	}

	function createTask(agentName: string, task: string, cwd: string, signal?: AbortSignal, parentCtx?: ExtensionContext): TaskRecord {
		const safeId = `${Date.now()}-${agentName}`.replace(/[^a-zA-Z0-9_.-]+/g, "-");
		const sessionDir = path.join(os.homedir(), ".pi", "sessions-subagents", safeId);
		fs.mkdirSync(sessionDir, { recursive: true });
		let finalTask = task;
		if (parentCtx) {
			const handoff = summarizeParentSession(parentCtx);
			const rawPath = path.join(sessionDir, "parent-context.json");
			fs.writeFileSync(rawPath, JSON.stringify({ capturedAt: Date.now(), cwd: parentCtx.cwd, entries: handoff.rawEntries }, null, 2), { encoding: "utf-8", mode: 0o600 });
			fs.writeFileSync(path.join(sessionDir, "parent-context.md"), handoff.summary, { encoding: "utf-8", mode: 0o600 });
			finalTask = withParentContext(task, handoff.summary, rawPath);
		}
		const record: TaskRecord = { id: safeId, agent: agentName, task: finalTask, cwd, status: "pending", createdAt: Date.now(), updatedAt: Date.now(), sessionDir };
		tasks.push(record);
		try {
			// Bind a tmux window/session at creation time. Opening the task later only
			// selects this window; it does not submit the prompt again.
			ensureTaskTmuxWindow(record, config, false);
			record.status = "running";
			record.updatedAt = Date.now();
			persistTasks();
		} catch (err) {
			// Non-tmux fallback: preserve old background JSON execution behavior.
			record.error = err instanceof Error ? err.message : String(err);
			launchTask(record, signal);
		}
		return record;
	}

	pi.on("session_start", async (_event, ctx) => restoreTasks(ctx));

	pi.registerCommand("tasks", {
		description: "Show spawned subagent tasks. Enter switches to full pi.dev tmux session; o opens inline output; a adds; d deletes; q closes.",
		handler: async (_args: string, ctx: any) => {
			if (!ctx.hasUI) {
				ctx.ui.notify(tasks.map((t) => `${t.id} ${t.status} ${t.agent}: ${t.task}`).join("\n") || "No tasks.", "info");
				return;
			}
			let index = 0;
			let view: "list" | "detail" = "list";
			while (true) {
				const action = await ctx.ui.custom((tui: any, theme: any, _kb: any, done: (action: "add" | "close" | "open") => void) => {
					const renderList = (width: number) => {
						const sorted = [...tasks].sort((a, b) => b.createdAt - a.createdAt);
						index = Math.min(index, Math.max(0, sorted.length - 1));
						const lines: string[] = [theme.fg("accent", " Subagent tasks  Enter pi.dev/tmux • o output • a add • d delete • r refresh • q/Esc")];
						if (!sorted.length) lines.push(theme.fg("muted", "  No tasks. Press a to add one."));
						for (let i = Math.max(0, index - 8); i < Math.min(sorted.length, index + 12); i++) {
							const t = sorted[i];
							const icon = t.status === "running" ? "⟳" : t.status === "completed" ? "✓" : t.status === "failed" ? "✗" : "○";
							const row = `${icon} ${t.status.padEnd(9)} ${t.agent.padEnd(10)} ${t.task.replace(/\n/g, " ")}`;
							lines.push((i === index ? theme.fg("accent", "› ") : "  ") + (i === index ? theme.fg("accent", row) : theme.fg("text", row)));
						}
						return lines.map((l) => truncateToWidth(l, width));
					};
					const renderDetail = (width: number) => {
						const sorted = [...tasks].sort((a, b) => b.createdAt - a.createdAt);
						const t = sorted[index];
						if (!t) return ["No task"];
						const output = t.result?.output || t.progress?.lastMessage || t.error || "(no output yet)";
						return [`${theme.fg("accent", t.agent)} ${theme.fg("dim", t.status)}  Enter pi.dev/tmux • Backspace/Esc back • q close`, "", `Task: ${t.task}`, "", output]
							.flatMap((s) => String(s).split("\n"))
							.map((l) => truncateToWidth(l, width));
					};
					return {
						render: (w: number) => view === "detail" ? renderDetail(w) : renderList(w),
						invalidate: () => { },
						handleInput: (data: string) => {
							const sorted = [...tasks].sort((a, b) => b.createdAt - a.createdAt);
							if (matchesKey(data, "q")) return done("close");
							if (view === "detail" && (matchesKey(data, Key.escape) || matchesKey(data, Key.backspace))) { view = "list"; tui.requestRender(); return; }
							if (matchesKey(data, Key.escape)) return done("close");
							if (matchesKey(data, "a")) return done("add");
							if (matchesKey(data, Key.up) || matchesKey(data, "k")) index = Math.max(0, index - 1);
							else if (matchesKey(data, Key.down) || matchesKey(data, "j")) index = Math.min(sorted.length - 1, index + 1);
							else if (matchesKey(data, Key.enter) && sorted[index]) return done("open");
							else if (matchesKey(data, "o") && sorted[index]) view = "detail";
							else if (matchesKey(data, "d") && sorted[index]) {
								const target = sorted[index];
								try { deleteTaskRuntime(target); } catch { }
								tasks = tasks.filter((t) => t.id !== target.id);
								persistTasks();
								index = Math.min(index, Math.max(0, tasks.length - 1));
							}
							tui.requestRender();
						},
					};
				});
				if (action === "open") {
					const sorted = [...tasks].sort((a, b) => b.createdAt - a.createdAt);
					const record = sorted[index];
					if (!record) continue;
					try {
						const message = openTaskInCurrentTmux(record, config);
						persistTasks();
						ctx.ui.notify(message, "info");
					} catch (err) {
						ctx.ui.notify(err instanceof Error ? err.message : String(err), "error");
					}
					return;
				}
				if (action !== "add") return;
				const prompt = await ctx.ui.editor("Subagent task prompt", "");
				if (!prompt?.trim()) continue;
				const agentName = agents.find((a) => a.name === "worker")?.name ?? agents[0]?.name;
				if (!agentName) { ctx.ui.notify("No subagents configured.", "error"); return; }
				const record = createTask(agentName, prompt.trim(), ctx.cwd, undefined, ctx);
				ctx.ui.notify(`Spawned ${agentName} task ${record.id} with parent context`, "info");
			}
		},
	});

	pi.registerTool({
		name: "spawn_subagent_task",
		label: "Spawn Subagent Task",
		description: "Start a subagent task in the background. Use /tasks to see status and open output.",
		promptSnippet: "Spawn background subagent tasks visible in /tasks",
		promptGuidelines: ["Use spawn_subagent_task when the user asks to start background subagent work and inspect it later with /tasks."],
		parameters: Type.Object({
			agent: Type.String({ description: "Name of the agent to invoke" }),
			task: Type.String({ description: "Complete task description. Subagent has no conversation context." }),
			cwd: Type.Optional(Type.String({ description: "Working directory for the agent process" })),
		}),
		async execute(_toolCallId: string, params: any, signal: AbortSignal | undefined, _onUpdate: any, ctx: any) {
			const available = agents.map((a) => a.name).join(", ") || "none";
			if (!agents.find((a) => a.name === params.agent)) throw new Error(`Unknown agent: ${params.agent}. Available agents: ${available}`);
			const record = createTask(params.agent, params.task, params.cwd ?? ctx.cwd, signal, ctx);
			return { content: [{ type: "text", text: `Spawned task ${record.id} with parent context. Use /tasks to monitor or open output.` }], details: { task: record } };
		},
	});

	pi.registerTool({
		name: "subagent",
		label: "Subagent",
		description:
			"Run a subagent to complete a task. Subagents have NO context from the current conversation — include all necessary context in the task description.",
		promptSnippet: "Run subagents for delegated tasks",
		promptGuidelines: [
			"Parallel tool calls are your primary parallelism mechanism — put multiple independent read/fetch/search calls in one function_calls block. Don't use subagents to parallelize simple I/O.",
			"Use subagent to delegate *reasoning and decisions*: codebase exploration (scout), web research (researcher), or isolated code changes (worker)",
			"For multiple independent subagent tasks, use parallel mode with tasks[] array",
			"Subagents have NO context from the current conversation — include ALL necessary context in the task description",
		],
		parameters: Type.Object({
			agent: Type.Optional(
				Type.String({ description: "Name of the agent to invoke (SINGLE mode)" }),
			),
			task: Type.Optional(Type.String({ description: "Task description (SINGLE mode)" })),
			tasks: Type.Optional(
				Type.Array(
					Type.Object({
						agent: Type.String({ description: "Name of the agent to invoke" }),
						task: Type.String({ description: "Task description" }),
						cwd: Type.Optional(Type.String({ description: "Working directory for the agent process" })),
					}),
					{ description: "PARALLEL mode: array of {agent, task} objects" },
				),
			),
			cwd: Type.Optional(Type.String({ description: "Working directory for the agent process (single mode)" })),
		}),

		async execute(toolCallId, params, signal, onUpdate, ctx) {
			const cwd = ctx.cwd;

			// Validate mode
			if (params.tasks && params.tasks.length > 0) {
				// ── Parallel mode ──
				const taskList = params.tasks;

				// Validate all agents
				const available = agents.map((a) => a.name).join(", ") || "none";
				for (const t of taskList) {
					if (!agents.find((a) => a.name === t.agent)) {
						throw new Error(`Unknown agent: ${t.agent}. Available agents: ${available}`);
					}
				}

				const allResults: AgentResult[] = [];

				// Initialize all result slots as pending
				for (let i = 0; i < taskList.length; i++) {
					allResults[i] = {
						agent: taskList[i].agent,
						task: taskList[i].task,
						output: "",
						exitCode: -1,
						model: undefined,
						usage: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0, cost: 0, turns: 0 },
						progress: { agent: taskList[i].agent, status: "pending" as any, task: taskList[i].task, recentTools: [], toolCount: 0, tokens: 0, durationMs: 0, lastMessage: "" },
					};
				}

				const flushParallelUpdate = () => {
					onUpdate?.({
						content: [{ type: "text", text: `Running ${taskList.length} tasks...` }],
						details: {
							mode: "parallel" as const,
							results: [...allResults],
						},
					});
				};
				const fireParallelUpdate = throttle(flushParallelUpdate, 150);

				const results = await mapConcurrent(taskList, maxConcurrency, async (t, idx) => {
					const agent = agents.find((a) => a.name === t.agent)!;
					const result = await runSubagent(agent, t.task, t.cwd ?? cwd, signal, (progress) => {
						allResults[idx].progress = progress;
						fireParallelUpdate();
					});

					// Update allResults with the completed result so the UI reflects it immediately
					allResults[idx] = result;
					flushParallelUpdate();

					return result;
				});

				// Build final output text
				const outputParts = results.map((r) => {
					const header = `## ${r.agent}${r.exitCode !== 0 ? " (FAILED)" : ""}`;
					return `${header}\n\n${r.output || "(no output)"}`;
				});

				return {
					content: [{ type: "text", text: outputParts.join("\n\n---\n\n") }],
					details: { mode: "parallel" as const, results },
				};
			} else if (params.agent && params.task) {
				// ── Single mode ──
				const agent = agents.find((a) => a.name === params.agent);
				if (!agent) {
					const available = agents.map((a) => a.name).join(", ") || "none";
					throw new Error(`Unknown agent: ${params.agent}. Available agents: ${available}`);
				}

				const liveResult: AgentResult = {
					agent: params.agent!,
					task: params.task!,
					output: "",
					exitCode: -1,
					model: agent.model,
					usage: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0, cost: 0, turns: 0 },
					progress: { agent: params.agent!, status: "running" as const, task: params.task!, recentTools: [], toolCount: 0, tokens: 0, durationMs: 0, lastMessage: "" },
				};
				const result = await runSubagent(agent, params.task, params.cwd ?? cwd, signal, (progress) => {
					liveResult.progress = progress;
					onUpdate?.({
						content: [{ type: "text", text: "(running...)" }],
						details: { mode: "single" as const, results: [liveResult] },
					});
				});

				const isError = result.exitCode !== 0 || !!result.progress.error;
				return {
					content: [{ type: "text", text: result.output || "(no output)" }],
					details: { mode: "single" as const, results: [result] },
					...(isError ? { isError: true } : {}),
				};
			} else {
				throw new Error("Provide either (agent + task) for single mode, or tasks[] for parallel mode.");
			}
		},

		// ── Render: tool call header ──
		renderCall(args, theme, _context) {
			if (args.tasks && args.tasks.length > 0) {
				const agentNames = args.tasks.map((t: any) => t.agent).join(", ");
				return new Text(
					`${theme.fg("toolTitle", theme.bold("subagent"))} ${theme.fg("accent", "parallel")} ${theme.fg("dim", `(${args.tasks.length} tasks: ${agentNames})`)}`,
					0, 0,
				);
			}
			if (args.agent) {
				const taskPreview = args.task
					? (args.task.length > 60 ? args.task.slice(0, 60) + "…" : args.task).replace(/\n/g, " ")
					: "";
				return new Text(
					`${theme.fg("toolTitle", theme.bold("subagent"))} ${theme.fg("accent", args.agent)} ${theme.fg("dim", taskPreview)}`,
					0, 0,
				);
			}
			return new Text(theme.fg("toolTitle", theme.bold("subagent")), 0, 0);
		},

		// ── Render: result ──
		renderResult(result: any, options: any, theme: any, context: any) {
			const details = result.details as Details | undefined;
			if (!details?.results?.length) {
				const t = result.content[0];
				const text = t?.type === "text" ? t.text : "(no output)";
				return new Text(text.slice(0, 200), 0, 0);
			}

			const w = getTermWidth() - 4;
			const expanded = options.expanded;
			const c = new Container();

			if (details.mode === "parallel") {
				// Parallel summary header
				const ok = details.results.filter((r) => r.exitCode === 0).length;
				const running = details.results.filter((r) => r.progress?.status === "running").length;
				const totalIcon = running > 0
					? theme.fg("warning", "⟳")
					: ok === details.results.length
						? theme.fg("success", "✓")
						: theme.fg("error", "✗");

				const totalDuration = Math.max(...details.results.map((r) => r.progress?.durationMs || 0));
				const totalTokens = details.results.reduce((s, r) => s + (r.progress?.tokens || 0), 0);
				c.addChild(
					new Text(
						truncLine(
							`${totalIcon} ${theme.fg("toolTitle", theme.bold("parallel"))} ${ok}/${details.results.length} completed · ${formatTokens(totalTokens)} tok · ${formatDuration(totalDuration)}`,
							w,
						),
						0, 0,
					),
				);
				c.addChild(new Spacer(1));

				for (let i = 0; i < details.results.length; i++) {
					const r = details.results[i];
					c.addChild(renderAgentProgress(r, theme, expanded, w));
					if (i < details.results.length - 1) c.addChild(new Spacer(1));
				}
			} else {
				// Single agent
				const r = details.results[0];
				c.addChild(renderAgentProgress(r, theme, expanded, w));
			}

			return c;
		},
	});
}
