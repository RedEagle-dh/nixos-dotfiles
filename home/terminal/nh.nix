{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
  # Linux: programs.nh in system/nix.nix
  flake = if isDarwin then "${config.home.homeDirectory}/developer/nix-dotfiles" else "/etc/nixos";
in
{
  programs.nh = lib.mkIf isDarwin {
    enable = true;
    inherit flake;
  };

  home.shellAliases = {
    nhs = "nh ${if isDarwin then "darwin" else "os"} switch && exec $SHELL";
    # gh-Token gegen das Rate-Limit der GitHub-API (anonym 60 Anfragen pro Stunde)
    nhu = ''(t=$(gh auth token 2>/dev/null); cd ${flake} && GITHUB_TOKEN="$t" ./pkgs/update.sh && NIX_CONFIG="''${t:+access-tokens = github.com=$t}" nix flake update)'';
  }
  # macOS kennt keinen Boot-Eintrag für die nächste Generation
  // lib.optionalAttrs (!isDarwin) {
    nhb = "nh os boot";
  };
}
