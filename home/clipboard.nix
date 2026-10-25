# home/clipboard.nix – Zwischenablage-Verlauf (Super+V, Löschen: Super+Alt+V).
# cliphist merkt sich alles Kopierte; das Menü holt einen Eintrag zurück.

{ pkgs, ... }:

let
  clipboard-menu = pkgs.writeShellApplication {
    name = "clipboard-menu";
    runtimeInputs = [
      pkgs.fuzzel
      pkgs.cliphist
      pkgs.wl-clipboard
    ];
    text = ''
      pick() {
        cliphist list \
          | fuzzel --dmenu --minimal-lines --with-nth 2 --prompt "$1" --placeholder "$2" --width 60
      }

      case "''${1:-}" in
        # Gewählter Eintrag wird aus dem Verlauf entfernt
        delete) pick "󰆴  " "Eintrag zum Löschen wählen …" | cliphist delete ;;
        # Gewählter Eintrag landet wieder in der Zwischenablage → Strg+V fügt ihn ein
        *) pick "󰅍  " "Zwischenablage durchsuchen …" | cliphist decode | wl-copy ;;
      esac
    '';
  };
in
{
  home.packages = [
    clipboard-menu
    pkgs.wl-clipboard # wl-copy / wl-paste im Terminal
  ];

  services.cliphist = {
    enable = true;
    allowImages = true;
  };
}
