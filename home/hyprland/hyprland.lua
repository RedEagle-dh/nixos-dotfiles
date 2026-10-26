local theme = require("theme")
local c = theme.colors

-- scheme/current.lua schreibt caelestia bei jedem Farbwechsel neu.
local schemeFile = io.open(os.getenv("HOME") .. "/.config/hypr/scheme/current.lua")
if schemeFile then
    schemeFile:close()
    local ok, scheme = pcall(require, "scheme.current")
    if ok and type(scheme) == "table" and scheme.primary then
        c = setmetatable({
            iris    = scheme.primary,
            rose    = scheme.tertiary,
            gold    = scheme.secondary,
            overlay = scheme.surfaceContainerHighest,
            subtle  = scheme.onSurfaceVariant,
            base    = scheme.surface,
        }, { __index = theme.colors })
    end
end

local function rgba(name, alpha)
    return "rgba(" .. c[name] .. (alpha or "ff") .. ")"
end

hl.monitor({
    output   = "",
    mode     = "highres",
    position = "auto",
    scale    = "auto",
    bitdepth = 10,
})

hl.env("XCURSOR_THEME", theme.cursor.name)
hl.env("XCURSOR_SIZE",  tostring(theme.cursor.size))

hl.config({
    general = {
        gaps_in  = 6,
        gaps_out = 14,

        border_size = 2,
        col = {
            active_border   = { colors = { rgba("iris"), rgba("rose") }, angle = 45 },
            inactive_border = rgba("overlay"),
        },

        resize_on_border = true,
        layout = "dwindle",

        snap = { enabled = true },
    },

    decoration = {
        rounding       = 14,
        rounding_power = 2.4,

        shadow = {
            enabled        = true,
            range          = 24,
            render_power   = 3,
            color          = "rgba(0000005a)",
            color_inactive = "rgba(00000030)",
        },

        blur = {
            enabled  = true,
            size     = 7,
            passes   = 3,
            vibrancy = 0.2,
            noise    = 0.015,
            popups   = true,
        },
    },

    group = {
        col = {
            border_active        = { colors = { rgba("rose"), rgba("iris") }, angle = 45 },
            border_inactive      = rgba("overlay"),
            border_locked_active = rgba("gold"),
        },
        groupbar = {
            font_family         = theme.fonts.ui,
            font_size           = 11,
            height              = 20,
            indicator_height    = 0,
            gradients           = true,
            rounding            = 8,
            text_color          = rgba("base"),
            text_color_inactive = rgba("subtle"),
            col = {
                active   = rgba("iris", "e6"),
                inactive = rgba("overlay", "e6"),
            },
        },
    },

    misc = {
        disable_hyprland_logo    = true,
        disable_splash_rendering = true,
        force_default_wallpaper  = 0,
        background_color         = rgba("base"),

        mouse_move_enables_dpms = true,
        key_press_enables_dpms  = true,

        focus_on_activate = true,

        middle_click_paste = false,

        enable_swallow = true,
        swallow_regex  = "^(kitty)$",

        -- Bei Flackern auf 0 setzen
        vrr = 2,
    },

    render = {
        cm_auto_hdr = 1,
    },

    cursor = {
        hide_on_key_press = true,
    },

    binds = {
        workspace_back_and_forth = true,
    },

    dwindle = {
        preserve_split = true,
    },

    xwayland = {
        force_zero_scaling = true,
    },

    ecosystem = {
        no_update_news   = true,
        no_donation_nag  = true,
    },
})

hl.config({ animations = { enabled = true } })

hl.curve("smooth", { type = "bezier", points = { {0.25, 1},    {0.5, 1}  } })
hl.curve("swift",  { type = "bezier", points = { {0.05, 0.9},  {0.1, 1}  } })
hl.curve("linear", { type = "bezier", points = { {0, 0},       {1, 1}    } })
-- Bei spring zählt speed nicht – nur stiffness und dampening.
hl.curve("bouncy", { type = "spring", mass = 1, stiffness = 300, dampening = 30 })

