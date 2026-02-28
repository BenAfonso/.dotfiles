-- Pull in the wezterm API
local wezterm = require("wezterm")

local mytable = require("lib/stdlib").mytable

local config = {
	enable_tab_bar = false,
	window_close_confirmation = "NeverPrompt",
	exit_behavior_messaging = "None",
	-- Hyprland
	-- https://github.com/wezterm/wezterm/issues/6991
	window_decorations = "NONE",
	-- enable_wayland = false,
	enable_kitty_graphics = false,
}


-- WSL
if string.find(wezterm.target_triple, "windows") ~= nil then
	config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
	config.default_domain = "WSL:Ubuntu"
	config.window_decorations = "RESIZE"
end


return mytable.merge_all(
	config,
	require('theme'),
	require('keybindings'),
	{}
)
