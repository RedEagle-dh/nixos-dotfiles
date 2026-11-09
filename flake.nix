# Neue Dateien erst mit `git add` hinzufügen – ein Flake sieht nur Dateien, die Git kennt.

{
  description = "NixOS-Konfiguration von David – Hyprland-Desktop und MacBook (nix-darwin)";

  inputs = {
    # Beim Wechsel auf stabil (z. B. "nixos-26.05") Home Manager auf "release-26.05" setzen.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    caelestia-shell = {
      url = "github:caelestia-dots/shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };

    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # ---- macOS

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Installiert Homebrew selbst, Version über flake.lock. Pakete regelt nix-darwins homebrew-Modul.
    # Fremd-Taps als weitere Inputs (flake = false), eingebunden in darwin/homebrew.nix
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    homebrew-hashicorp = {
      url = "github:hashicorp/homebrew-tap";
      flake = false;
    };

    homebrew-netbird = {
      url = "github:netbirdio/homebrew-tap";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      nix-darwin,
      ...
    }@inputs:
    let
      inherit (nixpkgs) lib;

      user = "dave";

      # Eigene Pakete aus pkgs/ in pkgs. Auf dem Mac nur für nhs (Überspringen), Programme kommen dort
      # aus Homebrew
      ownPackages = {
        nixpkgs.overlays = [ (import ./pkgs) ];
      };

      # Dieselben Pakete als Flake-Ausgabe, aus dem pkgs des Desktops: `nix build .#<name>`
      # (nhu prüft damit Updates, nhs findet darüber die Pakete außerhalb der Paketlisten)
      packagesOf =
        { pkgs, ... }:
        lib.filterAttrs (
          _: pkg: lib.isDerivation pkg && lib.meta.availableOn pkgs.stdenv.hostPlatform pkg
        ) (builtins.intersectAttrs (import ./pkgs pkgs pkgs) pkgs);

      # Auf beiden Systemen gleich: home/ ist gemeinsam, dazu der Teil fürs jeweilige System
      homeManager = platformModule: {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          backupFileExtension = "hm-backup";
          extraSpecialArgs = { inherit user inputs; };
          users.${user}.imports = [
            ./home
            platformModule
          ];
        };
      };
    in
    {
      formatter = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-darwin" ] (
        system: nixpkgs.legacyPackages.${system}.nixfmt-tree
      );

      # Name = LocalHostName (`scutil --get LocalHostName`), dann findet darwin-rebuild ihn ohne #…
      darwinConfigurations.elder = nix-darwin.lib.darwinSystem {
        specialArgs = { inherit user inputs; };
        modules = [
          ./darwin
          ownPackages
          home-manager.darwinModules.home-manager
          (homeManager ./home/darwin)
        ];
      };

      nixosConfigurations.baron = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit user; };
        modules = [
          ./configuration.nix
          ownPackages
          home-manager.nixosModules.home-manager
          (homeManager ./home/linux.nix)
        ];
      };

      packages.x86_64-linux = packagesOf self.nixosConfigurations.baron;
    };
}
