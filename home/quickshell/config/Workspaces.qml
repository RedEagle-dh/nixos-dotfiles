// Workspaces.qml – die Arbeitsflächen als Punkte in einer Leiste.
// Die aktive ist eine breite Pille in der Akzentfarbe, belegte Flächen
// haben eine helle Zahl, leere eine gedämpfte. Klick wechselt dorthin.

import Quickshell
import Quickshell.Hyprland
import QtQuick

Rectangle {
    id: root

    implicitWidth: row.implicitWidth + 6
    implicitHeight: Style.chipHeight
    radius: height / 2
    color: Style.alpha(Theme.overlay, 0.7)

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 2

        Repeater {
            // Ohne Notizblock-Fläche (die hat eine negative Nummer), nach Nummer sortiert
            model: ScriptModel {
                values: Hyprland.workspaces.values.filter(w => w.id > 0).sort((a, b) => a.id - b.id)
            }

            Item {
                id: ws

                required property HyprlandWorkspace modelData
                readonly property bool focused: modelData.focused
                readonly property bool occupied: modelData.toplevels.values.length > 0

                width: focused ? 40 : 24
                height: 24

                Behavior on width {
                    NumberAnimation {
                        duration: Style.slow
                        easing.type: Easing.OutBack
                        easing.overshoot: 1.4
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    radius: height / 2
                    color: ws.modelData.urgent ? Theme.love : ws.focused ? Theme.iris : mouse.containsMouse ? Style.alpha(Theme.text, 0.1) : "transparent"

                    Behavior on color {
                        ColorAnimation {
                            duration: Style.medium
                        }
                    }
                }

                Label {
                    anchors.centerIn: parent
                    text: ws.modelData.name
                    font.pixelSize: 12
                    font.weight: ws.focused ? Font.Bold : Font.DemiBold
                    color: ws.focused || ws.modelData.urgent ? Theme.base : ws.occupied ? Theme.text : Theme.muted
                }

                // Kleiner Punkt unter belegten Flächen
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 2
                    width: 3
                    height: 3
                    radius: 1.5
                    color: Theme.subtle
                    opacity: ws.occupied && !ws.focused ? 1 : 0

                    Behavior on opacity {
                        NumberAnimation {
                            duration: Style.medium
                        }
                    }
                }

                MouseArea {
                    id: mouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: ws.modelData.activate()
                }
            }
        }
    }

    // Mausrad über den Flächen: vor und zurück
    WheelHandler {
        onWheel: event => {
            const list = Hyprland.workspaces.values.filter(w => w.id > 0).sort((a, b) => a.id - b.id);
            const i = list.findIndex(w => w.focused);
            const next = list[i + (event.angleDelta.y < 0 ? 1 : -1)];
            if (next)
                next.activate();
        }
    }
}
