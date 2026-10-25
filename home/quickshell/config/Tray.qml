// Tray.qml – Tray-Icons (z. B. Netzwerk, 1Password, Steam).
// Klick: Hauptaktion bzw. Menü, Rechtsklick: Menü.

import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import QtQuick

Row {
    id: root

    spacing: 0
    visible: SystemTray.items.values.length > 0

    Repeater {
        model: SystemTray.items

        Chip {
            id: item

            required property SystemTrayItem modelData

            padding: 0
            implicitWidth: Style.chipHeight
            tooltip: modelData.tooltipTitle || modelData.title
            onClicked: mouse => {
                if (mouse.button === Qt.LeftButton && !modelData.onlyMenu)
                    modelData.activate();
                else if (mouse.button === Qt.MiddleButton)
                    modelData.secondaryActivate();
                else if (modelData.hasMenu)
                    menu.open();
            }
            onScrolled: wheel => modelData.scroll(wheel.angleDelta.y, false)

            IconImage {
                implicitSize: 17
                source: item.modelData.icon
            }

            QsMenuAnchor {
                id: menu
                menu: item.modelData.menu
                anchor.item: item
                anchor.rect.y: item.height + (Style.barHeight - Style.chipHeight) / 2 + 6
                anchor.rect.x: 0
                anchor.rect.width: item.width
                anchor.rect.height: 1
                anchor.edges: Edges.Top
                anchor.gravity: Edges.Bottom
            }
        }
    }
}
