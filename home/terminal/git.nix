# home/terminal/git.nix – Git. Commits und Tags werden über 1Password signiert,
#   mit demselben SSH-Key wie in ssh.nix (id_ed25519.pub).
#   Prüfen: git log --show-signature

{ lib, osConfig, ... }:

let
  name = "David Hermann";
  email = "redeagle.private@gmail.com";
  key = lib.trim (builtins.readFile ./id_ed25519.pub);
in
{
  programs.git = {
    enable = true;
    settings.user = {
      inherit name email;
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
}
