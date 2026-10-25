# home/terminal/ssh.nix – SSH über den 1Password-Agent.
#   Der Private Key liegt nur in 1Password, hier steht nur der Public Key
#   (id_ed25519.pub). Er sagt ssh, welchen der Keys im Agent es anbieten soll.
#   Neuer Rechner? Auf allen Servern ist schon derselbe Key hinterlegt.

{ ... }:

{
  # ~/.ssh/id_ed25519.pub
  home.file.".ssh/id_ed25519.pub".source = ./id_ed25519.pub;

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false; # alte Home-Manager-Standardwerte nicht übernehmen

    # Optionen heißen wie in `man ssh_config`. "*" landet automatisch am Ende.
    settings = {
      pi5 = {
        HostName = "192.168.188.20";
        User = "dave";
      };
      homelab = {
        HostName = "192.168.188.81";
        User = "dave";
      };
      dns = {
        HostName = "192.168.188.2";
        User = "dave";
      };
      dns2 = {
        HostName = "192.168.188.3";
        User = "dave";
      };

      "*" = {
        IdentityAgent = "~/.1password/agent.sock";
        IdentityFile = "~/.ssh/id_ed25519.pub";
        IdentitiesOnly = true; # nur diesen Key anbieten, nicht alle aus 1Password
        ServerAliveInterval = 60; # Verbindung bei Leerlauf am Leben halten
        ServerAliveCountMax = 3;
      };
    };
  };
}
