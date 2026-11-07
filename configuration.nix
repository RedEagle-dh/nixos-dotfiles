{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./system
  ];

  networking.hostName = "baron";

  # Nie ändern, auch nicht nach Updates – hält Daten älterer Dienste kompatibel.
  system.stateVersion = "26.05";
}
