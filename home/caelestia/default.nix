{
  config,
  lib,
  pkgs,
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

      # Ersetzt caelestias VPN-Teil: der kann nur ein VPN gleichzeitig, und seine Liste landet in der
      # schreibgeschützten shell.json. Die eigene Liste liegt in ~/.config/caelestia/vpn.json
      package =
        inputs.caelestia-shell.packages.${pkgs.stdenv.hostPlatform.system}.with-cli.overrideAttrs
          (old: {
            patches = (old.patches or [ ]) ++ [ ./vpn/vpn.patch ];
            postPatch = (old.postPatch or "") + ''
              cp ${./vpn/Vpns.qml} services/Vpns.qml
              cp ${./vpn/VpnRow.qml} components/VpnRow.qml
              cp ${./vpn/VpnToggles.qml} modules/utilities/cards/VpnToggles.qml
              cp ${./vpn/VpnSection.qml} modules/nexus/pages/VpnSection.qml
              cp ${./vpn/VpnEditPage.qml} modules/nexus/pages/network/VpnEditPage.qml
            '';
          });

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
        # Kein Ruhezustand möglich (nur zram, kein Swap auf der Platte → CanHibernate = "na"):
        # der Knopf im Session-Menü und auf dem Sperrbildschirm legt den PC stattdessen schlafen.
        # Sperren beim Schlafen übernimmt hypridle (before_sleep_cmd)
        session = {
          commands.hibernate = [
            "systemctl"
            "suspend"
          ];
          icons.hibernate = "bedtime";
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
        # Dieselben Farben wie sequences.txt (gen_sequences in caelestia/utils/theme.py), damit ein neues
        # kitty-Fenster gleich im aktuellen Schema startet, statt erst mit den festen Farben aus kitty.nix
        "caelestia/templates/kitty.conf".text = ''
          foreground ${m3 "onSurface"}
          background ${m3 "surface"}
          cursor ${m3 "secondary"}
          selection_background ${m3 "secondary"}
          ${
            lib.concatMapStrings (i: "color${toString i} ${m3 "term${toString i}"}\n") (lib.range 0 15)
          }color16 ${m3 "primary"}
          color17 ${m3 "secondary"}
          color18 ${m3 "tertiary"}
        '';
      };

    # Fehlt die Datei noch, überspringt kitty sie nur mit einer Log-Zeile (globinclude ginge nur relativ
    # zu ~/.config/kitty); caelestiaDefaults unten legt sie an
    programs.kitty.extraConfig = ''
      include ${themeDir}/kitty.conf
    '';

    gtk = {
      gtk3.extraCss = ''@import url("file://${themeDir}/gtk3.css");'';
      gtk4.extraCss = ''@import url("file://${themeDir}/gtk4.css");'';
    };

    # Ganz vorn (vor compinit und den Plugins), damit Farben und fastfetch sofort erscheinen
    programs.zsh.initContent = lib.mkOrder 400 ''
      [[ -r "${stateDir}/sequences.txt" ]] && command cat "${stateDir}/sequences.txt"
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
      elif [ ! -f "${config.xdg.configHome}/Equicord/themes/caelestia.theme.css" ] \
        || [ ! -f "${themeDir}/fuzzel.ini" ] \
        || [ ! -f "${themeDir}/kitty.conf" ] \
        || [ ! -f "${config.xdg.configHome}/zed/themes/caelestia.json" ]; then
        run ${cli}/bin/caelestia scheme set -m "$(${cli}/bin/caelestia scheme get -m)" || true
      fi
    '';
  };
}
