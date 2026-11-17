{ ... }:

{
  networking.networkmanager.enable = true;
  # Firewall mit nftables statt iptables. Kam mit der Agent-Sandbox (Incus braucht es, die läuft
  # heute auf dem Homelab-Server) und bleibt: kein Wechsel zurück im laufenden Betrieb, Docker geht
  # mit beidem
  networking.nftables.enable = true;
  security.polkit.enable = true;

  services.gnome.gnome-keyring.enable = true;
  security.pam.services.login.enableGnomeKeyring = true;

  programs.dconf.enable = true;
  services.udisks2.enable = true;
  services.gvfs.enable = true;
  services.gnome.sushi.enable = true;
}
