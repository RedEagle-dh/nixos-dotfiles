{
  lib,
  pkgs,
  theme,
  ...
}:

let
  # Nur für Qt-Quick-Programme, den Rest färbt Kvantum. Rollen-Reihenfolge wie in qt6ct:
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
        text = "muted";
        iris = "highlightMed";
      }
    }
  '';

  qtctSettings = {
    Appearance = {
      style = "kvantum";
      custom_palette = true;
      color_scheme_path = "${qtPalette}";
      icon_theme = theme.icons.name;
      standard_dialogs = "xdgdesktopportal";
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
    colorScheme = "dark";
    theme = theme.gtk;
    iconTheme = theme.icons;
    font = {
      inherit (theme.fonts.ui) name package size;
    };
  };

  dconf.settings."org/gnome/desktop/interface" = {
    accent-color = "purple";
    monospace-font-name = "${theme.fonts.mono.name} ${toString theme.fonts.mono.size}";
  };

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
    x11.enable = true;
  };
}
