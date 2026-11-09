# Werte, die mehrere Dateien der Agent-Sandbox brauchen – an einer Stelle statt abgeschrieben.
# Wird per `import ./settings.nix` geladen (wie inventory.nix im Homelab-Repo), kein Modul.
{
  container = "t3";
  bridge = "incusbr0";
  bridgeIp = "10.77.0.1";
  containerIp = "10.77.0.10";

  # pi5: Caddy (t3.dave.haus) und der Forgejo-SSH-Proxy (git.dave.haus:2222)
  pi5 = (import ../../inventory.nix).nexus.ip;
  forgejoSshPort = 2222;

  # T3 lauscht im Container auf t3Port, der Desktop reicht t3HostPort dorthin weiter. Eigener Port,
  # damit der alte t3-Dienst (3773, t3-host.nix) bis zum Umstellen parallel laufen kann
  t3Port = 3773;
  t3HostPort = 3774;

  # Dürfen per SSH als dev in den Container (Zed vom Mac, container/files.nix). "Daves Key" aus
  # 1Password, derselbe, mit dem der Mac auf den Desktop kommt
  sshKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMZLL7Fxqp3qXS04JkBDvHzdV98LgpL/LQ9ln6yh2rmx Daves Key"
  ];

  # ssh-agent des git-broker auf dem Host und sein Gegenstück im Container. /srv gibt es in jedem
  # Ubuntu-Image schon – das Verzeichnis muss existieren, bevor Incus dort den Socket anlegt
  hostAgentSocket = "/run/git-broker/ssh-agent.sock";
  containerAgentSocket = "/srv/ssh-agent.sock";
  keyFile = "/var/lib/git-broker/agent-git";

  # Wer im Container committet (wie home/terminal/git.nix). Die Adresse muss auf GitHub verifiziert
  # sein, sonst zeigt GitHub die Signatur nicht als "Verified"
  git = {
    name = "David Hermann";
    email = "redeagle.private@gmail.com";
  };

  # Obergrenzen (cgroup-Limits), nichts davon wird reserviert. Desktop: 16 Threads, 31 GiB.
  # cpu = alle Threads: bei Volllast teilen sich Container und user.slice die CPU per cgroup-Gewicht
  # (je 100), der Desktop bleibt bedienbar. memory lässt dem Host ~7 GiB
  limits = {
    memory = "24GiB";
    cpu = "16";
  };
}
