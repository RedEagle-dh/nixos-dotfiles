# system/boot.nix – Bootloader.

{ ... }:

{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Max. 10 Generationen im Bootmenü, damit /boot nicht vollläuft
  boot.loader.systemd-boot.configurationLimit = 10;
}
