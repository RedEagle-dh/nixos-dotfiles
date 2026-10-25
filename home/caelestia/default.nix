# home/caelestia/ – die caelestia-Shell (github.com/caelestia-dots/shell):
# Leiste links, Starter (Super antippen), Dashboard, Seitenleiste mit
# Benachrichtigungen, Sitzungsmenü, Lautstärke-Anzeige, Sperrbildschirm und
# Hintergrundbild und das Farbschema für Fensterrahmen, Terminal und GTK.
#
# Einstellungen: unten in settings (landen in ~/.config/caelestia/shell.json),
# alle Optionen: https://github.com/caelestia-dots/shell#example-configuration
# Hintergrund wechseln: im Starter ">wallpaper" tippen (Bilder aus ~/Pictures/Wallpapers).
#   Mit dem Farbschema "dynamic" färben sich dabei Shell, Fensterrahmen,
#   Terminal und GTK-Programme passend zum Bild.
# Farbschema wechseln: im Starter ">scheme" (fest, z. B. Rosé Pine) oder ">variant"
#   (Stil der Farben bei "dynamic"); ">mode" für hell/dunkel.

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
  themeDir = "${stateDir}/theme"; # ausgefüllte Farbvorlagen
in
{
  imports = [ inputs.caelestia-shell.homeManagerModules.default ];

  config = {
    programs.caelestia = {
      enable = true;
      cli.enable = true; # Befehl `caelestia` (Farbschema, Hintergrund, Screenshots …)

      settings = {
        general = {
          apps = {
            terminal = [ "kitty" ];
            audio = [ "pavucontrol" ];
            playback = [ "mpv" ];
            explorer = [ "nautilus" ];
          };
          # Sperren und Monitore aus übernimmt hypridle (hyprland/idle.nix);
          # gesperrt wird trotzdem mit dem Sperrbildschirm von caelestia
          idle = {
            lockBeforeSleep = false;
            timeouts = [ ];
          };
        };
      };

      # Was caelestia beim Farbwechsel mitfärbt: Hyprland-Rahmen
      # (hypr/scheme/current.lua, liest hyprland.lua) und offene Terminals.
      # Alles andere bleibt aus, weil caelestia sonst die von Nix verwalteten
      # Dateien überschreiben würde – GTK bekommt die Farben über die Vorlagen
      # unten, Qt (Kvantum) und fuzzel bleiben in Rosé Pine.
      cli.settings.theme =
        lib.genAttrs [
          "enableDiscord"
          "enableSpicetify"
          "enablePandora"
          "enableFuzzel"
          "enableBtop" # btop nutzt ohnehin die Terminalfarben
          "enableNvtop"
          "enableHtop"
          "enableGtk"
          "enableQt"
          "enableWarp"
          "enableChromium"
          "enableZed"
          "enableCava"
        ] (_: false)
        // {
          enableTerm = true;
          enableHypr = true;
        };
    };

    # GTK-Farben als Vorlagen: caelestia füllt sie bei jedem Farbwechsel aus
    # (nach ~/.local/state/caelestia/theme/), gtk.css bindet sie ein.
    # Offene GTK-Programme übernehmen neue Farben erst beim nächsten Start.
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

    # Neue Terminals starten gleich in den aktuellen Farben
    programs.zsh.initContent = lib.mkOrder 1400 ''
      [[ -r "${stateDir}/sequences.txt" ]] && cat "${stateDir}/sequences.txt"
    '';

    # Für die Auswahl: unser Hintergrundbild und das von caelestia. Eigene Bilder
    # einfach dazulegen – der Ordner ist ein normaler Ordner.
    home.file."Pictures/Wallpapers/rose-pine.png".source = theme.wallpaper;
    home.file."Pictures/Wallpapers/caelestia.webp".source =
      "${config.programs.caelestia.package}/share/caelestia-shell/assets/wallpaper.webp";

    # Beim ersten Mal: Hintergrundbild setzen und Farbschema "dynamic" (Farben
    # aus dem Hintergrundbild). Danach merkt sich caelestia beides selbst.
    home.activation.caelestiaDefaults = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      needScheme=""
      if [ ! -f "${themeDir}/gtk4.css" ]; then needScheme=1; fi
      if [ ! -f "${stateDir}/wallpaper/path.txt" ]; then
        run ${cli}/bin/caelestia wallpaper -f ${wallpaper} || true
      fi
      if [ -n "$needScheme" ]; then
        run ${cli}/bin/caelestia scheme set -n dynamic || true
      fi
    '';
  };
}
