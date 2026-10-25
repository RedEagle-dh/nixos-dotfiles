// Power.qml – Power-Knopf ganz rechts: Sperren, Abmelden, Neustart …

import Quickshell
import QtQuick

Chip {
    padding: 0
    implicitWidth: Style.chipHeight
    background: Style.alpha(Theme.love, 0.14)
    tint: Theme.love
    tooltip: "Sperren, Abmelden, Neustart, Ausschalten"
    onClicked: Quickshell.execDetached(["power-menu"])

    Icon {
        icon: "power_settings_new"
        size: 17
        color: Theme.love
    }
}
