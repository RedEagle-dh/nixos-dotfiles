# home/appearance.nix – Aussehen der Programme: GTK- und Qt-Theme, Icons, Mauszeiger.
# Welche es sind, steht in theme/default.nix. Die Farben der GTK-Programme kommen
# aus dem Farbschema von caelestia (home/caelestia), Qt bleibt in Rosé Pine.

{ lib, pkgs, theme, ... }:

let
  # Qt-Farbpalette (qt5ct/qt6ct-Format). Kvantum färbt normale Qt-Programme
  # schon selbst; die Palette braucht es für Qt-Quick-Programme wie den
  # Passwort-Dialog (hyprpolkitagent). Reihenfolge der Rollen wie in qt6ct:
  # WindowText, Button, Light, Midlight, Dark, Mid, Text, BrightText,
  # ButtonText, Base, Window, Shadow, Highlight, HighlightedText, Link,
  # LinkVisited, AlternateBase, NoRole, ToolTipBase, ToolTipText, PlaceholderText
  qtColors =
    overrides:
    lib.concatMapStringsSep ", " (name: "#ff${theme.colors.${overrides.${name} or name}}") [
      "text"
      "overlay"
      "highlightHigh"
      "highlightMed"
      "base"
      "highlightLow"
      "text"
      "text"
      "text"
      "base"
      "surface"
      "base"
      "iris"
      "base"
      "foam"
      "rose"
      "highlightLow"
      "base"
      "overlay"
      "text"
      "muted"
    ];
  qtPalette = pkgs.writeText "rose-pine.conf" ''
    [ColorScheme]
    active_colors=${qtColors { }}
    inactive_colors=${qtColors { }}
    disabled_colors=${
      qtColors {
        # Deaktiviert: Text gedämpft, Auswahl ohne Akzent
        text = "muted";
        iris = "highlightMed";
      }
    }
  '';

  # qt5ct/qt6ct-Einstellungen – daraus lesen Qt-Programme Stil, Farben, Icons und Schriften
  qtctSettings = {
    Appearance = {
      style = "kvantum";
      custom_palette = true;
      color_scheme_path = "${qtPalette}";
      icon_theme = theme.icons.name;
      standard_dialogs = "xdgdesktopportal"; # Dateidialoge wie bei GTK-Programmen
    };
    Fonts = {
      general = ''"${theme.fonts.ui.name},${toString theme.fonts.ui.size}"'';
      fixed = ''"${theme.fonts.mono.name},${toString theme.fonts.mono.size}"'';
    };
  };
in
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

  dconf.settings."org/gnome/desktop/interface" = {
    accent-color = "purple"; # für Programme, die die Akzentfarbe nur hier nachschauen
    monospace-font-name = "${theme.fonts.mono.name} ${toString theme.fonts.mono.size}";
  };

  # Qt-Programme (z. B. VLC, qBittorrent, OBS) im selben Look wie GTK
  qt = {
    enable = true;
    platformTheme.name = "qtct";
    style.name = "kvantum";
    kvantum = {
      enable = true;
      themes = [ theme.qt.package ];
      settings.General.theme = theme.qt.name;
    };
    qt5ctSettings = qtctSettings;
    qt6ctSettings = qtctSettings;
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
