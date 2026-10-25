// Group.qml – dezente Fläche, die zusammengehörige Bausteine bündelt
// (Arbeitsflächen, Systemwerte, Tray & Ton).

import QtQuick

Rectangle {
    default property alias content: row.data
    property alias spacing: row.spacing

    implicitWidth: row.implicitWidth + 6
    implicitHeight: Style.chipHeight
    radius: height / 2
    color: Style.alpha(Theme.overlay, 0.7)
    visible: row.implicitWidth > 0

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 0
    }
}
