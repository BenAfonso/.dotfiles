import path from "node:path";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { isToolCallEventType } from "@earendil-works/pi-coding-agent";

type ToolInputWithPath = { path?: string; command?: string };
type Decision = "allow" | "block";

const DEFAULT_SECRET_PATTERNS = [
  /(^|[/\\])\.env($|[.\-_/\\])/i,
  /(^|[/\\])\.env\.[^/\\]+$/i,
  /(^|[/\\])[^/\\]*secret[^/\\]*($|[.\-_/\\])/i,
  /(^|[/\\])[^/\\]*credential[^/\\]*($|[.\-_/\\])/i,
  /(^|[/\\])[^/\\]*token[^/\\]*($|[.\-_/\\])/i,
  /(^|[/\\])[^/\\]*passwd[^/\\]*$/i,
  /(^|[/\\])\.npmrc$/i,
  /(^|[/\\])\.pypirc$/i,
  /(^|[/\\])\.netrc$/i,
  /(^|[/\\])\.docker[/\\]config\.json$/i,
  /(^|[/\\])\.ssh[/\\][^/\\]+$/i,
  /(^|[/\\])id_(rsa|dsa|ecdsa|ed25519)(\.pub)?$/i,
  /(^|[/\\])[^/\\]*private[-_]?key[^/\\]*$/i,
  /(^|[/\\])[^/\\]*\.pem$/i,
  /(^|[/\\])[^/\\]*\.key$/i,
  /(^|[/\\])[^/\\]*\.p12$/i,
  /(^|[/\\])[^/\\]*\.pfx$/i,
  /(^|[/\\])secrets?[/\\]/i,
  /(^|[/\\])credentials?[/\\]/i,
];

const BASH_SECRET_HINT = /(^|\s|['"`=:/\\.\-])(\.env($|[.\-_/\\\s'"`])|[^\s'"`]*secret[^\s'"`]*|[^\s'"`]*credential[^\s'"`]*|[^\s'"`]*token[^\s'"`]*|\.npmrc\b|\.pypirc\b|\.netrc\b|id_(rsa|dsa|ecdsa|ed25519)\b|[^\s'"`]*\.(pem|key|p12|pfx)\b)/i;

const approvals = new Set<string>();

function normalizeForMatch(p: string, cwd: string): string {
  const cleaned = p.trim().replace(/^['"]|['"]$/g, "");
  const abs = path.isAbsolute(cleaned) ? cleaned : path.resolve(cwd, cleaned);
  return abs.split(path.sep).join("/");
}

function isSecretPath(p: string | undefined, cwd: string): boolean {
  if (!p) return false;
  const normalized = normalizeForMatch(p, cwd);
  return DEFAULT_SECRET_PATTERNS.some((pattern) => pattern.test(normalized));
}

function toolOp(toolName: string): "read" | "write" | "shell" | null {
  if (toolName === "read") return "read";
  if (toolName === "write" || toolName === "edit") return "write";
  if (toolName === "bash") return "shell";
  return null;
}

function approvalKey(op: string, target: string): string {
  return `${op}:${target}`;
}

async function askConsent(ctx: any, op: string, target: string): Promise<Decision> {
  const key = approvalKey(op, target);
  if (approvals.has(key)) return "allow";

  if (!ctx.hasUI) return "block";

  const ok = await ctx.ui.confirm(
    "sensible-guard: secret file access",
    [
      `Agent requested ${op} access to protected secret target:`,
      "",
      target,
      "",
      "Allow once for this session?",
    ].join("\n"),
  );

  if (!ok) return "block";
  approvals.add(key);
  return "allow";
}

export default function sensibleGuard(pi: ExtensionAPI) {
  pi.registerCommand("sensible-guard", {
    description: "Show sensible-guard status / clear approvals",
    handler: async (args, ctx) => {
      if (args.trim() === "clear") {
        approvals.clear();
        ctx.ui.notify("sensible-guard approvals cleared", "info");
        return;
      }
      ctx.ui.notify(`sensible-guard active; ${approvals.size} session approval(s). Use /sensible-guard clear to reset.`, "info");
    },
  });

  pi.on("tool_call", async (event, ctx) => {
    const op = toolOp(event.toolName);
    if (!op) return;

    let target: string | undefined;

    if (isToolCallEventType("read", event) || isToolCallEventType("write", event) || isToolCallEventType("edit", event)) {
      target = (event.input as ToolInputWithPath).path;
      if (!isSecretPath(target, ctx.cwd)) return;
    } else if (isToolCallEventType("bash", event)) {
      target = event.input.command;
      if (!BASH_SECRET_HINT.test(target)) return;
    } else {
      return;
    }

    const decision = await askConsent(ctx, op, target ?? "<unknown>");
    if (decision === "allow") return;

    return {
      block: true,
      reason: `Blocked by sensible-guard: ${op} access to protected secret target requires explicit user consent. Ask user before retrying.`,
    };
  });
}
