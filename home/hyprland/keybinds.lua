-- keybinds.lua – alle Tastenkürzel. SUPER = Windows-Taste.
--
-- Belegung wie bei caelestia (github.com/caelestia-dots/caelestia), mit Kitty
-- als Terminal und den Werkzeugen dieses Systems (fuzzel, mako, grimblast).
-- Auf die deutsche Tastatur übertragen: US-Minus/Gleich/Backslash liegen hier
-- auf ß, ´ und # (gleiche Stelle auf der Tastatur).
--
-- Super+F1 zeigt jederzeit eine durchsuchbare Liste aller Kürzel. Sie wird aus
-- den Beschreibungen hier erzeugt – beim Ändern eines Kürzels also die
-- Beschreibung mitpflegen.

local mod = "SUPER"

local terminal      = "kitty"
local browser       = "firefox"
local editor        = "code"
local files         = "nautilus --new-window"
local audioSettings = "pavucontrol"
local launcher      = "pkill -x fuzzel || fuzzel" -- zweiter Druck schließt den Starter wieder

-- Super allein (antippen) öffnet den Starter. Hyprland löst das beim Loslassen
-- von Super aus – auch nach Super+1 o. Ä. Deshalb merkt sich jedes Kürzel hier,
-- dass Super gerade "benutzt" wurde, und der Starter bleibt dann zu.
local superUsed = false

-- hl.bind mit Beschreibung für die Kürzel-Übersicht (Super+F1).
-- Mehrere Tasten für dieselbe Aktion: keys als Liste; nur die erste erscheint
-- in der Übersicht.
local function bind(keys, action, description, opts)
    if type(keys) == "table" then
        for i, key in ipairs(keys) do
            bind(key, action, i == 1 and description or nil, opts)
        end
        return
    end

    local o = { description = description }
    for k, v in pairs(opts or {}) do o[k] = v end

    if o.mouse then
        -- Maus-Aktionen (Ziehen) lassen sich nicht einpacken – ein zweites,
        -- durchlässiges Kürzel auf derselben Taste merkt sich die Benutzung
        hl.bind(keys, function() superUsed = true end, { non_consuming = true })
        return hl.bind(keys, action, o)
    end

    return hl.bind(keys, function()
        superUsed = true
        if type(action) == "function" then
            action()
        else
            hl.dispatch(action)
        end
    end, o)
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

-- Flags
local locked  = { locked = true } -- funktioniert auch auf dem Sperrbildschirm
local held    = { repeating = true } -- gedrückt halten wiederholt
local lockedHeld = { locked = true, repeating = true }
local mouse   = { mouse = true }
local release = { release = true }


-------------------
---- STARTER ----
-------------------

hl.bind(mod .. " + SUPER_L", function()
    if not superUsed then
        hl.dispatch(exec(launcher))
    end
    superUsed = false
end, { description = "Programm starten (Super antippen)", release = true })

bind(mod .. " + space", exec(launcher), nil)


--------------------
---- PROGRAMME ----
--------------------

bind({ mod .. " + T", mod .. " + Return" }, exec(terminal), "Terminal")
bind(mod .. " + W",            exec(browser),          "Browser")
bind(mod .. " + C",            exec(editor),           "Editor (VS Code)")
bind(mod .. " + E",            exec(files),            "Dateimanager")
bind("CTRL + ALT + V",         exec(audioSettings),    "Lautstärke-Einstellungen")
bind(mod .. " + V",            exec("clipboard-menu"), "Zwischenablage-Verlauf")
bind(mod .. " + ALT + V",      exec("clipboard-menu delete"), "Eintrag aus dem Zwischenablage-Verlauf löschen")
bind(mod .. " + period",       exec("emoji-menu"),     "Emoji einfügen")
bind(mod .. " + SHIFT + C",    exec("hyprpicker --autocopy --format=hex"), "Farbe vom Bildschirm kopieren")


