{ inputs, pkgs, ... }:

let
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

      Preferences = {
        "media.hardware-video-decoding.force-enabled" = locked true;
        "media.ffmpeg.vaapi.enabled" = locked true;
        "media.rdd-ffmpeg.enabled" = locked true;
      };
    };
  };

  programs.chromium = {
    enable = true;
    package = pkgs.ungoogled-chromium;
  };
}
