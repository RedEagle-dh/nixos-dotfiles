# Für nh-switch.sh (nhs): die Toplevel-Derivation des Systems und die Pakete, die nhs überspringen
# kann – alle aus den Paketlisten (System und Home Manager) und die eigenen aus pkgs/. Läuft mit
# --impure, NHS_FLAKE, NHS_CONFIGS, NHS_HOST und NHS_SKIP kommen aus der Umgebung
let
  flake = builtins.getFlake (builtins.getEnv "NHS_FLAKE");
  system = flake.${builtins.getEnv "NHS_CONFIGS"}.${builtins.getEnv "NHS_HOST"};
  inherit (system) config pkgs;
  inherit (pkgs) lib;

  listed =
    config.environment.systemPackages
    ++ lib.concatMap (user: user.home.packages) (lib.attrValues config.home-manager.users);

  # Eigene Pakete aus pkgs/ auch dann, wenn sie in keiner Paketliste stehen (etwa nur in einem Dienst)
  own = lib.attrValues (
    builtins.intersectAttrs (flake.packages.${pkgs.stdenv.hostPlatform.system} or { }) pkgs
  );

  isPackage = pkg: lib.isDerivation pkg && (builtins.tryEval pkg.drvPath).success;

  # path: woran pkgs/default.nix das Paket erkennt. built: die Ausgabe, die im System landet – wie
  # buildEnv sie wählt. Fehlt sie im Store, ist der Bau gescheitert
  describe =
    pkg:
    let
      output = lib.head ((pkg.meta.outputsToInstall or [ ]) ++ [ pkg.outputName or "out" ]);
    in
    {
      inherit (pkg) name drvPath;
      path = pkg.outPath;
      built = if pkg.outputSpecified or false then pkg.outPath else (pkg.${output} or pkg).outPath;
    };
in
{
  toplevel = config.system.build.toplevel.drvPath;
  packages = map describe (lib.filter isPackage (listed ++ own));
}
