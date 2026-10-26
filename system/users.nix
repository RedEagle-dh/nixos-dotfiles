{ pkgs, user, ... }:

{
  users.users.${user} = {
    isNormalUser = true;
    description = "David Hermann";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    shell = pkgs.zsh;
  };

  # Pflicht, damit zsh als Login-Shell erlaubt ist
  programs.zsh.enable = true;
}
