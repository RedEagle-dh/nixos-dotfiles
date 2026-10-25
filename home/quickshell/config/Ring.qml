// Ring.qml – kreisförmige Anzeige 0–1 mit Icon in der Mitte.

import QtQuick
import QtQuick.Shapes

Item {
    id: root

    property real value: 0
    property color color: Theme.iris
    property string icon
    property real thickness: 2.5

    implicitWidth: 22
    implicitHeight: 22

    Behavior on value {
        NumberAnimation {
            duration: Style.slow
            easing.type: Easing.OutCubic
        }
    }

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            strokeColor: Style.alpha(root.color, 0.22)
            strokeWidth: root.thickness
            fillColor: "transparent"
            PathAngleArc {
                centerX: root.width / 2
                centerY: root.height / 2
                radiusX: (root.width - root.thickness) / 2
                radiusY: radiusX
                startAngle: 0
                sweepAngle: 360
            }
        }

        ShapePath {
            strokeColor: root.color
            strokeWidth: root.thickness
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            PathAngleArc {
                centerX: root.width / 2
                centerY: root.height / 2
                radiusX: (root.width - root.thickness) / 2
                radiusY: radiusX
                startAngle: -90
                sweepAngle: 360 * Math.max(0.02, Math.min(1, root.value))
            }
        }
    }

    Icon {
        anchors.centerIn: parent
        icon: root.icon
        size: 12
        fill: 1
        color: root.color
    }
}
