{
  inputs,
  lib,
  pkgs,
  theme,
  ...
}:

let
  # Unter Linux schreibt caelestia das Theme passend zum Farbschema. Auf dem Mac gibt es kein caelestia:
  # dieselbe Vorlage, fest mit Rosé Pine gefüllt (wie discord.nix). Links caelestias Farbnamen
  template = builtins.readFile "${inputs.caelestia-shell.inputs.caelestia-cli}/src/caelestia/data/templates/zed.json";
  colours = with theme.colors; {
    surface = base;
    surfaceContainer = surface;
    surfaceContainerHigh = overlay;
    onSurface = text;
    onSurfaceVariant = subtle;
    outline = muted;
    outlineVariant = highlightMed;
    primary = iris;
    error = love;
    success = pine;
    red = love;
    maroon = love;
    pink = rose;
    mauve = iris;
    peach = gold;
    yellow = gold;
    green = pine;
    teal = foam;
    sky = foam;
    sapphire = pine;
    blue = foam;
    subtext0 = subtle;
    subtext1 = subtle;
  };
  staticTheme =
    let
      names = builtins.attrNames colours;
      filled = builtins.replaceStrings ([ "{{ mode }}" ] ++ map (n: "{{ ${n}.hex }}") names) (
        [ "dark" ] ++ map (n: colours.${n}) names
      ) template;
    in
    assert lib.assertMsg (
      !lib.hasInfix "{{" filled
    ) "zed.nix: Die caelestia-Vorlage nutzt eine Farbe, die in `colours` fehlt";
    filled;

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
      "prisma"
      "proto"
      "sql"
      "svelte"
      "terraform"
      "toml"
      "tsgo"
    ];

    # Als Objekt, weil Zeds Themenauswahl diese Form schreibt – sonst wäre nach dem Onboarding One Dark aktiv
    userSettings = {
      theme = {
        mode = "system";
        light = "Caelestia";
        dark = "Caelestia";
      };
      icon_theme = "Material Icon Theme";
      base_keymap = "VSCode";

      ui_font_family = theme.fonts.ui.name;
      ui_font_size = 16;
      buffer_font_family = theme.fonts.mono.name;
      buffer_font_size = 15;
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

  xdg.configFile."zed/themes/caelestia.json" = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
    text = staticTheme;
  };

  home.shellAliases.zed = "zeditor";
}
