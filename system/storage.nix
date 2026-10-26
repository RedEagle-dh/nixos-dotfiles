{ user, ... }:

{
  zramSwap.enable = true;

  # compress=zstd gilt nur für neu geschriebene Daten
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

  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
  };

  services.snapper = {
    persistentTimer = true;
    configs.home = {
      SUBVOLUME = "/home";
      ALLOW_USERS = [ user ];
      SYNC_ACL = true;
      TIMELINE_CREATE = true;
      TIMELINE_CLEANUP = true;
      TIMELINE_LIMIT_HOURLY = 10;
      TIMELINE_LIMIT_DAILY = 7;
      TIMELINE_LIMIT_WEEKLY = 4;
      TIMELINE_LIMIT_MONTHLY = 3;
      TIMELINE_LIMIT_YEARLY = 0;
    };
  };

  # snapper braucht /home/.snapshots als eigenes Subvolume ("v")
  systemd.tmpfiles.rules = [ "v /home/.snapshots 0750 root root -" ];
}
