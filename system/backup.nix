# system/backup.nix – tägliches Backup des Home-Verzeichnisses auf den Homelab (restic).
#
# restic speichert verschlüsselt und dedupliziert: Jedes Backup ist vollständig,
# überträgt aber nur, was sich geändert hat. Ältere Backups werden ausgedünnt
# (pruneOpts unten).
#
# Einmalig einrichten (vorher läuft der Dienst einfach nicht):
#   sudo mkdir -p /root/restic
#   sudo sh -c 'head -c 32 /dev/urandom | base64 > /root/restic/password'
#   sudo cat /root/restic/password      → in 1Password speichern! Ohne Passwort
#                                         sind die Backups nicht mehr lesbar.
#   sudo ssh-keygen -t ed25519 -N "" -C restic@nixos -f /root/restic/ssh_key
#   sudo cat /root/restic/ssh_key.pub   → auf dem Homelab in ~/.ssh/authorized_keys,
#     mit vorangestelltem  restrict,command="/usr/lib/openssh/sftp-server"
#     (der Key darf dann nur Dateien übertragen, keine Befehle ausführen)
#   sudo systemctl start restic-backups-homelab    erstes Backup, legt das Repository an
#
# Benutzen (sudo, weil das Passwort root gehört):
#   sudo restic-homelab snapshots                  alle Backups
#   sudo restic-homelab restore latest --target /tmp/restore --include /home/dave/Documents
#   sudo restic-homelab mount /mnt                 Backups als Ordner durchstöbern
#   systemctl status restic-backups-homelab        lief das letzte Backup durch?

{ user, ... }:

let
  dir = "/root/restic";
  homelab = "192.168.188.81"; # wie "homelab" in home/terminal/ssh.nix
in
{
  services.restic.backups.homelab = {
    initialize = true; # Repository beim ersten Lauf anlegen
    passwordFile = "${dir}/password";
    # Pfad relativ zum Home-Verzeichnis von dave auf dem Homelab
    repository = "sftp:${user}@${homelab}:backups/nixos";
    extraOptions = [
      "sftp.command='ssh ${user}@${homelab} -i ${dir}/ssh_key -o IdentitiesOnly=yes -s sftp'"
    ];

    paths = [ "/home/${user}" ];
    exclude = [
      # Lässt sich neu herunterladen oder erzeugen
      "/home/*/.cache"
      "/home/*/.local/share/Steam"
      "/home/*/.local/share/Trash"
      "/home/*/Games"
      "/home/*/.vscode/extensions"
      "/home/*/.npm"
      "/home/*/.bun/install/cache"
      "/home/*/.cargo/registry"
      "node_modules"
      ".direnv"
    ];
    extraBackupArgs = [ "--exclude-caches" ]; # Ordner mit CACHEDIR.TAG, z. B. Rust-Builds (target/)

    timerConfig = {
      OnCalendar = "daily";
      Persistent = true; # war der PC aus, beim nächsten Start nachholen
      RandomizedDelaySec = "1h";
    };
    pruneOpts = [
      "--keep-daily 7"
      "--keep-weekly 4"
      "--keep-monthly 12"
    ];
  };

  # Noch nicht eingerichtet (s. o.)? Dann überspringen statt mit Fehler abbrechen
  systemd.services.restic-backups-homelab.unitConfig.ConditionPathExists = "${dir}/password";

  # Host-Key des Homelabs, damit root ihm ohne Rückfrage vertraut
  programs.ssh.knownHosts.homelab = {
    hostNames = [
      "homelab"
      homelab
    ];
    publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGvUVcrdZjYIkadXvGN9CX5e+wVHnieRCe7O/zMsPKe4";
  };
}
