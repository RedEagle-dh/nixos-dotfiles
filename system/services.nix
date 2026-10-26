{ ... }:

{
  networking.networkmanager.enable = true;
  security.polkit.enable = true;

  services.gnome.gnome-keyring.enable = true;
  security.pam.services.login.enableGnomeKeyring = true;

  programs.dconf.enable = true;
  services.udisks2.enable = true;
  services.gvfs.enable = true;
  services.gnome.sushi.enable = true;
}
