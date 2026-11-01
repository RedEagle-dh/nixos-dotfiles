# Desktop als T3-Code-Host auf Abruf: per Wake-on-LAN aufwecken und per SSH schlafen legen (Buttons
# in Home Assistant auf dem pi5). Der t3-Dienst startet ohne Login, erreichbar über t3.dave.haus
# (Caddy auf dem pi5). Den Dienst legt `t3 up --lan --no-connect` an (User-Unit t3code.service).
{ user, ... }:

let
  pi5 = "192.168.188.20";
  # Öffentlicher Schlüssel von Home Assistant (/var/lib/home-assistant/.ssh/desktop_suspend.pub auf dem pi5)
  haSuspendKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGWBV/vcQyMb9PQS2JOefSsRggiPWTnxyYuOIGYLxZMa home-assistant@nexus";
in
{
  # Netzwerkkarte reagiert auf Magic Packets, auch aus Suspend und Soft-Off.
  # Zusätzlich im BIOS: "Power on by PCI-E" an, ErP aus
  networking.interfaces.enp14s0.wakeOnLan.enable = true;

  # Opening port 3773 for caddy on pi5 only because of the t3.dave.haus domain
  networking.firewall.extraCommands = ''
    iptables -A nixos-fw -p tcp -s 192.168.188.20 --dport 3773 -j nixos-fw-accept
  '';
  networking.firewall.extraStopCommands = ''
    iptables -D nixos-fw -p tcp -s 192.168.188.20 --dport 3773 -j nixos-fw-accept || true
  '';

  users.users.${user} = {
    # User-Dienste starten beim Booten statt erst beim Login (und laufen nach Logout weiter)
    linger = true;
    # Nur vom pi5, nur `systemctl suspend` (restrict = keine Shell, kein Forwarding), siehe unten
    openssh.authorizedKeys.keys = [
      ''restrict,from="${pi5}",command="/run/current-system/sw/bin/systemctl suspend" ${haSuspendKey}''
    ];
  };

  # Der t3-Installer legt den Befehl nach ~/.local/bin
  environment.localBinInPath = true;

  # Schlafen legen aus Home Assistant: HA meldet sich per SSH mit dem Schlüssel oben an.
  # Suspend geht erst mit hardware.nvidia.powerManagement (nvidia.nix), sonst friert Hyprland ein
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
  };
  # Über SSH ist die Sitzung nicht "lokal aktiv", polkit würde nach dem Admin-Passwort fragen.
  # multiple-sessions: die Desktop-Sitzung läuft parallel zur SSH-Sitzung
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if ((action.id == "org.freedesktop.login1.suspend" ||
           action.id == "org.freedesktop.login1.suspend-multiple-sessions") &&
          subject.user == "${user}") {
        return polkit.Result.YES;
      }
    });
  '';
}
