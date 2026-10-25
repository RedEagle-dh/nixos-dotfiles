# system/nix.nix – Nix selbst: Flakes, unfreie Pakete, Aufräumen, nh.

{ ... }:

{
  # Unfreie Pakete erlauben (NVIDIA-Treiber, VS Code, 1Password, Claude Code …)
  nixpkgs.config.allowUnfree = true;

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ]; # dieses Repo ist ein Flake
    auto-optimise-store = true; # identische Dateien im /nix/store zusammenlegen
  };

  # Jede Woche alte Generationen (älter als 14 Tage) löschen
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  # nh: angenehmeres nixos-rebuild (Aliase nhs/nhb in home/terminal/zsh.nix).
  # Aufräumen macht nix.gc oben – nh.clean deshalb nicht einschalten.
  programs.nh = {
    enable = true;
    flake = "/etc/nixos";
  };
}