hl.animation({ leaf = "global",           enabled = true, speed = 8,   bezier = "default" })
hl.animation({ leaf = "windows",          enabled = true, speed = 3,   spring = "bouncy" })
hl.animation({ leaf = "windowsIn",        enabled = true, speed = 3,   spring = "bouncy", style = "popin 88%" })
hl.animation({ leaf = "windowsOut",       enabled = true, speed = 1.5, bezier = "smooth", style = "popin 88%" })
hl.animation({ leaf = "border",           enabled = true, speed = 6,   bezier = "smooth" })
hl.animation({ leaf = "fade",             enabled = true, speed = 3,   bezier = "smooth" })
hl.animation({ leaf = "layersIn",         enabled = true, speed = 3,   bezier = "swift",  style = "popin 92%" })
hl.animation({ leaf = "layersOut",        enabled = true, speed = 2,   bezier = "smooth", style = "fade" })
hl.animation({ leaf = "workspaces",       enabled = true, speed = 4,   bezier = "swift",  style = "slidefade 12%" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 4,   bezier = "swift",  style = "slidefadevert 20%" })
hl.animation({ leaf = "zoomFactor",       enabled = true, speed = 6,   bezier = "smooth" })

hl.config({
    input = {
        kb_layout          = "de",
        numlock_by_default = true,

        repeat_delay = 280,
        repeat_rate  = 35,

        follow_mouse  = 1,
        sensitivity   = 0,
        accel_profile = "flat",
    },
})

hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({
    name  = "idle-inhibit-fullscreen",
    match = { class = ".*" },
    idle_inhibit = "fullscreen",
})

hl.window_rule({
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },
    no_focus = true,
})

local floating = {
    { class = "^(org.pulseaudio.pavucontrol)$" },
    { class = "^(nm-connection-editor)$" },
    { class = "^(org.gnome.FileRoller)$" },
    { class = "^(org.gnome.Calculator)$" },
    { class = "^(xdg-desktop-portal-gtk)$" },
    { class = "^(com.gabm.satty)$" },
    { title = "^(Datei öffnen|Datei speichern|Speichern unter|Open File|Save File|Save As).*$" },
}
for i, match in ipairs(floating) do
    hl.window_rule({
        name   = "float-tools-" .. i,
        match  = match,
        float  = true,
        center = true,
        size   = { "monitor_w*0.5", "monitor_h*0.6" },
    })
end

hl.window_rule({
    name   = "float-polkit",
    match  = { class = "(?i).*soteria.*" },
    float  = true,
    center = true,
    pin    = true,
})

hl.window_rule({
    name   = "float-btop",
    match  = { class = "^(btop)$" },
    float  = true,
    center = true,
    size   = { "monitor_w*0.7", "monitor_h*0.75" },
})

hl.window_rule({
    name  = "picture-in-picture",
    match = { title = "^(Picture-in-Picture|Bild-im-Bild)$" },
    float = true,
    pin   = true,
    keep_aspect_ratio = true,
    size  = { "monitor_w*0.25", "monitor_h*0.25" },
    move  = { "monitor_w-window_w-24", "monitor_h-window_h-24" },
})

for i = 1, 5 do
    hl.workspace_rule({ workspace = tostring(i), persistent = true })
end

for _, name in ipairs({ "passwords", "sysmon", "music", "communication" }) do
    hl.workspace_rule({ workspace = "special:" .. name, gaps_out = 60 })
end

hl.layer_rule({ name = "blur-launcher", match = { namespace = "^launcher$" }, blur = true, ignore_alpha = 0.3 })
hl.layer_rule({ name = "no-anim-selection", match = { namespace = "^(selection|hyprpicker)$" }, no_anim = true })
hl.layer_rule({ name = "caelestia-fade",    match = { namespace = "^caelestia-(drawers|background)$" }, animation = "fade" })
hl.layer_rule({ name = "caelestia-no-anim", match = { namespace = "^caelestia-(border-exclusion|area-picker)$" }, no_anim = true })

require("keybinds")

-- Autostart läuft als systemd-Dienste über UWSM, nicht hier.
