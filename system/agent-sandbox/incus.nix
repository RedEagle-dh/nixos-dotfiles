# Incus mit allem, was der Container "t3" braucht. Netz, Speicher und Profil kommen per Preseed:
# NixOS führt beim Start `incus admin init --preseed` aus, legt fehlende Teile an und gleicht
# bestehende ab – löscht aber nie etwas. Den Container selbst legt einmalig `incus launch` an
# (siehe default.nix), Preseed kennt keine Instanzen.
{
  lib,
  pkgs,
  user,
  ...
}:

let
  s = import ./settings.nix;
  files = import ./container/files.nix { inherit lib pkgs s; };
in
{
  virtualisation.incus = {
    enable = true;

    preseed = {
      networks = [
        {
          name = s.bridge;
          type = "bridge";
          config = {
            "ipv4.address" = "${s.bridgeIp}/24";
            "ipv4.nat" = "true";
            # Kein IPv6: sonst bräuchte jede Regel in firewall.nix ein IPv6-Gegenstück
            "ipv6.address" = "none";
          };
        }
      ];

      storage_pools = [
        {
          name = "default";
          driver = "dir";
          config.source = "/var/lib/incus/storage-pools/default";
        }
      ];

      profiles = [
        {
          name = "agent";
          description = "T3 Code und seine Agents";
          config = {
            "boot.autostart" = "true";
            "limits.memory" = s.limits.memory;
            "limits.cpu" = s.limits.cpu;

            # Docker im Container. Unkritisch: root im Container ist auf dem Host ein
            # unprivilegierter Nutzer, und Geheimnisse liegen dort keine
            "security.nesting" = "true";
            "security.syscalls.intercept.mknod" = "true";
            "security.syscalls.intercept.setxattr" = "true";

            # Läuft nur beim allerersten Start eines Containers mit diesem Profil
            "cloud-init.user-data" = import ./container/cloud-init.nix { inherit lib; };
          };

          devices = {
            root = {
              type = "disk";
              path = "/";
              pool = "default";
            };

            # Feste Adresse, damit firewall.nix den Container gezielt ansprechen kann
            eth0 = {
              type = "nic";
              name = "eth0";
              network = s.bridge;
              "ipv4.address" = s.containerIp;
            };

            # Dateien und Skripte aus container/files.nix, schreibgeschützt. Nach einem Rebuild zeigt
            # das Device auf den neuen Stand; im Container dann `sudo provision-agent`
            files = {
              type = "disk";
              source = "${files}";
              path = "/opt/agent-sandbox";
              readonly = "true";
            };

            # ssh-agent des Hosts im Container. bind = instance: der Socket entsteht im Container,
            # jede Verbindung darauf öffnet Incus auf dem Host zum echten ssh-agent. Der Schlüssel
            # verlässt den Host nie
            ssh-agent = {
              type = "proxy";
              bind = "instance";
              listen = "unix:${s.containerAgentSocket}";
              connect = "unix:${s.hostAgentSocket}";
              uid = "1000"; # dev im Container
              gid = "1000";
              mode = "0660";
            };

            # T3 von außen: <desktop>:3774 → Container:3773. nat = true leitet per DNAT weiter statt
            # über einen Proxy-Prozess – T3 sieht so die echte Quelle (Caddy) statt 127.0.0.1
            t3 = {
              type = "proxy";
              listen = "tcp:0.0.0.0:${toString s.t3HostPort}";
              connect = "tcp:${s.containerIp}:${toString s.t3Port}";
              nat = "true";
            };
          };
        }
      ];
    };
  };

  # `incus` ohne sudo. Achtung: incus-admin ist wie die docker-Gruppe praktisch root
  users.users.${user}.extraGroups = [ "incus-admin" ];
}
