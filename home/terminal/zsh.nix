# home/terminal/zsh.nix – Shell und Aliase.
# Dass zsh die Login-Shell ist, legt system/users.nix fest.

{ ... }:

{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true; # graue Vorschläge aus dem Verlauf, → übernimmt
    syntaxHighlighting.enable = true; # Befehle grün/rot beim Tippen
    history.size = 50000;
  };

  # Aliase für jede Shell
  home.shellAliases = {
    ".." = "cd ..";
    "..." = "cd ../..";
    nhb = "nh os boot";
    nhs = "nh os switch && exec $SHELL"; # danach neue Shell mit neuen Aliasen
  };
}
