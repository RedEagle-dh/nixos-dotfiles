// Style.qml – Größen, Abstände und Animationen der Leiste an einer Stelle.
// Farben und Schriften stehen in Theme.qml (erzeugt aus theme/default.nix).

pragma Singleton

import Quickshell
import QtQuick

Singleton {
    // Leiste
    readonly property int barHeight: 42
    readonly property int barGap: 8 // Abstand zum oberen Bildschirmrand
    readonly property int barSideGap: 14 // seitlich – wie gaps_out in hyprland.lua
    readonly property int barRadius: 16
    readonly property int barPadding: 6
    readonly property real barOpacity: 0.78

    // Knöpfe und Gruppen in der Leiste
    readonly property int chipHeight: 30
    readonly property int spacing: 6

    readonly property int fontSize: 13
    readonly property int iconSize: 20

    // Animationen (ms)
    readonly property int fast: 120
    readonly property int medium: 220
    readonly property int slow: 380

    // Farbe mit Deckkraft 0–1
    function alpha(color, opacity) {
        return Qt.rgba(color.r, color.g, color.b, opacity);
    }
}
