{
  config,
  lib,
  inputs,
  theme,
  ...
}:

let
  cli = config.programs.caelestia.cli.package;
  wallpaper = "${config.home.homeDirectory}/Pictures/Wallpapers/rose-pine.png";
  stateDir = "${config.xdg.stateHome}/caelestia";
  themeDir = "${stateDir}/theme";
in
{
  imports = [ inputs.caelestia-shell.homeManagerModules.default ];

  config = {
    programs.caelestia = {
      enable = true;
      cli.enable = true;

      settings = {
        general = {
          apps = {
            terminal = [ "kitty" ];
            audio = [ "pavucontrol" ];
            playback = [ "mpv" ];
            explorer = [ "nautilus" ];
          };
          # Übernimmt hypridle – sonst würde doppelt gesperrt
          idle = {
            lockBeforeSleep = false;
            timeouts = [ ];
          };
        };
      };

      # Aus, weil caelestia sonst von Nix verwaltete Dateien überschreibt (GTK und fuzzel haben eigene Vorlagen)
      cli.settings.theme =
        lib.genAttrs [
          "enableSpicetify"
          "enablePandora"
          "enableFuzzel"
          "enableBtop"
          "enableNvtop"
          "enableHtop"
          "enableGtk"
          "enableQt"
          "enableWarp"
          "enableChromium"
          "enableCava"
        ] (_: false)
        // {
          enableTerm = true;
          enableHypr = true;
          enableDiscord = true;
          enableZed = true;
        };
    };

    xdg.configFile =
      let
        m3 = name: "#{{ ${name}.hex }}";
        css = import ./gtk-css.nix { inherit lib; } {
          accent = m3 "primary";
          onAccent = m3 "onPrimary";
          error = m3 "error";
          onError = m3 "onError";
          success = m3 "term2";
          warning = m3 "term3";
          onStatus = m3 "surface";
          window = m3 "surface";
          view = m3 "surface";
          fg = m3 "onSurface";
          headerbar = m3 "surfaceContainer";
          sidebar = m3 "surfaceContainer";
          secondarySidebar = m3 "surfaceContainerLow";
          card = m3 "surfaceContainerLow";
          popover = m3 "surfaceContainerHigh";
          border = m3 "outlineVariant";
        };
      in
      {
        "caelestia/templates/gtk3.css".text = css.gtk3;
        "caelestia/templates/gtk4.css".text = css.gtk4;
      };

    gtk = {
      gtk3.extraCss = ''@import url("file://${themeDir}/gtk3.css");'';
      gtk4.extraCss = ''@import url("file://${themeDir}/gtk4.css");'';
    };

    programs.zsh.initContent = lib.mkOrder 1400 ''
      [[ -r "${stateDir}/sequences.txt" ]] && cat "${stateDir}/sequences.txt"
    '';

    home.file."Pictures/Wallpapers/rose-pine.png".source = theme.wallpaper;
    home.file."Pictures/Wallpapers/caelestia.webp".source =
      "${config.programs.caelestia.package}/share/caelestia-shell/assets/wallpaper.webp";

    # Eine neu hinzugefügte Vorlage füllt caelestia erst beim nächsten Farbwechsel aus – daher hier neu anwenden
    home.activation.caelestiaDefaults = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      needScheme=""
      if [ ! -f "${themeDir}/gtk4.css" ]; then needScheme=1; fi
      if [ ! -f "${stateDir}/wallpaper/path.txt" ]; then
        run ${cli}/bin/caelestia wallpaper -f ${wallpaper} || true
      fi
      if [ -n "$needScheme" ]; then
        run ${cli}/bin/caelestia scheme set -n dynamic || true
      elif [ ! -f "${config.xdg.configHome}/vesktop/themes/caelestia.theme.css" ] \
        || [ ! -f "${themeDir}/fuzzel.ini" ] \
        || [ ! -f "${config.xdg.configHome}/zed/themes/caelestia.json" ]; then
        run ${cli}/bin/caelestia scheme set -m "$(${cli}/bin/caelestia scheme get -m)" || true
      fi
    '';
  };
}
