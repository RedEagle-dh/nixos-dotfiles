# home/waybar.nix – Statusleiste oben.
#
# Drei schwebende "Inseln":
#   links   NixOS-Logo (öffnet den Starter) · Arbeitsflächen · aktives Fenster
#   Mitte   Datum & Uhrzeit (Kalender beim Drüberfahren)
#   rechts  CPU · RAM · GPU · Lautstärke · Tray · Benachrichtigungen · Power
#
# Die Leiste startet als systemd-Dienst mit der Sitzung (desktop.nix).
# Aussehen: waybar/style.css; die Farben werden aus theme/ davorgesetzt.

{ lib, pkgs, osConfig, ... }:

let
  theme = import ../theme { inherit pkgs; };
  c = theme.colors;

  nvidia-smi = "${osConfig.hardware.nvidia.package.bin}/bin/nvidia-smi";

  # Auslastung, Temperatur und Speicher der Grafikkarte für die Leiste
  gpu-status = pkgs.writeShellApplication {
    name = "gpu-status";
    runtimeInputs = [ pkgs.gawk ];
    text = ''
      if ! out=$(${nvidia-smi} --query-gpu=utilization.gpu,temperature.gpu,memory.used,memory.total,name \
                   --format=csv,noheader,nounits 2>/dev/null); then
        echo '{"text": "–", "tooltip": "Grafikkarte nicht erreichbar"}'
        exit 0
      fi
      awk -F', ' '{
        class = ($1 >= 90) ? "critical" : (($1 >= 60) ? "warning" : "normal")
        printf "{\"text\": \"%s%%\", \"class\": \"%s\", \"tooltip\": \"%s\\nAuslastung %s %%\\nTemperatur %s °C\\nGrafikspeicher %.1f / %.1f GiB\"}\n",
          $1, class, $5, $1, $2, $3 / 1024, $4 / 1024
      }' <<<"$out"
    '';
  };

  # Farben und Schriften aus theme/ als CSS vor style.css
  themeCss =
    lib.concatStrings (lib.mapAttrsToList (name: value: "@define-color ${name} #${value};\n") c)
    + ''
      * { font-family: "${theme.fonts.ui.name}", "${theme.fonts.mono.name}"; }
    '';
in
{
  programs.waybar = {
    enable = true;
    systemd.enable = false; # der Dienst kommt aus desktop.nix (programs.waybar)

    style = themeCss + builtins.readFile ./waybar/style.css;

    settings.main = {
      layer = "top";
      position = "top";
      height = 34;
      margin-top = 10;
      margin-left = 14;
      margin-right = 14;
      spacing = 0;

      modules-left = [
        "custom/logo"
        "ext/workspaces"
        "hyprland/window"
      ];
      modules-center = [ "clock" ];
      modules-right = [
        "cpu"
        "memory"
        "custom/gpu"
        "pulseaudio"
        "tray"
        "custom/notifications"
        "custom/power"
      ];

      "custom/logo" = {
        format = "";
        tooltip = false;
        on-click = "pkill -x fuzzel || fuzzel";
      };

      # Über das Wayland-Protokoll statt über hyprctl – so funktioniert das
      # Anklicken auch mit der Lua-Config von Hyprland
      "ext/workspaces" = {
        format = "{name}";
        on-click = "activate";
        sort-by-name = true;
        ignore-hidden = true; # Notizblock-Fläche nicht anzeigen
      };

      "hyprland/window" = {
        format = "{title}";
        icon = true;
        icon-size = 16;
        max-length = 56;
        separate-outputs = true;
        rewrite = {
          "(.*) — Mozilla Firefox" = "$1";
          "(.*) - Mozilla Firefox" = "$1";
        };
      };

      clock = {
        format = "{:%a %d. %b   %H:%M}";
        locale = "de_DE.UTF-8";
        tooltip-format = "<tt>{calendar}</tt>";
        calendar = {
          mode = "month";
          weeks-pos = "left";
          on-scroll = 1;
          format = {
            months = "<span color='#${c.rose}'><b>{}</b></span>";
            weekdays = "<span color='#${c.subtle}'>{}</span>";
            weeks = "<span color='#${c.muted}'>{}</span>";
            days = "<span color='#${c.text}'>{}</span>";
            today = "<span color='#${c.base}' background='#${c.iris}'><b>{}</b></span>";
          };
        };
        actions = {
          on-scroll-up = "shift_up";
          on-scroll-down = "shift_down";
          on-click-right = "mode"; # Monats- ↔ Jahresansicht
        };
      };

      cpu = {
        format = "  {usage}%";
        interval = 3;
        states = {
          warning = 70;
          critical = 90;
        };
        on-click = "kitty --class btop btop";
      };

      memory = {
        format = "  {percentage}%";
        interval = 5;
        tooltip-format = "{used:0.1f} von {total:0.1f} GiB belegt";
        states = {
          warning = 75;
          critical = 90;
        };
        on-click = "kitty --class btop btop";
      };

      "custom/gpu" = {
        exec = lib.getExe gpu-status;
        return-type = "json";
        interval = 5;
        format = "󰢮  {}";
        on-click = "kitty --class btop btop";
      };

      pulseaudio = {
        format = "{icon}  {volume}%";
        format-muted = "󰝟  stumm";
        format-icons = {
          default = [
            "󰕿"
            "󰖀"
            "󰕾"
          ];
          headphone = "󰋋";
        };
        tooltip-format = "{desc}";
        on-click = "pavucontrol";
        on-click-right = "volume-osd mute";
        on-scroll-up = "volume-osd up";
        on-scroll-down = "volume-osd down";
      };

      tray = {
        icon-size = 16;
        spacing = 10;
      };

      "custom/notifications" = {
        exec = "notifications status";
        return-type = "json";
        interval = 10;
        signal = 8; # sofort aktualisieren nach Super+Strg+N
        on-click = "notifications toggle-dnd";
        on-click-right = "makoctl restore";
      };

      "custom/power" = {
        format = "";
        tooltip = false;
        on-click = "power-menu";
      };
    };
  };
}
