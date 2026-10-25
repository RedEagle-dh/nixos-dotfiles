// Icon.qml – Symbol aus der Schrift "Material Symbols Rounded".
// Name wie auf https://fonts.google.com/icons, z. B. icon: "volume_up".
// fill: 0 = Umriss, 1 = gefüllt (lässt sich animieren).

import QtQuick

Text {
    property string icon
    property real size: Style.iconSize
    property real fill: 0

    text: icon
    color: Theme.text
    font.family: Theme.fontIcons
    font.pixelSize: size
    font.variableAxes: ({
            "FILL": fill,
            "wght": 450,
            "opsz": size
        })
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter

    Behavior on fill {
        NumberAnimation {
            duration: Style.medium
        }
    }
    Behavior on color {
        ColorAnimation {
            duration: Style.medium
        }
    }
}
