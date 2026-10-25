# home/terminal/git.nix – Git, delta, lazygit und gh.
#   Commits und Tags werden über 1Password signiert, mit demselben SSH-Key wie
#   in ssh.nix (id_ed25519.pub). Prüfen: git log --show-signature
#   git diff/log/show   Ausgabe über delta: Syntaxfarben, Zeilennummern,
#                       geänderte Wörter hervorgehoben; n/N springt zur nächsten Datei
#   lazygit             Git im Terminal mit Oberfläche (stagen, committen, rebasen …)
#   gh                  GitHub: PRs, Issues, Actions (einmalig: gh auth login)

{ lib, osConfig, ... }:

let
  name = "David Hermann";
  email = "redeagle.private@gmail.com";
  key = lib.trim (builtins.readFile ./id_ed25519.pub);
in
{
  programs.git = {
    enable = true;
    settings = {
      user = {
        inherit name email;
      };
      init.defaultBranch = "main";
      push.autoSetupRemote = true; # erstes `git push` eines neuen Branches ohne -u
      fetch.prune = true; # gelöschte Branches auf GitHub auch lokal vergessen
      diff.colorMoved = "default"; # verschobene Zeilen anders färben als geänderte
      merge.conflictStyle = "zdiff3"; # bei Konflikten auch den gemeinsamen Ursprung zeigen
    };
    signing = {
      format = "ssh";
      inherit key;
      signByDefault = true;
      # Pfad ändert sich bei jedem 1Password-Update – deshalb hier und nicht fest in der Config
      signer = lib.getExe' osConfig.programs._1password-gui.package "op-ssh-sign";
      # eigene Signaturen als vertrauenswürdig anzeigen
      allowedSigners = "${email} ${key}";
    };
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      line-numbers = true;
      syntax-theme = "ansi"; # Terminalfarben, wie bat
    };
  };

  programs.lazygit = {
    enable = true;
    settings = {
      gui = {
        nerdFontsVersion = "3"; # Icons für Dateien und Branches
        # Farbnamen statt fester Werte → folgt dem Farbschema von caelestia
        theme = {
          activeBorderColor = [
            "magenta"
            "bold"
          ];
          inactiveBorderColor = [ "default" ];
          selectedLineBgColor = [ "reverse" ];
        };
      };
      git.diffRenderers = [ { command = "delta --dark --paging=never"; } ];
    };
  };

  programs.gh = {
    enable = true;
    settings.git_protocol = "ssh"; # klonen und pushen über SSH (1Password), nicht HTTPS
  };
}
