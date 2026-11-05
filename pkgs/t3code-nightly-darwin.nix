# Mac-Fassung von t3code-nightly.nix: die signierte App aus dem Release, unverändert.
# ~/.t3 gehört hier der App selbst – den Hintergrunddienst gibt es nur auf dem Desktop
{
  lib,
  stdenvNoCC,
  fetchurl,
  unzip,
}:

let
  inherit (lib.importJSON ./t3code-nightly.json) version darwinHash;
in
stdenvNoCC.mkDerivation {
  pname = "t3code";
  inherit version;

  src = fetchurl {
    url = "https://github.com/pingdotgg/t3code/releases/download/v${version}/T3-Code-${version}-arm64.zip";
    hash = darwinHash;
  };

  nativeBuildInputs = [ unzip ];
  sourceRoot = ".";

  # Jede Änderung bräche die Signatur – dann verweigern Gatekeeper und Schlüsselbund den Dienst
  dontFixup = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/Applications
    cp -R "T3 Code (Nightly).app" $out/Applications/
    runHook postInstall
  '';

  meta = {
    description = "Desktop-App für Coding-Agents (Nightly-Kanal)";
    homepage = "https://github.com/pingdotgg/t3code";
    license = lib.licenses.mit;
    platforms = [ "aarch64-darwin" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
