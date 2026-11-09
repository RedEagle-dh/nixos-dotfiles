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
  # compinit macht schon Home Manager in ~/.zshrc – das zusätzliche in /etc/zshrc kostet ~40 ms pro Shell
  programs.zsh.enableGlobalCompInit = false;
}
