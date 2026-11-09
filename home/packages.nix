# Pakete für Desktop und Mac aus einer Liste: unter Linux aus nixpkgs, auf dem Mac aus Homebrew.
# Auf dem Mac installiert Nix keine Programme, Home Manager schreibt dort nur die Konfiguration.
# darwin/homebrew.nix installiert, was in brew.formulas und brew.casks zusammenkommt
#
#   shared.tools.<nixpkgs-Attribut> = "<Homebrew-Formel>";   null = derselbe Name
#   shared.apps.<nixpkgs-Attribut>  = "<Homebrew-Cask>";
#   brew.formulas / brew.casks: nur auf dem Mac, ohne Gegenstück unter Linux
{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkOption types;
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
  cfg = config.shared;

  mapping =
    description:
    mkOption {
      type = types.attrsOf (types.nullOr types.str);
      default = { };
      inherit description;
    };
  names =
    description:
    mkOption {
      type = types.listOf types.str;
      default = [ ];
      inherit description;
    };

  brewNames = lib.mapAttrsToList (attr: brew: if brew == null then attr else brew);
  # "jetbrains.idea" → pkgs.jetbrains.idea
  fromNixpkgs =
    attrs: map (attr: lib.getAttrFromPath (lib.splitString "." attr) pkgs) (lib.attrNames attrs);
in
{
  options = {
    shared = {
      tools = mapping "Kommandozeilen-Werkzeuge: nixpkgs-Attribut = Homebrew-Formel (null: derselbe Name)";
      apps = mapping "Apps: nixpkgs-Attribut = Homebrew-Cask (null: derselbe Name)";
    };
    brew = {
      formulas = names "Homebrew-Formeln für den Mac";
      casks = names "Homebrew-Casks für den Mac";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf isDarwin {
      brew.formulas = brewNames cfg.tools;
      brew.casks = brewNames cfg.apps;
    })
    (lib.mkIf (!isDarwin) {
      home.packages = fromNixpkgs (cfg.tools // cfg.apps);
    })
  ];
}
