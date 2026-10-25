# system/fonts.nix – Schriften.
# Systemweit, damit auch der Login-Bildschirm sie findet. Welche Schriften
# es sind, steht in theme/default.nix.

{ pkgs, theme, ... }:

{
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-color-emoji
    theme.fonts.ui.package # Inter – Oberflächen
    theme.fonts.mono.package # JetBrains Mono mit Icons – Terminal, Menüs
    theme.fonts.icons.package # Material Symbols – Leiste
  ];

  # Programme ohne eigene Schriftwahl bekommen dieselben Schriften
  fonts.fontconfig.defaultFonts = {
    sansSerif = [
      theme.fonts.ui.name
      "Noto Sans"
    ];
    monospace = [ theme.fonts.mono.name ];
    emoji = [ "Noto Color Emoji" ];
  };
}
