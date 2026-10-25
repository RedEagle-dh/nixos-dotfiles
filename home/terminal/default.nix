# home/terminal/ – Terminal und Shell.
#   kitty.nix      Terminal (leicht durchsichtig, Hyprland legt Milchglas dahinter)
#   zsh.nix        Shell, Tab-Vervollständigung mit fzf, Aliase (nhs/nhb …)
#   prompt.nix     Prompt mit Git-Status (starship)
#   cli-tools.nix  z, ls mit Icons, bat, Strg+R-Suche, btop, direnv, Befehle ohne Installation (,)
#   fastfetch.nix  Begrüßung mit Systeminfos beim Öffnen eines Terminals
#   ssh.nix        SSH über den 1Password-Agent, Hosts (pi5, homelab …)
#   git.nix        Git (signiert über 1Password), delta, lazygit, gh

{ ... }:

{
  imports = [
    ./kitty.nix
    ./zsh.nix
    ./prompt.nix
    ./cli-tools.nix
    ./fastfetch.nix
    ./ssh.nix
    ./git.nix
  ];
}
