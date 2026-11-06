pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Caelestia
import qs.utils

Singleton {
    id: root

    readonly property var types: ["tailscale", "netbird", "nordvpn", "wireguard", "custom"]
    readonly property var typeLabels: ({
            tailscale: "Tailscale",
            netbird: "NetBird",
            nordvpn: "NordVPN",
            wireguard: "WireGuard",
            custom: "Custom"
        })
    readonly property string netbirdCloudUrl: "https://api.netbird.io:443"
    // nordvpn login only prints the browser link and returns; without analytics consent it would block forever on stdin
    readonly property string nordvpnConnect: "nordvpn account >/dev/null 2>&1 || { nordvpn set analytics off >/dev/null 2>&1; nordvpn login || exit 1; i=0; until nordvpn account >/dev/null 2>&1; do i=$((i + 1)); [ $i -ge 150 ] && exit 1; sleep 2; done; }; exec nordvpn connect \"$@\""

    property var entries: []

    property bool tailscaleUp
    property bool netbirdUp
    property bool nordvpnUp
    property string netbirdHost
    property var wireguardConnections: []
    property var wireguardActive: ({})
    property var interfaces: []

    // id -> target state while a connect/disconnect command runs
    property var busy: ({})
    property var waitingForLogin: ({})
    property var runners: ({})

    function label(entry: var): string {
        return entry.name || typeLabels[entry.type] || entry.type;
    }

    function hostOf(url: string): string {
        return url.replace(/^[a-z]+:\/\//i, "").replace(/[:/].*$/, "").toLowerCase();
    }

    function isOn(entry: var): bool {
        switch (entry.type) {
        case "tailscale":
            return tailscaleUp;
        case "netbird":
            return netbirdUp && netbirdHost === hostOf(entry.url || netbirdCloudUrl);
        case "nordvpn":
            return nordvpnUp;
        case "wireguard":
            return wireguardActive[entry.connection] === true;
        default:
            return !!entry.interface && interfaces.includes(entry.interface);
        }
    }

    function isBusy(entry: var): bool {
        return busy[entry.id] !== undefined;
    }

    function stateText(entry: var): string {
        if (waitingForLogin[entry.id])
            return "Waiting for login in browser…";
        if (isBusy(entry))
            return busy[entry.id] ? "Connecting…" : "Disconnecting…";
        return isOn(entry) ? "Connected" : "Off";
    }

    function command(entry: var, up: bool): var {
        switch (entry.type) {
        case "tailscale":
            return ["tailscale", up ? "up" : "down"];
        case "netbird":
            return up ? ["netbird", "up", "--no-browser", "-m", entry.url || netbirdCloudUrl] : ["netbird", "down"];
        case "nordvpn":
            return up ? ["sh", "-c", nordvpnConnect, "sh", ...(entry.server ?? "").split(/\s+/).filter(Boolean)] : ["nordvpn", "disconnect"];
        case "wireguard":
            return ["nmcli", "connection", up ? "up" : "down", "id", entry.connection];
        default:
            return ["sh", "-c", up ? entry.connectCmd : entry.disconnectCmd];
        }
    }

    function setOn(entry: var, up: bool): void {
        if (isBusy(entry))
            return;
        busy = Object.assign({}, busy, {
            [entry.id]: up
        });
        const runner = runnerComp.createObject(root, {
            entryId: entry.id,
            label: root.label(entry)
        });
        runners[entry.id] = runner;
        runner.exec(root.command(entry, up));
    }

    function cancel(entry: var): void {
        const runner = runners[entry.id];
        if (runner) {
            runner.cancelled = true;
            runner.running = false;
        }
    }

    function finish(id: string): void {
        delete runners[id];
        const b = Object.assign({}, busy);
        delete b[id];
        busy = b;
        setWaiting(id, false);
        refresh();
        lateRefresh.restart();
    }

    function setWaiting(id: string, waiting: bool): void {
        const w = Object.assign({}, waitingForLogin);
        if (waiting)
            w[id] = true;
        else
            delete w[id];
        waitingForLogin = w;
    }

    function refresh(): void {
        const present = entries.map(e => e.type);
        if (present.includes("tailscale"))
            tailscaleStatus.running = true;
        if (present.includes("netbird"))
            netbirdStatus.running = true;
        if (present.includes("nordvpn"))
            nordvpnStatus.running = true;
        if (present.includes("custom"))
            linkStatus.running = true;
        nmStatus.running = true;
    }

    function save(list: var): void {
        entries = list;
        storage.setText(JSON.stringify(list, null, 2) + "\n");
        refresh();
    }

    function add(entry: var): void {
        save([...entries, Object.assign({
                id: `vpn-${Date.now().toString(36)}`
            }, entry)]);
    }

    function update(id: string, entry: var): void {
        save(entries.map(e => e.id === id ? Object.assign({
                id: id
            }, entry) : e));
    }

    function remove(id: string): void {
        const entry = entries.find(e => e.id === id);
        if (entry && isOn(entry))
            setOn(entry, false);
        save(entries.filter(e => e.id !== id));
    }

    Timer {
        id: lateRefresh

        interval: 2000
        onTriggered: root.refresh()
    }

    FileView {
        id: storage

        path: `${Paths.config}/vpn.json`
        printErrors: false
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            try {
                const data = JSON.parse(text());
                if (Array.isArray(data) && JSON.stringify(data) !== JSON.stringify(root.entries))
                    root.entries = data;
            } catch (e) {
                console.warn("vpn.json is not valid JSON:", e);
            }
            root.refresh();
        }
    }

    Component {
        id: runnerComp

        Process {
            id: runner

            property string entryId
            property string label
            property bool cancelled
            property bool exited
            property bool done
            property bool loginNext
            property bool loginOpened
            property string lastLine

            function handle(line: string): void {
                const trimmed = line.trim();
                if (trimmed.length === 0)
                    return;
                const url = trimmed.match(/https?:\/\/\S+/);
                const isLoginHint = /visit|log ?in|authenticat|browser/i.test(trimmed);
                if (url && (loginNext || isLoginHint) && !loginOpened) {
                    loginOpened = true;
                    root.setWaiting(entryId, true);
                    Qt.openUrlExternally(url[0]);
                } else if (isLoginHint) {
                    loginNext = true;
                }
                lastLine = trimmed;
            }

            function complete(): void {
                if (done)
                    return;
                done = true;
                root.finish(entryId);
                destroy();
            }

            stdout: SplitParser {
                onRead: data => runner.handle(data)
            }
            stderr: SplitParser {
                onRead: data => runner.handle(data)
            }

            onExited: exitCode => {
                exited = true;
                if (exitCode !== 0 && !cancelled)
                    Toaster.toast(`${label}: connection failed`, lastLine, "vpn_key_alert");
                complete();
            }
            onRunningChanged: {
                if (running || exited)
                    return;
                if (!cancelled)
                    Toaster.toast(`${label}: connection failed`, `Could not run ${command[0]}`, "vpn_key_alert");
                complete();
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
                    root.netbirdUp = status.daemonStatus === "Connected" || (status.management?.connected === true && status.signal?.connected === true);
                    root.netbirdHost = root.hostOf(status.management?.url ?? "");
                } catch (e) {
                    root.netbirdUp = false;
                }
            }
        }
    }

    Process {
        id: nordvpnStatus

        command: ["nordvpn", "status"]
        stdout: StdioCollector {
            onStreamFinished: root.nordvpnUp = /^Status: Connected$/m.test(text)
        }
    }

    Process {
        id: nmStatus

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
                if (JSON.stringify(names) !== JSON.stringify(root.wireguardConnections))
                    root.wireguardConnections = names;
                root.wireguardActive = active;
            }
        }
    }

    Process {
        id: linkStatus

        command: ["ip", "-o", "link", "show"]
        stdout: StdioCollector {
            onStreamFinished: root.interfaces = text.trim().split("\n").map(l => (l.split(": ")[1] ?? "").split("@")[0])
        }
    }
}
