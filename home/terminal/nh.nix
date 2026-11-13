{
  config,
  osConfig,
  lib,
  pkgs,
  ...
}:

let
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
  # Linux: programs.nh in system/nix.nix
  flake = if isDarwin then "${config.home.homeDirectory}/developer/nix-dotfiles" else "/etc/nixos";

  # nh … switch, das Pakete überspringt, deren Bau scheitert
  nh-switch = pkgs.writeShellApplication {
    name = "nh-switch";
    runtimeInputs = [ pkgs.jq ];
    text = ''
      flake=${lib.escapeShellArg flake}
      platform=${if isDarwin then "darwin" else "os"}
      # Fest aus der Konfiguration: macOS hängt bei einem Namenskonflikt im Netz "-2" an den
      # LocalHostName, dann gäbe es darwinConfigurations.elder-2 nicht
      darwin_host=${lib.escapeShellArg (osConfig.networking.localHostName or "")}
      analysis=${./nh-switch.nix}
    ''
    + builtins.readFile ./nh-switch.sh;
  };
in
{
  programs.nh = lib.mkIf isDarwin {
    enable = true;
    inherit flake;
  };

  home.shellAliases = {
    nhs = "${lib.getExe nh-switch} && exec $SHELL";
    # Flake-Inputs und pkgs/ aktualisieren, Übersicht am Ende
    nhu = "${flake}/pkgs/update.sh";
  }
  # macOS kennt keinen Boot-Eintrag für die nächste Generation
  // lib.optionalAttrs (!isDarwin) {
    nhb = "nh os boot";
  };
}
