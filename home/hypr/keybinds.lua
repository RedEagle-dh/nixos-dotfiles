-- keybinds.lua – alle Tastenkürzel. SUPER = Windows-Taste.
--
-- Super+F1 zeigt jederzeit eine durchsuchbare Liste aller Kürzel. Sie wird aus
-- den Beschreibungen hier erzeugt – beim Ändern eines Kürzels also die
-- Beschreibung mitpflegen.
--
-- Wo es passt, verhalten sich die Kürzel wie unter Windows:
-- Super+L sperrt, Super+E öffnet Dateien, Super+V die Zwischenablage,
-- Super+Umschalt+S macht einen Screenshot, Super+. öffnet Emojis.

local mod = "SUPER"

local terminal = "kitty"
local browser  = "firefox"
local files    = "nautilus --new-window"
local launcher = "pkill -x fuzzel || fuzzel" -- zweiter Druck schließt den Starter wieder

-- hl.bind mit Beschreibung für die Kürzel-Übersicht (Super+F1)
local function bind(keys, action, description, opts)
    local o = { description = description }
    for k, v in pairs(opts or {}) do o[k] = v end
    return hl.bind(keys, action, o)
end

local function exec(cmd)
    return hl.dsp.exec_cmd(cmd)
end

-- Mehrere Aktionen nacheinander auf einer Taste
local function chain(...)
    local actions = { ... }
    return function()
        for _, action in ipairs(actions) do
            hl.dispatch(action)
        end
    end
end


--------------------
---- PROGRAMME ----
--------------------

bind(mod .. " + Return",        exec(terminal),           "Terminal")
bind(mod .. " + space",         exec(launcher),           "Programm starten")
bind(mod .. " + E",             exec(files),              "Dateimanager")
bind(mod .. " + B",             exec(browser),            "Browser")
bind(mod .. " + V",             exec("clipboard-menu"),   "Zwischenablage-Verlauf")
bind(mod .. " + period",        exec("emoji-menu"),       "Emoji einfügen")
bind(mod .. " + SHIFT + C",     exec("hyprpicker --autocopy --format=hex"), "Farbe vom Bildschirm kopieren")


-----------------
---- FENSTER ----
-----------------

bind(mod .. " + Q",     hl.dsp.window.close(),                         "Fenster schließen")
bind(mod .. " + F",     hl.dsp.window.fullscreen(),                    "Vollbild")
bind(mod .. " + M",     hl.dsp.window.fullscreen({ mode = "maximized" }), "Maximieren (Leiste bleibt)")
bind(mod .. " + T",     chain(hl.dsp.window.float({ action = "toggle" }), hl.dsp.window.center()),
                                                                       "Schwebend ↔ gekachelt")
bind(mod .. " + P",     hl.dsp.window.pin(),                           "Schwebendes Fenster auf allen Flächen anheften")
bind(mod .. " + J",     hl.dsp.layout("togglesplit"),                  "Teilung drehen (neben- ↔ untereinander)")
bind(mod .. " + G",     hl.dsp.group.toggle(),                         "Fenster als Tabs gruppieren")
bind(mod .. " + ALT + right", hl.dsp.group.next(),                     "Nächster Tab in der Gruppe")
bind(mod .. " + ALT + left",  hl.dsp.group.prev(),                     "Vorheriger Tab in der Gruppe")

local directions = { left = "links", right = "rechts", up = "oben", down = "unten" }
for key, name in pairs(directions) do
    bind(mod .. " + " .. key,           hl.dsp.focus({ direction = key }),       "Fokus nach " .. name)
    bind(mod .. " + SHIFT + " .. key,   hl.dsp.window.move({ direction = key }), "Fenster nach " .. name .. " schieben")
end

-- Größe ändern; Taste gedrückt halten wiederholt
local step = 40
bind(mod .. " + CTRL + right", hl.dsp.window.resize({ x =  step, y = 0, relative = true }), "Fenster breiter",  { repeating = true })
bind(mod .. " + CTRL + left",  hl.dsp.window.resize({ x = -step, y = 0, relative = true }), "Fenster schmaler", { repeating = true })
bind(mod .. " + CTRL + down",  hl.dsp.window.resize({ x = 0, y =  step, relative = true }), "Fenster höher",    { repeating = true })
bind(mod .. " + CTRL + up",    hl.dsp.window.resize({ x = 0, y = -step, relative = true }), "Fenster niedriger", { repeating = true })

-- Mit der Maus: Super + linke Taste verschiebt, Super + rechte Taste ändert die Größe
bind(mod .. " + mouse:272", hl.dsp.window.drag(),   "Fenster mit der Maus verschieben")
bind(mod .. " + mouse:273", hl.dsp.window.resize(), "Fenstergröße mit der Maus ändern")

