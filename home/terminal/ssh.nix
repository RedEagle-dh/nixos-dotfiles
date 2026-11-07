{ lib, pkgs, ... }:

let
  # Leer = 1Password-Standard (alle Keys aus dem Privat-Tresor); sonst nur diese, in dieser Reihenfolge
  agentKeys = [
    { item = "5poti6gc3lkawn5v6cjwg3pkde"; }
    { item = "3lrymnkbhaovbsc6fuofstxhyi"; }
    { item = "ctvgjaz7hs2e5lvbdx7d4px74u"; }
  ];
in
{
  xdg.configFile."1Password/ssh/agent.toml" = lib.mkIf (agentKeys != [ ]) {
    source = (pkgs.formats.toml { }).generate "agent.toml" { ssh-keys = agentKeys; };
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    # Name und IP: `ssh 192.168.188.20` greift genauso wie `ssh nexus`. Alle Schlüssel aus 1Password
    settings = {
      "nexus 192.168.188.20" = {
        HostName = "192.168.188.20";
        User = "dave";
      };
      "inhibitor 192.168.188.81" = {
        HostName = "192.168.188.81";
        User = "dave";
      };
      "blue 192.168.188.2" = {
        HostName = "192.168.188.2";
        User = "dave";
      };
      "red 192.168.188.3" = {
        HostName = "192.168.188.3";
        User = "dave";
      };
      "airsoft 192.168.188.73" = {
        HostName = "192.168.188.73";
        User = "dave";
      };
      "ucg 192.168.188.1" = {
        HostName = "192.168.188.1";
        User = "root";
      };
      "baron 192.168.188.35" = {
        HostName = "192.168.188.35";
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
