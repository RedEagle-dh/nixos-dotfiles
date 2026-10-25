# system/docker.nix – Docker mit Zugriff auf die Grafikkarte.

{ user, ... }:

{
  virtualisation.docker.enable = true;
  hardware.nvidia-container-toolkit.enable = true; # GPU im Container: --device nvidia.com/gpu=all

  # docker ohne sudo. Achtung: Die Gruppe ist praktisch so mächtig wie root.
  users.users.${user}.extraGroups = [ "docker" ];
}
