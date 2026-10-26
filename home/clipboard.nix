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
        delete) pick "󰆴  " "Eintrag zum Löschen wählen …" | cliphist delete ;;
        *) pick "󰅍  " "Zwischenablage durchsuchen …" | cliphist decode | wl-copy ;;
      esac
    '';
  };
in
{
  home.packages = [
    clipboard-menu
    pkgs.wl-clipboard
  ];

  services.cliphist = {
    enable = true;
    allowImages = true;
  };
}
