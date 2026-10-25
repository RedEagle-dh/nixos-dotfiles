// Volume.qml – Lautstärke des Standard-Ausgangs.
// Mausrad: lauter/leiser · Klick: Mixer · Rechtsklick: stumm.

import Quickshell
import Quickshell.Services.Pipewire
import QtQuick

Chip {
    id: root

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property bool muted: sink?.audio?.muted ?? false
    readonly property real volume: sink?.audio?.volume ?? 0
    readonly property bool headphones: (sink?.properties["device.form-factor"] ?? "") === "headphone" || (sink?.description ?? "").toLowerCase().includes("headphone")

    tooltip: (sink?.description ?? "Kein Ausgabegerät") + "\n\nMausrad: Lautstärke · Rechtsklick: stumm"
    onClicked: mouse => Quickshell.execDetached(mouse.button === Qt.RightButton ? ["volume-osd", "mute"] : ["pavucontrol"])
    onScrolled: wheel => Quickshell.execDetached(["volume-osd", wheel.angleDelta.y > 0 ? "up" : "down"])

    // Hält die Werte des Geräts aktuell
    PwObjectTracker {
        objects: [root.sink]
    }

    Icon {
        icon: root.muted ? "volume_off" : root.headphones ? "headphones" : root.volume < 0.01 ? "volume_mute" : root.volume < 0.5 ? "volume_down" : "volume_up"
        fill: root.muted ? 0 : 1
        color: root.muted ? Theme.muted : Theme.gold
    }
    Label {
        text: root.muted ? "stumm" : Math.round(root.volume * 100) + "%"
        color: root.muted ? Theme.muted : Theme.text
        font.features: ({ "tnum": 1 })
    }
}
