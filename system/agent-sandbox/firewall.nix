# Netz des Containers: ins Internet ja, ins Heimnetz nein (pi5, server, dns, dns2, Router, VPN).
# Einzige Ausnahme ist Forgejo per SSH über den pi5 (git.dave.haus:2222). HTTPS zum pi5 bleibt zu:
# Caddy behandelt alles aus dem LAN als vertrauenswürdig, und der Container käme mit der Adresse
# des Desktops dort an.
{ ... }:

let
  s = import ./settings.nix;
in
{
  # Incus auf NixOS geht nur mit nftables. Darum ist networking.firewall.extraCommands (iptables)
  # nicht mehr erlaubt, siehe t3-host.nix
  networking.nftables.enable = true;

  # Die NixOS-Firewall braucht für den Container nur DHCP und DNS (dnsmasq von Incus auf der Bridge)
  networking.firewall.interfaces.${s.bridge} = {
    allowedUDPPorts = [
      53
      67
    ];
    allowedTCPPorts = [ 53 ];
  };

  # Eigene Tabelle statt extraInputRules/extraForwardRules. In nftables ist ein drop endgültig, egal
  # in welcher Tabelle – auch wenn Incus oder Docker den Verkehr in ihren Tabellen erlauben.
  # Ein accept gilt dagegen nur für die eigene Kette, die anderen Tabellen prüfen trotzdem noch.
  networking.nftables.tables.agent-sandbox = {
    family = "inet";
    content = ''
      chain input {
        type filter hook input priority filter - 10; policy accept;

        # Vom Container zum Host nur DHCP und DNS. extraInputRules ginge nicht: die stehen hinter
        # den global offenen Ports (z. B. SSH)
        iifname "${s.bridge}" ct state established,related accept
        iifname "${s.bridge}" udp dport { 53, 67 } accept
        iifname "${s.bridge}" tcp dport 53 accept
        iifname "${s.bridge}" drop
      }

      chain forward {
        type filter hook forward priority filter - 10; policy accept;

        # Antworten auf erlaubte Verbindungen
        ct state established,related accept

        # T3 im Container: nur Caddy auf dem pi5 darf rein (kommt über :${toString s.t3HostPort})
        oifname "${s.bridge}" ip daddr ${s.containerIp} tcp dport ${toString s.t3Port} ip saddr != ${s.pi5} drop

        # Forgejo-SSH über den pi5, sonst nichts im Heim-, VPN- und Docker-Netz des Hosts
        iifname "${s.bridge}" ip daddr ${s.pi5} tcp dport ${toString s.forgejoSshPort} accept
        iifname "${s.bridge}" ip daddr { 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16, 100.64.0.0/10, 169.254.0.0/16 } drop
        iifname "${s.bridge}" meta nfproto ipv6 drop
      }
    '';
  };

  # Docker setzt die FORWARD-Policy sonst auf DROP, sobald es IP-Forwarding einschaltet. Dann käme
  # der Container nicht mehr ins Internet, Docker blockt auch fremden weitergeleiteten Verkehr
  virtualisation.docker.daemon.settings.ip-forward-no-drop = true;
}
