# flake.nix – Einstiegspunkt der ganzen Konfiguration.
#
# Legt fest, welche Versionen von nixpkgs und Home Manager benutzt werden
# (die genauen Stände stehen in flake.lock), und baut daraus den Rechner "nixos".
#
# Anwenden (im Ordner dieses Repos):   sudo nixos-rebuild switch --flake .
# Alles aktualisieren:                 nix flake update  →  danach wie oben
#
# Wichtig: Neue Dateien erst mit `git add` hinzufügen – ein Flake sieht nur
# Dateien, die Git kennt.

{
  description = "NixOS-Konfiguration von David – Hyprland-Desktop";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    # Home Manager verwaltet alles im Home-Verzeichnis (~/.config usw.)
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs"; # dieselbe nixpkgs-Version wie das System
    };
  };

  outputs =
    { nixpkgs, home-manager, ... }:
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        modules = [
          ./configuration.nix

          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true; # gleiche Pakete & Einstellungen (z. B. allowUnfree) wie das System
              useUserPackages = true; # Programme landen im Benutzerprofil statt in ~/.nix-profile
              # Vorhandene Dateien (z. B. die alte hyprland.lua) nicht blockieren,
              # sondern als *.hm-backup zur Seite legen
              backupFileExtension = "hm-backup";
              users.dave = import ./home;
            };
          }
        ];
      };
    };
}
