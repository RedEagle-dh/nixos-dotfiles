{ pkgs, ... }:

{
  home.packages = with pkgs; [
    loupe
    papers
    gnome-text-editor
    file-roller
    vscode
    hyprmod
    bun
  ];

  # target-colorspace-hint geht nur mit gpu-next – darüber schaltet Hyprland im Vollbild auf HDR
  programs.mpv = {
    enable = true;
    config = {
      vo = "gpu-next";
      gpu-api = "vulkan";
      target-colorspace-hint = "yes";
      hwdec = "auto-safe";
    };
  };

  programs.claude-code.enable = true;
}
