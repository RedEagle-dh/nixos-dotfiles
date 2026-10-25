# home/appearance.nix – Aussehen der Programme: GTK- und Qt-Theme, Icons, Mauszeiger.
# Welche es sind, steht in theme/default.nix; die Farben kommen aus der Palette dort.

{ lib, pkgs, theme, ... }:

let
  c = name: "#${theme.colors.${name}}";

  # GTK/libadwaita-Farben (Namen: https://gnome.pages.gitlab.gnome.org/libadwaita/doc/main/css-variables.html).
  # Ohne sie sind GTK-Programme (Nautilus, Loupe, pavucontrol …) GNOME-grau,
  # und eine Akzentfarbe bekommen sie unter Hyprland auch nicht.
  shade = "rgba(0, 0, 0, 0.36)";
  gtkColors = {
    accent_color = c "iris";
    accent_bg_color = c "iris";
    accent_fg_color = c "base";
    destructive_color = c "love";
    destructive_bg_color = c "love";
    destructive_fg_color = c "base";
    success_color = c "foam";
    success_bg_color = c "pine";
    success_fg_color = c "text";
    warning_color = c "gold";
    warning_bg_color = c "gold";
    warning_fg_color = c "base";
    error_color = c "love";
    error_bg_color = c "love";
    error_fg_color = c "base";

    window_bg_color = c "base";
    window_fg_color = c "text";
    view_bg_color = c "base";
    view_fg_color = c "text";
    headerbar_bg_color = c "surface";
    headerbar_fg_color = c "text";
    headerbar_border_color = c "highlightMed";
    headerbar_backdrop_color = c "base";
    headerbar_shade_color = shade;
    headerbar_darker_shade_color = "rgba(0, 0, 0, 0.9)";
    sidebar_bg_color = c "surface";
    sidebar_fg_color = c "text";
    sidebar_backdrop_color = c "base";
    sidebar_border_color = c "highlightLow";
    sidebar_shade_color = shade;
    secondary_sidebar_bg_color = c "highlightLow";
    secondary_sidebar_fg_color = c "text";
    secondary_sidebar_backdrop_color = c "base";
    secondary_sidebar_border_color = c "highlightLow";
    secondary_sidebar_shade_color = shade;
    card_bg_color = c "surface";
    card_fg_color = c "text";
    card_shade_color = shade;
    dialog_bg_color = c "surface";
    dialog_fg_color = c "text";
    popover_bg_color = c "overlay";
    popover_fg_color = c "text";
    popover_shade_color = shade;
    thumbnail_bg_color = c "overlay";
    thumbnail_fg_color = c "text";
    shade_color = shade;
    scrollbar_outline_color = "rgba(0, 0, 0, 0.5)";
  };

  # GTK 3 (adw-gtk3) kennt nur die alten benannten Farben
  definedColors = lib.concatStrings (
    lib.mapAttrsToList (name: value: "@define-color ${name} ${value};\n") gtkColors
  );
  # libadwaita (GTK 4) liest seit 1.6 CSS-Variablen: accent_bg_color → --accent-bg-color
  cssVariables = lib.concatStrings (
    lib.mapAttrsToList (
      name: value: "  --${builtins.replaceStrings [ "_" ] [ "-" ] name}: ${value};\n"
    ) gtkColors
  );

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
    gtk3.extraCss = definedColors;
    gtk4.extraCss = definedColors + ":root {\n${cssVariables}}\n";
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
