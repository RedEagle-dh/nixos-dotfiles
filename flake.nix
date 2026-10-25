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
#                    Oder: Jeden Montag öffnet GitHub einen PR mit neuem flake.lock
#                    (.github/workflows/update.yml) – mergen, git pull, nhs.
#                    Bricht danach etwas: im Bootmenü die vorherige Generation
#                    wählen oder `git checkout flake.lock` und erneut nhs.
#
# Wichtig: Neue Dateien erst mit `git add` hinzufügen – ein Flake sieht nur
# Dateien, die Git kennt.

{
  description = "NixOS-Konfiguration von David – Hyprland-Desktop";

  inputs = {
    # Rolling Release: neueste Pakete, die die NixOS-Tests bestanden haben.
    # Zurück auf eine stabile Version: z. B. "nixos-26.05" (dann Home Manager
    # unten auf "release-26.05").
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Home Manager verwaltet alles im Home-Verzeichnis (~/.config usw.).
    # Der Hauptzweig gehört zu nixos-unstable.
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs"; # dieselbe nixpkgs-Version wie das System
    };

    # caelestia-Shell (Leiste, Starter, Benachrichtigungen, Sperrbildschirm …).
    # Eingebunden in home/caelestia.
    caelestia-shell = {
      url = "github:caelestia-dots/shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Spotify mit spicetify (Theme & Erweiterungen). Eingebunden in home/spotify.nix.
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Fertige Datenbank "welches Paket enthält welchen Befehl" – für `, befehl`
    # und den Hinweis bei unbekannten Befehlen. Eingebunden in home/terminal/cli-tools.nix.
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, home-manager, ... }@inputs:
    let
      # Benutzername – steht nur hier und wird an alle Module als `user` übergeben
      user = "dave";
      system = "x86_64-linux";
    in
    {
      # `nix fmt` formatiert alle .nix-Dateien im Repo einheitlich (nixfmt).
      # Die GitHub Action prüft das bei jedem Push (.github/workflows/check.yml).
      formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt-tree;

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
              extraSpecialArgs = { inherit user inputs; }; # inputs: für home/caelestia und home/spotify.nix
              users.${user} = import ./home;
            };
          }
        ];
      };
    };
}
