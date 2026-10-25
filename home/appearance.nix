# home/appearance.nix – Aussehen der Programme: GTK-Theme, Icons, Mauszeiger.
# Welche es sind, steht in theme/default.nix.

{ theme, ... }:

{
  gtk = {
    enable = true;
    colorScheme = "dark"; # GTK-4-/libadwaita-Programme dunkel
    theme = theme.gtk; # GTK-3-Programme passend dazu
    iconTheme = theme.icons;
    font = {
      inherit (theme.fonts.ui) name package size;
    };
  };

  # Akzentfarbe (Schalter, Auswahl) für libadwaita-Programme wie Nautilus
  dconf.settings."org/gnome/desktop/interface" = {
    accent-color = "purple";
    monospace-font-name = "${theme.fonts.mono.name} ${toString theme.fonts.mono.size}";
  };

  home.pointerCursor = {
    enable = true;
    inherit (theme.cursor) name package size;
    gtk.enable = true;
    x11.enable = true; # für ältere X11-Programme (XWayland)
  };

  # Hyprland selbst nutzt die schärfere hyprcursor-Variante (siehe hyprland/hyprland.lua)
  xdg.dataFile."icons/${theme.cursor.hyprcursor}".source =
    "${theme.cursor.hyprcursorPackage}/share/icons/${theme.cursor.hyprcursor}";
}
