// Chip.qml – runder Knopf: Inhalt nebeneinander, beim Drüberfahren leicht
// aufgehellt, beim Klicken etwas stärker (wie bei Material Design).
//
//   Chip {
//       tooltip: "Erklärung"
//       onClicked: mouse => …        mouse.button: Qt.LeftButton / Qt.RightButton
//       onScrolled: wheel => …       wheel.angleDelta.y > 0: nach oben
//       Icon { icon: "bolt" }
//   }

import QtQuick

Item {
    id: root

    default property alias content: row.data
    property alias spacing: row.spacing
    property int padding: 10
    property color background: "transparent"
    property color tint: Theme.text // Farbe des Hover-Effekts
    property string tooltip: ""
    property bool interactive: true
    readonly property bool hovered: mouse.containsMouse

    signal clicked(var mouse)
    signal scrolled(var wheel)

    implicitWidth: row.implicitWidth + padding * 2
    implicitHeight: Style.chipHeight

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: root.background

        Behavior on color {
            ColorAnimation {
                duration: Style.medium
            }
        }
    }

    // Hover-/Klick-Schicht
    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: root.tint
        opacity: !root.interactive ? 0 : mouse.pressed ? 0.16 : mouse.containsMouse ? 0.09 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: Style.fast
            }
        }
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: Style.spacing
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        cursorShape: root.interactive ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: event => root.interactive && root.clicked(event)
        onWheel: event => root.scrolled(event)
    }

    Tooltip {
        target: root
        text: root.tooltip
        shown: root.hovered && !mouse.pressed
    }
}
