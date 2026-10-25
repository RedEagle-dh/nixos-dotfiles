// ActiveWindow.qml – Icon und Titel des gerade aktiven Fensters.

import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets
import QtQuick

Row {
    id: root

    property real maxWidth: 400

    readonly property HyprlandToplevel window: Hyprland.activeToplevel
    // Auf einer leeren Arbeitsfläche nichts anzeigen
    readonly property bool present: window !== null && window.workspace === Hyprland.focusedWorkspace && window.title !== ""
    readonly property string appClass: window?.lastIpcObject?.class ?? ""
    readonly property DesktopEntry app: appClass !== "" ? DesktopEntries.heuristicLookup(appClass) : null

    spacing: 8
    leftPadding: 4
    height: Style.chipHeight
    opacity: present ? 1 : 0

    Behavior on opacity {
        NumberAnimation {
            duration: Style.medium
        }
    }

    IconImage {
        anchors.verticalCenter: parent.verticalCenter
        implicitSize: 18
        source: root.present ? Quickshell.iconPath(root.app?.icon ?? root.appClass, "application-x-executable") : ""
    }

    Label {
        anchors.verticalCenter: parent.verticalCenter
        width: Math.min(implicitWidth, root.maxWidth - 30)
        elide: Text.ElideRight
        color: Theme.subtle
        // "Seite — Mozilla Firefox" → "Seite"
        text: root.present ? root.window.title.replace(/ [—-] Mozilla Firefox$/, "") : ""
    }
}
