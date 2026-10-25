// Notifications.qml – Zustand von "Nicht stören" (mako).
// notifications toggle-dnd meldet Änderungen per
// `qs ipc call notifications refresh`, damit die Glocke sofort umspringt.

pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property bool doNotDisturb: false

    function refresh() {
        if (!query.running)
            query.running = true;
    }

    Process {
        id: query
        running: true
        command: ["makoctl", "mode"]
        stdout: StdioCollector {
            onStreamFinished: root.doNotDisturb = text.split("\n").includes("do-not-disturb")
        }
    }

    // Falls mako neu startet o. Ä.
    Timer {
        interval: 10000
        running: true
        repeat: true
        onTriggered: root.refresh()
    }

    IpcHandler {
        target: "notifications"

        function refresh(): void {
            root.refresh();
        }
    }
}
