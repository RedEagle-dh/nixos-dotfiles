# SSH auf dem Mac – Hosts und Agent-Schlüssel in home/terminal/ssh.nix
{ config, ... }:

{
  # 1Password legt den Agent-Socket auf dem Mac in einen App-Group-Container. Der Link macht ihn unter
  # demselben Pfad erreichbar wie unter Linux (ssh.nix: IdentityAgent ~/.1password/agent.sock)
  home.file.".1password/agent.sock".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock";

  # Von OrbStack: `ssh orb` in dessen Linux-Maschinen. Muss vor allen Host-Blöcken stehen
  programs.ssh.includes = [ "~/.orbstack/ssh/config" ];
}
