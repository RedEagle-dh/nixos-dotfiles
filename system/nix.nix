# system/nix.nix – Nix selbst: Flakes, unfreie Pakete, Aufräumen, nh.

{ ... }:

{
  # Unfreie Pakete erlauben (NVIDIA-Treiber, VS Code, 1Password, Claude Code …)
  nixpkgs.config.allowUnfree = true;

  # dieses Repo ist ein Flake
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Keine Kanäle (nix-channel): Paketstände kommen allein aus flake.lock.
  # `nix-shell -p` und `nix run nixpkgs#…` nutzen trotzdem dasselbe nixpkgs.
  nix.channel.enable = false;

  # Der eingebaute Hinweis "Befehl xy ist in Paket …" braucht Kanäle – den
  # übernimmt nix-index (home/terminal/cli-tools.nix)
  programs.command-not-found.enable = false;

  # Identische Dateien im /nix/store zusammenlegen – einmal pro Woche im
  # Hintergrund statt bei jedem Build
  nix.optimise.automatic = true;

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
