{
  config,
  lib,
  pkgs,
  user,
  ...
}:

{
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  programs.hyprlock.enable = true;

  # hyprlock ist zugleich der Login – sein Passwort entsperrt den Schlüsselbund
  security.pam.services.hyprlock.enableGnomeKeyring = true;

  security.soteria.enable = true;

  # Soteria braucht XDG_SESSION_ID, uwsm gibt sie nicht an systemd-Dienste weiter
  systemd.user.services.polkit-soteria.serviceConfig.ExecStart = lib.mkForce (
    pkgs.writeShellScript "soteria-session" ''
      export XDG_SESSION_ID=$(${pkgs.systemd}/bin/loginctl show-user "$USER" -p Display --value)
      exec ${lib.getExe config.security.soteria.package}
    ''
  );

  # Nach einem polkitd-Neustart meldet sich der Agent nicht wieder an –
  # dann fragt 1Password nach seinem Passwort statt nach dem Systempasswort
  systemd.services.polkit.serviceConfig.ExecStartPost = [
    "-${pkgs.systemd}/bin/systemctl --user --machine=${user}@ --no-block try-restart polkit-soteria.service"
  ];
}
