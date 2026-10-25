# home/terminal/ – Terminal und Shell.
#   kitty.nix      Terminal (leicht durchsichtig, Hyprland legt Milchglas dahinter)
#   zsh.nix        Shell, Aliase (nhs/nhb …)
#   prompt.nix     Prompt mit Git-Status (starship)
#   cli-tools.nix  z, ls mit Icons, bat, Strg+R-Suche, btop
#   fastfetch.nix  Begrüßung mit Systeminfos beim Öffnen eines Terminals

{ ... }:

{
  imports = [
    ./kitty.nix
    ./zsh.nix
    ./prompt.nix
    ./cli-tools.nix
    ./fastfetch.nix
  ];
}
