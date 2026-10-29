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
    };
  };

  home.shellAliases.zed = "zeditor";
}
