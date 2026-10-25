# home/default.nix – Home Manager: alles, was im Home-Verzeichnis von dave liegt.
#
# Aufteilung:
#   hyprland.nix  Fenster, Tastenkürzel, Animationen, Sperrbildschirm, Hintergrund
#   waybar.nix    Statusleiste oben
#   menus.nix     App-Starter, Benachrichtigungen und kleine Helfer (Power-Menü,
#                 Zwischenablage, Screenshots, Lautstärke-Anzeige)
#   terminal.nix  Kitty und die Shell
#
# Farben, Schriften & Co. kommen aus ../theme – dort ändern, nicht hier.

{ config, pkgs, ... }:

let
  theme = import ../theme { inherit pkgs; };
in
{
  imports = [
    ./hyprland.nix
    ./waybar.nix
    ./menus.nix
    ./terminal.nix
  ];

  home.username = "dave";
  home.homeDirectory = "/home/dave";

  # Wie system.stateVersion: beim ersten Einrichten festgelegt, nicht ändern.
  home.stateVersion = "26.05";

  home.packages = with pkgs; [
    # Programme, die zum Desktop gehören
    loupe # Bildbetrachter
    papers # PDF-Betrachter
    mpv # Videos
    gnome-text-editor # einfacher Texteditor
    file-roller # Archive (zip, tar …)
    pavucontrol # Lautstärke & Audiogeräte (Klick auf das Lautsprecher-Icon)
    playerctl # Medientasten
  ];

  programs.claude-code.enable = true;

  # ───────────────────────── Aussehen der Programme ─────────────────────────
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
    inherit (theme.cursor) name package size;
    gtk.enable = true;
    x11.enable = true; # für ältere X11-Programme (XWayland)
  };
  # Hyprland selbst nutzt die schärfere hyprcursor-Variante (siehe hypr/hyprland.lua)
  xdg.dataFile."icons/${theme.cursor.hyprcursor}".source =
    "${theme.cursor.hyprcursorPackage}/share/icons/${theme.cursor.hyprcursor}";

  # ───────────────────────── Ordner & Standardprogramme ─────────────────────────
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    extraConfig.SCREENSHOTS = "${config.home.homeDirectory}/Pictures/Screenshots";
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications =
      let
        browser = "firefox.desktop";
        images = "org.gnome.Loupe.desktop";
        video = "mpv.desktop";
        text = "org.gnome.TextEditor.desktop";
      in
      {
        "inode/directory" = "org.gnome.Nautilus.desktop";
        "text/html" = browser;
        "x-scheme-handler/http" = browser;
        "x-scheme-handler/https" = browser;
        "application/pdf" = "org.gnome.Papers.desktop";
        "text/plain" = text;
        "application/json" = text;
        "image/png" = images;
        "image/jpeg" = images;
        "image/webp" = images;
        "image/gif" = images;
        "image/svg+xml" = images;
        "video/mp4" = video;
        "video/webm" = video;
        "video/x-matroska" = video;
        "audio/mpeg" = video;
        "audio/flac" = video;
        "application/zip" = "org.gnome.FileRoller.desktop";
        "application/x-tar" = "org.gnome.FileRoller.desktop";
      };
  };
}
