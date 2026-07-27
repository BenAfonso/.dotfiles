import { config } from "./config";
import { lines, outputText, truncateText } from "./text";

export function updateLivePreview(event: any, ctx: any): void {
	const output = outputText(event.partialResult || {});
	if (!output || !ctx.ui?.setWidget) return;

	const latest = lines(output)
		.slice(-Math.min(4, config().previewLines))
		.map((line) => truncateText(line, 100))
		.join("\n");

	ctx.ui.setWidget("pi-pretty-live", [`${event.toolName} running`, latest]);
}

export function clearLivePreview(ctx: any): void {
	ctx.ui?.setWidget?.("pi-pretty-live", undefined);
}

export function updateThinkingStatus(event: any, ctx: any): void {
	const content = event.message?.content || [];
	const thinking = content.find?.((item: any) => item.type === "thinking")?.thinking;
	if (!thinking) return;

	const label = String(thinking).replace(/\s+/g, " ").slice(0, 36);
	ctx.ui?.setStatus?.("pi-pretty-thinking", `󰔟 thinking ${label}…`);
}

export function clearThinkingStatus(ctx: any): void {
	ctx.ui?.setStatus?.("pi-pretty-thinking", undefined);
}
