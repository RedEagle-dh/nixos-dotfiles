# Wie system/vpn.nix: Tailscale, NetBird, WireGuard – jeweils der Daemon, ohne Menüleisten-App.
# Bedienung über tailscale/netbird up|down|status. pkgs.netbird-ui baut unter macOS nicht (webkitgtk)
{ pkgs, ... }:

{
  services.tailscale.enable = true;

  services.netbird.enable = true;

  environment.systemPackages = with pkgs; [
    wireguard-tools
    wireguard-go # macOS hat kein WireGuard im Kernel
  ];

  # WireGuard-Tunnel: networking.wg-quick.interfaces.<name> = { address; dns; privateKeyFile; peers; }.
  # Den Schlüssel als Datei außerhalb des Repos ablegen, z. B. /etc/wireguard/<name>.key (root, 600)
}
