# Offizieller Discord-Client. Unter Linux mit Equicord für caelestias Theme, auf dem Mac ohne:
# Equicord ändert dort Dateien im signierten Discord.app, und macOS verweigert die App dann als
# "beschädigt" – auch neu ad hoc signiert
{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (pkgs.stdenv.hostPlatform) isLinux;

  # nixpkgs hängt bei Equicord oft Monate hinterher, und alte Versionen laufen nicht mit dem neuen
  # rspack-Build von Discord ("i.A is not a constructor"). Daher fest auf einen Tages-Tag von Equicord;
  # neuere Tags: https://github.com/Equicord/Equicord/releases. Hat nixpkgs denselben oder einen
  # neueren Stand, gilt der
  equicord =
    let
      version = "2026-11-07";
    in
    if lib.versionOlder pkgs.equicord.version version then
      pkgs.equicord.overrideAttrs (
        final: _: {
          inherit version;
          src = pkgs.fetchFromGitHub {
            owner = "Equicord";
            repo = "Equicord";
            tag = final.version;
            hash = "sha256-y48T5X5sMvGDU3Wp7+5U2kQcBacbeTQMJ4FryXJDe6w=";
          };
          pnpmDeps = pkgs.fetchPnpmDeps {
            inherit (final) pname version src;
            pnpm = pkgs.pnpm_11;
            fetcherVersion = 4;
            hash = "sha256-YI+fviBbfyKPdPZtMqin3Sk2M1Rumdf+B8n68bsibnc=";
          };
        }
      )
    else
      pkgs.equicord;
in
{
  programs.discord = {
    enable = true;
    package =
      if isLinux then
        pkgs.discord.override {
          withEquicord = true;
          inherit equicord;
        }
      else
        pkgs.discord;
  };

  # Equicord schreibt selbst in settings.json – nur diese Werte hineinmischen. Das Theme selbst legt
  # caelestia in ~/.config/Equicord/themes ab, passend zum aktuellen Farbschema
  home.activation.equicordSettings = lib.mkIf isLinux (
    lib.hm.dag.entryAfter [ "linkGeneration" ] (
      lib.hm.generators.mkImpureConfigMerger {
        inherit pkgs;
        format = "json";
        empty = "{}";
        jqOperation = "$dynamic * $static";
        path = "${config.xdg.configHome}/Equicord/settings/settings.json";
        staticSettings = (pkgs.formats.json { }).generate "equicord-settings.json" {
          # Weitere Themes hier eintragen, sonst setzt der nächste Switch sie zurück
          enabledThemes = [ "caelestia.theme.css" ];
        };
        mode = "600";
      }
    )
  );
}
