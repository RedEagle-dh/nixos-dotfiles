# home/terminal/kitty.nix – Terminal Kitty in den Farben aus theme/.

{ theme, ... }:

let
  hex = name: "#${theme.colors.${name}}";
in
{
  programs.kitty = {
    enable = true;
    font = {
      inherit (theme.fonts.mono) name package size;
    };
    settings = {
      background_opacity = "0.9";
      window_padding_width = 14;
      confirm_os_window_close = 0;
      enable_audio_bell = false;
      scrollback_lines = 20000;
      cursor_shape = "beam";
      cursor_trail = 3; # Cursor zieht beim Springen einen kurzen Schweif
      url_style = "curly";
      tab_bar_edge = "bottom";
      tab_bar_style = "powerline";
      tab_powerline_style = "slanted";

      # Farben: Rosé Pine
      foreground = hex "text";
      background = hex "base";
      selection_foreground = hex "text";
      selection_background = hex "highlightMed";
      cursor = hex "highlightHigh";
      cursor_text_color = hex "text";
      url_color = hex "iris";
      active_tab_foreground = hex "text";
      active_tab_background = hex "overlay";
      inactive_tab_foreground = hex "muted";
      inactive_tab_background = hex "base";
      tab_bar_background = hex "base";
      active_border_color = hex "pine";
      inactive_border_color = hex "highlightMed";

      color0 = hex "overlay";
      color8 = hex "muted";
      color1 = hex "love";
      color9 = hex "love";
      color2 = hex "pine";
      color10 = hex "pine";
      color3 = hex "gold";
      color11 = hex "gold";
      color4 = hex "foam";
      color12 = hex "foam";
      color5 = hex "iris";
      color13 = hex "iris";
      color6 = hex "rose";
      color14 = hex "rose";
      color7 = hex "text";
      color15 = hex "text";
    };
    keybindings = {
      "ctrl+shift+enter" = "new_window_with_cwd";
      "ctrl+shift+t" = "new_tab_with_cwd";
    };
  };
}
