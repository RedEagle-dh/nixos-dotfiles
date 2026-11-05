# Wie system/nix.nix – nix-darwin übernimmt /etc/nix/nix.conf und den nix-daemon
{ ... }:

{
  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nix.channel.enable = false;

  nix.optimise.automatic = true;

  # launchd holt verpasste Termine nach dem Aufwachen nach – der Mac läuft nicht durch
  nix.gc = {
    automatic = true;
    interval = {
      Weekday = 0;
      Hour = 12;
      Minute = 0;
    };
    options = "--delete-older-than 14d";
  };
}
