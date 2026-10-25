# home/terminal/zsh.nix – Shell und Aliase.
# Dass zsh die Login-Shell ist, legt system/users.nix fest.
#   Tab            Vervollständigung als durchsuchbare Liste (fzf-tab), mit
#                  Vorschau beim Ordnerwechsel; , und . wechseln die Gruppe
#   ordner         nur den Ordnernamen tippen = cd ordner
#   " befehl"      mit Leerzeichen davor landet ein Befehl nicht im Verlauf

{ lib, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true; # graue Vorschläge aus dem Verlauf, → übernimmt
    syntaxHighlighting.enable = true; # Befehle grün/rot beim Tippen
    autocd = true;

    history = {
      size = 50000;
      save = 50000;
      ignoreAllDups = true; # Wiederholungen nur einmal (der neueste Aufruf bleibt)
      ignoreSpace = true;
      extended = true; # Zeitpunkt jedes Befehls mitspeichern
    };

    # fzf-tab muss nach der Vervollständigung (compinit, 570) und vor den
    # Vorschlägen (autosuggestion, 700) geladen werden
    initContent = lib.mkOrder 600 ''
      source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}' # Groß-/Kleinschreibung egal
      zstyle ':completion:*:descriptions' format '[%d]' # Gruppen in fzf-tab benennen
      zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}
      zstyle ':fzf-tab:*' switch-group ',' '.'
      zstyle ':fzf-tab:complete:(cd|z|eza|ls):*' fzf-preview 'eza -1 --color=always --icons $realpath'
    '';
  };

  # Aliase für jede Shell
  home.shellAliases = {
    ".." = "cd ..";
    "..." = "cd ../..";
    nhb = "nh os boot";
    nhs = "nh os switch && exec $SHELL"; # danach neue Shell mit neuen Aliasen
  };
}
