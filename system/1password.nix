# Muss ins System, nicht in Home Manager: legt Gruppe, setuid-Helfer und Polkit-Regel an.

{
  config,
  lib,
  user,
  ...
}:

{
  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ user ];
  };

  # Zen steht nicht auf der eingebauten Liste – sonst verbindet sich die Browser-Erweiterung nicht mit der App
  environment.etc."1password/custom_allowed_browsers" = {
    text = "zen\nzen-bin\n";
    mode = "0644";
  };

  # Ohne laufendes 1Password gibt es keinen SSH-Agent → ssh: "Permission denied (publickey)"
  systemd.user.services."1password" = {
    description = "1Password im Hintergrund (SSH-Agent, Git-Signatur)";
    partOf = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = "${lib.getExe config.programs._1password-gui.package} --silent";
      Restart = "on-failure";
      RestartSec = 2;
    };
  };
}
