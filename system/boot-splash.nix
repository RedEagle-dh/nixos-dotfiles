{ config, theme, ... }:

{
  boot.plymouth = {
    enable = true;
    theme = theme.plymouth.name;
    themePackages = [ theme.plymouth ];
    font = theme.plymouth.fontFile;
  };

  # Letztes Bild stehen lassen, bis der Login übernimmt – sonst kurz schwarz
  systemd.services.plymouth-quit.serviceConfig.ExecStart = [
    ""
    "-${config.boot.plymouth.package}/bin/plymouth quit --retain-splash"
  ];

  boot.consoleLogLevel = 3;
  boot.kernelParams = [
    "quiet"
    "udev.log_level=3"
    "rd.udev.log_level=3"
    "systemd.show_status=auto"
    "rd.systemd.show_status=auto"
  ];
}
