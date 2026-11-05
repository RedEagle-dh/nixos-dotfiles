# Nur auf dem MacBook – möglichst wenig, alles Gemeinsame steht in home/
{ user, ... }:

{
  imports = [
    ./terminal.nix
    ./ssh.nix
    ./apps.nix
  ];

  home.homeDirectory = "/Users/${user}";
}
