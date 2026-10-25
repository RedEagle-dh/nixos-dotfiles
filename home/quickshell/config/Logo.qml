// Logo.qml – NixOS-Logo ganz links, öffnet den Programmstarter.

import Quickshell
import QtQuick

Chip {
    padding: 0
    implicitWidth: Style.chipHeight + 4
    background: Style.alpha(Theme.iris, 0.14)
    tint: Theme.iris
    tooltip: "Programme"
    onClicked: Quickshell.execDetached(["sh", "-c", "pkill -x fuzzel || fuzzel"])

    Label {
        text: "\uf313" // NixOS-Schneeflocke aus der Nerd-Font-Schrift
        font.family: Theme.fontMono
        font.pixelSize: 17
        color: Theme.iris
        leftPadding: 1
    }
}
