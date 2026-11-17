{ lib, pkgs, ... }:

let
  inventory = import ../../inventory.nix;

  # Leer = 1Password-Standard (alle Keys aus dem Privat-Tresor); sonst nur diese, in dieser Reihenfolge
  agentKeys = [
    { item = "5poti6gc3lkawn5v6cjwg3pkde"; }
    { item = "3lrymnkbhaovbsc6fuofstxhyi"; }
    { item = "ctvgjaz7hs2e5lvbdx7d4px74u"; }
  ];
in
{
  xdg.configFile."1Password/ssh/agent.toml" = lib.mkIf (agentKeys != [ ]) {
    source = (pkgs.formats.toml { }).generate "agent.toml" { ssh-keys = agentKeys; };
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    # Ein Block pro Gerät aus inventory.nix. Name und IP: `ssh 10.1.20.5` greift genauso wie
    # `ssh nexus`. Alle Schlüssel aus 1Password, der Agent wird mitgenommen – außer aufs Gateway, dort
    # ist man root auf fremder Firmware
    settings =
      lib.mapAttrs' (
        name: node:
        lib.nameValuePair "${name} ${node.ip}" {
          HostName = node.ip;
          User = node.user or "dave";
          ForwardAgent = name != "ucg";
        }
      ) inventory
      // {
        git-local = {
          HostName = inventory.inhibitor.ip;
          Port = 2222;
        };

        # T3-Container auf dem Homelab-Server (Homelab-Repo, hosts/server/services/agent-sandbox, dort
        # auch die IP), für Zed: `zed ssh://t3/<pfad>`. t3.local ist das Ziel, das T3 bei "Open in Zed"
        # meldet. Der Container hängt per NAT hinter dem Server, also über ihn springen. Nur dieser
        # Rechner authentifiziert sich, ProxyJump leitet keinen Agent weiter
        "t3 t3.local" = {
          HostName = "10.77.0.10";
          User = "dev";
          ProxyJump = "inhibitor";
        };

        # In einer SSH-Sitzung den weitergeleiteten Agent nehmen statt des lokalen 1Password.
        # Muss vor "*" stehen, weil der erste IdentityAgent gewinnt
        forwarded-agent = lib.hm.dag.entryBefore [ "*" ] {
          header = ''Match exec "test -n \"$SSH_CONNECTION\" -a -S \"$SSH_AUTH_SOCK\""'';
          IdentityAgent = "SSH_AUTH_SOCK";
        };

        "*" = {
          IdentityAgent = "~/.1password/agent.sock";
          ServerAliveInterval = 60;
          ServerAliveCountMax = 3;
        };
      };
  };
}