-----------------
---- FENSTER ----
-----------------

local directions = { left = "links", right = "rechts", up = "oben", down = "unten" }
for key, name in pairs(directions) do
    bind(mod .. " + " .. key,         hl.dsp.focus({ direction = key }),       "Fokus nach " .. name)
    bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ direction = key }), "Fenster nach " .. name .. " schieben")
end

bind(mod .. " + Q",           hl.dsp.window.close(),                            "Fenster schließen")
bind(mod .. " + F",           hl.dsp.window.fullscreen({ mode = "fullscreen" }), "Vollbild")
bind(mod .. " + ALT + F",     hl.dsp.window.fullscreen({ mode = "maximized" }),  "Maximieren (Leiste bleibt)")
bind(mod .. " + ALT + space", hl.dsp.window.float(),                            "Schwebend ↔ gekachelt")
bind(mod .. " + P",           hl.dsp.window.pin(),                              "Schwebendes Fenster auf allen Flächen anheften")
bind(mod .. " + J",           hl.dsp.layout("togglesplit"),                     "Teilung drehen (neben- ↔ untereinander)")
bind("CTRL + " .. mod .. " + numbersign", hl.dsp.window.center(),                "Fenster mittig setzen")

-- Bildschirmgröße in Prozent → absolute Größe
local function screenSize(xPercent, yPercent)
    local screen = hl.get_active_monitor()
    if screen and screen.width and screen.height then
        return {
            x = math.floor(screen.width * xPercent / 100),
            y = math.floor(screen.height * yPercent / 100),
            relative = false,
        }
    end
end

bind("CTRL + " .. mod .. " + ALT + numbersign", function()
    local size = screenSize(55, 70)
    if size then hl.dispatch(hl.dsp.window.resize(size)) end
    hl.dispatch(hl.dsp.window.center())
end, "Fenster auf Standardgröße (55 × 70 %) und mittig")

-- Bild-im-Bild: Fenster schwebend, klein unten rechts, auf allen Flächen
bind(mod .. " + ALT + numbersign", function()
    local win = hl.get_active_window()
    local screen = hl.get_active_monitor()
    if not (win and win.size and screen and screen.width) then return end

    local width  = screen.width / screen.scale
    local height = screen.height / screen.scale
    local factor = (height / 4) / win.size.y
    local w      = math.floor(math.max(200, win.size.x * factor))
    local h      = math.floor(math.max(150, win.size.y * factor))
    local offset = math.min(width, height) * 0.03

    if not win.floating then hl.dispatch(hl.dsp.window.float()) end
    hl.dispatch(hl.dsp.window.resize({ x = w, y = h, window = win }))
    hl.dispatch(hl.dsp.window.move({
        x = math.floor(screen.x + width - w - offset),
        y = math.floor(screen.y + height - h - offset),
        relative = false,
        window = win,
    }))
    hl.dispatch(hl.dsp.window.set_prop({ prop = "keep_aspect_ratio", value = "true", window = win }))
    hl.dispatch(hl.dsp.window.pin({ action = "on", window = "address:" .. win.address }))
end, "Bild-im-Bild (klein unten rechts, angeheftet)")

-- Größe in 10-%-Schritten der aktuellen Fenstergröße
local function resizeBy(xPercent, yPercent)
    return function()
        local win = hl.get_active_window()
        if win and win.size then
            hl.dispatch(hl.dsp.window.resize({
                x = win.size.x * xPercent / 100,
                y = win.size.y * yPercent / 100,
                relative = true,
            }))
        end
    end
end

bind({ mod .. " + dead_acute", mod .. " + ALT + right" },        resizeBy(10, 0),  "Fenster breiter",   held)
bind({ mod .. " + ssharp", mod .. " + ALT + left" },             resizeBy(-10, 0), "Fenster schmaler",  held)
bind({ mod .. " + SHIFT + dead_acute", mod .. " + ALT + down" }, resizeBy(0, 10),  "Fenster höher",     held)
bind({ mod .. " + SHIFT + ssharp", mod .. " + ALT + up" },       resizeBy(0, -10), "Fenster niedriger", held)

