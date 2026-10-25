// Tooltip.qml – kleines Hinweisfenster unter einem Baustein der Leiste.
// Erscheint nach kurzem Verweilen; mehrzeilig mit "\n".

import Quickshell
import QtQuick

Item {
    id: root

    required property Item target
    property string text
    property bool shown

    // Erst nach kurzem Verweilen einblenden, sofort wieder aus
    property bool open: false
    onShownChanged: shown ? delay.restart() : (delay.stop(), open = false)

    Timer {
        id: delay
        interval: 450
        onTriggered: root.open = root.text !== ""
    }

    LazyLoader {
        active: root.open

        PopupWindow {
            anchor.item: root.target
            // Mittig unter dem Baustein, mit etwas Abstand zur Leiste
            anchor.rect.x: 0
            anchor.rect.y: root.target.height + (Style.barHeight - root.target.height) / 2 + 6
            anchor.rect.width: root.target.width
            anchor.rect.height: 1
            anchor.edges: Edges.Top
            anchor.gravity: Edges.Bottom
            anchor.adjustment: PopupAdjustment.SlideX
            visible: true
            color: "transparent"
            implicitWidth: box.width
            implicitHeight: box.height

            Rectangle {
                id: box
                width: label.implicitWidth + 24
                height: label.implicitHeight + 16
                radius: 12
                color: Style.alpha(Theme.surface, 0.97)
                border.width: 1
                border.color: Theme.highlightMed

                opacity: 0
                scale: 0.94
                Component.onCompleted: {
                    opacity = 1;
                    scale = 1;
                }
                Behavior on opacity {
                    NumberAnimation {
                        duration: Style.fast
                    }
                }
                Behavior on scale {
                    NumberAnimation {
                        duration: Style.medium
                        easing.type: Easing.OutCubic
                    }
                }

                Label {
                    id: label
                    anchors.centerIn: parent
                    text: root.text
                    font.pixelSize: 12
                    lineHeight: 1.25
                }
            }
        }
    }
}
