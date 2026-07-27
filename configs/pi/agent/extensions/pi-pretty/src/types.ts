export type Theme = {
	fg: (name: string, text: string) => string;
	bg?: (name: string, text: string) => string;
	bold: (text: string) => string;
};

export type ToolResult = {
	content?: Array<{ type: string; text?: string }>;
	details?: any;
};

export type PrettyTool = Record<string, any> & {
	__piPrettyWrapped?: boolean;
};

export type OutputMode = "hidden" | "summary" | "preview";

export type Config = {
	mode?: "compact" | "border" | "transparent";
	readMode?: OutputMode;
	searchMode?: OutputMode;
	bashMode?: "summary" | "preview";
	mcpMode?: OutputMode;
	groupToolCalls?: boolean;
	themeAdaptive?: boolean;
	previewLines?: number;
	expandedPreviewLines?: number;
	wideDiffAt?: number;
	diffColors?: {
		bgAdd?: string;
		bgDel?: string;
		bgAddHighlight?: string;
		bgDelHighlight?: string;
	};
};
