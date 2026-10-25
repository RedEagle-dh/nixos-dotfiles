//@ pragma UseQApplication
// shell.qml – Einstieg der Oberfläche: eine Leiste pro Bildschirm.
//
// Aufbau (alle Dateien in diesem Ordner):
//   Bar.qml            die Leiste: links Logo · Arbeitsflächen · Fenster,
//                      Mitte Uhr, rechts Systemwerte · Tray · Ton · Glocke · Power
//   Workspaces.qml …   je ein Baustein der Leiste
//   Chip.qml           runder Knopf mit Hover-Effekt – Grundbaustein für alles Klickbare
//   Style.qml          Größen, Abstände, Animationszeiten
//   Theme.qml          Farben & Schriften – erzeugt aus theme/default.nix
//   SystemInfo.qml     CPU, RAM, GPU   ·   Notifications.qml  "Nicht stören"
//
// Quickshell lädt Änderungen sofort neu – zum Ausprobieren also einfach die
// Datei unter ~/.config/quickshell bearbeiten; dauerhaft dann hier im Repo.
// Doku: https://quickshell.org/docs/

import Quickshell
import Quickshell.Io
import QtQuick

ShellRoot {
    id: root

    property bool barVisible: true

    Variants {
        model: Quickshell.screens

        Bar {
            required property ShellScreen modelData
            screen: modelData
            visible: root.barVisible
        }
    }

    // Super+Umschalt+B: qs ipc call bar toggle
    IpcHandler {
        target: "bar"

        function toggle(): void {
            root.barVisible = !root.barVisible;
        }
    }
}
