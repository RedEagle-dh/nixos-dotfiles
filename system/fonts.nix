{ pkgs, theme, ... }:

{
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-color-emoji
    theme.fonts.ui.package
    theme.fonts.mono.package
  ];

  fonts.fontconfig.defaultFonts = {
    sansSerif = [
      theme.fonts.ui.name
      "Noto Sans"
    ];
    monospace = [ theme.fonts.mono.name ];
    emoji = [ "Noto Color Emoji" ];
  };
}
