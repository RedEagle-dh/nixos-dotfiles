{ pkgs, ... }:

{
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = [ pkgs.nvidia-vaapi-driver ];
  };

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "nvidia";
    # Aus Zens abgeschottetem Dekodier-Prozess erreicht der Treiber die GPU nicht
    MOZ_DISABLE_RDD_SANDBOX = "1";
  };
  services.xserver.videoDrivers = [ "nvidia" ];

  # Early KMS – sonst schwarzer Bildschirm mit "_", bis die Karte übernimmt
  boot.initrd.kernelModules = [
    "nvidia"
    "nvidia_modeset"
    "nvidia_drm"
  ];

  hardware.nvidia = {
    open = true;
    modesetting.enable = true;
    nvidiaSettings = true;

    # Nur einschalten, falls das Bild nach Standby kaputt ist oder Apps abstürzen:
    # powerManagement.enable = true;
  };
}
