# home/spotify.nix – Spotify mit spicetify (github.com/Gerg-L/spicetify-nix):
# Theme "Comfy" in den Rosé-Pine-Farben aus ../theme.
#
# spicetify baut Theme und Erweiterungen fest in das Spotify-Paket ein. Darum
# färbt caelestia Spotify nicht mit (anders als Discord) – neue Farben gibt es
# nur über theme/default.nix und nhs.
#
# Alle Themes:        https://gerg-l.github.io/spicetify-nix/themes.html
# Alle Erweiterungen: https://gerg-l.github.io/spicetify-nix/extensions.html

{
  inputs,
  pkgs,
  theme,
  ...
}:

let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
  c = theme.colors;
in
{
  imports = [ inputs.spicetify-nix.homeManagerModules.spicetify ];

  # Installiert Spotify gleich mit – pkgs.spotify nicht zusätzlich installieren
  programs.spicetify = {
    enable = true;
    theme = spicePkgs.themes.comfy;

    customColorScheme = {
      text = c.text;
      subtext = c.subtle;
      main = c.base; # Inhalt
      main-elevated = c.surface; # Suchleiste, erhöhte Flächen
      main-transition = c.base;
      highlight = c.overlay; # Zeile unter der Maus
      highlight-elevated = c.highlightMed;
      sidebar = c.surface; # Bibliothek links
      player = c.surface; # Leiste unten
      card = c.surface; # Kontextmenüs, Karten
      shadow = c.base;
      selected-row = c.text;
      button = c.iris;
      button-active = c.rose;
      button-disabled = c.muted;
      tab-active = c.overlay;
      notification = c.iris;
      notification-error = c.love;
      misc = c.subtle;
      play-button = c.iris;
      play-button-active = c.rose;
      progress-fg = c.iris;
      progress-bg = c.highlightMed;
      heart = c.love;
      pagelink-active = c.iris;
      radio-btn-active = c.iris;
    };

    enabledExtensions = with spicePkgs.extensions; [
      shuffle # echtes Zufallsprinzip statt Spotifys "Smart Shuffle"
      fullAppDisplay # Vollbild-Ansicht mit großem Cover
    ];
  };
}
