-- Pull in the wezterm API
local wezterm = require("wezterm")

local config = {}

if wezterm.config_builder then
	config = wezterm.config_builder()
end

config.font_size = 15.0
config.line_height = 1.2

config.font = wezterm.font("FiraCode Nerd Font", { weight = "Medium" })

config.font_rules = {
	-- normal-intensity-and-italic
	{
		intensity = "Normal",
		italic = true,
		font = wezterm.font({
			family = "FiraCode Nerd Font",
			weight = "DemiBold",
			italic = true,
		}),
	},
}

-- Trying out Monaspace
-- config.font = wezterm.font("Monaspace Neon", { weight = "Medium", stretch = "Normal" })
-- config.font_rules = {
-- 	{
-- 		intensity = "Bold",
-- 		italic = false,
-- 		font = wezterm.font({
-- 			family = "Monaspace Argon",
-- 			weight = "Bold",
-- 			italic = false,
-- 		}),
-- 	},
-- 	-- Bold-and-italic
-- 	{
-- 		intensity = "Bold",
-- 		italic = true,
-- 		font = wezterm.font({
-- 			family = "Monaspace Radon",
-- 			weight = "Bold",
-- 			italic = true,
-- 		}),
-- 	},
-- 	-- normal-intensity-and-italic
-- 	{
-- 		intensity = "Normal",
-- 		italic = true,
-- 		font = wezterm.font({
-- 			family = "Monaspace Radon",
-- 			weight = "DemiBold",
-- 			italic = true,
-- 		}),
-- 	},
-- }
--
-- config.exit_behavior = "Close"
config.window_close_confirmation = "NeverPrompt"
config.exit_behavior_messaging = "None"

-- This is where you actually apply your config choices

-- config.window_decorations = "RESIZE"
config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
-- config.default_domain = "WSL:Ubuntu"
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
	{ key = "P", mods = "SHIFT|CTRL", action = wezterm.action.DisableDefaultAssignment },
	{ key = "p", mods = "SHIFT|CTRL", action = wezterm.action.DisableDefaultAssignment },
	{ key = "P", mods = "CTRL", action = wezterm.action.DisableDefaultAssignment },
}

local color = "#ff33b8"

config.color_scheme = "Night Owl (Gogh)"
config.window_background_opacity = 0.97
config.window_frame = {
	active_titlebar_bg = "#011627",
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
	-- cursor_bg = "#80a4c2",
	-- cursor_fg = "#7f6057",
	cursor_bg = color,
	cursor_fg = "#01121f",
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
