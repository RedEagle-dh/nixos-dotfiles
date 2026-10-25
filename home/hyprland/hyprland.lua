-- hyprland.lua – Hyprland-Konfiguration (Hyprland 0.55, Lua)
--
-- Liegt im Repo unter home/hyprland/ und wird von Home Manager nach ~/.config/hypr/
-- verlinkt. Änderungen also im Repo machen und dann neu bauen: nhs
--
-- Aufteilung:
--   hyprland.lua  Bildschirm, Aussehen, Animationen, Eingabe, Fensterregeln
--   keybinds.lua  alle Tastenkürzel
--   theme.lua     Farben & Schriften – automatisch erzeugt aus theme/default.nix
--
-- Doku: https://wiki.hypr.land/Configuring/Start/

local theme = require("theme")
local c = theme.colors

-- Die Farben folgen dem Schema von caelestia (z. B. aus dem Hintergrundbild
-- berechnet): hypr/scheme/current.lua, schreibt caelestia bei jedem Wechsel
-- neu – Hyprland lädt die Config dann selbst neu. Fehlt die Datei noch,
-- gelten die Farben aus theme/default.nix.
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

-- Farbe aus der Palette als Hyprland-Farbwert, optional mit Deckkraft "00"–"ff"
local function rgba(name, alpha)
    return "rgba(" .. c[name] .. (alpha or "ff") .. ")"
end


--------------------
---- BILDSCHIRM ----
--------------------

-- Höchste Auflösung, dabei die höchste Bildwiederholrate (z. B. 1440p @ 165 Hz).
-- Für mehrere Monitore: `hyprctl monitors` zeigt die Namen, dann z. B.
-- hl.monitor({ output = "DP-1", mode = "2560x1440@165", position = "0x0", scale = 1 })
--
-- HDR: Der Monitor (Dell S2721DGF, DisplayHDR 400, bis ca. 420 Nits) kann HDR10.
-- Der Desktop bleibt in SDR; sobald ein Vollbild-Programm HDR liefert (Spiel,
-- Video in mpv), schaltet Hyprland von selbst auf HDR (render.cm_auto_hdr).
-- 10 Bit pro Farbe verhindert Farbstufen in Verläufen und im HDR-Modus.
-- HDR dauerhaft, auch auf dem Desktop: cm = "hdr" ergänzen. Wirken normale
-- Programme dann blass oder dunkel: sdrbrightness (z. B. 1.2) und
-- sdrsaturation (z. B. 1.1) nachregeln.
hl.monitor({
    output   = "",
    mode     = "highres",
    position = "auto",
    scale    = "auto",
    bitdepth = 10,
})


----------------------------
---- UMGEBUNGSVARIABLEN ----
----------------------------

-- Mauszeiger (theme/default.nix) – für Hyprland selbst und alle Programme
hl.env("XCURSOR_THEME", theme.cursor.name)
hl.env("XCURSOR_SIZE",  tostring(theme.cursor.size))


-----------------
---- AUSSEHEN ----
-----------------

hl.config({
    general = {
        gaps_in  = 6,   -- Abstand zwischen Fenstern
        gaps_out = 14,  -- Abstand zum Bildschirmrand (passt zur Leiste)

        border_size = 2,
        col = {
            -- aktives Fenster: Verlauf in den beiden Akzentfarben
            active_border   = { colors = { rgba("iris"), rgba("rose") }, angle = 45 },
            inactive_border = rgba("overlay"),
        },

        resize_on_border = true, -- Fenster am Rand mit der Maus größer/kleiner ziehen
        layout = "dwindle",      -- jedes neue Fenster teilt den Platz des aktiven

        snap = { enabled = true }, -- schwebende Fenster rasten an Rändern ein
    },

    decoration = {
        rounding       = 14,
        rounding_power = 2.4, -- etwas weicher als ein Kreisbogen ("Squircle")

        shadow = {
            enabled        = true,
            range          = 24,
            render_power   = 3,
            color          = "rgba(0000005a)",
            color_inactive = "rgba(00000030)",
        },

        -- Milchglas hinter halbtransparenten Flächen (Leiste, Menüs, Terminal)
        blur = {
            enabled  = true,
            size     = 7,
            passes   = 3,
            vibrancy = 0.2,
            noise    = 0.015,
            popups   = true,
        },
    },

    -- Tabs (Super+G): Fenster in einer Gruppe stapeln
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
        background_color         = rgba("base"), -- falls das Hintergrundbild noch lädt

        -- ausgeschaltete Monitore wachen bei Maus oder Tastatur auf
        mouse_move_enables_dpms = true,
        key_press_enables_dpms  = true,

        -- Link im Terminal anklicken → Browser kommt nach vorne
        focus_on_activate = true,

        -- Mittlere Maustaste fügt NICHT die markierte Auswahl ein
        middle_click_paste = false,

        -- Startet man z. B. mpv aus Kitty, ersetzt das Video das Terminalfenster
        enable_swallow = true,
        swallow_regex  = "^(kitty)$",

        -- Adaptive Sync (G-Sync/FreeSync) nur bei Vollbild – ideal für Spiele.
        -- Bei Flackern auf 0 setzen.
        vrr = 2,
    },

    render = {
        -- Vollbild-Programm liefert HDR → Monitor schaltet auf HDR (1 = an)
        cm_auto_hdr = 1,
    },

    cursor = {
        hide_on_key_press = true, -- Zeiger verschwindet beim Tippen
    },

    binds = {
        workspace_back_and_forth = true, -- Super+3 auf Fläche 3 springt zurück
    },

    dwindle = {
        preserve_split = true, -- Teilungsrichtung bleibt beim Schließen erhalten
    },

    xwayland = {
        force_zero_scaling = true, -- ältere X11-Programme werden nicht unscharf skaliert
    },

    ecosystem = {
        no_update_news   = true,
        no_donation_nag  = true,
    },
})


