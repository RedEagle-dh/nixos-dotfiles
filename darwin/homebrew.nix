# Homebrew ist auf dem Mac der einzige Paketmanager: Nix schreibt nur die Konfiguration (nix-darwin,
# Home Manager) und baut nichts. Was der Mac installiert, kommt hier zusammen:
#   - shared.tools / shared.apps (home/packages.nix): dieselben Werkzeuge wie unter Linux
#   - home/darwin/brew.nix: die Programme der Home-Manager-Module (git, starship, kitty, …)
#   - brew.formulas / brew.casks aus home/, homebrew.* aus darwin/: nur Mac
# Namen prüfen: brew search <name> oder formulae.brew.sh
{
  config,
  lib,
  inputs,
  user,
  ...
}:

let
  home = config.home-manager.users.${user};
in
{
  imports = [ inputs.nix-homebrew.darwinModules.nix-homebrew ];

  nix-homebrew = {
    enable = true;
    inherit user;

    # Übernimmt die bestehende Installation unter /opt/homebrew, installierte Pakete bleiben.
    # Einmalig vorher Library/Taps beiseitelegen, sonst bricht die Aktivierung ab (siehe unten: Taps)
    autoMigrate = true;

    # Taps nur aus Flake-Inputs, Stand über flake.lock (nhu aktualisiert sie) – `brew tap` geht nicht
    # mehr. homebrew/core und homebrew/cask kommen über Homebrews API. Neuer Tap: Input in flake.nix
    # (flake = false) und hier "user/homebrew-repo" = inputs.homebrew-repo;
    mutableTaps = false;
    taps = {
      "hashicorp/homebrew-tap" = inputs.homebrew-hashicorp; # terraform
      "netbirdio/homebrew-tap" = inputs.homebrew-netbird; # netbird-ui
    };

    # Seit Homebrew 6 lädt brew aus fremden Taps nur, was als vertrauenswürdig eingetragen ist –
    # sonst scheitert die Installation. Einzeln statt ganzer Taps. Entfernen trägt nicht aus:
    # `brew untrust --formula|--cask <name>`
    trust = {
      formulae = [ "hashicorp/tap/terraform" ];
      casks = [ "netbirdio/tap/netbird-ui" ];
    };

    # Sonst setzt `brew shellenv` /opt/homebrew/bin vor die Nix-Pfade
    enableZshIntegration = false;
  };

  # Vor /usr/local/bin und /usr/bin, damit git & Co. aus Homebrew vor denen von macOS kommen. Die
  # Nix-Profile davor enthalten nur noch Nix selbst, nh und kleine Skripte. `brew` liegt als Starter in
  # /run/current-system/sw/bin. rustup verlinkt Homebrew nicht (keg-only, kollidiert mit rust)
  environment.systemPath = lib.mkOrder 1100 [
    "${config.homebrew.prefix}/bin"
    "${config.homebrew.prefix}/sbin"
    "${config.homebrew.prefix}/opt/rustup/bin"
  ];

  homebrew = {
    enable = true;

    onActivation = {
      # "none": was nicht in den Listen steht, bleibt installiert. Erst prüfen, was sonst ginge (ohne
      # --force nur Anzeige), Gewolltes eintragen, dann "uninstall" – danach entfernt jedes nhs, was
      # aus den Listen verschwindet:
      #   brew bundle cleanup --file=$(grep -om1 '/nix/store/[a-z0-9]*-Brewfile' /run/current-system/activate)
      # Nie "zap": das löscht bei Casks auch die App-Daten unter ~/Library
      cleanup = "none";

      # nhs installiert nur, was fehlt – aktualisiert wird in nhu (pkgs/update.sh: brew update und
      # brew upgrade). Ein Upgrade hier machte jedes nhs minutenlang, Casks mit sudo-Schritten
      # (netbird-ui, tailscale-app, nordvpn) fragten einzeln nach dem Passwort, und ein gescheitertes
      # Upgrade ließ die ganze Aktivierung scheitern
      upgrade = false;
    };

    # brew kennt Taps ohne "homebrew-": aus "user/homebrew-repo" wird "user/repo"
    taps = map (builtins.replaceStrings [ "/homebrew-" ] [ "/" ]) (
      builtins.attrNames config.nix-homebrew.taps
    );

    # Formeln aus Fremd-Taps voll qualifiziert ("user/repo/name"), siehe taps oben
    brews = lib.unique home.brew.formulas;

    # Casks aus Fremd-Taps voll qualifiziert ("user/repo/cask"): nix-darwin vertraut dann nur dem Cask,
    # nicht dem ganzen Tap. Hier nur Apps ohne Gegenstück unter Linux, die übrigen kommen aus home/.
    # Eine schon von Hand installierte App bricht `brew bundle` ab ("already an App at …"). --adopt
    # scheitert an macOS' App-Verwaltungsschutz – stattdessen die App löschen und frisch per Cask
    # installieren; Einstellungen unter ~/Library bleiben. Vorher prüfen, ob der Cask dieselbe App ist
    # Nicht hier: Compositor – der Cask "compositor" ist eine andere App (com.microlarge) als die
    # installierte (com.wonderassembly), für die gibt es keinen Cask
    casks = lib.unique home.brew.casks ++ [
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
    # Nicht hier: WireGuard (darwin/vpn.nix). GeoGebra bleibt: pkgs.geogebra6 ist "Classic 6",
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
