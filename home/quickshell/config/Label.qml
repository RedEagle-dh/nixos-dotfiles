// Label.qml – Text in der Schrift und Größe der Leiste.

import QtQuick

Text {
    color: Theme.text
    font.family: Theme.fontUi
    font.pixelSize: Style.fontSize
    font.weight: Font.Medium
    verticalAlignment: Text.AlignVCenter

    Behavior on color {
        ColorAnimation {
            duration: Style.medium
        }
    }
}
