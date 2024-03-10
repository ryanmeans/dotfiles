local wezterm = require("wezterm")
local config = wezterm.config_builder()
local act = wezterm.action

config.font = wezterm.font("SF Mono")
config.font_size = 13.0

config.use_fancy_tab_bar = false

local activatePane = function(direction)
	return act({ ActivatePaneDirection = direction })
end

local activateTab = function(idx)
	return act({ ActivateTab = idx })
end

local resizePane = function(direction)
	return act({ AdjustPaneSize = { direction, 5 } })
end

config.leader = { key = "a", mods = "CTRL" }
config.keys = {
	{ key = "s", mods = "LEADER", action = wezterm.action({ SplitHorizontal = { domain = "CurrentPaneDomain" } }) },
	{ key = "v", mods = "LEADER", action = wezterm.action({ SplitVertical = { domain = "CurrentPaneDomain" } }) },
	{ key = "c", mods = "LEADER", action = wezterm.action({ SpawnTab = "CurrentPaneDomain" }) },
	{ key = "z", mods = "LEADER", action = "TogglePaneZoomState" },
	{ key = "h", mods = "CTRL", action = activatePane("Left") },
	{ key = "j", mods = "CTRL", action = activatePane("Down") },
	{ key = "k", mods = "CTRL", action = activatePane("Up") },
	{ key = "l", mods = "CTRL", action = activatePane("Right") },
	{ key = "o", mods = "CTRL|LEADER", action = act.RotatePanes("Clockwise") },
	-- I dunno if you need to add SHIFT as a mod here, since the key is already uppercase
	-- The config I copied this from had this though
	{ key = "H", mods = "CTRL|SHIFT", action = resizePane("Left") },
	{ key = "J", mods = "CTRL|SHIFT", action = resizePane("Down") },
	{ key = "K", mods = "CTRL|SHIFT", action = resizePane("Up") },
	{ key = "L", mods = "CTRL|SHIFT", action = resizePane("Right") },
	{ key = "1", mods = "LEADER", action = activateTab(0) },
	{ key = "2", mods = "LEADER", action = activateTab(1) },
	{ key = "3", mods = "LEADER", action = activateTab(2) },
	{ key = "4", mods = "LEADER", action = activateTab(3) },
	{ key = "5", mods = "LEADER", action = activateTab(4) },
	{ key = "6", mods = "LEADER", action = activateTab(5) },
	{ key = "7", mods = "LEADER", action = activateTab(6) },
	{ key = "8", mods = "LEADER", action = activateTab(7) },
	{ key = "9", mods = "LEADER", action = activateTab(8) },
	{ key = "0", mods = "LEADER", action = activateTab(9) },
}

wezterm.on("window-config-reloaded", function(window)
	window:set_right_status(wezterm.format({
		{ Text = "stay positive :)" },
	}))
end)

config.color_schemes = {
	-- Apparently mine is a bit different from the one that ships with wezterm
	-- I think really just the background is different
	["Gruvbox dark (modified)"] = {
		foreground = "#EBDBB2",
		background = "#32302F",

		ansi = {
			"#282828",
			"#CC241D",
			"#98971A",
			"#D79921",
			"#458588",
			"#B16286",
			"#689D6A",
			"#A89984",
		},

		brights = {
			"#928374",
			"#FB4934",
			"#B8BB26",
			"#FABD2F",
			"#83A598",
			"#D3869B",
			"#8EC07C",
			"#EBDBB2",
		},

		tab_bar = {
			background = "#282828",

			active_tab = {
				bg_color = "#282828",
				fg_color = "#EBDBB2",
			},

			inactive_tab = {
				bg_color = "#282828",
				fg_color = "#A89984",
			},
		},
	},
}

config.color_scheme = "Gruvbox dark (modified)"

return config
