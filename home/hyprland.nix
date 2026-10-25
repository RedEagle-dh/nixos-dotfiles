# home/hyprland.nix – Hyprland-Config, Sperrbildschirm, Leerlauf und Hintergrundbild.
#
# Hyprland selbst ist systemweit installiert (desktop.nix). Die eigentliche
# Config steht als normale Lua-Datei in hypr/ – hier wird sie nur verlinkt.

{ lib, pkgs, ... }:

let
  theme = import ../theme { inherit pkgs; };
  c = theme.colors;
  font = theme.fonts.ui.name;

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
in
{
  home.packages = [ display-power ];

  # ───────────────────────── Hyprland ─────────────────────────
  xdg.configFile = {
    "hypr/hyprland.lua".source = ./hypr/hyprland.lua;
    "hypr/keybinds.lua".source = ./hypr/keybinds.lua;

    # Farben & Schriften für die Lua-Config, erzeugt aus theme/default.nix
    "hypr/theme.lua".text = ''
      -- Automatisch erzeugt aus theme/default.nix – Änderungen bitte dort machen.
      return ${
        lib.generators.toLua { } {
          colors = c;
          fonts = {
            ui = theme.fonts.ui.name;
            mono = theme.fonts.mono.name;
          };
          cursor = {
            inherit (theme.cursor) name hyprcursor size;
          };
        }
      }
    '';
  };

  # ───────────────────────── Hintergrundbild ─────────────────────────
  systemd.user.services.wallpaper = {
    Unit = {
      Description = "Hintergrundbild";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${lib.getExe pkgs.swaybg} --mode fill --image ${theme.wallpaper}";
      Restart = "on-failure";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  # ───────────────────────── Sperrbildschirm ─────────────────────────
  # Super+L. Verschwommenes Hintergrundbild, große Uhr, Passwortfeld.
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        hide_cursor = true;
        ignore_empty_input = true;
      };

      animations = {
        enabled = true;
        bezier = [ "smooth, 0.25, 1, 0.5, 1" ];
        animation = [
          "fadeIn, 1, 4, smooth"
          "fadeOut, 1, 4, smooth"
          "inputFieldDots, 1, 2, smooth"
        ];
      };

      background = [
        {
          path = "${theme.wallpaper}";
          blur_passes = 3;
          blur_size = 8;
          brightness = 0.7;
          vibrancy = 0.2;
        }
      ];

      label = [
        # Uhrzeit
        {
          text = "$TIME";
          color = "rgb(${c.text})";
          font_size = 110;
          font_family = "${font} Light";
          position = "0, 170";
          halign = "center";
          valign = "center";
        }
        # Datum, z. B. "Samstag, 25. Oktober"
        {
          text = ''cmd[update:60000] LC_TIME=de_DE.UTF-8 date +"%A, %-d. %B"'';
          color = "rgb(${c.subtle})";
          font_size = 20;
          font_family = font;
          position = "0, 70";
          halign = "center";
          valign = "center";
        }
        # Hinweis unten
        {
          text = "Gesperrt · Passwort eingeben und Enter drücken";
          color = "rgba(${c.muted}ff)";
          font_size = 12;
          font_family = font;
          position = "0, 40";
          halign = "center";
          valign = "bottom";
        }
      ];

      input-field = [
        {
          size = "320, 56";
          position = "0, -60";
          halign = "center";
          valign = "center";
          rounding = -1; # Pillenform
          outline_thickness = 2;
          outer_color = "rgba(${c.iris}ee) rgba(${c.rose}ee) 45deg";
          inner_color = "rgba(${c.base}cc)";
          font_color = "rgb(${c.text})";
          font_family = font;
          check_color = "rgb(${c.gold})";
          fail_color = "rgb(${c.love})";
          capslock_color = "rgb(${c.gold})";
          placeholder_text = ''<span foreground="##${c.subtle}">Passwort</span>'';
          fail_text = "Falsches Passwort";
          dots_size = 0.25;
          dots_spacing = 0.3;
          fade_on_empty = false;
          shadow_passes = 2;
        }
      ];
    };
  };

  # ───────────────────────── Leerlauf ─────────────────────────
  # Der Dienst hypridle läuft systemweit (desktop.nix, programs.hyprlock);
  # hier nur, wann was passiert. Läuft ein Video oder Spiel im Vollbild,
  # passiert nichts (siehe Fensterregel "idle-inhibit-fullscreen").
  xdg.configFile."hypr/hypridle.conf".text =
    let
      display = lib.getExe display-power;
    in
    ''
      general {
          lock_cmd = pidof hyprlock || hyprlock
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