-- Mit der Maus: Super + linke Taste (oder Z) verschiebt, Super + rechte Taste (oder X) ändert die Größe
bind({ mod .. " + mouse:272", mod .. " + Z" }, hl.dsp.window.drag(),   "Fenster mit der Maus verschieben", mouse)
bind({ mod .. " + mouse:273", mod .. " + X" }, hl.dsp.window.resize(), "Fenstergröße mit der Maus ändern", mouse)

-- Alt+Tab wie gewohnt
bind("ALT + Tab",         chain(hl.dsp.window.cycle_next(), hl.dsp.window.bring_to_top()),
                          "Nächstes Fenster", held)
bind("SHIFT + ALT + Tab", chain(hl.dsp.window.cycle_next({ next = false }), hl.dsp.window.bring_to_top()),
                          "Vorheriges Fenster", held)

-- Gruppen: mehrere Fenster als Tabs in einem Rahmen
bind(mod .. " + comma",           hl.dsp.group.toggle(),                    "Fenster als Tabs gruppieren")
bind(mod .. " + U",               hl.dsp.window.move({ out_of_group = true }), "Fenster aus der Gruppe lösen")
bind(mod .. " + SHIFT + comma",   hl.dsp.group.lock_active(),               "Gruppe sperren")
bind("CTRL + ALT + Tab",          hl.dsp.group.next(),                      "Nächster Tab in der Gruppe",  held)
bind("CTRL + SHIFT + ALT + Tab",  hl.dsp.group.prev(),                      "Vorheriger Tab in der Gruppe", held)


-----------------------
---- ARBEITSFLÄCHEN ----
-----------------------
-- Flächen sind in Zehnergruppen eingeteilt (1–10, 11–20 …). Super+Zahl
-- bleibt in der aktuellen Gruppe, Strg+Super+Zahl wechselt die Gruppe.

local function workspaceAction(kind, inGroup, i)
    return function()
        local active = hl.get_active_workspace()
        if not active then return end

        local id     = active.id
        local target = inGroup and ((i - 1) * 10 + (id % 10))
                                or (math.floor((id - 1) / 10) * 10 + i)

        if kind == "move" then
            hl.dispatch(hl.dsp.window.move({ workspace = target }))
        elseif kind == "send" then
            hl.dispatch(hl.dsp.window.move({ workspace = target, follow = false }))
        else
            hl.dispatch(hl.dsp.focus({ workspace = target }))
        end
    end
end

for i = 1, 10 do
    local key = tostring(i % 10) -- Fläche 10 liegt auf der Taste 0
    -- In der Übersicht nur einmal beschreiben statt zehnmal
    local first = i == 1
    bind(mod .. " + " .. key,                  workspaceAction("focus", false, i),
         first and "Zu Arbeitsfläche 1…10 wechseln (Tasten 1…0)" or nil)
    bind(mod .. " + ALT + " .. key,            workspaceAction("move", false, i),
         first and "Fenster auf Arbeitsfläche 1…10 mitnehmen" or nil)
    bind(mod .. " + SHIFT + " .. key,          workspaceAction("send", false, i),
         first and "Fenster auf Arbeitsfläche 1…10 schicken (hierbleiben)" or nil)
    bind("CTRL + " .. mod .. " + " .. key,     workspaceAction("focus", true, i),
         first and "Zu Flächengruppe 1…10 wechseln" or nil)
    bind("CTRL + " .. mod .. " + ALT + " .. key, workspaceAction("move", true, i),
         first and "Fenster in Flächengruppe 1…10 mitnehmen" or nil)
end

