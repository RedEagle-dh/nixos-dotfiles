# system/storage.nix – Swap und Pflege des Dateisystems.

{ config, ... }:

{
  # Komprimierter Swap im RAM statt Swap-Partition: fängt Lastspitzen ab
  # (große Builds, LLM-Experimente), ohne dass das System einfriert.
  zramSwap.enable = true;

  # Prüft monatlich alle Btrfs-Dateisysteme auf Datenfehler. Schaltet sich nur
  # ein, wenn es überhaupt ein Btrfs-Dateisystem gibt.
  services.btrfs.autoScrub = {
    enable = builtins.any (fs: fs.fsType == "btrfs") (builtins.attrValues config.fileSystems);
    interval = "monthly";
  };
}
