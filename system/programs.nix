{ pkgs, ... }:

{
  programs.nix-ld.enable = true;

  programs.nautilus-open-any-terminal = {
    enable = true;
    terminal = "kitty";
  };

  environment.systemPackages = with pkgs; [
    nautilus

    git
    vim
    wget
    curl
    unzip
  ];
}
