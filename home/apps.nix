{ pkgs, lib, ... }:

let
  inherit (pkgs.stdenv.hostPlatform) isLinux isDarwin;
in
{
  home.packages =
    with pkgs;
    [
      (callPackage (
        if isDarwin then ../pkgs/t3code-nightly-darwin.nix else ../pkgs/t3code-nightly.nix
      ) { })
      (callPackage ../pkgs/command-code { })
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

  programs.claude-code = {
    enable = true;
    package = pkgs.claude-code.override {
      manifest = lib.importJSON ../pkgs/claude-code.json;
    };
  };
}
