{ ... }:

{
  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nix.channel.enable = false;
  programs.command-not-found.enable = false;

  nix.optimise.automatic = true;

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  # Aufräumen macht nix.gc – nh.clean deshalb nicht einschalten
  programs.nh = {
    enable = true;
    flake = "/etc/nixos";
  };
}
