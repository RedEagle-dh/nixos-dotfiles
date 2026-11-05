pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.services

ColumnLayout {
    id: root

    property bool shown

    spacing: Tokens.spacing.small

    onShownChanged: {
        if (shown)
            Vpns.refresh();
    }

    Timer {
        interval: 3000
        repeat: true
        running: root.shown
        onTriggered: Vpns.refresh()
    }

    StyledText {
        Layout.topMargin: Tokens.spacing.small
        text: "VPN"
        font: Tokens.font.body.medium
    }

    StyledText {
        Layout.fillWidth: true
        visible: Vpns.entries.length === 0
        text: "Add VPNs in Settings → Network."
        color: Colours.palette.m3onSurfaceVariant
        font: Tokens.font.body.small
        wrapMode: Text.WordWrap
    }

    Repeater {
        model: Vpns.entries

        delegate: VpnRow {
            required property var modelData

            Layout.fillWidth: true
            entry: modelData
        }
    }
}
