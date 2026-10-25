# home/xdg.nix – Standard-Ordner und welches Programm welche Dateien öffnet.

{ ... }:

{
  # ~/Documents, ~/Downloads, ~/Pictures … (Screenshot-Ordner: screenshots.nix)
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications =
      let
        browser = "firefox.desktop";
        images = "org.gnome.Loupe.desktop";
        video = "mpv.desktop";
        text = "org.gnome.TextEditor.desktop";
        archives = "org.gnome.FileRoller.desktop";
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
        "application/zip" = archives;
        "application/x-tar" = archives;
      };
  };
}
