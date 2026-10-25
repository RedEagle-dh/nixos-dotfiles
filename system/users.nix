# system/users.nix – Benutzerkonto und Login-Shell.
# Das Passwort wird nicht hier gesetzt, sondern mit `passwd`.

{ pkgs, user, ... }:

{
  users.users.${user} = {
    isNormalUser = true;
    description = "David Hermann";
    extraGroups = [
      "networkmanager" # Netzwerke verwalten
      "wheel" # sudo
    ];
    shell = pkgs.zsh; # Einrichtung der Shell: home/terminal/zsh.nix
  };

  # Pflicht, damit zsh als Login-Shell erlaubt ist
  programs.zsh.enable = true;
}
