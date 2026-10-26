{ lib, pkgs, ... }:

let
  # Mit Lua-Config braucht hyprctl die Lua-Schreibweise
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
    # Kein lock_cmd: caelestia reagiert selbst auf loginctl lock-session
    general {
        before_sleep_cmd = loginctl lock-session
        after_sleep_cmd = ${display} on
    }

    listener {
        timeout = 600
        on-timeout = loginctl lock-session
    }

    listener {
        timeout = 900
        on-timeout = ${display} off
        on-resume = ${display} on
    }
  '';
}
