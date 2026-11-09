{ pkgs, lib, ... }:

let
  inherit (pkgs.stdenv.hostPlatform) isLinux;
in
{
  # Unter Linux aus nixpkgs, auf dem Mac als Cask (home/packages.nix)
  shared.apps = {
    t3code-nightly = "t3-code@nightly"; # Linux: pkgs/ (Overlay in flake.nix)
    datagrip = null;
    "jetbrains.idea" = "intellij-idea";
    bruno = null;
    lmstudio = "lm-studio";
  };

  home.packages = lib.optionals isLinux (
    with pkgs;
    [
      # Aus pkgs/ (Overlay in flake.nix). Homebrew hat es nicht – auf dem Mac `npm i -g command-code`
      command-code

      # Unter macOS übernehmen das Vorschau, TextEdit und Finder
      loupe
      papers
      gnome-text-editor
      file-roller
      hyprmod
    ]
  );

  programs.mpv = {
    enable = true;
    # target-colorspace-hint geht nur mit gpu-next – darüber schaltet Hyprland im Vollbild auf HDR
    config = lib.mkIf isLinux {
      vo = "gpu-next";
      gpu-api = "vulkan";
      target-colorspace-hint = "yes";
      hwdec = "auto-safe";
    };
  };

  # Linux: pkgs.claude-code in der Version aus pkgs/claude-code.json (Overlay in flake.nix)
  programs.claude-code.enable = true;
}
