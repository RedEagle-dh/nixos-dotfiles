{ user, ... }:

{
  virtualisation.docker.enable = true;
  hardware.nvidia-container-toolkit.enable = true;

  # Achtung: Die docker-Gruppe ist praktisch so mächtig wie root.
  users.users.${user}.extraGroups = [ "docker" ];
}
