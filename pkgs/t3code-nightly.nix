{
  lib,
  appimageTools,
  cloudflared,
  fetchurl,
}:

let
  pname = "t3code";
  inherit (lib.importJSON ./t3code-nightly.json) version hash;

  src = fetchurl {
    url = "https://github.com/pingdotgg/t3code/releases/download/v${version}/T3-Code-${version}-x86_64.AppImage";
    inherit hash;
  };

  contents = appimageTools.extract { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  profile = ''
    export T3CODE_CLOUDFLARED_PATH=${lib.getExe cloudflared}
    # ~/.t3 gehört dem Hintergrunddienst (system/t3-host.nix), die App bekommt ein eigenes
    # Home und verbindet sich per Pairing mit dem Dienst
    export T3CODE_HOME="''${T3CODE_HOME:-$HOME/.t3-desktop}"
  '';

  extraInstallCommands = ''
    install -Dm444 ${contents}/t3code.desktop -t $out/share/applications
    substituteInPlace $out/share/applications/t3code.desktop \
      --replace-fail 'Exec=AppRun' 'Exec=t3code'
    cp -r ${contents}/usr/share/icons $out/share
  '';

  meta = {
    description = "Desktop-App für Coding-Agents (Nightly-Kanal)";
    homepage = "https://github.com/pingdotgg/t3code";
    license = lib.licenses.mit;
    mainProgram = "t3code";
    platforms = [ "x86_64-linux" ];
  };
}
