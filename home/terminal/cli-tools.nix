# home/terminal/cli-tools.nix – Werkzeuge für die Kommandozeile.
#   z ordner   springt in oft benutzte Ordner (zoxide)
#   ls, ll …   mit Icons und Git-Status (eza)
#   bat        wie cat, mit Syntaxfarben
#   Strg+R     Verlauf durchsuchen (fzf)
#   btop       Systemmonitor (auch Strg+Umschalt+Esc)
#   direnv     lädt in Projektordnern mit .envrc die passende Umgebung
#              (z. B. "use flake" → Werkzeuge aus dem devShell des Projekts);
#              einmal pro Ordner freigeben: direnv allow
#   , befehl   startet ein Programm, ohne es zu installieren (z. B. ", cowsay hi")
#              Unbekannter Befehl? Die Shell nennt das Paket, das ihn enthält.
#   nix-locate sucht, welches Paket eine Datei enthält (nix-locate bin/ffmpeg)

{ inputs, theme, ... }:

let
  hex = name: "#${theme.colors.${name}}";
in
{
  # Fertige Paket-Datenbank, wöchentlich neu gebaut – kommt mit nix flake update
  imports = [ inputs.nix-index-database.homeModules.nix-index ];
  programs.nix-index.enable = true; # Hinweis bei unbekannten Befehlen
  programs.nix-index-database.comma.enable = true;

  programs.zoxide.enable = true;

  programs.direnv = {
    enable = true; # bindet sich automatisch in zsh ein
    nix-direnv.enable = true; # merkt sich Nix-Umgebungen → schneller, übersteht Aufräumen
    silent = true; # keine Meldungen beim Betreten eines Ordners
  };

  programs.eza = {
    enable = true;
    icons = "auto";
    git = true;
  };

  programs.bat = {
    enable = true;
    config.theme = "ansi"; # nutzt die Terminalfarben → passt zur Palette
  };

  programs.fzf = {
    enable = true;
    colors = {
      fg = hex "subtle";
      "fg+" = hex "text";
      bg = "-1";
      "bg+" = hex "overlay";
      hl = hex "rose";
      "hl+" = hex "rose";
      border = hex "highlightMed";
      header = hex "pine";
      gutter = "-1";
      spinner = hex "gold";
      info = hex "foam";
      pointer = hex "iris";
      marker = hex "love";
      prompt = hex "subtle";
    };
  };

  programs.btop = {
    enable = true;
    settings = {
      color_theme = "TTY"; # nutzt die Terminalfarben
      theme_background = false;
      rounded_corners = true;
    };
  };
}
