// Bar.qml – die Leiste oben: eine schwebende, leicht durchsichtige Fläche.
//   links   Logo (Starter) · Arbeitsflächen · aktives Fenster
//   Mitte   Uhrzeit & Datum
//   rechts  CPU/RAM/GPU · Tray · Lautstärke · Benachrichtigungen · Power

import Quickshell
import Quickshell.Wayland
import QtQuick

PanelWindow {
    id: bar

    anchors {
        top: true
        left: true
        right: true
    }
    margins {
        top: Style.barGap
        left: Style.barSideGap
        right: Style.barSideGap
    }
    implicitHeight: Style.barHeight
    color: "transparent"

    WlrLayershell.namespace: "bar" // für Hyprlands Milchglas-Regel
    WlrLayershell.layer: WlrLayer.Top

    Rectangle {
        anchors.fill: parent
        radius: Style.barRadius
        color: Style.alpha(Theme.base, Style.barOpacity)
        border.width: 1
        border.color: Style.alpha(Theme.highlightHigh, 0.35)
    }

    Row {
        anchors.left: parent.left
        anchors.leftMargin: Style.barPadding
        anchors.verticalCenter: parent.verticalCenter
        spacing: Style.spacing + 2

        Logo {}
        Workspaces {}
        ActiveWindow {
            maxWidth: Math.max(0, bar.width / 2 - x - clock.width / 2 - 24)
        }
    }

    Clock {
        id: clock
        anchors.centerIn: parent
    }

    Row {
        anchors.right: parent.right
        anchors.rightMargin: Style.barPadding
        anchors.verticalCenter: parent.verticalCenter
        spacing: Style.spacing

        Group {
            SystemStats {}
        }
        Group {
            Tray {}
            Volume {}
            NotificationBell {}
        }
        Power {}
    }
}
