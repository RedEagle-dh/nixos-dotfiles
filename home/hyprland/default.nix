{ lib, theme, ... }:

{
  imports = [
    ./lock.nix
    ./idle.nix
  ];

  xdg.configFile = {
    "hypr/hyprland.lua".source = ./hyprland.lua;
    "hypr/keybinds.lua".source = ./keybinds.lua;

    "hypr/theme.lua".text = ''
      -- Erzeugt aus theme/default.nix – nicht hier ändern.
      return ${
        lib.generators.toLua { } {
          inherit (theme) colors;
          fonts = {
            ui = theme.fonts.ui.name;
            mono = theme.fonts.mono.name;
          };
          cursor = {
            inherit (theme.cursor) name size;
          };
        }
      }
    '';
  };
}
