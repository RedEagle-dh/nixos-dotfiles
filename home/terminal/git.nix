{ lib, osConfig, ... }:

let
  name = "David Hermann";
  email = "redeagle.private@gmail.com";
  key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMZLL7Fxqp3qXS04JkBDvHzdV98LgpL/LQ9ln6yh2rmx";
in
{
  programs.git = {
    enable = true;
    settings = {
      user = {
        inherit name email;
      };
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      fetch.prune = true;
      diff.colorMoved = "default";
      merge.conflictStyle = "zdiff3";
    };
    signing = {
      format = "ssh";
      inherit key;
      signByDefault = true;
      # Pfad ändert sich bei jedem 1Password-Update – nicht fest eintragen
      signer = lib.getExe' osConfig.programs._1password-gui.package "op-ssh-sign";
      allowedSigners = "${email} ${key}";
    };
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      line-numbers = true;
      syntax-theme = "ansi";
    };
  };

  programs.lazygit = {
    enable = true;
    settings = {
      gui = {
        nerdFontsVersion = "3";
        # Farbnamen statt Hex, damit es dem caelestia-Schema folgt
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
    settings.git_protocol = "ssh";
  };
}
