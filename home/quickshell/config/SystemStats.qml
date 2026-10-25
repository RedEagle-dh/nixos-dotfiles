// SystemStats.qml – CPU, Arbeitsspeicher und Grafikkarte als Ringe.
// Gelb ab hoher, Rot ab sehr hoher Auslastung. Klick öffnet btop.

import Quickshell
import QtQuick

Chip {
    id: root

    function level(value, normal) {
        return value >= 0.9 ? Theme.love : value >= 0.7 ? Theme.gold : normal;
    }
    function percent(value) {
        return Math.round(value * 100) + "%";
    }

    spacing: 12
    padding: 10
    onClicked: Quickshell.execDetached(["kitty", "--class", "btop", "btop"])
    tooltip: {
        const s = SystemInfo;
        let t = "Prozessor  " + percent(s.cpu) + "\nArbeitsspeicher  " + s.memoryUsed.toFixed(1) + " / " + s.memoryTotal.toFixed(1) + " GiB";
        if (s.gpuAvailable)
            t += "\n" + s.gpuName + "  " + percent(s.gpu) + " · " + s.gpuTemperature + " °C · " + s.gpuMemoryUsed.toFixed(1) + " / " + s.gpuMemoryTotal.toFixed(1) + " GiB";
        return t + "\n\nKlick: Systemmonitor";
    }

    Repeater {
        model: [
            { icon: "memory", value: () => SystemInfo.cpu, color: Theme.foam, shown: true },
            { icon: "memory_alt", value: () => SystemInfo.memory, color: Theme.iris, shown: true },
            { icon: "stadia_controller", value: () => SystemInfo.gpu, color: Theme.rose, shown: SystemInfo.gpuAvailable }
        ]

        Row {
            id: stat
            required property var modelData
            readonly property real value: modelData.value()

            visible: modelData.shown
            spacing: 6

            Ring {
                anchors.verticalCenter: parent.verticalCenter
                value: stat.value
                icon: stat.modelData.icon
                color: root.level(stat.value, stat.modelData.color)
            }
            Label {
                anchors.verticalCenter: parent.verticalCenter
                text: root.percent(stat.value)
                font.features: ({ "tnum": 1 })
                width: 30
            }
        }
    }
}
