pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.services
import qs.modules.nexus
import qs.modules.nexus.common

ColumnLayout {
    id: root

    required property NexusState nState

    function openEditor(index: int): void {
        nState.editingVpnIndex = index;
        nState.openSubPage(4);
    }

    Layout.fillWidth: true
    spacing: Tokens.spacing.extraSmall / 2

    Timer {
        running: root.visible
        repeat: true
        triggeredOnStart: true
        interval: 3000
        onTriggered: Vpns.refresh()
    }

    SectionHeader {
        first: true
        text: "VPN"
    }

    Repeater {
        model: Vpns.entries

        delegate: ConnectedRect {
            id: row

            required property var modelData
            required property int index

            Layout.fillWidth: true
            first: index === 0
            implicitHeight: vpnRow.implicitHeight + Tokens.padding.medium * 2

            VpnRow {
                id: vpnRow

                anchors.fill: parent
                anchors.margins: Tokens.padding.medium
                anchors.leftMargin: Tokens.padding.largeIncreased
                entry: row.modelData
                editable: true
                onEditClicked: root.openEditor(row.index)
            }
        }
    }

    RowButton {
        first: Vpns.entries.length === 0
        last: true
        icon: "add"
        text: "Add VPN"
        onClicked: root.openEditor(-1)
    }
}
