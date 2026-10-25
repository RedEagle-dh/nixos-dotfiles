# system/nvidia.nix – Grafiktreiber für die RTX 4080.

{ ... }:

{
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # 32-Bit-Treiber für Steam/Proton
  };
  services.xserver.videoDrivers = [ "nvidia" ]; # heißt so, gilt aber auch für Wayland

  # Treiber schon in der frühen Bootphase laden ("Early KMS"). Sonst übernimmt die
  # Karte erst, wenn der Login-Bildschirm schon läuft → schwarzer Bildschirm mit "_".
  boot.initrd.kernelModules = [
    "nvidia"
    "nvidia_modeset"
    "nvidia_drm"
  ];

  hardware.nvidia = {
    open = true; # offene Kernelmodule – für RTX 20xx und neuer empfohlen
    modesetting.enable = true; # Pflicht für Wayland/Hyprland
    nvidiaSettings = true; # GUI-Tool "nvidia-settings"

    # Nur einschalten, falls das Bild nach Standby kaputt ist oder Apps abstürzen:
    # powerManagement.enable = true;
  };
}
