# kitty auf dem Mac – Grundeinstellungen in home/terminal/kitty.nix
{ theme, ... }:

let
  hex = name: "#${theme.colors.${name}}";
in
{
  programs.kitty = {
    settings = {
      # Option bleibt fürs deutsche Layout (@ [ ] { } | ~), nicht als Alt
      macos_option_as_alt = "no";

      # Der Strich-Cursor (cursor_shape in kitty.nix) wirkt auf dem Retina-Display mit 1,5 pt zu dünn
      cursor_beam_thickness = "2.5";

      # Ohne Titelleiste und mit Unschärfe hinter der Transparenz – wie unter Hyprland
      hide_window_decorations = "titlebar-only";
      background_blur = 32;

      # Unter Linux setzt caelestia 16–18 auf die Akzentfarben des Schemas (fastfetch, Begrüßung)
      color16 = hex "iris";
      color17 = hex "rose";
      color18 = hex "foam";
    };

    # Zusätzlich zu Ctrl+Shift+Enter/T aus kitty.nix
    keybindings = {
      "cmd+enter" = "new_window_with_cwd";
      "cmd+t" = "new_tab_with_cwd";
    };
  };

  # Unterdrückt macOS' "Last login: …" vor der Begrüßung – unter Linux gibt es die Zeile nicht
  home.file.".hushlogin".text = "";
}
