-- Pull in the wezterm API
local wezterm = require("wezterm")

local config = {}

if wezterm.config_builder then
	config = wezterm.config_builder()
end

config.term = "wezterm"

config.font_size = 14
config.line_height = 1

-- config.font = wezterm.font("FiraCode Nerd Font")
-- config.font = wezterm.font("JetBrainsMono Nerd Font Mono", { weight = "Medium" })
config.font = wezterm.font("Maple Mono NF", { weight = "Regular" })
-- config.font = wezterm.font("JetBrainsMono Nerd Font Mono", { weight = "Medium" })
-- config.bold_brightens_ansi_colors = "BrightAndBold"

-- config.font = wezterm.font("Monaspace Neon", { weight = "Regular" })
-->
-- => asdas
--

-- config.font_rules = {
-- 	-- normal-intensity-and-italic
-- 	{
-- 		intensity = "Normal",
-- 		italic = true,
-- 		font = wezterm.font({
-- 			family = "FiraCode Nerd Font",
-- 			-- weight = "DemiBold",
-- 			-- italic = true,
-- 		}),
-- 	},
-- }

-- Trying out Monaspace
-- config.font = wezterm.font("Monaspace Neon", { weight = "Medium", stretch = "Normal" })
config.font_rules = {
	-- {
	-- 	intensity = "Bold",
	-- 	italic = false,
	-- 	font = wezterm.font({
	-- 		family = "Monaspace Argon",
	-- 		weight = "Bold",
	-- 		italic = false,
	-- 	}),
	-- },
	-- 	-- Bold-and-italic
	-- {
	-- 	intensity = "Bold",
	-- 	italic = true,
	-- 	font = wezterm.font({
	-- 		family = "Monaspace Radon",
	-- 		weight = "Bold",
	-- 		italic = true,
	-- 	}),
	-- },
	-- 	-- normal-intensity-and-italic
	-- {
	-- 	intensity = "Normal",
	-- 	italic = true,
	-- 	font = wezterm.font({
	-- 		family = "Monaspace Radon",
	-- 		weight = "Regular",
	-- 		italic = false,
	-- 	}),
	-- },
}

-- config.exit_behavior = "Close"
-- config.hide_tab_bar_if_only_one_tab = true
config.window_close_confirmation = "NeverPrompt"
config.exit_behavior_messaging = "None"

-- This is where you actually apply your config choices

-- config.window_decorations = "RESIZE"
config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"


if string.find(wezterm.target_triple, "windows") ~= nil then
	config.default_domain = "WSL:Ubuntu"
end

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
	{
		key = "y",
		mods = "CTRL",
		action = wezterm.action.SpawnTab({
			DomainName = 'local',
		}),
	},
	{ key = "O", mods = "CTRL",       action = wezterm.action.DisableDefaultAssignment },
	{ key = "o", mods = "SHIFT|CTRL", action = wezterm.action.DisableDefaultAssignment },
	{ key = "P", mods = "SHIFT|CTRL", action = wezterm.action.DisableDefaultAssignment },
	{ key = "p", mods = "SHIFT|CTRL", action = wezterm.action.DisableDefaultAssignment },
	{ key = "P", mods = "CTRL",       action = wezterm.action.DisableDefaultAssignment },
}

local color = "#ff33b8"


config.color_scheme = "Catppuccin Mocha"
config.window_background_opacity = 0.981
-- config.window_background_opacity = 0.3
config.macos_window_background_blur = 10
-- config.window_frame = {
-- 	active_titlebar_bg = "#011627",
-- 	active_titlebar_fg = "#011627",
-- 	inactive_titlebar_bg = "#061d30",
-- 	inactive_titlebar_fg = "#060d30",
-- }
-- config.color_scheme = "Tokyo Night"

-- config.window_background_opacity = 0.90
-- config.window_background_opacity = 0.3
-- config.macos_window_background_blur = 10

-- Night owl
-- config.window_frame = {
-- 	active_titlebar_bg = "#011627",
-- 	active_titlebar_fg = "#011627",
-- 	inactive_titlebar_bg = "#061d30",
-- 	inactive_titlebar_fg = "#060d30",
-- }
--
-- config.colors = {
-- 	-- cursor_bg = "#80a4c2",
-- 	-- cursor_fg = "#7f6057",
-- 	cursor_bg = color,
-- 	cursor_fg = "#01121f",
-- 	tab_bar = {
-- 		active_tab = {
-- 			bg_color = "#0b2942",
-- 			fg_color = "#ffffff",
-- 		},
-- 		inactive_tab = {
-- 			bg_color = "#061d30",
-- 			fg_color = "#5c7886",
-- 		},
-- 		inactive_tab_hover = {
-- 			bg_color = "#061d30",
-- 			fg_color = "#5c7886",
-- 		},
-- 		new_tab = {
-- 			bg_color = "#011627",
-- 			fg_color = "#5c7886",
-- 		},
-- 		new_tab_hover = {
-- 			bg_color = "#0b2942",
-- 			fg_color = "#ffffff",
-- 		},
-- 	},
-- }

-- Catpuccin
-- config.window_frame = {
-- 	active_titlebar_bg = "#181825",
-- 	active_titlebar_fg = "#181825",
-- 	inactive_titlebar_bg = "#2a2b3c",
-- 	inactive_titlebar_fg = "#2a2b3c",
-- }
config.colors = {
	cursor_bg = color,
	cursor_fg = "#01121f",
	-- tab_bar = {
	-- 	active_tab = {
	-- 		bg_color = "#181825",
	-- 		fg_color = "#181825",
	-- 	},
	-- 	inactive_tab = {
	-- 		bg_color = "#2a2b3c",
	-- 		fg_color = "#5c7886",
	-- 	},
	-- 	inactive_tab_hover = {
	-- 		bg_color = "#2a2b3c",
	-- 		fg_color = "#c5ceeb",
	-- 	},
	-- 	new_tab = {
	-- 		bg_color = "#181825",
	-- 		fg_color = "#181825",
	-- 	},
	-- 	new_tab_hover = {
	-- 		bg_color = "#2a2b3c",
	-- 		fg_color = "#c5ceeb",
	-- 	},
	-- },
}

-- Zen mode nvim plugin
-- https://github.com/folke/zen-mode.nvim?tab=readme-ov-file#wezterm
wezterm.on("user-var-changed", function(window, pane, name, value)
	local overrides = window:get_config_overrides() or {}
	if name == "ZEN_MODE" then
		local incremental = value:find("+")
		local number_value = tonumber(value)
		if incremental ~= nil then
			while number_value > 0 do
				window:perform_action(wezterm.action.IncreaseFontSize, pane)
				number_value = number_value - 1
			end
			overrides.enable_tab_bar = false
		elseif number_value < 0 then
			window:perform_action(wezterm.action.ResetFontSize, pane)
			overrides.font_size = nil
			overrides.enable_tab_bar = true
		else
			overrides.font_size = number_value
			overrides.enable_tab_bar = false
		end
	end
	window:set_config_overrides(overrides)
end)

return config
