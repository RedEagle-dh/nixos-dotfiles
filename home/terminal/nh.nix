{ ... }:

{
  home.shellAliases = {
    nhb = "nh os boot";
    nhs = "nh os switch && exec $SHELL";
    nhu = "(cd /etc/nixos && ./pkgs/update.sh && nix flake update)";
  };
}
