# Wie system/vpn.nix: Tailscale, NetBird, WireGuard – hier mit den Menüleisten-Apps der Hersteller,
# alle aus Homebrew. Die CLIs bleiben: tailscale/netbird up|down|status
{ pkgs, ... }:

{
  homebrew.casks = [
    # Tailscale als eigenständige App statt tailscaled: Sie bringt eine eigene Netzwerk-
    # Systemerweiterung mit, beide zusammen kämen sich bei Routen und DNS in die Quere. Beim ersten
    # Start Systemerweiterung und VPN-Konfiguration erlauben, "Launch at login" einschalten
    "tailscale-app"

    # Menüleisten-App mit Dienst: der Cask zieht die Formel netbird nach und richtet den Dienst
    # unter /Library/LaunchDaemons ein. Anmeldung und Einstellungen bleiben in /var/lib/netbird.
    # Autostart der App in ihren Einstellungen einschalten
    "netbirdio/tap/netbird-ui"
  ];

  homebrew.brews = [
    "wireguard-tools"
    "wireguard-go" # macOS hat kein WireGuard im Kernel
  ];

  # CLI der App, wie es Tailscales eigener Installer unter /usr/local/bin anlegt – der Cask tut es nicht
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "tailscale" ''
      exec /Applications/Tailscale.app/Contents/MacOS/Tailscale "$@"
    '')
  ];

  # WireGuard-Tunnel: Konfiguration nach /opt/homebrew/etc/wireguard/<name>.conf (root, 600), dann
  # `sudo wg-quick up <name>`
}
