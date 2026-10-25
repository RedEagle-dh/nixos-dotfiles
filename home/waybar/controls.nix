# home/waybar/controls.nix – Lautstärke, Benachrichtigungen, Power-Knopf.
# Die aufgerufenen Befehle kommen aus audio.nix, notifications.nix und menus/power.nix.

{ ... }:

{
  programs.waybar.settings.main = {
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
}