bind({ mod .. " + mouse_down", "CTRL + " .. mod .. " + right", mod .. " + Page_Down" },
     hl.dsp.focus({ workspace = "+1" }), "Nächste Arbeitsfläche")
bind({ mod .. " + mouse_up", "CTRL + " .. mod .. " + left", mod .. " + Page_Up" },
     hl.dsp.focus({ workspace = "-1" }), "Vorherige Arbeitsfläche")
bind("CTRL + " .. mod .. " + mouse_down", hl.dsp.focus({ workspace = "+10" }), "Nächste Flächengruppe (Mausrad)")
bind("CTRL + " .. mod .. " + mouse_up",   hl.dsp.focus({ workspace = "-10" }), "Vorherige Flächengruppe (Mausrad)")
bind(mod .. " + Tab", hl.dsp.focus({ workspace = "previous" }), "Zurück zur letzten Arbeitsfläche")

bind({ mod .. " + ALT + mouse_down", mod .. " + ALT + Page_Down", "CTRL + " .. mod .. " + SHIFT + right" },
     hl.dsp.window.move({ workspace = "+1" }), "Fenster auf die nächste Fläche mitnehmen")
bind({ mod .. " + ALT + mouse_up", mod .. " + ALT + Page_Up", "CTRL + " .. mod .. " + SHIFT + left" },
     hl.dsp.window.move({ workspace = "-1" }), "Fenster auf die vorherige Fläche mitnehmen")


---------------------------
---- SPEZIAL-FLÄCHEN ----
---------------------------
-- Schweben über allem und lassen sich ein- und ausblenden. Die festen
-- Flächen holen ihre Programme dorthin (bzw. starten sie, wo angegeben).

local specialApps = {
    sysmon        = { { class = "btop", command = "kitty --class btop btop" } },
    music         = { { class = "Spotify" }, { class = "feishin" } },
    communication = { { class = "discord" }, { class = "vesktop" }, { class = "whatsapp" } },
    todo          = {},
}

local function toggleSpecial(name)
    return function()
        local active  = hl.get_active_special_workspace()
        local target  = "special:" .. name
        local isOpen  = active and active.name == target

        if isOpen then
            return hl.dispatch(hl.dsp.workspace.toggle_special(name))
        end
        hl.dispatch(hl.dsp.focus({ workspace = target }))

        local windows = hl.get_windows() or {}
        for _, app in ipairs(specialApps[name] or {}) do
            local running = false
            for _, win in ipairs(windows) do
                if win.class == app.class then
                    running = true
                    if not (win.workspace and win.workspace.name == target) then
                        hl.dispatch(hl.dsp.window.move({ window = win, workspace = target, follow = false }))
                    end
                end
            end
            if not running and app.command then
                hl.dispatch(hl.dsp.exec_cmd(app.command, { workspace = target }))
            end
        end
    end
end

-- Super+S: offene Spezial-Fläche schließen, sonst die allgemeine öffnen
bind(mod .. " + S", function()
    local active = hl.get_active_special_workspace()
    local name   = active and active.name:gsub("^special:", "") or "special"
    hl.dispatch(hl.dsp.workspace.toggle_special(name))
end, "Spezial-Fläche ein/aus")

bind("CTRL + SHIFT + Escape", toggleSpecial("sysmon"),        "Systemmonitor (btop) ein/aus")
bind(mod .. " + M",           toggleSpecial("music"),         "Musik-Fläche ein/aus")
bind(mod .. " + D",           toggleSpecial("communication"), "Chat-Fläche ein/aus")
bind(mod .. " + R",           toggleSpecial("todo"),          "Aufgaben-Fläche ein/aus")

bind({ mod .. " + ALT + S", "CTRL + " .. mod .. " + SHIFT + up" },
     hl.dsp.window.move({ workspace = "special:special" }), "Fenster auf die Spezial-Fläche")
