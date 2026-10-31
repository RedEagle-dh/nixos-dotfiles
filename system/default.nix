{ pkgs, ... }:

{
  imports = [
    ./boot.nix
    ./boot-splash.nix
    ./nix.nix
    ./locale.nix
    ./users.nix
    ./nvidia.nix
    ./hyprland.nix
    ./login.nix
    ./sound.nix
    ./bluetooth.nix
    ./services.nix
    ./fonts.nix
    ./programs.nix
    ./1password.nix
    ./docker.nix
    ./gaming.nix
    ./storage.nix
    # ./backup.nix
  ];

  _module.args.theme = import ../theme { inherit pkgs; };
}
