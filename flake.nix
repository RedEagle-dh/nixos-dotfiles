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
    # Fremd-Taps kämen als weitere Inputs dazu (flake = false), siehe darwin/homebrew.nix
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      nix-darwin,
      ...
    }@inputs:
    let
      user = "dave";

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
      darwinConfigurations."MacBook-Pro-von-Dave" = nix-darwin.lib.darwinSystem {
        specialArgs = { inherit user inputs; };
        modules = [
          ./darwin
          home-manager.darwinModules.home-manager
          (homeManager ./home/darwin)
        ];
      };

      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit user; };
        modules = [
          ./configuration.nix
          home-manager.nixosModules.home-manager
          (homeManager ./home/linux.nix)
        ];
      };
    };
}
