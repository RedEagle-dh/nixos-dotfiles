# Offizieller Discord-Client. Unter Linux mit Vencord für caelestias Theme, auf dem Mac ohne:
# Vencord ändert dort Dateien im signierten Discord.app, und macOS verweigert die App dann als
# "beschädigt" – auch neu ad hoc signiert
{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (pkgs.stdenv.hostPlatform) isLinux;
in
{
  programs.discord = {
    enable = true;
    package = if isLinux then pkgs.discord.override { withVencord = true; } else pkgs.discord;
  };

  # Vencord schreibt selbst in settings.json – nur diese Werte hineinmischen. Das Theme selbst legt
  # caelestia in ~/.config/Vencord/themes ab, passend zum aktuellen Farbschema
  home.activation.vencordSettings = lib.mkIf isLinux (
    lib.hm.dag.entryAfter [ "linkGeneration" ] (
      lib.hm.generators.mkImpureConfigMerger {
        inherit pkgs;
        format = "json";
        empty = "{}";
        jqOperation = "$dynamic * $static";
        path = "${config.xdg.configHome}/Vencord/settings/settings.json";
        staticSettings = (pkgs.formats.json { }).generate "vencord-settings.json" {
          # Weitere Themes hier eintragen, sonst setzt der nächste Switch sie zurück
          enabledThemes = [ "caelestia.theme.css" ];
        };
        mode = "600";
      }
    )
  );
}
