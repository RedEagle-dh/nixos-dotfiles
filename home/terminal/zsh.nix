{ lib, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    autocd = true;

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
      zstyle ':fzf-tab:complete:(cd|z|eza|ls):*' fzf-preview 'eza -1 --color=always --icons $realpath'
    '';
  };

  home.shellAliases = {
    ".." = "cd ..";
    "..." = "cd ../..";
    nhb = "nh os boot";
    nhs = "nh os switch && exec $SHELL";
  };
}
