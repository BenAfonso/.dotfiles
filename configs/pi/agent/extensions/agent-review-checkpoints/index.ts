/**
 * Agent review checkpoints extension.
 *
 * Captures hidden Git snapshots before and after each Pi agent turn so the user
 * can review only the files changed by the latest agent work in Neovim Diffview.
 *
 * Design notes:
 * - Snapshots are stored as hidden refs under `refs/pi/checkpoints/...`, not as
 *   branch commits or stash entries.
 * - A temporary Git index (`GIT_INDEX_FILE`) captures tracked and untracked
 *   working-tree content without mutating the user's real index.
 * - Ignored files are excluded by default; protected/secret-looking paths require
 *   explicit confirmation because checkpoint commits retain file contents in
 *   `.git/objects`.
 * - Direct paths come from Pi `edit`/`write` tool calls; detected paths come from
 *   Git diffs between before/after snapshots so formatter/codegen side effects
 *   can be reviewed too.
 *
 * Command:
 * - `/checkpoints` opens the checkpoint menu.
 *
 * Checkpoint menu keys:
 * - `Enter` reviews selected checkpoint.
 * - `a` creates a manual checkpoint with a generated name.
 * - `A` prompts for a manual checkpoint name, then creates it.
 * - `R` confirms and restores selected checkpoint.
 * - `d` deletes selected checkpoint.
 * - `D` deletes all checkpoints, including manual checkpoints.
 */
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { isToolCallEventType } from "@earendil-works/pi-coding-agent";
import { Key, matchesKey, truncateToWidth } from "@earendil-works/pi-tui";
import { execFile } from "node:child_process";
import { existsSync, mkdtempSync, rmSync, writeFileSync, readFileSync } from "node:fs";
import os from "node:os";
import path from "node:path";
import { promisify } from "node:util";

const execFileAsync = promisify(execFile);
const STATE_TYPE = "agent-review-checkpoints";
const RETAIN_AUTO_TURNS = 50;

type CheckpointKind = "before" | "after" | "manual" | "live";
type Checkpoint = {
  id: string;
  label: string;
  ref: string;
  commit: string;
  kind: CheckpointKind;
  turnId?: string;
  createdAt: number;
  directPaths: string[];
  detectedPaths: string[];
  summary?: string;
};
type Turn = { id: string; before?: Checkpoint; after?: Checkpoint; directPaths: Set<string>; startedAt: number };
type Persisted = { checkpoints: Checkpoint[]; lastTurnId?: string };

type ExecOpts = { cwd: string; env?: NodeJS.ProcessEnv; timeout?: number };

type ToolPathInput = { path?: string; filePath?: string };

const SECRET_PATTERNS = [
  /(^|[/\\])\.env($|[.\-_/\\])/i,
  /(^|[/\\])\.env\.[^/\\]+$/i,
  /(^|[/\\])[^/\\]*secret[^/\\]*($|[.\-_/\\])/i,
  /(^|[/\\])[^/\\]*credential[^/\\]*($|[.\-_/\\])/i,
  /(^|[/\\])[^/\\]*token[^/\\]*($|[.\-_/\\])/i,
  /(^|[/\\])\.npmrc$/i,
  /(^|[/\\])\.pypirc$/i,
  /(^|[/\\])\.netrc$/i,
  /(^|[/\\])\.ssh[/\\][^/\\]+$/i,
  /(^|[/\\])id_(rsa|dsa|ecdsa|ed25519)(\.pub)?$/i,
  /(^|[/\\])[^/\\]*private[-_]?key[^/\\]*$/i,
  /(^|[/\\])[^/\\]*\.(pem|key|p12|pfx)$/i,
  /(^|[/\\])secrets?[/\\]/i,
  /(^|[/\\])credentials?[/\\]/i,
];

function slug(s: string): string {
  return s.replace(/[^a-zA-Z0-9._-]+/g, "-").replace(/^-+|-+$/g, "").slice(0, 80) || "checkpoint";
}

function uniq(xs: Iterable<string>): string[] {
  return [...new Set([...xs].filter(Boolean))].sort();
}

