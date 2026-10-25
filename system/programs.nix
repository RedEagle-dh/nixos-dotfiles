# system/programs.nix – Programme, die systemweit installiert sind.
#
# Hierher gehört nur, was ein NixOS-Modul braucht oder für alle Benutzer da
# sein soll. Persönliche Programme stehen in home/apps.nix.

{ pkgs, ... }:

let
  # Erweiterung aus addons.mozilla.org, fest installiert (nicht entfernbar)
  extension = slug: {
    installation_mode = "force_installed";
    install_url = "https://addons.mozilla.org/firefox/downloads/latest/${slug}/latest.xpi";
  };
in
{
  # Firefox. Was hier steht, ist in Firefox ausgegraut und wird bei jedem Start
  # gesetzt; alles andere stellt man wie gewohnt in Firefox ein.
  # Übersicht der aktiven Regeln: about:policies
  programs.firefox = {
    enable = true;

    policies = {
      ExtensionSettings = {
        "uBlock0@raymondhill.net" = extension "ublock-origin";
        "{d634138d-c276-4fc8-924b-40a0ea21d284}" = extension "1password-x-password-manager";
      };

      # Passwörter verwaltet 1Password
      OfferToSaveLogins = false;
      DontCheckDefaultBrowser = true;

      # Keine Datensammlung, Werbung oder Experimente
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      FirefoxHome = {
        SponsoredTopSites = false;
        SponsoredStories = false;
        Stories = false;
      };
      FirefoxSuggest = {
        SponsoredSuggestions = false;
        ImproveSuggest = false;
      };
      UserMessaging = {
        ExtensionRecommendations = false;
        FeatureRecommendations = false;
        SkipOnboarding = true;
      };
    };

    preferences = {
      # Videos über die Grafikkarte dekodieren (Treiber: system/nvidia.nix)
      "media.hardware-video-decoding.force-enabled" = true;
      "media.ffmpeg.vaapi.enabled" = true;
      "media.rdd-ffmpeg.enabled" = true;
    };
  };

  programs.nix-ld.enable = true; # vorkompilierte Fremd-Binaries lauffähig machen

  # Dateimanager Nautilus mit "In Kitty öffnen" im Rechtsklickmenü
  programs.nautilus-open-any-terminal = {
    enable = true;
    terminal = "kitty";
  };

  environment.systemPackages = with pkgs; [
    nautilus # Dateimanager (Super+E)

    # Basics – auch ohne Home Manager und für root verfügbar
    git
    vim
    wget
    curl
    unzip
  ];
}
