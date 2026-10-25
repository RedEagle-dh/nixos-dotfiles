# system/nvidia.nix – Grafiktreiber für die RTX 4080.

{ pkgs, ... }:

{
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # 32-Bit-Treiber für Steam/Proton

    # Videos im Browser über die Grafikkarte dekodieren (VA-API → NVDEC) statt
    # auf der CPU. Prüfen: in Firefox about:support → "Hardware Video Decoding",
    # oder beim Abspielen in nvidia-smi nach "firefox" schauen.
    # Firefox-Einstellungen dazu: system/programs.nix
    extraPackages = [ pkgs.nvidia-vaapi-driver ];
  };

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "nvidia"; # VA-API soll den NVIDIA-Treiber laden
    # Firefox dekodiert in einem abgeschotteten Prozess, aus dem heraus der
    # Treiber die Grafikkarte nicht erreicht – laut nvidia-vaapi-driver nötig
    MOZ_DISABLE_RDD_SANDBOX = "1";
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
