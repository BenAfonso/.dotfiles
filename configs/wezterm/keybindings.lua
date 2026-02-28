local config = {}

local wezterm = require("wezterm")

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

return config
