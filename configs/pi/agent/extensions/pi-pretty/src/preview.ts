import { effectivePreviewCap } from "./config";
import { branch } from "./rows";
import type { Theme } from "./types";
import { dim, lines, safeWidth, themed, truncateText } from "./text";

export function previewText(theme: Theme, output: string, cap: number, width = 80): string {
	const max = Math.max(16, safeWidth(width) - 6);
	const outputLines = lines(output).filter((line) => line.length > 0);
	const effectiveCap = effectivePreviewCap(cap);
	const shown = outputLines.slice(-effectiveCap).map((line, index, array) => {
		const connector = branch(theme, index === array.length - 1);
		return `${connector} ${themed(theme, "toolOutput", truncateText(line, max))}`;
	});

	if (outputLines.length > effectiveCap) {
		shown.unshift(`${branch(theme)} ${dim(theme, truncateText(`… ${outputLines.length - effectiveCap} earlier lines`, max))}`);
	}

	return shown.join("\n");
}
