{ pkgs, theme, ... }:

{
  programs.zed-editor = {
    enable = true;

    extraPackages = with pkgs; [
      nixd
      nixfmt
    ];

    # Als Objekt, weil Zeds Themenauswahl diese Form schreibt – sonst wäre nach dem Onboarding One Dark aktiv
    userSettings = {
      theme = {
        mode = "system";
        light = "Caelestia";
        dark = "Caelestia";
      };
      ui_font_family = theme.fonts.ui.name;
      buffer_font_family = theme.fonts.mono.name;
      telemetry = {
        diagnostics = false;
        metrics = false;
      };

      languages.Nix.language_servers = [
        "nixd"
        "!nil"
      ];
      lsp.nixd.settings.formatting.command = [ "nixfmt" ];
      # Das heruntergeladene JDTLS braucht mindestens Java 25, programs.java liefert 21
      lsp.jdtls.settings.java_home = pkgs.jdk25.home;
    };
  };

  home.shellAliases.zed = "zeditor";
}
