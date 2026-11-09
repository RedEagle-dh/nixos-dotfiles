# Wie system/vpn.nix: Tailscale, NetBird, WireGuard – hier mit den Menüleisten-Apps der Hersteller.
# Die CLIs bleiben: tailscale/netbird up|down|status
{ lib, pkgs, ... }:

{
  # Tailscale als eigenständige App (tailscale-gui) statt tailscaled: Sie bringt eine eigene
  # Netzwerk-Systemerweiterung mit, beide zusammen kämen sich bei Routen und DNS in die Quere.
  # Systemerweiterungen lässt macOS nur aus /Applications zu, und Tailscale erwartet genau
  # /Applications/Tailscale.app – darum dorthin kopiert wie 1Password, nicht nach "Nix Apps".
  # Beim ersten Start Systemerweiterung und VPN-Konfiguration erlauben, "Launch at login" einschalten.
  # Updates kommen über nhu (pkgs/update.sh), ein Update aus der App heraus nähme der nächste Rebuild zurück
  system.activationScripts.applications.text = lib.mkAfter ''
    install -o root -g wheel -m0555 -d /Applications/Tailscale.app
    ${lib.getExe pkgs.rsync} --checksum --copy-unsafe-links --archive --delete --chmod=-w \
      --no-group --no-owner \
      ${pkgs.tailscale-gui}/Applications/Tailscale.app/ /Applications/Tailscale.app
  '';

  # NetBird: App und Dienst aus dem offiziellen Release (pkgs/netbird-darwin.nix). Die App landet
  # wie in apps.nix unter /Applications/Nix Apps. Anmeldung und Einstellungen bleiben in
  # /var/lib/netbird. Autostart der App in ihren Einstellungen einschalten
  services.netbird = {
    enable = true;
    package = pkgs.netbird-app;
  };

  environment.systemPackages = with pkgs; [
    # CLI der App, wie es Tailscales eigener Installer unter /usr/local/bin anlegt
    (writeShellScriptBin "tailscale" ''
      exec /Applications/Tailscale.app/Contents/MacOS/Tailscale "$@"
    '')

    wireguard-tools
    wireguard-go # macOS hat kein WireGuard im Kernel
  ];

  # WireGuard-Tunnel: networking.wg-quick.interfaces.<name> = { address; dns; privateKeyFile; peers; }.
  # Den Schlüssel als Datei außerhalb des Repos ablegen, z. B. /etc/wireguard/<name>.key (root, 600)
}
