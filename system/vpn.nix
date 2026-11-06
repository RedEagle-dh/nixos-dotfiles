{
  config,
  pkgs,
  user,
  ...
}:

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
    # NixOS legt config.json vor NetBird an, NetBird hält sie für eine alte Konfiguration und schaltet
    # seinen SSH-Server ein. Dann darf nur root die Management-URL ändern (netbird up -m …)
    clients.default.config.ServerSSHAllowed = false;
  };

  # config.d landet nur beim Start des Dienstes in config.json, ohne Neustart bliebe eine Änderung wirkungslos
  systemd.services.netbird.restartTriggers = [
    config.environment.etc."netbird/config.d/50-nixos.json".source
  ];

  services.nordvpn.enable = true;
  # Ohne die Gruppe kommt die nordvpn-CLI nicht an den Socket von nordvpnd
  users.users.${user}.extraGroups = [ "nordvpn" ];

  environment.systemPackages = [ pkgs.wireguard-tools ];
}