--------------------
---- ANIMATIONEN ----
--------------------
-- Kurz und federnd: Fenster "ploppen" auf, Arbeitsflächen gleiten seitlich.

hl.config({ animations = { enabled = true } })

hl.curve("smooth", { type = "bezier", points = { {0.25, 1},    {0.5, 1}  } })
hl.curve("swift",  { type = "bezier", points = { {0.05, 0.9},  {0.1, 1}  } })
hl.curve("linear", { type = "bezier", points = { {0, 0},       {1, 1}    } })
-- Feder für Fenster (Verschieben, Öffnen). Bei Federn zählt "speed" nicht – die
-- Dauer ergibt sich aus stiffness (höher = schneller) und dampening (höher =
-- weniger Nachfedern). So steht ein Fenster nach etwa 0,25 s, mit leichtem Federn.
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


-----------------
---- EINGABE ----
-----------------

hl.config({
    input = {
        kb_layout          = "de",
        numlock_by_default = true,

        repeat_delay = 280, -- ms bis zur Tastenwiederholung
        repeat_rate  = 35,  -- Wiederholungen pro Sekunde

        follow_mouse  = 1,      -- Fokus folgt der Maus
        sensitivity   = 0,
        accel_profile = "flat", -- Maus 1:1 ohne Beschleunigung (gut für Spiele)
    },
})


---------------------------------
---- FENSTER- & EBENENREGELN ----
---------------------------------
-- Doku: https://wiki.hypr.land/Configuring/Basics/Window-Rules/

-- Programme dürfen sich nicht selbst maximieren – das Layout entscheidet
hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

-- Kein Bildschirmschoner/Sperren, solange etwas im Vollbild läuft (Video, Spiel)
hl.window_rule({
    name  = "idle-inhibit-fullscreen",
    match = { class = ".*" },
    idle_inhibit = "fullscreen",
})

-- Behebt Ziehen&Ablegen bei manchen X11-Programmen
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

-- Kleine Werkzeuge und Dialoge schweben mittig statt das Layout zu zerteilen
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

-- Passwortabfrage (Soteria, system/hyprland.nix): klein, mittig, im Vordergrund
hl.window_rule({
    name   = "float-polkit",
    match  = { class = "(?i).*soteria.*" },
    float  = true,
    center = true,
    pin    = true,
})

-- Systemmonitor (Klick auf CPU/RAM/GPU in der Leiste): groß und mittig
hl.window_rule({
    name   = "float-btop",
    match  = { class = "^(btop)$" },
    float  = true,
    center = true,
    size   = { "monitor_w*0.7", "monitor_h*0.75" },
})

-- Bild-im-Bild (Firefox): klein, unten rechts, auf allen Arbeitsflächen
hl.window_rule({
    name  = "picture-in-picture",
    match = { title = "^(Picture-in-Picture|Bild-im-Bild)$" },
    float = true,
    pin   = true,
    keep_aspect_ratio = true,
    size  = { "monitor_w*0.25", "monitor_h*0.25" },
    move  = { "monitor_w-window_w-24", "monitor_h-window_h-24" },
})

-- Arbeitsflächen 1–5 gibt es immer (auch leer) – so stehen sie fest in der Leiste
for i = 1, 5 do
    hl.workspace_rule({ workspace = tostring(i), persistent = true })
end

-- Spezial-Flächen (Super+S, Super+M …) mit mehr Rand, damit sie wie ein Overlay wirken
for _, name in ipairs({ "passwords", "sysmon", "music", "communication" }) do
    hl.workspace_rule({ workspace = "special:" .. name, gaps_out = 60 })
end

-- Milchglas hinter den fuzzel-Menüs (Zwischenablage, Emojis, Super+F1)
hl.layer_rule({ name = "blur-launcher", match = { namespace = "^launcher$" }, blur = true, ignore_alpha = 0.3 })
-- Auswahlrahmen beim Screenshot ohne Einblendanimation
hl.layer_rule({ name = "no-anim-selection", match = { namespace = "^(selection|hyprpicker)$" }, no_anim = true })
-- caelestia-Shell: Flächen blenden weich ein, Hilfsflächen sofort
-- (Milchglas hinter den Panels setzt die Shell selbst)
hl.layer_rule({ name = "caelestia-fade",    match = { namespace = "^caelestia-(drawers|background)$" }, animation = "fade" })
hl.layer_rule({ name = "caelestia-no-anim", match = { namespace = "^caelestia-(border-exclusion|area-picker)$" }, no_anim = true })


---------------------
---- TASTENKÜRZEL ----
---------------------

require("keybinds")


----------------
---- START  ----
----------------
-- Leiste, Benachrichtigungen, Hintergrundbild, Zwischenablage, Netzwerk-Icon
-- und Idle-Erkennung starten als systemd-Dienste mit der Sitzung (UWSM) –
-- hier muss nichts mehr gestartet werden.
