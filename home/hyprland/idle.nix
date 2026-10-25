# home/hyprland/idle.nix – Was bei Inaktivität passiert.
#
# Der Dienst hypridle läuft systemweit (system/hyprland.nix); hier steht nur,
# wann was passiert. Läuft ein Video oder Spiel im Vollbild, passiert nichts
# (Fensterregel "idle-inhibit-fullscreen" in hyprland.lua).

{ lib, pkgs, ... }:

let
  # Bildschirm an/aus – mit Lua-Config braucht hyprctl die Lua-Schreibweise
  display-power = pkgs.writeShellApplication {
    name = "display-power";
    text = ''
      case "''${1:-}" in
        on | off) hyprctl dispatch "hl.dsp.dpms({ action = \"$1\" })" ;;
        *) echo "Aufruf: display-power on|off" >&2; exit 1 ;;
      esac
    '';
  };
  display = lib.getExe display-power;
in
{
  home.packages = [ display-power ];

  xdg.configFile."hypr/hypridle.conf".text = ''
    # loginctl lock-session zeigt caelestias Sperrbildschirm (caelestia hört
    # selbst darauf) – deshalb hier kein lock_cmd
    general {
        before_sleep_cmd = loginctl lock-session
        after_sleep_cmd = ${display} on
    }

    # Nach 10 Minuten sperren
    listener {
        timeout = 600
        on-timeout = loginctl lock-session
    }

    # Nach 15 Minuten Monitore aus – Maus oder Taste weckt sie wieder
    listener {
        timeout = 900
        on-timeout = ${display} off
        on-resume = ${display} on
    }
  '';
}