-- Alt+Tab wie gewohnt
bind("ALT + Tab",         chain(hl.dsp.window.cycle_next(), hl.dsp.window.bring_to_top()),
                          "Nächstes Fenster")
bind("ALT + SHIFT + Tab", chain(hl.dsp.window.cycle_next({ next = false }), hl.dsp.window.bring_to_top()),
                          "Vorheriges Fenster")


-----------------------
---- ARBEITSFLÄCHEN ----
-----------------------

for i = 1, 10 do
    local key = tostring(i % 10) -- Fläche 10 liegt auf der Taste 0
    -- In der Übersicht nur einmal beschreiben statt zehnmal
    local first = i == 1
    bind(mod .. " + " .. key,
         hl.dsp.focus({ workspace = i }),
         first and "Zu Arbeitsfläche 1…10 wechseln (Tasten 1…0)" or nil)
    bind(mod .. " + SHIFT + " .. key,
         hl.dsp.window.move({ workspace = i }),
         first and "Fenster auf Arbeitsfläche 1…10 mitnehmen" or nil)
    bind(mod .. " + ALT + " .. key,
         hl.dsp.window.move({ workspace = i, follow = false }),
         first and "Fenster auf Arbeitsfläche 1…10 schicken (hierbleiben)" or nil)
end

bind(mod .. " + Tab",        hl.dsp.focus({ workspace = "previous" }), "Zurück zur letzten Arbeitsfläche")
bind(mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }),      "Nächste belegte Arbeitsfläche (Mausrad)")
bind(mod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }),      "Vorherige belegte Arbeitsfläche (Mausrad)")

-- Notizblock-Fläche: schwebt über allem, z. B. für Terminal, Notizen, Musik
bind(mod .. " + S",       hl.dsp.workspace.toggle_special("scratchpad"),            "Notizblock-Fläche ein/aus")
bind(mod .. " + ALT + S", hl.dsp.window.move({ workspace = "special:scratchpad" }), "Fenster auf die Notizblock-Fläche")


----------------------
---- SCREENSHOTS ----
----------------------
-- Landen in der Zwischenablage und unter ~/Pictures/Screenshots

bind("Print",               exec("screenshot area"),   "Screenshot: Bereich oder Fenster anklicken")
bind(mod .. " + SHIFT + S", exec("screenshot area"),   "Screenshot: Bereich oder Fenster anklicken")
bind("SHIFT + Print",       exec("screenshot screen"), "Screenshot: ganzer Bildschirm")
bind("ALT + Print",         exec("screenshot active"), "Screenshot: aktives Fenster")
bind(mod .. " + Print",     exec("screenshot edit"),   "Screenshot: Bereich beschriften (Pfeile, Text …)")


----------------
---- SYSTEM ----
----------------

bind(mod .. " + L",          exec("loginctl lock-session"), "Bildschirm sperren")
bind(mod .. " + Escape",     exec("power-menu"),            "Sperren, Abmelden, Neustart, Ausschalten")
bind(mod .. " + F1",         exec("keybind-help"),          "Diese Übersicht")
bind(mod .. " + SHIFT + B",  exec("pkill -SIGUSR1 waybar"), "Leiste ein-/ausblenden")

bind(mod .. " + N",          exec("makoctl dismiss"),           "Benachrichtigung schließen")
bind(mod .. " + SHIFT + N",  exec("makoctl restore"),           "Letzte Benachrichtigung zurückholen")
bind(mod .. " + CTRL + N",   exec("notifications toggle-dnd"),  "Nicht stören an/aus")


---------------
---- MEDIEN ----
---------------
-- "locked": funktioniert auch auf dem Sperrbildschirm

local media = { locked = true }
local held  = { locked = true, repeating = true }

bind("XF86AudioRaiseVolume", exec("volume-osd up"),          "Lauter",          held)
bind("XF86AudioLowerVolume", exec("volume-osd down"),        "Leiser",          held)
bind("XF86AudioMute",        exec("volume-osd mute"),        "Ton aus/an",      media)
bind("XF86AudioMicMute",     exec("volume-osd mic-mute"),    "Mikrofon aus/an", media)
bind("XF86AudioPlay",        exec("playerctl play-pause"),   "Wiedergabe/Pause", media)
bind("XF86AudioPause",       exec("playerctl play-pause"),   nil,               media)
bind("XF86AudioNext",        exec("playerctl next"),         "Nächster Titel",  media)
bind("XF86AudioPrev",        exec("playerctl previous"),     "Vorheriger Titel", media)
