# system/storage.nix – Swap, Kompression, Snapshots und Pflege des Dateisystems.
#
# Snapshots von /home (snapper): stündlich ein Abbild, ältere werden
# automatisch ausgedünnt. Versehentlich gelöschte oder kaputte Datei zurückholen:
#   snapper -c home list                         welche Snapshots gibt es
#   /home/.snapshots/<Nr>/snapshot/dave/…        dort liegt der alte Stand, einfach zurückkopieren
#   snapper -c home status <Nr>..0               was hat sich seitdem geändert
# Ordner, die selbst ein Btrfs-Subvolume sind, landen nicht in den Snapshots –
# gut für große, wiederherstellbare Daten wie Spiele (siehe unten).

{ user, ... }:

{
  # Komprimierter Swap im RAM statt Swap-Partition: fängt Lastspitzen ab
  # (große Builds, LLM-Experimente), ohne dass das System einfriert.
  zramSwap.enable = true;

  # Alle drei liegen auf demselben Btrfs (siehe hardware-configuration.nix);
  # die Optionen werden dort angehängt.
  #   compress=zstd  komprimiert beim Schreiben – /nix schrumpft etwa auf die Hälfte.
  #                  Gilt nur für neu geschriebene Daten.
  #   noatime        kein Schreibzugriff bei jedem Lesen einer Datei
  fileSystems =
    let
      options = [
        "compress=zstd"
        "noatime"
      ];
    in
    {
      "/".options = options;
      "/home".options = options;
      "/nix".options = options;
    };

  # Prüft monatlich das Dateisystem auf Datenfehler
  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
  };

  services.snapper = {
    persistentTimer = true; # verpasste Snapshots nach dem Einschalten nachholen
    configs.home = {
      SUBVOLUME = "/home";
      ALLOW_USERS = [ user ]; # snapper ohne sudo, Snapshots lesen
      SYNC_ACL = true;
      TIMELINE_CREATE = true;
      TIMELINE_CLEANUP = true;
      # So viele Snapshots bleiben jeweils erhalten
      TIMELINE_LIMIT_HOURLY = 10;
      TIMELINE_LIMIT_DAILY = 7;
      TIMELINE_LIMIT_WEEKLY = 4;
      TIMELINE_LIMIT_MONTHLY = 3;
      TIMELINE_LIMIT_YEARLY = 0;
    };
  };

  # snapper legt seine Snapshots in /home/.snapshots ab, das selbst ein
  # Subvolume sein muss ("v" = Subvolume anlegen, falls es fehlt)
  systemd.tmpfiles.rules = [ "v /home/.snapshots 0750 root root -" ];

  # Spiele aus den Snapshots heraushalten (einmalig von Hand, Steam vorher beenden):
  #   mv ~/.local/share/Steam ~/.local/share/Steam.alt
  #   btrfs subvolume create ~/.local/share/Steam
  #   cp -a --reflink=always ~/.local/share/Steam.alt/. ~/.local/share/Steam/ && rm -rf ~/.local/share/Steam.alt
  # Dasselbe geht für ~/Games (Heroic) und ~/.cache.
}
