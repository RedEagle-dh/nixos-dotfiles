# Homebrew nur als Ausweg: hier steht nur, wofür es keinen Nix-Weg gibt – weder in nixpkgs für
# aarch64-darwin noch als Flake. Gibt es ein Modul (nix-darwin, Home Manager), dann das nehmen,
# sonst das Paket. Auch Apps mit Systemerweiterung gehen über Nix (Karabiner, 1Password, Tailscale …)
# Verfügbarkeit prüfen: search.nixos.org, Plattform aarch64-darwin, oder
#   nix eval nixpkgs#legacyPackages.aarch64-darwin.<name>.meta.platforms
# Vorsicht: Pakete ohne Plattformangabe gelten überall als verfügbar, sind aber oft Linux-Builds
# (z. B. steam) – im Zweifel src im Paket ansehen
{
  config,
  lib,
  inputs,
  user,
  ...
}:

{
  imports = [ inputs.nix-homebrew.darwinModules.nix-homebrew ];

  nix-homebrew = {
    enable = true;
    inherit user;

    # Übernimmt die bestehende Installation unter /opt/homebrew, installierte Pakete bleiben.
    # Einmalig vorher Library/Taps beiseitelegen, sonst bricht die Aktivierung ab (siehe unten: Taps)
    autoMigrate = true;

    # Taps nur aus Flake-Inputs, Stand über flake.lock – `brew tap` geht nicht mehr. Derzeit keine nötig,
    # homebrew/core und homebrew/cask kommen über Homebrews API. Neuer Tap: Input in flake.nix
    # (flake = false) und hier z. B. "user/homebrew-repo" = inputs.homebrew-repo;
    mutableTaps = false;
    taps = { };

    # Sonst setzt `brew shellenv` /opt/homebrew/bin vor die Nix-Pfade
    enableZshIntegration = false;
  };

  # Hinter den Nix-Profilen, vor /usr/bin: Programme aus Casks bleiben erreichbar, Nix gewinnt.
  # `brew` selbst liegt als Starter in /run/current-system/sw/bin
  environment.systemPath = lib.mkOrder 1100 [ "${config.homebrew.prefix}/bin" ];

  homebrew = {
    enable = true;

    onActivation = {
      # Vorerst "none": die CLI-Werkzeuge kommen noch aus brew, bis sie in Nix stehen.
      # Danach "uninstall" – nie "zap": das löscht bei Casks auch App-Daten unter ~/Library,
      # und die nach Nix umgezogenen Apps (Chrome, Zed, …) benutzen dieselben Daten weiter
      cleanup = "none";

      # Bei jedem nhs veraltete Casks, Formeln und App-Store-Apps von unten aktualisieren. Was neu ist,
      # weiß brew erst nach `brew update` – das läuft in nhu (pkgs/update.sh). autoUpdate hier bliebe
      # wirkungslos: nix-homebrew setzt bei festen Taps immer HOMEBREW_NO_AUTO_UPDATE.
      # Casks, die sich selbst aktualisieren (auto_updates), lässt brew dabei aus – die halten sich selbst
      # aktuell. Nicht erfasst: brew-Pakete, die nicht unten stehen (`brew upgrade` von Hand)
      upgrade = true;
    };

    # brew kennt Taps ohne "homebrew-": aus "user/homebrew-repo" wird "user/repo"
    taps = map (builtins.replaceStrings [ "/homebrew-" ] [ "/" ]) (
      builtins.attrNames config.nix-homebrew.taps
    );

    # Unter Linux aus nixpkgs (home/terminal/dev-tools.nix)
    brews = [
      "librealsense" # pkgs.librealsense hängt an v4l-utils, das es nur für Linux gibt
      "u-boot-tools" # mkimage – ubootTools baut nixpkgs nur für Linux
    ];

    # Casks aus Fremd-Taps voll qualifiziert ("user/repo/cask"): nix-darwin vertraut dann nur dem Cask,
    # nicht dem ganzen Tap.
    # Eine schon von Hand installierte App bricht `brew bundle` ab ("already an App at …"). --adopt
    # scheitert an macOS' App-Verwaltungsschutz – stattdessen die App löschen und frisch per Cask
    # installieren; Einstellungen unter ~/Library bleiben. Vorher prüfen, ob der Cask dieselbe App ist
    # Nicht hier: Compositor – der Cask "compositor" ist eine andere App (com.microlarge) als die
    # installierte (com.wonderassembly), für die gibt es keinen Cask
    casks = [
      "arduino-ide" # pkgs.arduino-ide nur für Linux
      "claude"
      "figma"
      "geolibre"
      "keyboardcleantool"
      "linear"
      # pkgs.teams verliert beim Entpacken Microsofts Signatur – ohne die verweigert die Sandbox
      # Anmeldung und Daten, Teams lädt endlos – und hinkt über ein Jahr hinterher
      "microsoft-teams"
      "nordvpn"
      "openscreen" # pkgs.openscreen ist ein anderes Projekt
      "openwhispr"
      "raspberry-pi-imager" # pkgs.rpi-imager nur für Linux
      "termius" # pkgs.termius nur für Linux
      "ungoogled-chromium" # nixpkgs baut Chromium nur für Linux, dort home/browsers.nix
      "vibe-island"
      "vlc" # pkgs.vlc nur für Linux
    ];

    # Mac App Store, IDs über `mas list` bzw. `mas search <name>`. Braucht eine Anmeldung im App Store.
    # Nur Installation – was hier verschwindet, deinstalliert brew bundle nicht.
    # Nicht hier: WireGuard (networking.wg-quick). GeoGebra bleibt: pkgs.geogebra6 ist "Classic 6",
    # eine andere App als der Graphing Calculator
    masApps = {
      "Amphetamine" = 937984704;
      "Developer" = 640199958;
      "eduVPN" = 1317704208;
      "Final Cut Pro" = 1631624924;
      "GeoGebra Graphing Calculator" = 1294018688;
      "Goodnotes" = 1444383602;
      "Infuse" = 1136220934;
      "Keynote" = 361285480;
      "Microsoft Excel" = 462058435;
      "Microsoft Outlook" = 985367838;
      "Microsoft PowerPoint" = 462062816;
      "Microsoft Word" = 462054704;
      "Xcode" = 497799835;
    };
  };
}
