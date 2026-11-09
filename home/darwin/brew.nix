# Mac: Die Programme der Home-Manager-Module kommen aus Homebrew, die Module schreiben nur die
# Konfiguration. Hier steht pro Modul die Formel bzw. der Cask. Verlangt ein Modul ein Paket, weil es
# `${package}/bin/…` aufruft, bekommt es einen Verweis auf das Programm in Homebrew (fromBrew).
# Installiert werden alle Einträge von darwin/homebrew.nix (brew.formulas, brew.casks)
{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}:

let
  inherit (osConfig.homebrew) prefix;

  # Verweist auf bin/<bin> und links (Pfad im Paket = Pfad unter /opt/homebrew). version aus nixpkgs,
  # weil manche Module sie prüfen (fzf ≥ 0.48) – Homebrew ist meist gleich oder neuer
  fromBrew =
    name: m:
    pkgs.runCommandLocal "${m.bin}-homebrew"
      {
        inherit (pkgs.${name}) version;
        meta.mainProgram = m.bin;
      }
      (
        lib.concatStrings (
          lib.mapAttrsToList (path: target: ''
            mkdir -p "$(dirname "$out/${path}")"
            ln -s ${prefix}/${target} $out/${path}
          '') ({ "bin/${m.bin}" = "bin/${m.bin}"; } // m.links or { })
        )
      );

  # Modul = Formel oder Cask; bin (und links) nur, wo das Modul ein Paket verlangt
  modules = {
    awscli.formula = "awscli";
    bat = {
      formula = "bat";
      bin = "bat";
    };
    btop.formula = "btop";
    claude-code.cask = "claude-code";
    delta = {
      formula = "git-delta";
      bin = "delta";
    };
    direnv = {
      formula = "direnv";
      bin = "direnv";
    };
    discord.cask = "discord";
    eza.formula = "eza";
    fd.formula = "fd";
    fzf = {
      formula = "fzf";
      bin = "fzf";
      # Die Shell-Integration liest share/fzf, Homebrew legt die Skripte nach opt/fzf/shell
      links = {
        "share/fzf/key-bindings.zsh" = "opt/fzf/shell/key-bindings.zsh";
        "share/fzf/completion.zsh" = "opt/fzf/shell/completion.zsh";
      };
    };
    gh = {
      formula = "gh";
      bin = "gh";
    };
    git.formula = "git";
    go.formula = "go";
    gpg.formula = "gnupg";
    jq.formula = "jq";
    k9s.formula = "k9s";
    kitty.cask = "kitty";
    lazygit.formula = "lazygit";
    micro.formula = "micro";
    mpv.formula = "mpv";
    opencode.formula = "opencode";
    ripgrep.formula = "ripgrep";
    starship = {
      formula = "starship";
      bin = "starship";
    };
    # Policies und Erweiterungen setzt das Modul über die macOS-Einstellungen (darwin.packageMode
    # "signed"), dafür braucht es kein Paket
    zen-browser.cask = "zen";
    zed-editor.cask = "zed";
    zoxide = {
      formula = "zoxide";
      bin = "zoxide";
    };
    # zsh von macOS, eingerichtet von nix-darwin (programs.zsh)
    zsh = { };
  };

  enabled = lib.filterAttrs (name: _: config.programs.${name}.enable) modules;
  collect =
    kind: lib.concatLists (lib.mapAttrsToList (_: m: lib.optional (m ? ${kind}) m.${kind}) enabled);
in
{
  config = lib.mkMerge [
    {
      programs = lib.mapAttrs (name: m: {
        package = lib.mkForce (if m ? bin then fromBrew name m else null);
      }) modules;

      brew.formulas = collect "formula";
      brew.casks = collect "cask";
    }

    {
      # Zed: nixd gibt es nicht in Homebrew, nixfmt schon (Formatierer in zed.nix). JDTLS braucht
      # Java 25, die Projekte 21 – beide als Cask, JAVA_HOME zeigt auf 21 wie programs.java unter Linux
      programs.zed-editor = {
        extraPackages = lib.mkForce [ ];
        userSettings.lsp.jdtls.settings.java_home =
          lib.mkForce "/Library/Java/JavaVirtualMachines/zulu-25.jdk/Contents/Home";
      };
      programs.java.enable = lib.mkForce false;
      home.sessionVariables.JAVA_HOME = "$(/usr/libexec/java_home -v 21 2>/dev/null)";

      programs.kitty.font.package = lib.mkForce null;

      # Spicetify ändert die Spotify-App selbst – mit dem signierten Cask geht das nicht
      programs.spicetify.enable = lib.mkForce false;

      # Sucht Programme in nixpkgs – auf dem Mac kommen sie aus Homebrew
      programs.nix-index.enable = lib.mkForce false;
      programs.nix-index-database.comma.enable = lib.mkForce false;

      # Der Cask aktualisiert sich selbst (auto_updates), brew upgrade lässt ihn aus
      programs.zen-browser.policies.DisableAppUpdate = false;

      brew.formulas = [ "nixfmt" ];
      brew.casks = [
        "font-jetbrains-mono-nerd-font" # kitty, Zed (theme.fonts.mono)
        "font-inter" # Zed (theme.fonts.ui)
        "zulu@21"
        "zulu@25"
        "spotify"
      ];
    }
  ];
}
