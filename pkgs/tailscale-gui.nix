# tailscale-gui aus nixpkgs, aber in der neuesten Version von pkgs.tailscale.com – nixpkgs hinkt oft
# mehrere Releases hinterher. Version und Hash setzt pkgs/update.sh
{
  lib,
  fetchurl,
  tailscale-gui,
}:

let
  inherit (lib.importJSON ./tailscale-gui.json) version hash;
in
tailscale-gui.overrideAttrs {
  inherit version;
  src = fetchurl {
    url = "https://pkgs.tailscale.com/stable/Tailscale-${version}-macos.pkg";
    inherit hash;
  };

  # Ältere Installer enthalten nur Contents/ (Ziel /Applications/Tailscale.app), neuere (ab 1.104) das
  # ganze Tailscale.app (Ziel /Applications). Die installPhase aus nixpkgs kennt nur die alte Form
  installPhase = ''
    runHook preInstall
    xar -xf $src
    cd Distribution.pkg
    pbzx -n Payload | cpio -i --quiet

    app=.
    if [ -d Tailscale.app ]; then app=Tailscale.app; fi
    mkdir -p $out/Applications/Tailscale.app $out/bin
    cp -R "$app/Contents" $out/Applications/Tailscale.app/
    ln -s ../Applications/Tailscale.app/Contents/MacOS/Tailscale $out/bin/tailscale
    runHook postInstall
  '';

  # Jede Änderung bräche die Signatur
  dontFixup = true;
}
