# flake.nix – Einstiegspunkt der ganzen Konfiguration.
#
# Legt fest, welche Versionen von nixpkgs und Home Manager benutzt werden
# (die genauen Stände stehen in flake.lock), und baut daraus den Rechner "nixos".
#
# Aufbau des Repos:
#   configuration.nix   dieser Rechner (Hardware, Name, stateVersion)
#   system/             NixOS: ein Modul pro Thema (Sound, Login, NVIDIA …)
#   home/               Home Manager: alles im Home-Verzeichnis
#   theme/              Farben, Schriften, Hintergrundbild – für System und Home
#
# Anwenden:          nhs  (bzw. sudo nixos-rebuild switch)
# Aktualisieren:     nix flake update  →  danach nhs
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
    let
      # Benutzername – steht nur hier und wird an alle Module als `user` übergeben
      user = "dave";
    in
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit user; };
        modules = [
          ./configuration.nix

          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true; # gleiche Pakete & Einstellungen (z. B. allowUnfree) wie das System
              useUserPackages = true; # Programme landen im Benutzerprofil statt in ~/.nix-profile
              # Vorhandene Dateien nicht blockieren, sondern als *.hm-backup zur Seite legen
              backupFileExtension = "hm-backup";
              extraSpecialArgs = { inherit user; };
              users.${user} = import ./home;
            };
          }
        ];
      };
    };
}
