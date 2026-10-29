{ lib, pkgs, ... }:

let
  # Leer = 1Password-Standard (alle Keys aus dem Privat-Tresor); sonst nur diese, in dieser Reihenfolge
  agentKeys = [
    { item = "5poti6gc3lkawn5v6cjwg3pkde"; }
  ];
in
{
  xdg.configFile."1Password/ssh/agent.toml" = lib.mkIf (agentKeys != [ ]) {
    source = (pkgs.formats.toml { }).generate "agent.toml" { ssh-keys = agentKeys; };
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

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
      git-local = {
        HostName = "192.168.188.81";
        Port = 2222;

      };

      "*" = {
        IdentityAgent = "~/.1password/agent.sock";
        ServerAliveInterval = 60;
        ServerAliveCountMax = 3;
      };
    };
  };
}
