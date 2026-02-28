-- Pull in the wezterm API
local wezterm = require("wezterm")


local config = {}

config.term = "wezterm"

config.font_size = 14
config.line_height = 1

config.font = wezterm.font("Maple Mono NF", { weight = "Regular" })

config.window_padding = {
	left = 0,
	right = 0,
	top = 10,
	bottom = 0,
}

local color = "#ff33b8"

config.color_scheme = "Catppuccin Mocha"
config.window_background_opacity = 1 -- 0.981
-- config.window_background_opacity = 0.3
config.macos_window_background_blur = 10

config.colors = {
	cursor_bg = color,
	cursor_fg = "#01121f",
}

config.enable_tab_bar = false

return config
