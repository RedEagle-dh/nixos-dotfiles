// NotificationBell.qml – Glocke: Klick schaltet "Nicht stören",
// Rechtsklick holt die letzte Benachrichtigung zurück.

import Quickshell
import QtQuick

Chip {
    padding: 0
    implicitWidth: Style.chipHeight
    background: Notifications.doNotDisturb ? Style.alpha(Theme.love, 0.16) : "transparent"
    tint: Notifications.doNotDisturb ? Theme.love : Theme.text
    tooltip: Notifications.doNotDisturb ? "Nicht stören ist an\nKlick: ausschalten" : "Benachrichtigungen\nKlick: nicht stören · Rechtsklick: letzte zurückholen"
    onClicked: mouse => Quickshell.execDetached(mouse.button === Qt.RightButton ? ["makoctl", "restore"] : ["notifications", "toggle-dnd"])

    Icon {
        icon: Notifications.doNotDisturb ? "notifications_off" : "notifications"
        fill: Notifications.doNotDisturb ? 1 : 0
        color: Notifications.doNotDisturb ? Theme.love : Theme.subtle
    }
}
