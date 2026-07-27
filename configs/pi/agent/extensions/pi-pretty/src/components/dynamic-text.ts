import type { Component } from "@earendil-works/pi-tui";

export class DynamicText implements Component {
	constructor(private readonly renderText: (width: number) => string) {}

	render(width: number): string[] {
		return this.renderText(width).split("\n");
	}

	invalidate(): void {}
}
