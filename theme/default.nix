{ pkgs }:

let
  colors = {
    base = "191724";
    surface = "1f1d2e";
    overlay = "26233a";
    muted = "6e6a86";
    subtle = "908caa";
    text = "e0def4";
    love = "eb6f92";
    gold = "f6c177";
    rose = "ebbcba";
    pine = "31748f";
    foam = "9ccfd8";
    iris = "c4a7e7";
    highlightLow = "21202e";
    highlightMed = "403d52";
    highlightHigh = "524f67";
  };

  wallpaper = import ./wallpaper.nix { inherit pkgs colors; };

  bootWallpaper = import ./wallpaper.nix {
    inherit pkgs colors;
    width = 2560;
    height = 1440;
  };

  nixosLogo = pkgs.runCommand "nixos-logo.svg" { } ''
    sed -e 's/#415e9a/#${colors.iris}/I; s/#4a6baf/#${colors.iris}/I; s/#5277c3/#${colors.iris}/I' \
        -e 's/#699ad7/#${colors.rose}/I; s/#7eb1dd/#${colors.rose}/I; s/#7ebae4/#${colors.rose}/I' \
        ${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg > $out
  '';
in
{
  inherit colors;

  fonts = {
    ui = {
      name = "Inter";
      package = pkgs.inter;
      size = 11;
    };
    mono = {
      name = "JetBrainsMono Nerd Font";
      package = pkgs.nerd-fonts.jetbrains-mono;
      size = 12;
    };
  };

  cursor = {
    name = "Bibata-Modern-Ice";
    package = pkgs.bibata-cursors;
    size = 24;
  };

  icons = {
    name = "Papirus-Dark";
    package = pkgs.papirus-icon-theme.override { color = "violet"; };
  };

  gtk = {
    name = "adw-gtk3-dark";
    package = pkgs.adw-gtk3;
  };

  qt = {
    name = "rose-pine-iris";
    package = pkgs.rose-pine-kvantum;
  };

  inherit wallpaper bootWallpaper;

  refind = import ./refind.nix {
    inherit pkgs colors nixosLogo;
    wallpaper = bootWallpaper;
  };

  plymouth = import ./plymouth.nix {
    inherit pkgs colors nixosLogo;
    wallpaper = bootWallpaper;
  };
}
