# Alle Geräte im Heimnetz an einer Stelle: ändert sich eine IP, nur hier anpassen.
# Wird per `import` geladen, kein Modul.
# Nodes im Servernetz 10.1.20.0/24, Desktop im 10.1.10.0/24 (wie inventory.nix im Homelab-Repo).
# user = SSH-Login, sonst dave (home/terminal/ssh.nix)
{
  ucg = {
    ip = "10.1.10.1";
    user = "root";
  };
  blue.ip = "10.1.20.2";
  red.ip = "10.1.20.3";
  # pi5: Home Assistant, Caddy (t3.dave.haus) und der Forgejo-SSH-Proxy (git.dave.haus:2222)
  nexus.ip = "10.1.20.5";
  baron.ip = "10.1.10.10";
  airsoft.ip = "192.168.188.73";
  # Homelab-Server: Backups (system/backup.nix) und Forgejo
  inhibitor.ip = "10.1.20.10";
}
