import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components.controls
import qs.services

RowLayout {
    id: root

    required property var entry
    property bool editable

    readonly property bool connected: Vpns.isOn(entry)
    readonly property bool busy: Vpns.isBusy(entry)

    signal editClicked

    spacing: Tokens.spacing.medium

    StyledRect {
        implicitWidth: implicitHeight
        implicitHeight: icon.implicitHeight + Tokens.padding.small * 2
        radius: Tokens.rounding.full
        color: root.connected ? Colours.palette.m3primaryContainer : Colours.palette.m3surfaceContainerHighest

        MaterialIcon {
            id: icon

            anchors.centerIn: parent
            text: root.connected ? "vpn_key" : "vpn_key_off"
            fill: root.connected ? 1 : 0
            color: root.connected ? Colours.palette.m3onPrimaryContainer : Colours.palette.m3onSurfaceVariant
            fontStyle: Tokens.font.icon.medium
            animate: true
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 0

        StyledText {
            Layout.fillWidth: true
            text: Vpns.label(root.entry)
            font: Tokens.font.body.medium
            elide: Text.ElideRight
        }

        StyledText {
            Layout.fillWidth: true
            text: Vpns.stateText(root.entry)
            color: root.connected ? Colours.palette.m3primary : Colours.palette.m3onSurfaceVariant
            font: Tokens.font.label.small
            elide: Text.ElideRight
            animate: true
        }
    }

    IconButton {
        visible: root.editable
        type: IconButton.Tonal
        isRound: true
        icon: "edit"
        onClicked: root.editClicked()
    }

    StyledSwitch {
        checked: root.busy ? Vpns.busy[root.entry.id] === true : root.connected
        onToggled: {
            if (root.busy)
                Vpns.cancel(root.entry);
            else
                Vpns.setOn(root.entry, checked);
        }
    }
}
