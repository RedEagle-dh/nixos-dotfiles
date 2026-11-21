{
  lib,
  pkgs,
  theme,
  ...
}:

let
  biome = {
    formatter.language_server.name = "biome";
    format_on_save = "on";
  };
  # Die tsgo-Erweiterung registriert ihren Server seit v1.1.0 als "typescript-ls"
  tsgo = [
    "typescript-ls"
    "!vtsls"
    "!typescript-language-server"
  ];
in
{
  programs.zed-editor = {
    enable = true;

    extraPackages = with pkgs; [
      nixd
      nixfmt
    ];

    extensions = [
      "biome"
      "dockerfile"
      "emmet"
      "helm"
      "html"
      "java-eclipse-jdtls"
      "jinja2"
      "latex"
      "make"
      "markdown-oxide"
      "markdown-snippets"
      "material-icon-theme"
      "nix"
      "palenight"
      "prisma"
      "proto"
      "sql"
      "svelte"
      "terraform"
      "toml"
      "tsgo"
    ];

    userSettings = {
      # Festes Theme statt der Wallpaper-Farben: caelestia gleicht alle Syntaxfarben an den Farbton des
      # Wallpapers an, bis sie kaum noch zu unterscheiden sind – und gleiche Farbe soll gleiche Bedeutung
      # behalten. Palenight gibt es nur dunkel, daher für beide Modi.
      # Als Objekt, weil Zeds Themenauswahl diese Form schreibt – sonst wäre nach dem Onboarding One Dark aktiv
      theme = {
        mode = "system";
        light = "Palenight Theme";
        dark = "Palenight Theme";
      };
      icon_theme = "Material Icon Theme";
      base_keymap = "VSCode";

      ui_font_family = theme.fonts.ui.name;
      ui_font_size = 16;
      buffer_font_family = theme.fonts.mono.name;
      buffer_font_size = 15;
      # Kontrast wirkt auch über die Schrift: JetBrains Mono liegt als Medium bei, das bei 15 px
      # mehr Strichfläche hat als Regular. 400 = Regular, 500 = Medium, 600 = SemiBold.
      buffer_font_weight = 500;

      terminal = {
        font_size = 12;
        line_height.custom = 1.5;
        cursor_shape = "bar";
        blinking = "on";
        max_scroll_history_lines = 10000;
      };

      cursor_blink = true;
      sticky_scroll.enabled = true;
      minimap.show = "never";
      colorize_brackets = false;
      diff_view_style = "split";
      project_panel = {
        dock = "left";
        auto_fold_dirs = false;
      };
      cli_default_open_behavior = "existing_window";
      session.trust_all_worktrees = true;

      disable_ai = true;
      show_edit_predictions = true;
      edit_predictions = {
        provider = "zed";
        allow_data_collection = "no";
      };
      collaboration_panel.button = false;
      calls = {
        share_on_join = false;
        mute_on_join = true;
      };
      telemetry = {
        diagnostics = false;
        metrics = false;
      };

      file_types = {
        ignore = [ ".eslintignore" ];
        dotenv = [ ".env*" ];
        html = [ "*.ejs" ];
        jsonc = [
          ".eslintrc"
          ".prettierrc"
        ];
      };

      languages = {
        JavaScript = biome;
        JSX = biome;
        TypeScript = biome // {
          language_servers = tsgo;
        };
        TSX = biome // {
          language_servers = tsgo;
        };
        Nix.language_servers = [
          "nixd"
          "!nil"
        ];
      };

      lsp = {
        biome.settings.require_config_file = true;
        nixd.settings.formatting.command = [ "nixfmt" ];
        # Das heruntergeladene JDTLS braucht mindestens Java 25, programs.java liefert 21
        jdtls.settings.java_home = pkgs.jdk25.home;
      };
    };
  };

  # nixpkgs nennt das Programm zeditor, der Cask auf dem Mac zed
  home.shellAliases = lib.mkIf pkgs.stdenv.hostPlatform.isLinux { zed = "zeditor"; };
}
