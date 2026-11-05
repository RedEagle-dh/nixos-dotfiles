{ pkgs, user, ... }:

{
  # Jedes VPN trägt sein DNS pro Interface bei resolved ein, statt sich um /etc/resolv.conf zu streiten
  services.resolved.enable = true;

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
    extraSetFlags = [
      # NetBird nutzt wie Tailscale 100.64.0.0/10. Im Standardmodus verwirft Tailscale alles aus diesem
      # Netz, was nicht über tailscale0 kommt – NetBird ginge dann gar nicht
      "--netfilter-mode=nodivert"
      # Der VPN-Schalter in caelestia ruft tailscale up/down ohne sudo auf
      "--operator=${user}"
    ];
  };

  services.netbird = {
    enable = true;
    useRoutingFeatures = "client";
  };

  environment.systemPackages = [ pkgs.wireguard-tools ];
}
