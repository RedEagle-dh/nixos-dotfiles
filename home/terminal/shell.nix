# Shell-Ergänzungen für Desktop und Mac. Bewusst getrennt von zsh.nix und cli-tools.nix,
# die unverändert auch im Homelab-Repo liegen
{ lib, pkgs, ... }:

let
  # `op` aus dem PATH: unter NixOS der setgid-Wrapper, auf dem Mac /usr/local/bin/op –
  # nur diese akzeptiert die 1Password-App für die CLI-Anbindung
  sopsAgeKey = pkgs.writeShellScript "sops-age-key" ''
    op read "op://Homelab/sops-admin/password"
    status=$?
    op signout >/dev/null 2>&1
    exit $status
  '';
in
{
  home.sessionVariables.SOPS_AGE_KEY_CMD = "${sopsAgeKey}";

  home.shellAliases = {
    cat = "bat";
    k = "kubectl";
  };

  # Ordner zuerst; gilt für alle eza-Aliase, weil `eza` selbst ein Alias mit diesen Optionen ist
  programs.eza.extraOptions = [ "--group-directories-first" ];

  programs.zsh = {
    # Überschreiben die Vorgaben aus programs.eza (dort mkDefault)
    shellAliases = {
      la = "eza -la";
      lt = "eza --tree --level=2";
    };

    setOptions = [
      "HIST_REDUCE_BLANKS"
      "INTERACTIVE_COMMENTS"
    ];

    initContent = lib.mkOrder 1000 ''
      # Selbst installierte Werkzeuge (uv, codex, …) – hinten angehängt, Nix-Pakete gehen vor
      typeset -U path
      path+=(~/.local/bin(N/) ~/.bun/bin(N/) ~/.lmstudio/bin(N/) ~/.kimi-code/bin(N/))

      ${builtins.readFile ./functions/killport.zsh}
      ${builtins.readFile ./functions/ghtest.zsh}
    '';
  };
}
