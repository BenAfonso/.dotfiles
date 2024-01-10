-- Pull in the wezterm API
local wezterm = require("wezterm")
local colors = require("colors")

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
	config = wezterm.config_builder()
end

-- config.exit_behavior = "Close"
config.window_close_confirmation = "NeverPrompt"
-- config.tab_close_confirmation = "NeverPrompt"
config.exit_behavior_messaging = "None"

-- This is where you actually apply your config choices

config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
config.default_domain = "WSL:Ubuntu"
config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}

config.keys = {
	{
		key = "r",
		mods = "CMD|SHIFT",
		action = wezterm.action.ReloadConfiguration,
	},
}

local color = "#ff33b8"

config.window_frame = {
	active_titlebar_bg = color, -- "#011627",
	active_titlebar_border_bottom = "#ff0000", --"#2b2042",
	-- border_left_width = "2px",
	-- border_right_width = "2px",
	-- border_bottom_height = "2px",
	-- border_top_height = "2px",
	-- border_left_color = color,
	-- border_right_color = color,
	-- border_bottom_color = color,
	-- border_top_color = color,
}

config.colors = {
	cursor_bg = color,
	tab_bar = {
		active_tab = {
			bg_color = "#0b2942",
			fg_color = "#ffffff",
		},
		inactive_tab = {
			bg_color = "#061d30",
			fg_color = "#5c7886",
		},
		inactive_tab_hover = {
			bg_color = "#061d30",
			fg_color = "#5c7886",
		},
		new_tab = {
			bg_color = "#011627",
			fg_color = "#5c7886",
		},
		new_tab_hover = {
			bg_color = "#0b2942",
			fg_color = "#ffffff",
		},
	},
}

return config
