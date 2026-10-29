# Einmalig einrichten (vorher läuft der Dienst nicht):
#   sudo mkdir -p /root/restic
#   sudo sh -c 'head -c 32 /dev/urandom | base64 > /root/restic/password'
#   sudo cat /root/restic/password  → in 1Password speichern, ohne Passwort sind die Backups verloren
#   sudo ssh-keygen -t ed25519 -N "" -C restic@nixos -f /root/restic/ssh_key
#   sudo cat /root/restic/ssh_key.pub → auf dem Homelab in ~/.ssh/authorized_keys,
#     mit vorangestelltem  restrict,command="/usr/lib/openssh/sftp-server"
#   sudo systemctl start restic-backups-homelab

{ user, ... }:

let
  dir = "/root/restic";
  homelab = "192.168.188.81";
in
{
  services.restic.backups.homelab = {
    initialize = true;
    passwordFile = "${dir}/password";
    repository = "sftp:${user}@${homelab}:backups/nixos";
    extraOptions = [
      "sftp.command='ssh ${user}@${homelab} -i ${dir}/ssh_key -o IdentitiesOnly=yes -s sftp'"
    ];

    paths = [ "/home/${user}" ];
    exclude = [
      "/home/*/.cache"
      "/home/*/.local/share/Steam"
      "/home/*/.local/share/Trash"
      "/home/*/Games"
      "/home/*/.config/heroic/tools"
      "/home/*/.local/share/umu"
      "/home/*/.local/share/zed/extensions"
      "/home/*/.npm"
      "/home/*/.bun/install/cache"
      "/home/*/.cargo/registry"
      "node_modules"
      ".direnv"
    ];
    extraBackupArgs = [ "--exclude-caches" ];

    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
      RandomizedDelaySec = "1h";
    };
    pruneOpts = [
      "--keep-daily 7"
      "--keep-weekly 4"
      "--keep-monthly 12"
    ];
  };

  systemd.services.restic-backups-homelab.unitConfig.ConditionPathExists = "${dir}/password";

  programs.ssh.knownHosts.homelab = {
    hostNames = [
      "homelab"
      homelab
    ];
    publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGvUVcrdZjYIkadXvGN9CX5e+wVHnieRCe7O/zMsPKe4";
  };
}
