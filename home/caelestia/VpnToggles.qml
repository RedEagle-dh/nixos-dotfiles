pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import Caelestia
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.services

ColumnLayout {
    id: root

    property bool shown

    property bool tailscaleUp
    property bool netbirdUp
    property var wireguardNames: []
    property var wireguardActive: ({})

    function refresh(): void {
        tailscaleStatus.running = true;
        netbirdStatus.running = true;
        wireguardStatus.running = true;
    }

    spacing: Tokens.spacing.small

    onShownChanged: {
        if (shown)
            refresh();
    }

    Timer {
        interval: 3000
        repeat: true
        running: root.shown
        onTriggered: root.refresh()
    }

    StyledText {
        Layout.topMargin: Tokens.spacing.small
        text: "VPN"
        font: Tokens.font.body.medium
    }

    Repeater {
        model: ["tailscale", "netbird", ...root.wireguardNames.map(n => `wg:${n}`)]

        delegate: RowLayout {
            id: vpn

            required property string modelData

            readonly property bool isWireguard: modelData.startsWith("wg:")
            readonly property string name: isWireguard ? modelData.slice(3) : modelData === "tailscale" ? "Tailscale" : "NetBird"
            readonly property bool on: modelData === "tailscale" ? root.tailscaleUp : modelData === "netbird" ? root.netbirdUp : root.wireguardActive[name] === true
            readonly property bool busy: action.running
            property bool target
            property bool waitingForLogin
            property bool cancelled
            property string lastError

            function command(up: bool): var {
                if (isWireguard)
                    return ["nmcli", "connection", up ? "up" : "down", "id", name];
                if (modelData === "netbird")
                    return up ? ["netbird", "up", "--no-browser"] : ["netbird", "down"];
                return ["tailscale", up ? "up" : "down"];
            }

            function handleOutput(line: string): void {
                const url = line.match(/https?:\/\/\S+/);
                if (url && !waitingForLogin) {
                    waitingForLogin = true;
                    Qt.openUrlExternally(url[0]);
                }
                if (line.trim().length > 0)
                    lastError = line.trim();
            }

            Layout.fillWidth: true
            spacing: Tokens.spacing.medium

            StyledRect {
                implicitWidth: implicitHeight
                implicitHeight: icon.implicitHeight + Tokens.padding.small * 2
                radius: Tokens.rounding.full
                color: vpn.on ? Colours.palette.m3primaryContainer : Colours.palette.m3surfaceContainerHighest

                MaterialIcon {
                    id: icon

                    anchors.centerIn: parent
                    text: vpn.on ? "vpn_key" : "vpn_key_off"
                    fill: vpn.on ? 1 : 0
                    color: vpn.on ? Colours.palette.m3onPrimaryContainer : Colours.palette.m3onSurfaceVariant
                    fontStyle: Tokens.font.icon.medium
                    animate: true
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                StyledText {
                    Layout.fillWidth: true
                    text: vpn.name
                    font: Tokens.font.body.medium
                    elide: Text.ElideRight
                }

                StyledText {
                    Layout.fillWidth: true
                    text: {
                        if (vpn.waitingForLogin)
                            return "Waiting for login in browser…";
                        if (vpn.busy)
                            return vpn.target ? "Connecting…" : "Disconnecting…";
                        return vpn.on ? "Connected" : "Off";
                    }
                    color: vpn.on ? Colours.palette.m3primary : Colours.palette.m3onSurfaceVariant
                    font: Tokens.font.label.small
                    elide: Text.ElideRight
                    animate: true
                }
            }

            StyledSwitch {
                checked: vpn.busy ? vpn.target : vpn.on
                onToggled: {
                    if (vpn.busy) {
                        vpn.cancelled = true;
                        action.running = false;
                        return;
                    }
                    vpn.target = checked;
                    vpn.waitingForLogin = false;
                    vpn.cancelled = false;
                    vpn.lastError = "";
                    action.exec(vpn.command(checked));
                }
            }

            Process {
                id: action

                stdout: SplitParser {
                    onRead: data => vpn.handleOutput(data)
                }
                stderr: SplitParser {
                    onRead: data => vpn.handleOutput(data)
                }
                onExited: exitCode => {
                    vpn.waitingForLogin = false;
                    if (exitCode !== 0 && !vpn.cancelled)
                        Toaster.toast(`${vpn.name} failed`, vpn.lastError, "vpn_key_alert");
                    root.refresh();
                }
            }
        }
    }

    Process {
        id: tailscaleStatus

        command: ["tailscale", "status", "--json", "--peers=false"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.tailscaleUp = JSON.parse(text).BackendState === "Running";
                } catch (e) {
                    root.tailscaleUp = false;
                }
            }
        }
    }

    Process {
        id: netbirdStatus

        command: ["netbird", "status", "--json"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const status = JSON.parse(text);
                    root.netbirdUp = status.management?.connected === true && status.signal?.connected === true;
                } catch (e) {
                    root.netbirdUp = false;
                }
            }
        }
    }

    Process {
        id: wireguardStatus

        command: ["nmcli", "-t", "-f", "TYPE,ACTIVE,NAME", "connection", "show"]
        stdout: StdioCollector {
            onStreamFinished: {
                const names = [];
                const active = {};
                for (const line of text.trim().split("\n")) {
                    const [type, isActive, ...rest] = line.split(":");
                    if (type !== "wireguard")
                        continue;
                    const name = rest.join(":").replace(/\\(.)/g, "$1");
                    names.push(name);
                    active[name] = isActive === "yes";
                }
                if (JSON.stringify(names) !== JSON.stringify(root.wireguardNames))
                    root.wireguardNames = names;
                root.wireguardActive = active;
            }
        }
    }
}