function shQuote(s: string): string {
  return `'${s.replaceAll("'", `'\\''`)}'`;
}

function vimQuote(s: string): string {
  return s.replaceAll("\\", "\\\\").replaceAll(" ", "\\ ").replaceAll("|", "\\|").replaceAll("'", "\\'");
}

function normalizeRel(cwd: string, p: string): string {
  const clean = p.trim().replace(/^['"]|['"]$/g, "");
  const abs = path.isAbsolute(clean) ? clean : path.resolve(cwd, clean);
  return path.relative(cwd, abs).split(path.sep).join("/");
}

function isProtected(rel: string): boolean {
  const normalized = rel.split(path.sep).join("/");
  return SECRET_PATTERNS.some((p) => p.test(normalized));
}

async function execGit(args: string[], opts: ExecOpts): Promise<string> {
  const { stdout } = await execFileAsync("git", args, {
    cwd: opts.cwd,
    env: { ...process.env, ...(opts.env ?? {}) },
    timeout: opts.timeout ?? 10_000,
    maxBuffer: 20 * 1024 * 1024,
  });
  return stdout.trim();
}

async function gitTop(cwd: string): Promise<string> {
  return execGit(["rev-parse", "--show-toplevel"], { cwd });
}

async function sessionKey(ctx: any): Promise<string> {
  const file = ctx.sessionManager?.getSessionFile?.();
  if (file) return slug(path.basename(file, path.extname(file)));
  return slug(path.basename(await gitTop(ctx.cwd)));
}

async function changedPathsBetween(cwd: string, a: string, b: string): Promise<string[]> {
  const out = await execGit(["diff", "--name-only", a, b, "--"], { cwd });
  return out ? out.split("\n").filter(Boolean) : [];
}

async function changedPathsWorking(cwd: string): Promise<string[]> {
  const out = await execGit(["status", "--porcelain=v1", "--untracked-files=all"], { cwd });
  return out.split("\n").map((l) => l.slice(3).trim()).filter(Boolean).map((p) => p.includes(" -> ") ? p.split(" -> ").pop()! : p);
}

async function assertNoProtected(ctx: any, cwd: string, paths: string[], allowProtected: boolean): Promise<void> {
  const protectedPaths = uniq(paths.map((p) => normalizeRel(cwd, p)).filter(isProtected));
  if (!protectedPaths.length || allowProtected) return;
  if (!ctx.hasUI) throw new Error(`Protected paths would be snapshotted: ${protectedPaths.join(", ")}`);
  const ok = await ctx.ui.confirm("agent checkpoints: protected paths", [
    "Checkpoint would store protected paths in .git/objects:",
    "",
    ...protectedPaths.map((p) => `- ${p}`),
    "",
    "Allow this checkpoint?",
  ].join("\n"));
  if (!ok) throw new Error(`Checkpoint blocked: protected paths: ${protectedPaths.join(", ")}`);
}

async function makeCheckpoint(ctx: any, kind: CheckpointKind, label: string, directPaths: string[] = [], turnId?: string, allowProtected = false): Promise<Checkpoint> {
  const cwd = await gitTop(ctx.cwd);
  const key = await sessionKey(ctx);
  const id = `${Date.now()}-${slug(label)}`;
  const changed = await changedPathsWorking(cwd);
  await assertNoProtected(ctx, cwd, changed, allowProtected);

  const tmpDir = mkdtempSync(path.join(os.tmpdir(), "pi-checkpoint-"));
  const tmpIndex = path.join(tmpDir, "index");
  try {
    await execGit(["read-tree", "HEAD"], { cwd, env: { GIT_INDEX_FILE: tmpIndex } });
    // Tracked + untracked, ignored excluded by default.
    await execGit(["add", "-A", "--", "."], { cwd, env: { GIT_INDEX_FILE: tmpIndex }, timeout: 30_000 });
    const tree = await execGit(["write-tree"], { cwd, env: { GIT_INDEX_FILE: tmpIndex } });
    const parent = await execGit(["rev-parse", "HEAD"], { cwd });
    const commit = await execGit(["commit-tree", tree, "-p", parent, "-m", label], { cwd });
    const ref = `refs/pi/checkpoints/${key}/${id}`;
    await execGit(["update-ref", ref, commit], { cwd });
    const createdAt = Date.now();
    const direct = uniq(directPaths);
    return { id, label, ref, commit, kind, turnId, createdAt, directPaths: direct, detectedPaths: [], summary: checkpointSummary(kind, label, direct, []) };
  } finally {
    rmSync(tmpDir, { recursive: true, force: true });
  }
}

function statePath(cwd: string): string {
  return path.join(cwd, ".git", "pi-checkpoints.json");
}

function mirror(cwd: string, checkpoints: Checkpoint[]) {
  try {
    writeFileSync(statePath(cwd), JSON.stringify({ checkpoints }, null, 2));
  } catch { }
}

function parseFlags(args: string): { flags: Set<string>; rest: string[] } {
  const parts = args.trim().split(/\s+/).filter(Boolean);
  const flags = new Set(parts.filter((p) => p.startsWith("--")));
  return { flags, rest: parts.filter((p) => !p.startsWith("--")) };
}

function basenameList(paths: string[], max = 3): string {
  const names = uniq(paths).map((p) => path.basename(p));
  if (!names.length) return "no files";
  const shown = names.slice(0, max).join(", ");
  return names.length > max ? `${shown} +${names.length - max}` : shown;
}

function checkpointSummary(kind: CheckpointKind, label: string, directPaths: string[] = [], detectedPaths: string[] = []): string {
  if (kind === "manual") return label || "manual checkpoint";
  if (kind === "before") return label.startsWith("before agent") ? "before agent edit" : label;
  if (kind === "live") return `current worktree snapshot (${basenameList([...directPaths, ...detectedPaths])})`;
  const direct = uniq(directPaths);
  const detected = uniq(detectedPaths).filter((p) => !direct.includes(p));
  if (direct.length && detected.length) return `edited ${basenameList(direct)}; detected ${basenameList(detected)}`;
  if (direct.length) return `edited ${basenameList(direct)}`;
  if (detected.length) return `changed ${basenameList(detected)}`;
  return "agent edit checkpoint";
}

function checkpointHour(ts: number): string {
  return new Intl.DateTimeFormat(undefined, { hour: "2-digit", minute: "2-digit" }).format(new Date(ts));
}

function truncateText(s: string, max: number): string {
  if (s.length <= max) return s;
  if (max <= 1) return "…";
  return `${s.slice(0, max - 1)}…`;
}

function kindBadge(kind: CheckpointKind): string {
  if (kind === "after") return "● agent ";
  if (kind === "manual") return "◆ manual";
  if (kind === "before") return "○ before";
  return "◇ live  ";
}

function checkpointPaths(c: Checkpoint): string {
  const paths = uniq([...c.directPaths, ...c.detectedPaths]);
  if (!paths.length) return "";
  return paths.slice(0, 2).map((p) => path.basename(p)).join(", ") + (paths.length > 2 ? ` +${paths.length - 2}` : "");
}

function checkpointLabel(c: Checkpoint): string {
  const when = checkpointHour(c.createdAt).padStart(5);
  const edited = String(c.directPaths.length).padStart(6);
  const changed = String(c.detectedPaths.length).padStart(7);
  const summary = truncateText(c.summary || checkpointSummary(c.kind, c.label, c.directPaths, c.detectedPaths), 54).padEnd(54);
  const files = truncateText(checkpointPaths(c), 28);
  return `${when}  ${kindBadge(c.kind)}  ${summary}  ${edited}  ${changed}  ${files}`.trimEnd();
}

type CheckpointPickerResult =
  | { action: "review"; checkpoint: Checkpoint }
  | { action: "reviewBetween"; from: Checkpoint; to: Checkpoint }
  | { action: "restore"; checkpoint: Checkpoint }
  | { action: "add"; named: boolean }
  | { action: "cancel" };

type CheckpointPickerCallbacks = {
  deleteOne(checkpoint: Checkpoint): Promise<void>;
  deleteAll(checkpoints: Checkpoint[]): Promise<void>;
};

async function pickCheckpointAction(ctx: any, candidates: Checkpoint[], callbacks: CheckpointPickerCallbacks): Promise<CheckpointPickerResult> {
  if (!ctx.hasUI) throw new Error("Checkpoint picker requires interactive UI.");

  let sorted = [...candidates]
    .filter((c) => c.kind !== "live")
    .sort((a, b) => b.createdAt - a.createdAt);

  return ctx.ui.custom<CheckpointPickerResult>((tui: any, theme: any, _kb: any, done: (result: CheckpointPickerResult) => void) => {
    let index = 0;
    let selectedForDiff: Checkpoint | undefined;
    let cachedLines: string[] | undefined;

    function refresh() {
      cachedLines = undefined;
      tui.requestRender();
    }

    function handleInput(data: string) {
      if (matchesKey(data, Key.up) || matchesKey(data, "k")) {
        index = Math.max(0, index - 1);
        refresh();
        return;
      }
      if (matchesKey(data, Key.down) || matchesKey(data, "j")) {
        index = Math.min(sorted.length - 1, index + 1);
        refresh();
        return;
      }
      if (matchesKey(data, Key.enter)) {
        if (sorted[index]) done({ action: "review", checkpoint: sorted[index] });
        return;
      }
      if (data === " " || matchesKey(data, " ")) {
        const target = sorted[index];
        if (!target) return;
        if (!selectedForDiff) {
          selectedForDiff = target;
          refresh();
          return;
        }
        if (selectedForDiff.ref === target.ref) {
          selectedForDiff = undefined;
          refresh();
          return;
        }
        done({ action: "reviewBetween", from: selectedForDiff, to: target });
        return;
      }
      if (data === "a" || matchesKey(data, "a")) {
        done({ action: "add", named: true });
        return;
      }
      if (matchesKey(data, "d")) {
        const target = sorted[index];
        if (!target) return;
        void callbacks.deleteOne(target).then(() => {
          sorted = sorted.filter((c) => c.ref !== target.ref);
          index = Math.min(index, Math.max(0, sorted.length - 1));
          refresh();
          if (!sorted.length) done({ action: "cancel" });
        });
        return;
      }
      if (matchesKey(data, "D")) {
        const targets = [...sorted];
        void callbacks.deleteAll(targets).then(() => {
          sorted = [];
          refresh();
          done({ action: "cancel" });
        });
        return;
      }
      if (matchesKey(data, "R")) {
        const target = sorted[index];
        if (target) done({ action: "restore", checkpoint: target });
        return;
      }
      if (matchesKey(data, Key.escape) || matchesKey(data, "q")) done({ action: "cancel" });
    }

    function render(width: number): string[] {
      if (cachedLines) return cachedLines;
      const lines: string[] = [];
      const add = (s: string) => lines.push(truncateToWidth(s, width));
      add(theme.fg("accent", "─".repeat(width)));
      add(`${theme.fg("accent", " Review checkpoints")} ${theme.fg("dim", "Enter review • Space select/diff • a add • A named add • R restore • d delete • D delete all • ↑↓/jk • q/Esc")}`);
      add(theme.fg("dim", " time   kind      summary                                                 edited  changed  files"));
      add(theme.fg("dim", " " + "─".repeat(Math.max(1, width - 2))));
      const visible = sorted.slice(Math.max(0, index - 8), Math.max(16, index + 8));
      const start = Math.max(0, index - 8);
      if (!visible.length) {
        add(theme.fg("muted", "  No checkpoints yet. Press a to create one, or A to name it."));
      }
      for (let i = 0; i < visible.length; i++) {
        const actual = start + i;
        const selected = actual === index;
        const marked = selectedForDiff?.ref === visible[i].ref;
        const prefix = selected ? theme.fg("accent", "› ") : marked ? theme.fg("warning", "◆ ") : "  ";
        const row = checkpointLabel(visible[i]);
        const styled = marked ? theme.fg("warning", row) : selected ? theme.fg("accent", row) : theme.fg("text", row);
        add(prefix + styled);
      }
      add(theme.fg("accent", "─".repeat(width)));
      cachedLines = lines;
      return lines;
    }

    return { render, handleInput, invalidate: () => { cachedLines = undefined; } };
  });
}

async function listServers(): Promise<string[]> {
  try {
    const { stdout } = await execFileAsync("nvr", ["--serverlist"], { timeout: 1500 });
    return stdout.split("\n").map((x) => x.trim()).filter(Boolean);
  } catch { return []; }
}

function addressExists(address: string): boolean {
  if (/^(localhost|127\.0\.0\.1|\d+\.\d+\.\d+\.\d+):\d+$/.test(address)) return true;
  return existsSync(address);
}

function savedNvimAddress(ctx: any): string | undefined {
  const branch = ctx.sessionManager?.getBranch?.() ?? [];
  for (let i = branch.length - 1; i >= 0; i--) {
    const entry = branch[i];
    if (
      entry.type === "custom" &&
      entry.customType === "nvim-bridge-state" &&
      typeof entry.data?.address === "string" &&
      addressExists(entry.data.address)
    ) {
      return entry.data.address;
    }
  }
  return undefined;
}

async function nvimAddress(ctx: any): Promise<string | undefined> {
  const saved = savedNvimAddress(ctx);
  if (saved) return saved;
  if (process.env.NVIM_LISTEN_ADDRESS && addressExists(process.env.NVIM_LISTEN_ADDRESS)) return process.env.NVIM_LISTEN_ADDRESS;
  if (process.env.TMUX) {
    try {
      const { stdout } = await execFileAsync("tmux", ["display-message", "-p", "#S"], { timeout: 1000 });
      const addr = `/tmp/nvim-server-${stdout.trim()}`;
      if (addressExists(addr)) return addr;
    } catch { }
  }
  const servers = await listServers();
  return servers.length === 1 ? servers[0] : undefined;
}

async function openDiffview(ctx: any, cwd: string, rev: string, paths: string[], printOnly: boolean): Promise<string> {
  const cmd = `DiffviewOpen ${rev} -- ${paths.map(vimQuote).join(" ")}`;
  if (printOnly) return `: ${cmd}\ngit diff ${rev.replace("..", " ")} -- ${paths.map(shQuote).join(" ")}`;
  const addr = await nvimAddress(ctx);
  if (!addr) return `No Neovim server found. Run /nvim:bind auto or export NVIM_LISTEN_ADDRESS.\nCommand: :${cmd}`;
  // nvr's process cwd does not necessarily become Neovim's cwd. Force Neovim
  // into the repo before opening Diffview so old-session refs/pathspecs resolve
  // against the right Git root regardless of the user's current buffer.
  await execFileAsync("nvr", ["--nostart", "--servername", addr, "-c", `cd ${vimQuote(cwd)}`, "-c", cmd], { cwd, timeout: 5000 });
  return `Opened Diffview: ${cmd}`;
}

export default function agentReviewCheckpoints(pi: ExtensionAPI) {
  let checkpoints: Checkpoint[] = [];
  let currentTurn: Turn | undefined;

  function persist(ctx?: any) {
    pi.appendEntry<Persisted>(STATE_TYPE, { checkpoints });
    if (ctx?.cwd) gitTop(ctx.cwd).then((top) => mirror(top, checkpoints)).catch(() => { });
  }

  async function restore(ctx: any) {
    let saved: Persisted | undefined;
    for (const entry of ctx.sessionManager.getBranch()) {
      if (entry.type === "custom" && entry.customType === STATE_TYPE && entry.data?.checkpoints) saved = entry.data;
    }
    if (saved) checkpoints = saved.checkpoints ?? [];
    else {
      try {
        const top = await gitTop(ctx.cwd);
        if (existsSync(statePath(top))) checkpoints = JSON.parse(readFileSync(statePath(top), "utf8")).checkpoints ?? [];
      } catch { }
    }
  }

  async function deleteCheckpointRefs(ctx: any, cps: Checkpoint[]): Promise<void> {
    const cwd = await gitTop(ctx.cwd);
    for (const c of cps) await execGit(["update-ref", "-d", c.ref], { cwd }).catch(() => "");
  }

  async function cleanup(ctx: any, dryRun = false, allAuto = false, all = false): Promise<string> {
    const cwd = await gitTop(ctx.cwd);
    const manual = checkpoints.filter((c) => c.kind === "manual");
    const auto = checkpoints.filter((c) => c.kind !== "manual").sort((a, b) => b.createdAt - a.createdAt);
    const keep = all ? [] : allAuto ? manual : [...manual, ...auto.slice(0, RETAIN_AUTO_TURNS * 2)];
    const keepRefs = new Set(keep.map((c) => c.ref));
    const remove = checkpoints.filter((c) => !keepRefs.has(c.ref));
    if (!dryRun) {
      for (const c of remove) await execGit(["update-ref", "-d", c.ref], { cwd }).catch(() => "");
      checkpoints = keep.sort((a, b) => a.createdAt - b.createdAt);
      persist(ctx);
    }
    return `${dryRun ? "Would remove" : "Removed"} ${remove.length} checkpoint ref(s).`;
  }

  pi.on("session_start", async (_event: any, ctx: any) => { await restore(ctx); });

  pi.on("agent_start", async (_event: any, ctx: any) => {
    try {
      const id = `${Date.now()}`;
      currentTurn = { id, directPaths: new Set(), startedAt: Date.now() };
      currentTurn.before = await makeCheckpoint(ctx, "before", `before agent ${id}`, [], id);
      checkpoints.push(currentTurn.before);
      persist(ctx);
    } catch (err) {
      ctx.ui.notify(`agent checkpoint before failed: ${err instanceof Error ? err.message : String(err)}`, "warning");
    }
  });

  pi.on("tool_call", async (event: any, ctx: any) => {
    if (!currentTurn) return;
    if (isToolCallEventType("edit", event) || isToolCallEventType("write", event)) {
      const p = (event.input as ToolPathInput).path ?? (event.input as ToolPathInput).filePath;
      if (p) currentTurn.directPaths.add(normalizeRel(ctx.cwd, p));
    }
  });

  pi.on("agent_end", async (_event: any, ctx: any) => {
    if (!currentTurn) return;
    try {
      const direct = uniq(currentTurn.directPaths);
      const after = await makeCheckpoint(ctx, "after", `after agent ${currentTurn.id}`, direct, currentTurn.id);
      if (currentTurn.before) after.detectedPaths = await changedPathsBetween(await gitTop(ctx.cwd), currentTurn.before.ref, after.ref);
      if (!after.detectedPaths.length) {
        // The turn produced no file-content delta. Drop both automatic refs so
        // read-only/tool-only/chat-only turns do not clutter the picker.
        await deleteCheckpointRefs(ctx, [currentTurn.before, after].filter(Boolean) as Checkpoint[]);
        checkpoints = checkpoints.filter((c) => c.ref !== currentTurn.before?.ref && c.ref !== after.ref);
        persist(ctx);
        return;
      }
      after.summary = checkpointSummary(after.kind, after.label, after.directPaths, after.detectedPaths);
      currentTurn.after = after;
      checkpoints.push(after);
      await cleanup(ctx, false, false, false);
      persist(ctx);
    } catch (err) {
      ctx.ui.notify(`agent checkpoint after failed: ${err instanceof Error ? err.message : String(err)}`, "warning");
    } finally {
      currentTurn = undefined;
    }
  });

  async function createManualCheckpoint(ctx: any, label?: string): Promise<Checkpoint> {
    const cp = await makeCheckpoint(ctx, "manual", label?.trim() || `manual ${checkpointHour(Date.now())}`, [], undefined, false);
    checkpoints.push(cp);
    persist(ctx);
    ctx.ui.notify(`Checkpoint created: ${cp.summary || cp.label}\n${cp.ref}`, "info");
    return cp;
  }

  async function deleteCheckpoint(ctx: any, cp: Checkpoint): Promise<void> {
    await deleteCheckpointRefs(ctx, [cp]);
    checkpoints = checkpoints.filter((c) => c.ref !== cp.ref);
    persist(ctx);
  }

  async function deleteAllCheckpoints(ctx: any, cps: Checkpoint[]): Promise<void> {
    await deleteCheckpointRefs(ctx, cps);
    const removedRefs = new Set(cps.map((c) => c.ref));
    checkpoints = checkpoints.filter((c) => !removedRefs.has(c.ref));
    persist(ctx);
  }

  async function restoreCheckpoint(ctx: any, cp: Checkpoint): Promise<void> {
    if (!ctx.hasUI) throw new Error("Restore requires interactive confirmation.");
    const ok = await ctx.ui.confirm(
      "Restore checkpoint?",
      [
        "This will overwrite the working tree and index with:",
        "",
        cp.summary || cp.label,
        cp.ref,
        "",
        "A safety checkpoint of the current state will be created first.",
        "Untracked, non-ignored files not present in the checkpoint will be removed.",
        "Ignored files are left alone.",
      ].join("\n"),
    );
    if (!ok) return;

    const cwd = await gitTop(ctx.cwd);
    const safety = await makeCheckpoint(ctx, "manual", `before restore ${checkpointHour(Date.now())}`, [], undefined, true);
    safety.summary = `safety before restore to ${cp.summary || cp.label}`;
    checkpoints.push(safety);

    await execGit(["restore", "--source", cp.ref, "--staged", "--worktree", "--", "."], { cwd, timeout: 30_000 });
    await execGit(["clean", "-fd", "--", "."], { cwd, timeout: 30_000 });
    await execGit(["reset", "--", "."], { cwd, timeout: 30_000 });
    persist(ctx);
    ctx.ui.notify(`Restored checkpoint: ${cp.summary || cp.label}\nSafety checkpoint: ${safety.ref}`, "info");
  }

  async function reviewBetweenCheckpoints(ctx: any, from: Checkpoint, to: Checkpoint): Promise<void> {
    const cwd = await gitTop(ctx.cwd);
    const changed = await changedPathsBetween(cwd, from.ref, to.ref);
    if (!changed.length) throw new Error("No changed paths between selected checkpoints.");
    ctx.ui.notify(await openDiffview(ctx, cwd, `${from.ref}..${to.ref}`, changed, false), "info");
  }

  async function reviewSinceCheckpoint(ctx: any, cp: Checkpoint | undefined, flags: Set<string>, refOverride?: string): Promise<void> {
    const ref = cp?.ref ?? refOverride;
    if (!ref) throw new Error("No checkpoint ref selected.");
    const cwd = await gitTop(ctx.cwd);
    const live = await makeCheckpoint(ctx, "live", `live review since ${cp?.id ?? ref}`, [], undefined, flags.has("--allow-protected"));
    const changedSince = await changedPathsBetween(cwd, ref, live.ref);
    const sincePaths = cp ? uniq([...(cp.directPaths ?? []), ...(cp.detectedPaths ?? [])]) : [];
    const paths = flags.has("--all") || !sincePaths.length ? changedSince : sincePaths.filter((p) => changedSince.includes(p));
    const finalPaths = paths.length ? paths : changedSince;
    if (!finalPaths.length) throw new Error("No changed paths to review.");
    ctx.ui.notify(await openDiffview(ctx, cwd, `${ref}..${live.ref}`, finalPaths, flags.has("--print")), "info");
    checkpoints.push(live);
    persist(ctx);
  }

  pi.registerCommand("checkpoints", {
    description: "Open checkpoint picker. Enter reviews selected checkpoint; d deletes it; D deletes all.",
    handler: async (_args: string, ctx: any) => {
      try {
        while (true) {
          const picked = await pickCheckpointAction(ctx, checkpoints, {
            deleteOne: (cp) => deleteCheckpoint(ctx, cp),
            deleteAll: (cps) => deleteAllCheckpoints(ctx, cps),
          });
          if (picked.action === "cancel") return;
          if (picked.action === "restore") {
            await restoreCheckpoint(ctx, picked.checkpoint);
            return;
          }
          if (picked.action === "reviewBetween") {
            await reviewBetweenCheckpoints(ctx, picked.to, picked.from);
            return;
          }
          if (picked.action === "add") {
            const label = picked.named ? await ctx.ui.input("Checkpoint name", "manual checkpoint") : undefined;
            if (picked.named && !label?.trim()) continue;
            await createManualCheckpoint(ctx, label);
            // Reopen the checkpoint menu after creating manual checkpoints.
            // ctx.ui.input/custom components are single-use; loop creates a fresh picker.
            continue;
          }
          await reviewSinceCheckpoint(ctx, picked.checkpoint, new Set<string>());
          return;
        }
      } catch (err) { ctx.ui.notify(err instanceof Error ? err.message : String(err), "error"); }
    },
  });
}
