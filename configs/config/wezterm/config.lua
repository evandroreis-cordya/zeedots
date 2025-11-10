local wezterm = require("wezterm")
local config = {}

if wezterm.config_builder then
	config = wezterm.config_builder()
end

config.default_cursor_style = "BlinkingBlock"
config.automatically_reload_config = true
config.window_close_confirmation = "AlwaysPrompt"
config.adjust_window_size_when_changing_font_size = false
config.window_decorations = "TITLE | RESIZE"
config.check_for_updates = true
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = false
config.font_size = 16
config.font = wezterm.font("CaskaydiaCove Nerd Font", { weight = "Regular", stretch = "Normal", style = "Normal" })
config.enable_tab_bar = true
config.initial_cols = 120
config.initial_rows = 28
config.window_padding = {
	left = 4,
	right = 4,
	top = 4,
	bottom = 4,
}
config.background = {
	{
		source = {
			File = os.getenv("HOME") .. "/.config/.personalize/backgrounds/wallpaperroses.jpg",
		},
		hsb = {
			hue = 1.0,
			saturation = 1.02,
			brightness = 0.25,
		},
		-- attachment = { Parallax = 0.3 },
		-- width = "100%",
		-- height = "100%",
	},
	{
		source = {
			Color = "#282c35",
		},
		width = "100%",
		height = "100%",
		-- opacity = 0.55,
		opacity = 0.75,
		-- opacity = 1,
	},
}
config.window_background_opacity = 0.3
config.macos_window_background_blur = 20
config.keys = {
	{ key = "Enter", mods = "CTRL", action = wezterm.action({ SendString = "\x1b[13;5u" }) },
	{ key = "Enter", mods = "SHIFT", action = wezterm.action({ SendString = "\x1b[13;2u" }) },
}
-- from: https://akos.ma/blog/adopting-wezterm/
config.hyperlink_rules = {
	-- Matches: a URL in parens: (URL)
	{
		regex = "\\((\\w+://\\S+)\\)",
		format = "$1",
		highlight = 1,
	},
	-- Matches: a URL in brackets: [URL]
	{
		regex = "\\[(\\w+://\\S+)\\]",
		format = "$1",
		highlight = 1,
	},
	-- Matches: a URL in curly braces: {URL}
	{
		regex = "\\{(\\w+://\\S+)\\}",
		format = "$1",
		highlight = 1,
	},
	-- Matches: a URL in angle brackets: <URL>
	{
		regex = "<(\\w+://\\S+)>",
		format = "$1",
		highlight = 1,
	},
	-- Then handle URLs not wrapped in brackets
	{
		regex = "[^(]\\b(\\w+://\\S+[)/a-zA-Z0-9-]+)",
		format = "$1",
		highlight = 1,
	},
}
return config
