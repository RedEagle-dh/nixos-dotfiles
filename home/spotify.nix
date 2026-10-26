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

  # Installiert Spotify mit – pkgs.spotify nicht zusätzlich installieren
  programs.spicetify = {
    enable = true;
    theme = spicePkgs.themes.comfy;

    customColorScheme = {
      text = c.text;
      subtext = c.subtle;
      main = c.base;
      main-elevated = c.surface;
      main-transition = c.base;
      highlight = c.overlay;
      highlight-elevated = c.highlightMed;
      sidebar = c.surface;
      player = c.surface;
      card = c.surface;
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
      shuffle
      fullAppDisplay
    ];
  };
}