bind("CTRL + " .. mod .. " + SHIFT + down",
     hl.dsp.window.move({ workspace = "e+0" }), "Fenster von der Spezial-Fläche zurückholen")


----------------------------------
---- SCREENSHOTS & AUFNAHMEN ----
----------------------------------
-- Screenshots landen in der Zwischenablage und unter ~/Pictures/Screenshots,
-- Aufnahmen unter ~/Videos/Recordings. Gleiches Kürzel beendet die Aufnahme.

bind("Print",                         exec("screenshot screen"), "Screenshot: ganzer Bildschirm", locked)
bind(mod .. " + SHIFT + S",           exec("screenshot area"),   "Screenshot: Bereich oder Fenster anklicken")
bind(mod .. " + SHIFT + ALT + S",     exec("screenshot edit"),   "Screenshot: Bereich beschriften (Pfeile, Text …)")
bind("ALT + Print",                   exec("screenshot active"), "Screenshot: aktives Fenster")
bind("CTRL + ALT + R",                exec("record"),            "Bildschirm aufnehmen (an/aus)")
bind(mod .. " + ALT + R",             exec("record sound"),      "Bildschirm mit Ton aufnehmen (an/aus)")
bind(mod .. " + SHIFT + ALT + R",     exec("record region"),     "Bereich aufnehmen (an/aus)")


----------------
---- SYSTEM ----
----------------

bind("CTRL + ALT + Delete",    exec("power-menu"),             "Sperren, Abmelden, Neustart, Ausschalten")
bind(mod .. " + L",            exec("loginctl lock-session"),  "Bildschirm sperren", locked)
bind(mod .. " + SHIFT + L",    exec("systemctl suspend"),      "Bereitschaft (Standby)", locked)
bind(mod .. " + F1",           exec("keybind-help"),           "Diese Übersicht")
bind(mod .. " + SHIFT + B",    exec("qs ipc call bar toggle"), "Leiste ein-/ausblenden")
bind("CTRL + " .. mod .. " + SHIFT + R", exec("systemctl --user stop quickshell"),    "Leiste beenden", release)
bind("CTRL + " .. mod .. " + ALT + R",   exec("systemctl --user restart quickshell"), "Leiste neu starten", release)

bind(mod .. " + N",            exec("makoctl restore"),          "Letzte Benachrichtigung zurückholen")
bind(mod .. " + SHIFT + N",    exec("makoctl dismiss"),          "Benachrichtigung schließen")
bind("CTRL + ALT + C",         exec("makoctl dismiss --all"),    "Alle Benachrichtigungen schließen", locked)
bind("CTRL + " .. mod .. " + N", exec("notifications toggle-dnd"), "Nicht stören an/aus")


---------------
---- MEDIEN ----
---------------

bind("XF86AudioRaiseVolume",   exec("volume-osd up"),       "Lauter",          lockedHeld)
bind("XF86AudioLowerVolume",   exec("volume-osd down"),     "Leiser",          lockedHeld)
bind({ "XF86AudioMute", mod .. " + SHIFT + M" },
                               exec("volume-osd mute"),     "Ton aus/an",      locked)
bind("XF86AudioMicMute",       exec("volume-osd mic-mute"), "Mikrofon aus/an", locked)

bind({ "CTRL + " .. mod .. " + space", "XF86AudioPlay", "XF86AudioPause" },
                               exec("playerctl play-pause"), "Wiedergabe/Pause",  locked)
bind({ "CTRL + " .. mod .. " + dead_acute", "XF86AudioNext" },
                               exec("playerctl next"),       "Nächster Titel",   locked)
bind({ "CTRL + " .. mod .. " + ssharp", "XF86AudioPrev" },
                               exec("playerctl previous"),   "Vorheriger Titel", locked)
bind({ "CTRL + " .. mod .. " + BackSpace", "XF86AudioStop" },
                               exec("playerctl stop"),       "Wiedergabe stoppen", locked)
