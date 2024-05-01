local wezterm = require("wezterm")
local config = wezterm.config_builder()
local act = wezterm.action

config.font = wezterm.font("SF Mono")
config.font_size = 13.0

config.use_fancy_tab_bar = false
config.window_decorations = "RESIZE"
config.audible_bell = "Disabled"
config.inactive_pane_hsb = {
	brightness = 0.90,
	saturation = 1.00,
}

local activate_tab = function(idx)
	return act({ ActivateTab = idx })
end

local resize_pane = function(direction)
	return act({ AdjustPaneSize = { direction, 5 } })
end

local function is_inside_vim(pane)
	local tty = pane:get_tty_name()

	if tty == nil then
		return false
	end

	local cmd = "ps -o state= -o comm= -t "
		.. wezterm.shell_quote_arg(tty)
		.. " | "
		.. "grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|l?n?vim?x?)(diff)?$'"

	local success, _, _ = wezterm.run_child_process({ "sh", "-c", cmd })
	return success
end

local function is_outside_vim(pane)
	return not is_inside_vim(pane)
end

local function action_if(cond, key, mods, action)
	local function callback(win, pane)
		if cond(pane) then
			win:perform_action(action, pane)
		else
			win:perform_action(act.SendKey({ key = key, mods = mods }), pane)
		end
	end

	return { key = key, mods = mods, action = wezterm.action_callback(callback) }
end

config.leader = { key = "a", mods = "CTRL" }
config.keys = {
	{ key = "v", mods = "LEADER", action = wezterm.action({ SplitHorizontal = { domain = "CurrentPaneDomain" } }) },
	{ key = "s", mods = "LEADER", action = wezterm.action({ SplitVertical = { domain = "CurrentPaneDomain" } }) },
	{ key = "c", mods = "LEADER", action = wezterm.action({ SpawnTab = "CurrentPaneDomain" }) },
	{ key = "z", mods = "LEADER", action = "TogglePaneZoomState" },
	{ key = "o", mods = "CTRL|LEADER", action = act.RotatePanes("Clockwise") },

	action_if(is_outside_vim, "h", "CTRL", act.ActivatePaneDirection("Left")),
	action_if(is_outside_vim, "j", "CTRL", act.ActivatePaneDirection("Down")),
	action_if(is_outside_vim, "k", "CTRL", act.ActivatePaneDirection("Up")),
	action_if(is_outside_vim, "l", "CTRL", act.ActivatePaneDirection("Right")),

	-- I dunno if you need to add SHIFT as a mod here, since the key is already uppercase
	-- The config I copied this from had this though
	{ key = "H", mods = "CTRL|SHIFT", action = resize_pane("Left") },
	{ key = "J", mods = "CTRL|SHIFT", action = resize_pane("Down") },
	{ key = "K", mods = "CTRL|SHIFT", action = resize_pane("Up") },
	{ key = "L", mods = "CTRL|SHIFT", action = resize_pane("Right") },
	{ key = "1", mods = "LEADER", action = activate_tab(0) },
	{ key = "2", mods = "LEADER", action = activate_tab(1) },
	{ key = "3", mods = "LEADER", action = activate_tab(2) },
	{ key = "4", mods = "LEADER", action = activate_tab(3) },
	{ key = "5", mods = "LEADER", action = activate_tab(4) },
	{ key = "6", mods = "LEADER", action = activate_tab(5) },
	{ key = "7", mods = "LEADER", action = activate_tab(6) },
	{ key = "8", mods = "LEADER", action = activate_tab(7) },
	{ key = "9", mods = "LEADER", action = activate_tab(8) },
	{ key = "0", mods = "LEADER", action = activate_tab(9) },

	{
		key = "#",
		mods = "LEADER|SHIFT",
		action = act.PaneSelect({
			alphabet = "1234567890",
			mode = "SwapWithActive",
		}),
	},

	{
		key = "$",
		mods = "LEADER|SHIFT",
		action = act.ShowDebugOverlay,
	},
}

config.adjust_window_size_when_changing_font_size = false

config.tab_bar_style = {}

local function add_tab_bar_to_scheme(scheme)
	scheme["tab_bar"] = {
		background = scheme.indexed[18],
		-- background = scheme.background,
		active_tab = {
			bg_color = scheme.background,
			fg_color = scheme.foreground,
		},
		inactive_tab = {
			bg_color = scheme.background,
			fg_color = scheme.brights[1],
		},
		inactive_tab_hover = {
			bg_color = scheme.indexed[18],
			fg_color = scheme.foreground,
		},
		new_tab = {
			bg_color = scheme.background,
			fg_color = scheme.brights[1],
		},
		new_tab_hover = {
			bg_color = scheme.indexed[18],
			fg_color = scheme.foreground,
		},
	}
	return scheme
end

local nord = add_tab_bar_to_scheme(wezterm.get_builtin_color_schemes()["Nord (base16)"])
local gruvbox_dark_base16 = add_tab_bar_to_scheme(wezterm.get_builtin_color_schemes()["Gruvbox dark, medium (base16)"])
local gruvbox_light_base16 =
	add_tab_bar_to_scheme(wezterm.get_builtin_color_schemes()["Gruvbox light, medium (base16)"])
local rose_pine_dawn = add_tab_bar_to_scheme(wezterm.get_builtin_color_schemes()["Rosé Pine Dawn (base16)"])

local colors, _ = wezterm.color.load_base16_scheme("/Users/means/.local/share/wezterm/themes/atelier-dune-light.yaml")
local atelier_dune_light = add_tab_bar_to_scheme(colors)

config.color_schemes = {
	["Gruvbox dark (base16)"] = gruvbox_dark_base16,
	["Gruvbox light (base16)"] = gruvbox_light_base16,
	["Nord (base16)"] = nord,
	["Atelier Dune Light"] = atelier_dune_light,
	["Rose Pine Dawn"] = rose_pine_dawn,
}

config.color_scheme = "Gruvbox dark (base16)"

local function scheme_for_appearence(appearence)
	if appearence:find("Dark") then
		return "Gruvbox dark (base16)"
	else
		return "Gruvbox light (base16)"
	end
end

wezterm.on("window-config-reloaded", function(window)
	window:set_right_status(wezterm.format({
		{ Text = "stay positive :)" },
	}))

	local overrides = window:get_config_overrides() or {}
	local appearence = window:get_appearance()
	local scheme = scheme_for_appearence(appearence)
	if overrides.color_scheme ~= scheme then
		overrides.color_scheme = scheme
		window:set_config_overrides(overrides)
	end
end)

return config
