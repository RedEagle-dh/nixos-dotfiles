# Netz des Containers: er erreicht Internet und Heimnetz wie jedes andere Gerät im LAN (mit der
# Adresse des Desktops, NAT). Geschützt werden die Nodes nicht über das Netz, sondern über fehlende
# Zugangsdaten: der Container hat keinen SSH-Schlüssel für pi5, server, dns oder dns2, nur den
# Git-Schlüssel (git-broker.nix), und der ist nur bei GitHub und Forgejo hinterlegt.
# Was über Caddy aus dem LAN erreichbar ist (*.dave.haus), schützt nur der Login der jeweiligen App.
{ ... }:

let
  s = import ./settings.nix;
in
{
  # Incus auf NixOS geht nur mit nftables. Darum ist networking.firewall.extraCommands (iptables)
  # nicht mehr erlaubt, siehe t3-host.nix
  networking.nftables.enable = true;

  # DHCP und DNS für den Container (dnsmasq von Incus auf der Bridge). Alle anderen Ports des
  # Desktops gelten für den Container wie für jedes Gerät im LAN
  networking.firewall.interfaces.${s.bridge} = {
    allowedUDPPorts = [
      53
      67
    ];
    allowedTCPPorts = [ 53 ];
  };

  # Bleibt als einzige Regel: Schutz für T3, nicht gegen die Agents. T3 im Container ist per
  # Weiterleitung über :${toString s.t3HostPort} erreichbar, und sein einziges Schloss ist der
  # Pairing-Code. Darum darf nur Caddy auf dem pi5 rein (t3.dave.haus).
  # Eigene Tabelle: in nftables ist ein drop endgültig, egal was Incus oder Docker erlauben
  networking.nftables.tables.agent-sandbox = {
    family = "inet";
    content = ''
      chain forward {
        type filter hook forward priority filter - 10; policy accept;
        ct state established,related accept
        oifname "${s.bridge}" ip daddr ${s.containerIp} tcp dport ${toString s.t3Port} ip saddr != ${s.pi5} drop
      }
    '';
  };

  # Docker setzt die FORWARD-Policy sonst auf DROP, sobald es IP-Forwarding einschaltet. Dann käme
  # der Container nicht mehr ins Internet, Docker blockt auch fremden weitergeleiteten Verkehr
  virtualisation.docker.daemon.settings.ip-forward-no-drop = true;
}
