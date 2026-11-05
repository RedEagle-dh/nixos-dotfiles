{
  inputs,
  lib,
  pkgs,
  ...
}:

let
  inherit (pkgs.stdenv.hostPlatform) isLinux;
  extension = slug: {
    installation_mode = "force_installed";
    install_url = "https://addons.mozilla.org/firefox/downloads/latest/${slug}/latest.xpi";
  };
  locked = Value: {
    inherit Value;
    Status = "locked";
  };
in
{
  imports = [ inputs.zen-browser.homeModules.beta ];

  programs.zen-browser = {
    enable = true;

    policies = {
      ExtensionSettings = {
        "uBlock0@raymondhill.net" = extension "ublock-origin";
        "{d634138d-c276-4fc8-924b-40a0ea21d284}" = extension "1password-x-password-manager";
      };

      OfferToSaveLogins = false;
      DontCheckDefaultBrowser = true;

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
    }
    # VA-API gibt es nur unter Linux, macOS dekodiert ohnehin in Hardware
    // lib.optionalAttrs isLinux {
      Preferences = {
        "media.hardware-video-decoding.force-enabled" = locked true;
        "media.ffmpeg.vaapi.enabled" = locked true;
        "media.rdd-ffmpeg.enabled" = locked true;
      };
    };
  };

  # Auf dem Mac als Cask (darwin/homebrew.nix) – nixpkgs baut Chromium nur für Linux
  programs.chromium = lib.mkIf isLinux {
    enable = true;
    package = pkgs.ungoogled-chromium;
  };
}
