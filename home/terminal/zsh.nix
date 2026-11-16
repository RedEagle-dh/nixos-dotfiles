# Unverändert auch im Homelab-Repo – nur, was auf den Nodes ebenso passt
# Änderungen in nix-dotfiles machen und rüberkopieren
{ lib, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    autocd = true;

    plugins = [
      {
        name = "zsh-nix-shell";
        file = "nix-shell.plugin.zsh";
        src = "${pkgs.zsh-nix-shell}/share/zsh-nix-shell";
      }
    ];

    history = {
      size = 50000;
      save = 50000;
      ignoreAllDups = true;
      ignoreSpace = true;
      extended = true;
    };

    # fzf-tab muss nach compinit (570) und vor autosuggestion (700) laden
    initContent = lib.mkOrder 600 ''
      source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
      zstyle ':completion:*:descriptions' format '[%d]'
      zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}
      zstyle ':fzf-tab:*' switch-group ',' '.'
      zstyle ':fzf-tab:complete:(cd|z|eza|ls):*' fzf-preview 'eza -1 --color=always --icons=always $realpath'

      # Viele Server kennen kein terminfo für xterm-kitty (kaputtes Backspace, "unknown terminal type").
      # Nur kittys Wert ersetzen, damit tmux (tmux-256color) und die Linux-Konsole (linux) ihren behalten
      [[ $TERM == xterm-kitty ]] && export TERM=xterm-256color

      # kitty schickt für Option+←/→ ^[[1;3D/C und für Cmd+←/→ ^[[1;9D/C – ohne Bindung landet ";3D" als Text in der Zeile
      bindkey '^[[1;3D' backward-word
      bindkey '^[[1;3C' forward-word
      bindkey '^[[1;9D' beginning-of-line
      bindkey '^[[1;9C' end-of-line

      [[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
    '';
  };

  home.shellAliases = {
    ".." = "cd ..";
    "..." = "cd ../..";
  };
}
