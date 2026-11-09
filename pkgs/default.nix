# Eigene Pakete als Overlay (flake.nix): pkgs.t3code-nightly, pkgs.command-code, pkgs.claude-code.
# Nur der Desktop installiert sie, der Mac nimmt Homebrew. Versionen und Hashes setzt update.sh (nhu),
# einzeln bauen mit `nix build .#<name>`.
#
# nhs (home/terminal/nh-switch.sh): Scheitert der Bau an einzelnen Paketen, baut es das System noch
# einmal ohne sie. Deren Store-Pfade kommen als NHS_SKIP und wirken nur mit --impure – im normalen,
# reinen Build liefert getEnv "" und das Overlay fügt nur die Pakete hinzu
final: prev:

let
  inherit (prev) lib;

  skipped = lib.filter (path: path != "") (lib.splitString " " (builtins.getEnv "NHS_SKIP"));
  # tryEval: Pakete fürs andere System (t3code-nightly auf dem Mac) lassen sich gar nicht auswerten
  isSkipped =
    pkg:
    let
      path = builtins.tryEval (pkg.outPath or null);
    in
    skipped != [ ] && lib.isAttrs pkg && path.success && builtins.elem path.value skipped;

  # Eigene Fassung eines Pakets aus nixpkgs – baut sie nicht, nimmt nhs die aus nixpkgs
  orUpstream = own: upstream: if isSkipped own then upstream else own;
in
{
  t3code-nightly = final.callPackage ./t3code-nightly.nix { };

  command-code = final.callPackage ./command-code { };

  claude-code = orUpstream (prev.claude-code.override {
    manifest = lib.importJSON ./claude-code.json;
  }) prev.claude-code;
}
// lib.optionalAttrs (skipped != [ ]) {
  # Übersprungene Pakete aus allen Umgebungen nehmen: system-path, home-manager-path, Nix Apps.
  # buildEnv nimmt die Argumente auch als Funktion von finalAttrs
  buildEnv = lib.mirrorFunctionArgs prev.buildEnv (
    args:
    let
      withoutSkipped =
        attrs:
        attrs
        // lib.optionalAttrs (attrs ? paths) { paths = lib.filter (pkg: !isSkipped pkg) attrs.paths; };
    in
    prev.buildEnv (
      if lib.isFunction args then finalAttrs: withoutSkipped (args finalAttrs) else withoutSkipped args
    )
  );
}
