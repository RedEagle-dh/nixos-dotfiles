{ pkgs, lib, ... }:

let
  inherit (pkgs.stdenv.hostPlatform) isLinux;
in
{
  home.packages =
    with pkgs;
    [
      # Aus pkgs/ (Overlay in flake.nix)
      t3code-nightly
      command-code
      datagrip
      jetbrains.idea
      bruno
      lmstudio
    ]
    # Unter macOS übernehmen das Vorschau, TextEdit und Finder
    ++ lib.optionals isLinux [
      loupe
      papers
      gnome-text-editor
      file-roller
      hyprmod
    ];

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

  # pkgs.claude-code in der Version aus pkgs/claude-code.json (Overlay in flake.nix)
  programs.claude-code.enable = true;
}
