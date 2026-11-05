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
    nhu = "(cd ${flake} && ./pkgs/update.sh && nix flake update)";
  }
  # macOS kennt keinen Boot-Eintrag für die nächste Generation
  // lib.optionalAttrs (!isDarwin) {
    nhb = "nh os boot";
  };
}
