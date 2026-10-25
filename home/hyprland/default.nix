# home/hyprland/ – Hyprland.
#
# Die eigentliche Config steht als normale Lua-Datei daneben und wird hier
# nur nach ~/.config/hypr/ verlinkt:
#   hyprland.lua   Bildschirm, Aussehen, Animationen, Eingabe, Fensterregeln
#   keybinds.lua   alle Tastenkürzel
# Hyprland selbst ist systemweit installiert (system/hyprland.nix).

{ lib, theme, ... }:

{
  imports = [
    ./lock.nix # Sperrbildschirm beim Login (hyprlock)
    ./idle.nix # Sperren & Monitore aus bei Inaktivität
  ];

  xdg.configFile = {
    "hypr/hyprland.lua".source = ./hyprland.lua;
    "hypr/keybinds.lua".source = ./keybinds.lua;

    # Farben & Schriften für die Lua-Config, erzeugt aus theme/default.nix
    "hypr/theme.lua".text = ''
      -- Automatisch erzeugt aus theme/default.nix – Änderungen bitte dort machen.
      return ${
        lib.generators.toLua { } {
          inherit (theme) colors;
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
}
