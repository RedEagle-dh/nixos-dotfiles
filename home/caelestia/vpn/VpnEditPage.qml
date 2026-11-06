pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Caelestia.Components
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.services
import qs.modules.nexus.common

PageBase {
    id: root

    readonly property int editIndex: nState.editingVpnIndex
    readonly property var existing: editIndex >= 0 ? (Vpns.entries[editIndex] ?? null) : null

    property string type: existing?.type ?? "tailscale"
    property string connection: existing?.connection ?? ""

    readonly property list<MenuItem> typeItems: [
        MenuItem {
            text: "Tailscale"
            value: "tailscale"
        },
        MenuItem {
            text: "NetBird"
            value: "netbird"
        },
        MenuItem {
            text: "NordVPN"
            value: "nordvpn"
        },
        MenuItem {
            text: "WireGuard"
            value: "wireguard"
        },
        MenuItem {
            text: "Custom"
            value: "custom"
        }
    ]

    function submit(): void {
        if (type === "wireguard" && !connection)
            return;

        if (type === "custom") {
            connectField.isError = !connectField.text.trim();
            disconnectField.isError = !disconnectField.text.trim();
            if (connectField.isError || disconnectField.isError)
                return;
        }

        const entry = {
            type: type,
            name: nameField.text.trim()
        };
        if (type === "netbird" && urlField.text.trim())
            entry.url = urlField.text.trim();
        if (type === "nordvpn" && serverField.text.trim())
            entry.server = serverField.text.trim();
        if (type === "wireguard")
            entry.connection = connection;
        if (type === "custom") {
            entry.connectCmd = connectField.text.trim();
            entry.disconnectCmd = disconnectField.text.trim();
            entry.interface = interfaceField.text.trim();
        }

        if (existing)
            Vpns.update(existing.id, entry);
        else
            Vpns.add(entry);

        nState.closeSubPage();
    }

    title: existing ? "Edit VPN" : "Add VPN"
    isSubPage: true

    Component.onCompleted: {
        Vpns.refresh();
        if (existing) {
            nameField.text = existing.name ?? "";
            urlField.text = existing.url ?? "";
            serverField.text = existing.server ?? "";
            connectField.text = existing.connectCmd ?? "";
            disconnectField.text = existing.disconnectCmd ?? "";
            interfaceField.text = existing.interface ?? "";
        }
    }

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: root.cappedWidth
        spacing: Tokens.spacing.large

        SelectRow {
            first: true
            last: true
            label: "Provider"
            menuItems: root.typeItems
            active: root.typeItems.find(i => i.value === root.type) ?? null
            onSelected: item => root.type = item.value
        }

        StyledTextField {
            id: nameField

            Layout.fillWidth: true
            placeholderText: "Name"
            leadingIcon: "label"
            supportingText: `Shown in the VPN list (default: ${Vpns.typeLabels[root.type]})`
            onAccepted: root.submit()
        }

        StyledTextField {
            id: urlField

            Layout.fillWidth: true
            visible: root.type === "netbird"
            placeholderText: "Management URL"
            leadingIcon: "dns"
            supportingText: "Leave empty for NetBird Cloud"
            inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText | Qt.ImhUrlCharactersOnly
            onAccepted: root.submit()
        }

        StyledTextField {
            id: serverField

            Layout.fillWidth: true
            visible: root.type === "nordvpn"
            placeholderText: "Server"
            leadingIcon: "public"
            supportingText: "Country, city, group or server, e.g. Germany, Germany Berlin, P2P, de1234. Leave empty for the fastest"
            inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText
            onAccepted: root.submit()
        }

        SelectRow {
            visible: root.type === "wireguard" && Vpns.wireguardConnections.length > 0
            first: true
            last: true
            label: "Connection"
            subtext: "WireGuard connection in NetworkManager"
            fallbackText: "Select"
            menuItems: wireguardItems.instances
            active: wireguardItems.instances.find(i => i.value === root.connection) ?? null
            onSelected: item => root.connection = item.value

            Variants {
                id: wireguardItems

                model: Vpns.wireguardConnections

                MenuItem {
                    required property string modelData

                    text: modelData
                    value: modelData
                }
            }
        }

        StyledTextField {
            id: connectField

            Layout.fillWidth: true
            visible: root.type === "custom"
            placeholderText: "Connect command"
            leadingIcon: "play_arrow"
            errorText: "Required"
            inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText
        }

        StyledTextField {
            id: disconnectField

            Layout.fillWidth: true
            visible: root.type === "custom"
            placeholderText: "Disconnect command"
            leadingIcon: "stop"
            errorText: "Required"
            inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText
        }

        StyledTextField {
            id: interfaceField

            Layout.fillWidth: true
            visible: root.type === "custom"
            placeholderText: "Interface"
            leadingIcon: "lan"
            supportingText: "Shown as connected while this network interface exists"
            inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText
        }

        StyledText {
            Layout.fillWidth: true
            Layout.leftMargin: Tokens.padding.small
            text: {
                switch (root.type) {
                case "tailscale":
                    return "The first connect opens the Tailscale login in your browser.";
                case "netbird":
                    return "The first connect opens the NetBird login in your browser. Only one NetBird network can be connected at a time.";
                case "nordvpn":
                    return "The first connect opens the NordVPN login in your browser. Only one NordVPN server can be connected at a time.";
                case "wireguard":
                    return Vpns.wireguardConnections.length > 0 ? "Import more configs with: nmcli connection import type wireguard file <name>.conf" : "No WireGuard connection in NetworkManager yet. Import your config first: nmcli connection import type wireguard file <name>.conf";
                default:
                    return "Commands run with sh -c. A login link in their output opens in your browser.";
                }
            }
            color: Colours.palette.m3onSurfaceVariant
            font: Tokens.font.body.small
            wrapMode: Text.WordWrap
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Tokens.spacing.small

            IconTextButton {
                visible: !!root.existing
                isRound: true
                horizontalPadding: Tokens.padding.extraLarge
                verticalPadding: Tokens.padding.medium
                inactiveColour: Colours.palette.m3errorContainer
                inactiveOnColour: Colours.palette.m3onErrorContainer
                iconLabel.fill: 1
                iconLabel.grade: 25
                icon: "delete_forever"
                text: "Delete"
                onClicked: {
                    Vpns.remove(root.existing.id);
                    root.nState.closeSubPage();
                }
            }

            Item {
                Layout.fillWidth: true
            }

            ButtonRow {
                spacing: parent.spacing

                TextButton {
                    isRound: true
                    shapeMorph: true
                    horizontalPadding: Tokens.padding.extraLarge
                    verticalPadding: Tokens.padding.medium
                    type: TextButton.Tonal
                    text: "Cancel"
                    onClicked: root.nState.closeSubPage()
                }

                TextButton {
                    isRound: true
                    shapeMorph: true
                    horizontalPadding: Tokens.padding.extraLarge
                    verticalPadding: Tokens.padding.medium
                    text: root.existing ? "Save" : "Add"
                    disabled: root.type === "wireguard" && !root.connection
                    onClicked: root.submit()
                }
            }
        }
    }
}
