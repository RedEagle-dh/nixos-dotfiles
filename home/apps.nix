# home/apps.nix – Programme.
#
# Faustregel: Ohne Konfiguration per Nix → in die Liste.
# Mit Konfiguration per Nix → programs.<name> (siehe Claude Code unten).

{ pkgs, ... }:

{
  home.packages = with pkgs; [
    loupe # Bildbetrachter
    papers # PDF-Betrachter
    mpv # Videos
    gnome-text-editor # einfacher Texteditor
    file-roller # Archive (zip, tar …)
    vscode # Erweiterungen & Einstellungen pflegst du in VS Code selbst
    hyprmod # Hyprland-Einstellungen live ausprobieren; Ergebnis dann in home/hyprland/ übernehmen
  ];

  programs.claude-code.enable = true;
}
