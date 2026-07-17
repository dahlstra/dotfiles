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
    top = 10,
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

-- Catppuccin Mocha palette
local mocha = {
  rosewater = "#f5e0dc",
  flamingo  = "#f2cdcd",
  pink      = "#f5c2e7",
  mauve     = "#cba6f7",
  red       = "#f38ba8",
  maroon    = "#eba0ac",
  peach     = "#fab387",
  yellow    = "#f9e2af",
  green     = "#a6e3a1",
  teal      = "#94e2d5",
  sky       = "#89dceb",
  sapphire  = "#74c7ec",
  blue      = "#89b4fa",
  lavender  = "#b4befe",
  text      = "#cdd6f4",
  subtext1  = "#bac2de",
  subtext0  = "#a6adc8",
  overlay2  = "#9399b2",
  overlay1  = "#7f849c",
  overlay0  = "#6c7086",
  surface2  = "#585b70",
  surface1  = "#45475a",
  surface0  = "#313244",
  base      = "#1e1e2e",
  mantle    = "#181825",
  crust     = "#11111b",
}

config.color_scheme = "Catppuccin Mocha"
config.font = wezterm.font("Hack Nerd Font Mono")
config.font_size = 12

-- General tab bar look
config.enable_tab_bar = true
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = false
config.hide_tab_bar_if_only_one_tab = false
config.tab_max_width = 62

config.window_frame = {
  font = wezterm.font({ family = "Hack Nerd Font Mono", weight = "Bold" }),
  font_size = 12,
  active_titlebar_bg = mocha.base,
  inactive_titlebar_bg = mocha.base,
}

config.colors = {
  tab_bar = {
    background = mocha.crust,
    new_tab = {
      bg_color = mocha.crust,
      fg_color = mocha.overlay0,
    },
    new_tab_hover = {
      bg_color = mocha.surface0,
      fg_color = mocha.lavender,
      italic = true,
    },
  },
}

-- Powerline-style separators
local SOLID_LEFT_ARROW = wezterm.nerdfonts.pl_right_hard_divider
local SOLID_RIGHT_ARROW = wezterm.nerdfonts.pl_left_hard_divider

local accent_colors = {
  mocha.mauve,
  mocha.blue,
  mocha.green,
  mocha.peach,
  mocha.pink,
  mocha.sapphire,
  mocha.yellow,
  mocha.red,
}

-- Process name -> Nerd Font icon
-- Keys are matched against the last path segment of the foreground process,
-- lowercased, with any .exe stripped (Windows-friendly).
local process_icons = {
  ["nvim"]        = wezterm.nerdfonts.custom_vim,
  ["vim"]         = wezterm.nerdfonts.dev_vim,
  ["git"]         = wezterm.nerdfonts.dev_git,
  ["node"]        = wezterm.nerdfonts.md_nodejs,
  ["npm"]         = wezterm.nerdfonts.md_npm,
  ["python"]      = wezterm.nerdfonts.dev_python,
  ["python3"]     = wezterm.nerdfonts.dev_python,
  ["cargo"]       = wezterm.nerdfonts.dev_rust,
  ["rustc"]       = wezterm.nerdfonts.dev_rust,
  ["docker"]      = wezterm.nerdfonts.linux_docker,
  ["docker-compose"] = wezterm.nerdfonts.linux_docker,
  ["ssh"]         = wezterm.nerdfonts.md_ssh,
  ["lazygit"]     = wezterm.nerdfonts.dev_git,
  ["pwsh"]        = wezterm.nerdfonts.md_powershell,
  ["powershell"]  = wezterm.nerdfonts.md_powershell,
  ["cmd"]         = wezterm.nerdfonts.md_console,
  ["bash"]        = wezterm.nerdfonts.cod_terminal_bash,
  ["zsh"]         = wezterm.nerdfonts.dev_terminal,
  ["fish"]        = wezterm.nerdfonts.dev_terminal,
  ["dotnet"]      = wezterm.nerdfonts.md_language_csharp,
  ["msbuild"]     = wezterm.nerdfonts.md_language_csharp,
  ["code"]        = wezterm.nerdfonts.md_microsoft_visual_studio_code,
  ["top"]         = wezterm.nerdfonts.md_chart_donut,
  ["htop"]        = wezterm.nerdfonts.md_chart_donut,
  ["btop"]        = wezterm.nerdfonts.md_chart_donut,
  ["psql"]        = wezterm.nerdfonts.dev_postgresql,
  ["mysql"]       = wezterm.nerdfonts.dev_mysql,
  ["make"]        = wezterm.nerdfonts.seti_makefile,
}

local default_icon = wezterm.nerdfonts.md_console_line

local function get_process_icon(tab)
  local process_name = tab.active_pane.foreground_process_name or ""

  -- Strip path (handles both / and \ separators) and .exe suffix
  local basename = process_name:match("([^/\\]+)$") or process_name
  basename = basename:gsub("%.exe$", ""):lower()

  return process_icons[basename] or default_icon
end

wezterm.on("format-tab-title", function(tab, _, _, cfg, hover, _)
  local index = tab.tab_index + 1
  local accent = accent_colors[(index % #accent_colors) + 1]

  local is_active = tab.is_active
  local bg = is_active and accent or mocha.surface0
  local fg = is_active and mocha.crust or mocha.subtext0
  local edge_bg = mocha.crust

  if hover and not is_active then
    bg = mocha.surface1
    fg = mocha.text
  end

  local title = tab.tab_title
  if not title or title == "" then
    title = tab.active_pane.title
  end

  local icon = get_process_icon(tab)

  local max_title_width = cfg.tab_max_width - 8
  if #title > max_title_width then
    title = wezterm.truncate_right(title, max_title_width) .. "…"
  end

  return {
    { Background = { Color = edge_bg } },
    { Foreground = { Color = bg } },
    { Text = SOLID_LEFT_ARROW },
    { Background = { Color = bg } },
    { Foreground = { Color = fg } },
    { Text = " " .. icon .. " " .. title .. " " },
    { Background = { Color = edge_bg } },
    { Foreground = { Color = bg } },
    { Text = SOLID_RIGHT_ARROW },
  }
end)

return config
