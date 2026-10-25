# home/waybar/workspaces.nix – linke Insel: Logo, Arbeitsflächen, aktives Fenster.

{ ... }:

{
  programs.waybar.settings.main = {
    "custom/logo" = {
      format = "";
      tooltip = false;
      on-click = "pkill -x fuzzel || fuzzel"; # öffnet den Starter
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
  };
}
