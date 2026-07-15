local wezterm = require("wezterm")
local act = wezterm.action
local config = wezterm.config_builder()

config.command_palette_fg_color = '#b4befe'
config.command_palette_bg_color = '#0c0b0f'
config.command_palette_font_size = 12
config.command_palette_rows = 25

config.inactive_pane_hsb = {
    saturation = 1,
    brightness = 1,
}

config.adjust_window_size_when_changing_font_size = false
config.visual_bell = {
    fade_in_function = 'EaseIn',
    fade_in_duration_ms = 250,
    fade_out_function = 'EaseOut',
    fade_out_duration_ms = 250,
    target = 'CursorColor',
}
config.front_end = "OpenGL"
config.background = {
    {
        source = {
            File = "C:\\Users\\dahls\\OneDrive\\Documents\\totoro.jpg",
        },
        horizontal_align = "Center",
    },
    {
        source = { Color = "#1f1f28" },
        height = '120%',
        width = '120%',
        vertical_offset = '-10%',
        horizontal_offset = '-10%',
        opacity = 0.88,
    },
}
config.max_fps = 144
config.window_decorations = "RESIZE"
config.hide_tab_bar_if_only_one_tab = true
config.tab_max_width = 23
config.show_tab_index_in_tab_bar = false
config.switch_to_last_active_tab_when_closing_tab = true
config.animation_fps = 144
config.cursor_blink_rate = 900
config.cursor_blink_ease_in = "EaseOut"
config.cursor_blink_ease_out = "EaseOut"
config.automatically_reload_config = true
config.use_fancy_tab_bar = true
config.window_close_confirmation = "NeverPrompt"
config.default_cursor_style = "BlinkingBar"
config.color_scheme = "Catppuccin Mocha"
config.font = wezterm.font("Hack Nerd Font Mono")
config.font_size = 11
config.initial_cols = 80
config.default_prog = { "pwsh.exe", "-NoLogo" }
config.window_padding = {
    left = 5,
    right = 5,
    top = 7.5,
    bottom = 5,
}
config.window_frame = {
    font_size = 11,
    font = wezterm.font({ family = "Hack Nerd Font Mono", weight = "Regular" }),
    active_titlebar_bg = '#181825',
}

config.keys = {
    {
        key = "T",
        mods = "SHIFT|ALT",
        action = wezterm.action.EmitEvent("toggle-opacity"),
    },
    {
        key = "+",
        mods = "SHIFT|ALT",
        action = wezterm.action.SplitPane({
            direction = "Right",
            size = { Percent = 50 },
        }),
    },
    {
        key = "_",
        mods = "SHIFT|ALT",
        action = wezterm.action.SplitPane({
            direction = "Down",
            size = { Percent = 50 },
        }),
    },
    {
        key = "LeftArrow",
        mods = "ALT|SHIFT",
        action = act.AdjustPaneSize({ "Left", 5 }),
    },
    {
        key = "DownArrow",
        mods = "ALT|SHIFT",
        action = act.AdjustPaneSize({ "Down", 5 }),
    },
    {
        key = "UpArrow",
        mods = "ALT|SHIFT",
        action = act.AdjustPaneSize({ "Up", 5 }),
    },
    {
        key = "RightArrow",
        mods = "ALT|SHIFT",
        action = act.AdjustPaneSize({ "Right", 5 }),
    },
    {
        key = "h",
        mods = "ALT|SHIFT",
        action = act.ActivatePaneDirection("Left"),
    },
    {
        key = "j",
        mods = "ALT|SHIFT",
        action = act.ActivatePaneDirection("Down"),
    },
    {
        key = "k",
        mods = "ALT|SHIFT",
        action = act.ActivatePaneDirection("Up"),
    },
    {
        key = "l",
        mods = "ALT|SHIFT",
        action = act.ActivatePaneDirection("Right"),
    },
    {
        key = "w",
        mods = "ALT|SHIFT",
        action = act.CloseCurrentPane({ confirm = true }),
    },
    {
        key = 'E',
        mods = 'CTRL|SHIFT',
        action = act.PromptInputLine {
            description = 'Enter new name for tab',
            action = wezterm.action_callback(function(window, _, line)
                -- line will be `nil` if they hit escape without entering anything
                -- An empty string if they just hit enter
                -- Or the actual line of text they wrote
                if line then
                    window:active_tab():set_title(line)
                end
            end),
        },
    },
}

return config
