{ ... }:

{
  programs.vesktop = {
    enable = true;

    mutableSettings = true;
    settings = {
      discordBranch = "stable";
      arRPC = true;
      minimizeToTray = true;
      hardwareAcceleration = true;
      checkUpdates = false;
    };

    vencord.mutableSettings = true;
    vencord.settings = {
      # Weitere Themes hier eintragen, sonst setzt nhs sie zurück
      enabledThemes = [ "caelestia.theme.css" ];
    };
  };
}
