# home/apps.nix – Programme.
#
# Faustregel: Ohne Konfiguration per Nix → in die Liste.
# Mit Konfiguration per Nix → programs.<name> (siehe Claude Code unten).

{ pkgs, ... }:

{
  home.packages = with pkgs; [
    loupe # Bildbetrachter
    papers # PDF-Betrachter
    gnome-text-editor # einfacher Texteditor
    file-roller # Archive (zip, tar …)
    vscode # Erweiterungen & Einstellungen pflegst du in VS Code selbst
    hyprmod # Hyprland-Einstellungen live ausprobieren; Ergebnis dann in home/hyprland/ übernehmen
  ];

  # Videos. Mit gpu-next meldet mpv HDR-Videos an Hyprland – im Vollbild
  # schaltet der Monitor dann auf HDR (siehe hyprland.lua, Abschnitt BILDSCHIRM)
  programs.mpv = {
    enable = true;
    config = {
      vo = "gpu-next";
      gpu-api = "vulkan";
      target-colorspace-hint = "yes";
      hwdec = "auto-safe"; # Grafikkarte dekodiert, spart CPU
    };
  };

  programs.claude-code.enable = true;
}
