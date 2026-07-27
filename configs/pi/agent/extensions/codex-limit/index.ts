import type { ExtensionAPI, ExtensionCommandContext, Theme } from "@earendil-works/pi-coding-agent";
import type { Component } from "@earendil-works/pi-tui";
import { matchesKey, truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";
import { createReadStream } from "node:fs";
import { readFile, readdir, stat } from "node:fs/promises";
import { homedir } from "node:os";
import { join } from "node:path";
import { createInterface } from "node:readline";

interface CodexRateLimitWindow {
  used_percent?: number;
  window_minutes?: number;
  resets_at?: number;
  reset_after_seconds?: number;
}

interface UsageWindow {
  used_percent?: number;
  limit_window_seconds?: number;
  reset_at?: number;
  reset_after_seconds?: number;
}

interface UsageRateLimit {
  primary_window?: UsageWindow | null;
  secondary_window?: UsageWindow | null;
}

interface UsagePayload {
  plan_type?: string;
  rate_limit?: UsageRateLimit | null;
  additional_rate_limits?: Array<{
    metered_feature?: string;
    limit_name?: string;
    rate_limit?: UsageRateLimit | null;
  }> | null;
}

interface CodexAuthJson {
  tokens?: {
    access_token?: string;
    account_id?: string;
  };
}

interface CodexRateLimits {
  limit_id?: string;
  limit_name?: string | null;
  primary?: CodexRateLimitWindow | null;
  secondary?: CodexRateLimitWindow | null;
  plan_type?: string | null;
  rate_limit_reached_type?: string | null;
}

interface Snapshot {
  timestamp: number;
  file: string;
  rateLimits: CodexRateLimits;
}

interface DisplayRow {
  label: string;
  usedPercent: number | null;
  remainingPercent: number | null;
  resetText: string;
  windowMinutes?: number;
  resetAfterSeconds?: number;
}

export default function (pi: ExtensionAPI) {
  let footerTimer: ReturnType<typeof setInterval> | undefined;

  async function refreshFooter(ctx: { ui: { setStatus: (key: string, value: string | undefined) => void; theme?: Theme } }) {
    const snapshot = (await fetchLiveRateLimitSnapshot().catch(() => null)) ?? (await readLatestRateLimitSnapshot());
    ctx.ui.setStatus("codex-limit", formatFooterStatus(snapshot, ctx.ui.theme));
  }

  pi.on("session_start", async (_event, ctx) => {
    // Show cached/session-log value quickly, then refresh live in background.
    readLatestRateLimitSnapshot()
      .then((snapshot) => ctx.ui.setStatus("codex-limit", formatFooterStatus(snapshot, ctx.ui.theme)))
      .catch(() => ctx.ui.setStatus("codex-limit", formatFooterStatus(null, ctx.ui.theme)));
    void refreshFooter(ctx);
    footerTimer = setInterval(() => void refreshFooter(ctx), 60_000);
  });

  pi.on("session_shutdown", async (_event, ctx) => {
    if (footerTimer) clearInterval(footerTimer);
    footerTimer = undefined;
    ctx.ui.setStatus("codex-limit", undefined);
  });

  pi.on("agent_end", async (_event, ctx) => {
    await refreshFooter(ctx);
  });

  pi.registerCommand("codex-limit", {
    description: "Show Codex 5-hour and weekly usage limits",
    handler: async (_args: string, ctx: ExtensionCommandContext) => {
      const snapshot = (await fetchLiveRateLimitSnapshot().catch(() => null)) ?? (await readLatestRateLimitSnapshot());

      if (!ctx.hasUI) {
        const message = snapshot ? formatSnapshotText(snapshot) : "No Codex rate-limit snapshot found.";
        ctx.ui.notify(message, snapshot ? "info" : "warning");
        return;
      }

      ctx.ui.setStatus("codex-limit", formatFooterStatus(snapshot, ctx.ui.theme));

      await ctx.ui.custom<void>(
        (_tui, theme, _keybindings, done) => new CodexLimitModal(theme, snapshot, done),
        {
          overlay: true,
          overlayOptions: {
            anchor: "center",
            width: 92,
            maxHeight: 14,
            margin: 2,
          },
        },
      );
    },
  });
}

class CodexLimitModal implements Component {
  constructor(
    private readonly theme: Theme,
    private readonly snapshot: Snapshot | null,
    private readonly done: () => void,
  ) {}

  handleInput(data: string): void {
    if (
      matchesKey(data, "escape") ||
      matchesKey(data, "enter") ||
      matchesKey(data, "return") ||
      matchesKey(data, "ctrl+c") ||
      data.toLowerCase() === "q"
    ) {
      this.done();
    }
  }

  render(width: number): string[] {
    const inner = Math.max(20, width - 2);
    const top = this.borderLine("┌", "─", "┐", inner);
    const bottom = this.borderLine("└", "─", "┘", inner);
    const lines: string[] = [top];

    if (!this.snapshot) {
      lines.push(this.pad("No Codex rate-limit snapshot found." , inner));
      lines.push(this.pad("Run Codex once and use /status, then retry." , inner));
      lines.push(this.pad("Source: ~/.codex/sessions/**/*.jsonl" , inner));
      lines.push(this.pad("Esc/Enter/q closes" , inner, "dim"));
      lines.push(bottom);
      return lines.map((line) => truncateToWidth(line, width));
    }

    const rows = buildRows(this.snapshot.rateLimits);
    const captured = formatFetchedAt(this.snapshot.timestamp);
    const limitName = this.snapshot.rateLimits.limit_name || this.snapshot.rateLimits.limit_id || "codex";
    const plan = this.snapshot.rateLimits.plan_type ? ` (${this.snapshot.rateLimits.plan_type})` : "";

    const source = this.snapshot.file.startsWith("https://") ? "live API" : "session log";
    lines.push(this.padCentered(this.theme.fg("accent", this.theme.bold("Codex usage limits")), inner));
    lines.push(this.padCentered(this.theme.fg("dim", `(fetched: ${captured})`), inner));
    lines.push(this.pad("", inner));
    lines.push(this.pad(`${limitName}${plan} • ${source}`, inner, "dim"));

    if (rows.length === 0) {
      lines.push(this.pad("No 5h/weekly window data in snapshot.", inner, "warning"));
    } else {
      for (const row of rows) lines.push(this.pad(formatRow(row, inner - 2), inner));
    }

    if (this.snapshot.rateLimits.rate_limit_reached_type) {
      lines.push(this.pad(`Reached: ${this.snapshot.rateLimits.rate_limit_reached_type}`, inner, "warning"));
    }

    lines.push(this.pad("Esc/Enter/q", inner, "dim"));
    lines.push(bottom);
    return lines.map((line) => truncateToWidth(line, width));
  }

  invalidate(): void {}

  private borderLine(left: string, fill: string, right: string, inner: number, title?: string): string {
    if (!title) return this.theme.fg("accent", left + fill.repeat(inner) + right);
    const raw = fill.repeat(Math.max(0, inner - visibleWidth(title)));
    const before = raw.slice(0, Math.floor(raw.length / 2));
    const after = raw.slice(before.length);
    return this.theme.fg("accent", left + before + title + after + right);
  }

  private pad(text: string, inner: number, color: "text" | "accent" | "dim" | "warning" = "text"): string {
    const clipped = truncateToWidth(text, inner, "");
    const padding = " ".repeat(Math.max(0, inner - visibleWidth(clipped)));
    return this.theme.fg("accent", "│") + this.theme.fg(color, clipped + padding) + this.theme.fg("accent", "│");
  }

  private padCentered(text: string, inner: number): string {
    const clipped = truncateToWidth(text, inner, "");
    const total = Math.max(0, inner - visibleWidth(clipped));
    const left = " ".repeat(Math.floor(total / 2));
    const right = " ".repeat(total - left.length);
    return this.theme.fg("accent", "│") + left + clipped + right + this.theme.fg("accent", "│");
  }
}

async function fetchLiveRateLimitSnapshot(): Promise<Snapshot | null> {
  const authPath = join(homedir(), ".codex", "auth.json");
  const auth = JSON.parse(await readFile(authPath, "utf8")) as CodexAuthJson;
  const token = auth.tokens?.access_token;
  if (!token) return null;

  const headers: Record<string, string> = {
    Authorization: `Bearer ${token}`,
    "User-Agent": `codex-cli`,
  };
  if (auth.tokens?.account_id) headers["ChatGPT-Account-Id"] = auth.tokens.account_id;

  const response = await fetch("https://chatgpt.com/backend-api/wham/usage", {
    method: "GET",
    headers,
    signal: AbortSignal.timeout(10_000),
  });

  if (!response.ok) {
    throw new Error(`Usage API failed: HTTP ${response.status}`);
  }

  const payload = (await response.json()) as UsagePayload;
  const snapshots = snapshotsFromUsagePayload(payload);
  return snapshots[0] ?? null;
}

function snapshotsFromUsagePayload(payload: UsagePayload): Snapshot[] {
  const now = Date.now();
  const snapshots: Snapshot[] = [
    {
      timestamp: now,
      file: "https://chatgpt.com/backend-api/wham/usage",
      rateLimits: {
        limit_id: "codex",
        primary: mapUsageWindow(payload.rate_limit?.primary_window),
        secondary: mapUsageWindow(payload.rate_limit?.secondary_window),
        plan_type: payload.plan_type ?? null,
      },
    },
  ];

  for (const additional of payload.additional_rate_limits ?? []) {
    snapshots.push({
      timestamp: now,
      file: "https://chatgpt.com/backend-api/wham/usage",
      rateLimits: {
        limit_id: additional.metered_feature ?? additional.limit_name ?? "codex_other",
        limit_name: additional.limit_name ?? null,
        primary: mapUsageWindow(additional.rate_limit?.primary_window),
        secondary: mapUsageWindow(additional.rate_limit?.secondary_window),
        plan_type: payload.plan_type ?? null,
      },
    });
  }

  const preferred = snapshots.find((snapshot) => snapshot.rateLimits.limit_id === "codex");
  return preferred ? [preferred, ...snapshots.filter((snapshot) => snapshot !== preferred)] : snapshots;
}

function mapUsageWindow(window: UsageWindow | null | undefined): CodexRateLimitWindow | null {
  if (!window) return null;
  return {
    used_percent: window.used_percent,
    window_minutes: typeof window.limit_window_seconds === "number" ? Math.ceil(window.limit_window_seconds / 60) : undefined,
    resets_at: window.reset_at,
    reset_after_seconds: window.reset_after_seconds,
  };
}

async function readLatestRateLimitSnapshot(): Promise<Snapshot | null> {
  const sessionsDir = join(homedir(), ".codex", "sessions");
  const files = await listJsonlFiles(sessionsDir).catch(() => []);
  const newest = await Promise.all(
    files.map(async (file) => ({ file, mtimeMs: (await stat(file)).mtimeMs })),
  ).catch(() => [] as Array<{ file: string; mtimeMs: number }>);

  newest.sort((a, b) => b.mtimeMs - a.mtimeMs);

  for (const { file } of newest.slice(0, 40)) {
    const snapshot = await latestSnapshotInFile(file);
    if (snapshot) return snapshot;
  }

  return null;
}

async function listJsonlFiles(dir: string): Promise<string[]> {
  const entries = await readdir(dir, { withFileTypes: true });
  const nested = await Promise.all(
    entries.map(async (entry) => {
      const path = join(dir, entry.name);
      if (entry.isDirectory()) return listJsonlFiles(path);
      if (entry.isFile() && entry.name.endsWith(".jsonl")) return [path];
      return [];
    }),
  );
  return nested.flat();
}

async function latestSnapshotInFile(file: string): Promise<Snapshot | null> {
  let latest: Snapshot | null = null;
  const rl = createInterface({ input: createReadStream(file), crlfDelay: Infinity });

  for await (const line of rl) {
    if (!line.includes('"rate_limits"')) continue;
    try {
      const parsed = JSON.parse(line) as {
        timestamp?: string;
        rate_limits?: CodexRateLimits;
        payload?: { rate_limits?: CodexRateLimits };
      };
      const rateLimits = parsed.rate_limits ?? parsed.payload?.rate_limits;
      if (!rateLimits) continue;
      const timestamp = parsed.timestamp ? Date.parse(parsed.timestamp) : Number.NaN;
      latest = {
        timestamp: Number.isFinite(timestamp) ? timestamp : Date.now(),
        file,
        rateLimits,
      };
    } catch {
      // Ignore malformed historical lines.
    }
  }

  return latest;
}

function formatFetchedAt(timestamp: number): string {
  const date = new Date(timestamp);
  const dd = String(date.getDate()).padStart(2, "0");
  const mm = String(date.getMonth() + 1).padStart(2, "0");
  const yyyy = date.getFullYear();
  const hh = String(date.getHours()).padStart(2, "0");
  const min = String(date.getMinutes()).padStart(2, "0");
  const ss = String(date.getSeconds()).padStart(2, "0");
  return `${dd}/${mm}/${yyyy}, ${hh}:${min}:${ss}`;
}

function formatSnapshotText(snapshot: Snapshot): string {
  const rows = buildRows(snapshot.rateLimits);
  if (rows.length === 0) return "Codex limits: no window data in latest snapshot.";
  return rows.map((row) => `${row.label}: ${row.remainingPercent?.toFixed(0) ?? "?"}% left, resets ${row.resetText}`).join("; ");
}

function formatFooterStatus(snapshot: Snapshot | null, theme?: Theme): string {
  const dim = (text: string) => theme?.fg("dim", text) ?? text;
  const accent = (text: string) => theme?.fg("accent", text) ?? text;
  const warning = (text: string) => theme?.fg("warning", text) ?? text;
  if (!snapshot) return dim("◇ Codex ?");

  const rows = buildRows(snapshot.rateLimits);
  const primary = rows.find((row) => row.windowMinutes === 300 || row.label.toLowerCase().includes("5-hour"));
  const weekly = rows.find((row) => row.label.toLowerCase().includes("weekly") || row.windowMinutes === 43200);
  if (!primary) return dim("◇ Codex ?");

  const badge = usageBadge(primary.remainingPercent);
  const left = primary.remainingPercent === null ? "?" : `${primary.remainingPercent.toFixed(0)}%`;
  const reset = compactReset(formatResetIn(primary));
  const bar = usageBar(primary.usedPercent, 8);
  const weeklyText = weekly?.remainingPercent === null || weekly?.remainingPercent === undefined ? "" : ` · W ${weekly.remainingPercent.toFixed(0)}%`;
  const color = primary.remainingPercent !== null && primary.remainingPercent <= 25 ? warning : accent;
  return color(`${badge} 5h ${bar} ${left} ↺ ${reset}${weeklyText}`);
}

function buildRows(rateLimits: CodexRateLimits): DisplayRow[] {
  const rows: DisplayRow[] = [];
  if (rateLimits.primary) rows.push(windowRow(rateLimits.primary, fallbackLabel(rateLimits.primary, "Primary")));
  if (rateLimits.secondary) rows.push(windowRow(rateLimits.secondary, fallbackLabel(rateLimits.secondary, "Secondary")));
  return rows;
}

function fallbackLabel(window: CodexRateLimitWindow, fallback: string): string {
  if (window.window_minutes === 300) return "5-hour";
  if (window.window_minutes === 43200) return "30d";
  if (window.window_minutes && window.window_minutes >= 7 * 24 * 60 && window.window_minutes < 8 * 24 * 60) return "Weekly";
  if (window.window_minutes && window.window_minutes < 24 * 60) return `${Math.round(window.window_minutes / 60)}h`;
  if (window.window_minutes && window.window_minutes % (24 * 60) === 0) return `${window.window_minutes / (24 * 60)}d`;
  return fallback;
}

function windowRow(window: CodexRateLimitWindow, label: string): DisplayRow {
  const usedPercent = typeof window.used_percent === "number" ? clamp(window.used_percent, 0, 100) : null;
  const remainingPercent = usedPercent === null ? null : 100 - usedPercent;
  return {
    label: `${label} limit`,
    usedPercent,
    remainingPercent,
    resetText: window.resets_at ? new Date(window.resets_at * 1000).toLocaleString() : "unknown reset",
    windowMinutes: window.window_minutes,
    resetAfterSeconds: window.reset_after_seconds,
  };
}

function formatRow(row: DisplayRow, width: number): string {
  const used = row.usedPercent === null ? "?" : row.usedPercent.toFixed(0);
  const left = row.remainingPercent === null ? "?" : row.remainingPercent.toFixed(0);
  const resetIn = formatResetIn(row);
  const label = shortLabel(row.label).padEnd(7, " ");
  const bar = usageBar(row.usedPercent, 18);
  const text = `${usageBadge(row.remainingPercent)} ${label} ${bar} ${used}% used · ${left}% left · ↺ ${resetIn}`;
  return truncateToWidth(text, width);
}

function shortLabel(label: string): string {
  return label.replace(" limit", "");
}

function formatResetIn(row: DisplayRow): string {
  const seconds = row.resetAfterSeconds ?? (row.resetText === "unknown reset" ? undefined : Math.max(0, Math.round((Date.parse(row.resetText) - Date.now()) / 1000)));
  if (seconds === undefined || !Number.isFinite(seconds)) return "unknown";

  const totalMinutes = Math.max(0, Math.ceil(seconds / 60));
  const days = Math.floor(totalMinutes / (24 * 60));
  const hours = Math.floor((totalMinutes % (24 * 60)) / 60);
  const minutes = totalMinutes % 60;

  if (days > 0) return `${days}d${hours}h ${minutes}m`;
  if (hours > 0) return `${hours}h ${minutes}m`;
  return `${minutes}m`;
}

function usageBadge(remainingPercent: number | null): string {
  if (remainingPercent === null) return "◇";
  if (remainingPercent <= 10) return "🔴";
  if (remainingPercent <= 25) return "🟠";
  if (remainingPercent <= 50) return "🟡";
  return "🟢";
}

function usageBar(usedPercent: number | null, width: number): string {
  if (usedPercent === null) return `[${"?".repeat(width)}]`;
  const filled = Math.round((clamp(usedPercent, 0, 100) / 100) * width);
  return `[${"█".repeat(filled)}${"░".repeat(Math.max(0, width - filled))}]`;
}

function compactReset(text: string): string {
  return text.replace(/\s+/g, "").replace("unknown", "?");
}

function clamp(value: number, min: number, max: number): number {
  return Math.min(max, Math.max(min, value));
}
