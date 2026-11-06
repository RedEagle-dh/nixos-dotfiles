# Mac: NetBird.app aus dem offiziellen Installer, unverändert und signiert – darin UI (netbird-ui) und
# Dienst/CLI (netbird). pkgs.netbird-ui lässt sich unter macOS nicht bauen (wails3 hängt an webkitgtk),
# und pkgs.netbird lauscht auf /var/run/netbird/sock, die App sucht ihn unter /var/run/netbird.sock.
# Darum läuft auch der Dienst mit dem netbird aus dieser App (darwin/vpn.nix).
# Version und Hash setzt pkgs/update.sh
{
  lib,
  stdenvNoCC,
  fetchurl,
  xar,
  cpio,
}:

let
  inherit (lib.importJSON ./netbird-darwin.json) version hash;
in
stdenvNoCC.mkDerivation {
  pname = "netbird-app";
  inherit version;

  src = fetchurl {
    url = "https://github.com/netbirdio/netbird/releases/download/v${version}/netbird_${version}_darwin_arm64.pkg";
    inherit hash;
  };

  dontUnpack = true;

  nativeBuildInputs = [
    xar
    cpio
  ];

  # Jede Änderung bräche die Signatur
  dontFixup = true;

  # Die Skripte des Installers (Dienst unter /Library/LaunchDaemons, /usr/local/bin/netbird) bleiben
  # außen vor – das übernimmt services.netbird
  installPhase = ''
    runHook preInstall
    xar -xf $src
    mkdir -p $out/bin
    gzip -dc netbird_arm64.pkg/Payload | (cd $out && cpio -id --quiet)
    ln -s ../Applications/NetBird.app/Contents/MacOS/netbird $out/bin/netbird
    runHook postInstall
  '';

  meta = {
    description = "NetBird-Client für macOS: Menüleisten-App und Dienst";
    homepage = "https://netbird.io";
    license = lib.licenses.bsd3;
    mainProgram = "netbird";
    platforms = [ "aarch64-darwin" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
