# home/hyprland/lock.nix – Sperrbildschirm (Super+L) und Login.
# Verschwommenes Hintergrundbild, große Uhr, Passwortfeld.
# Die Passwortprüfung (PAM) richtet system/hyprland.nix ein.
#
# Beim Start der Sitzung sperrt er sich sofort: Weil system/login.nix
# automatisch anmeldet, ist der Sperrbildschirm zugleich der Login.

{
  config,
  lib,
  theme,
  ...
}:

let
  c = theme.colors;
  font = theme.fonts.ui.name;
in
{
  systemd.user.services.lock-on-login = {
    Unit = {
      Description = "Sperrbildschirm direkt nach dem Login";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session-pre.target" ];
    };
    Service.ExecStart = "${lib.getExe config.programs.hyprlock.package} --immediate";
    Install.WantedBy = [ "graphical-session.target" ];
  };

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
}
