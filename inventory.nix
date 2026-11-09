# Alle Geräte im Heimnetz an einer Stelle: ändert sich eine IP, nur hier anpassen.
# Wird per `import` geladen (wie system/agent-sandbox/settings.nix), kein Modul.
# user = SSH-Login, sonst dave (home/terminal/ssh.nix)
{
  ucg = {
    ip = "192.168.188.1";
    user = "root";
  };
  blue.ip = "192.168.188.2";
  red.ip = "192.168.188.3";
  # pi5: Home Assistant, Caddy (t3.dave.haus) und der Forgejo-SSH-Proxy (git.dave.haus:2222)
  nexus.ip = "192.168.188.20";
  baron.ip = "192.168.188.35";
  airsoft.ip = "192.168.188.73";
  # Homelab-Server: Backups (system/backup.nix) und Forgejo
  inhibitor.ip = "192.168.188.81";
}
