{ inputs, theme, ... }:

let
  hex = name: "#${theme.colors.${name}}";
in
{
  imports = [ inputs.nix-index-database.homeModules.nix-index ];
  programs.nix-index.enable = true;
  programs.nix-index-database.comma.enable = true;

  programs.zoxide.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    silent = true;
  };

  programs.eza = {
    enable = true;
    icons = "auto";
    git = true;
  };

  programs.bat = {
    enable = true;
    config.theme = "ansi";
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
      color_theme = "TTY";
      theme_background = false;
      rounded_corners = true;
    };
  };
}
