# home/terminal/prompt.nix – Prompt (starship): Ordner, Git-Status, Laufzeit.

{ theme, ... }:

let
  hex = name: "#${theme.colors.${name}}";
in
{
  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;
      format = "$directory$git_branch$git_status$nix_shell$python$nodejs$bun$rust$cmd_duration$line_break$character";

      directory = {
        style = "bold ${hex "iris"}";
        truncation_length = 3;
        truncate_to_repo = true;
        read_only = " 󰌾";
      };
      git_branch = {
        format = "[$symbol$branch]($style) ";
        symbol = " ";
        style = hex "rose";
      };
      git_status = {
        format = "([$all_status$ahead_behind]($style) )";
        style = hex "love";
      };
      nix_shell = {
        format = "[$symbol$name]($style) ";
        symbol = " ";
        style = hex "foam";
      };
      python.format = "[$symbol($version )]($style)";
      nodejs.format = "[$symbol($version )]($style)";
      bun.format = "[$symbol($version )]($style)";
      rust.format = "[$symbol($version )]($style)";
      cmd_duration = {
        format = "[ $duration]($style) ";
        style = hex "gold";
        min_time = 2000;
      };
      character = {
        success_symbol = "[❯](bold ${hex "iris"})";
        error_symbol = "[❯](bold ${hex "love"})";
      };
    };
  };
}
