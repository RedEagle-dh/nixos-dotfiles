# home/terminal/cli-tools.nix – Werkzeuge für die Kommandozeile.
#   z ordner   springt in oft benutzte Ordner (zoxide)
#   ls, ll …   mit Icons und Git-Status (eza)
#   bat        wie cat, mit Syntaxfarben
#   Strg+R     Verlauf durchsuchen (fzf)
#   btop       Systemmonitor (auch per Klick auf CPU/RAM/GPU in der Leiste)

{ theme, ... }:

let
  hex = name: "#${theme.colors.${name}}";
in
{
  programs.zoxide.enable = true;

  programs.eza = {
    enable = true;
    icons = "auto";
    git = true;
  };

  programs.bat = {
    enable = true;
    config.theme = "ansi"; # nutzt die Terminalfarben → passt zur Palette
  };

  programs.fzf = {
    enable = true;
    colors = {
      fg = hex "subtle";
      "fg+" = hex "text";
      bg = "-1";
      "bg+" = hex "overlay";
      hl = hex "rose";
      "hl+" = hex "rose";
      border = hex "highlightMed";
      header = hex "pine";
      gutter = "-1";
      spinner = hex "gold";
      info = hex "foam";
      pointer = hex "iris";
      marker = hex "love";
      prompt = hex "subtle";
    };
  };

  programs.btop = {
    enable = true;
    settings = {
      color_theme = "TTY"; # nutzt die Terminalfarben
      theme_background = false;
      rounded_corners = true;
    };
  };
}
