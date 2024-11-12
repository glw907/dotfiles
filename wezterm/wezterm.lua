-- Pull in the wezterm API
local wezterm = require("wezterm")

-- Define the configuration table
local config = {}

-- Set the color scheme to match the NeoVim kickstart theme
-- Ensure you've installed the 'tokyonight' color scheme for WezTerm
config.color_scheme = "tokyonight"

-- General Settings
config.enable_tab_bar = false -- Disable tab bar, NeoVim will manage splits and buffers
config.use_fancy_tab_bar = false -- Disable fancy tab bar for a cleaner look

-- Set font to FiraCode Nerd Font with SemiBold weight for a balanced look
config.font = wezterm.font("FiraCode Nerd Font", { weight = 500 })
config.font_size = 14.0 -- Adjust font size as needed

-- Set default window size to 140x40
config.initial_cols = 140
config.initial_rows = 40

-- macOS-Specific Optimizations
config.native_macos_fullscreen_mode = true -- Uses native macOS fullscreen
config.hide_mouse_cursor_when_typing = true -- Automatically hide cursor when typing

-- Enable ligatures for better code readability
config.harfbuzz_features = { "calt=1", "clig=1", "liga=1" }

-- Window Appearance
config.window_decorations = "RESIZE" -- Simplified window decorations for a clean look
config.window_background_opacity = 0.9 -- Slightly transparent background
config.macos_window_background_blur = 20 -- Add a subtle blur for aesthetic effect

-- Key Bindings to Support NeoVim Workflow
config.keys = {
	-- Map Command+w to close the WezTerm window, similar to standard macOS behavior
	{
		key = "w",
		mods = "CMD",
		action = wezterm.action.CloseCurrentPane({ confirm = true }),
	},
	-- Map Command+t to open a new tab if needed, following macOS standard shortcuts
	{
		key = "t",
		mods = "CMD",
		action = wezterm.action.SpawnTab("CurrentPaneDomain"),
	},
	-- Map Command+Enter to toggle fullscreen, aligning with macOS fullscreen conventions
	{
		key = "Enter",
		mods = "CMD",
		action = wezterm.action.ToggleFullScreen,
	},
}

-- Performance and Rendering
config.enable_wayland = false -- Wayland is disabled for compatibility with macOS
config.adjust_window_size_when_changing_font_size = false -- Prevents resizing on font change

-- Cursor and Scrollbar Settings
config.cursor_blink_rate = 0 -- Set to 0 for no blinking, personal preference
config.scrollback_lines = 5000 -- Ample scrollback for longer outputs

-- Status Line (Optional)
config.window_frame = {
	font = wezterm.font({ family = "JetBrains Mono", weight = "Bold" }),
	font_size = 12.0,
	active_titlebar_bg = "#1f2335", -- Matches the TokyoNight color scheme
	inactive_titlebar_bg = "#16161e",
}

-- Optional: Customize pane split to match NeoVim splits (useful if you’re opening WezTerm panes directly)
config.keys = {
	-- Vertical split
	{
		key = "|",
		mods = "CMD|SHIFT",
		action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	-- Horizontal split
	{
		key = "-",
		mods = "CMD|SHIFT",
		action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
}

-- Return the configuration to WezTerm
return config
