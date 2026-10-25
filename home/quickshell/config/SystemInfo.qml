// SystemInfo.qml – Auslastung von CPU, Arbeitsspeicher und Grafikkarte,
// alle 2 Sekunden neu gelesen. Werte von 0 bis 1.

pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property real cpu: 0
    property real memory: 0
    property real memoryUsed: 0 // GiB
    property real memoryTotal: 0

    property bool gpuAvailable: false
    property real gpu: 0
    property int gpuTemperature: 0
    property real gpuMemoryUsed: 0 // GiB
    property real gpuMemoryTotal: 0
    property string gpuName: ""

    property var previousCpu: null

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            stat.reload();
            meminfo.reload();
            if (!gpuQuery.running)
                gpuQuery.running = true;
        }
    }

    // Erste Zeile: "cpu  user nice system idle iowait irq softirq …"
    FileView {
        id: stat
        path: "/proc/stat"
        onLoaded: {
            const fields = text().split("\n")[0].trim().split(/\s+/).slice(1).map(Number);
            const idle = fields[3] + fields[4];
            const total = fields.reduce((a, b) => a + b, 0);
            const prev = root.previousCpu;
            if (prev && total > prev.total)
                root.cpu = 1 - (idle - prev.idle) / (total - prev.total);
            root.previousCpu = { idle, total };
        }
    }

    FileView {
        id: meminfo
        path: "/proc/meminfo"
        onLoaded: {
            const value = key => Number(text().match(new RegExp("^" + key + ":\\s+(\\d+)", "m"))[1]);
            const total = value("MemTotal");
            const used = total - value("MemAvailable");
            root.memory = used / total;
            root.memoryUsed = used / 1048576;
            root.memoryTotal = total / 1048576;
        }
    }

    Process {
        id: gpuQuery
        command: ["nvidia-smi", "--query-gpu=utilization.gpu,temperature.gpu,memory.used,memory.total,name", "--format=csv,noheader,nounits"]
        stdout: StdioCollector {
            onStreamFinished: {
                const f = text.trim().split(/,\s*/);
                root.gpuAvailable = f.length >= 5;
                if (!root.gpuAvailable)
                    return;
                root.gpu = Number(f[0]) / 100;
                root.gpuTemperature = Number(f[1]);
                root.gpuMemoryUsed = Number(f[2]) / 1024;
                root.gpuMemoryTotal = Number(f[3]) / 1024;
                root.gpuName = f[4].replace(/^NVIDIA GeForce /, "");
            }
        }
    }
}
