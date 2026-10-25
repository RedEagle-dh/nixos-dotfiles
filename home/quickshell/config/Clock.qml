// Clock.qml – Uhrzeit groß, Datum daneben. Tooltip: Kalenderwoche.

import Quickshell
import QtQuick

Chip {
    id: root

    readonly property var locale: Qt.locale("de_DE")

    interactive: false
    padding: 14
    spacing: 10
    tooltip: {
        const d = clock.date;
        const t = new Date(Date.UTC(d.getFullYear(), d.getMonth(), d.getDate()));
        t.setUTCDate(t.getUTCDate() + 4 - (t.getUTCDay() || 7));
        const week = Math.ceil(((t - Date.UTC(t.getUTCFullYear(), 0, 1)) / 86400000 + 1) / 7);
        return root.locale.toString(d, "dddd, d. MMMM yyyy") + "\nKalenderwoche " + week;
    }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Label {
        text: root.locale.toString(clock.date, "HH:mm")
        font.pixelSize: 15
        font.weight: Font.Bold
        font.features: ({ "tnum": 1 }) // Ziffern gleich breit
    }

    Label {
        text: root.locale.toString(clock.date, "ddd d. MMMM").replace(".", "")
        color: Theme.subtle
        anchors.verticalCenter: parent.verticalCenter
    }
}
