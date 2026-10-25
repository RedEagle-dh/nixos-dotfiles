# home/ – Home Manager: alles im Home-Verzeichnis.
#
# Ein Modul pro Funktion. Neues Modul? Datei anlegen, hier eintragen, `git add`.
# Jedes Modul bekommt automatisch `user` (aus flake.nix) und `theme`
# (Farben, Schriften, Hintergrundbild aus ../theme) als Argument.

{ pkgs, user, ... }:

{
  imports = [
    ./apps.nix # Programme
    ./appearance.nix # GTK-Theme, Icons, Mauszeiger
    ./xdg.nix # Ordner & Standardprogramme
    ./hyprland # Fenster, Tastenkürzel, Sperrbildschirm, Leerlauf, Hintergrund
    ./waybar # Statusleiste
    ./menus # Starter, Power-Menü, Emojis, Kürzel-Übersicht
    ./notifications.nix # Benachrichtigungen & "Nicht stören"
    ./clipboard.nix # Zwischenablage-Verlauf
    ./screenshots.nix # Screenshots & Farbpipette
    ./audio.nix # Lautstärke-Anzeige & Medientasten
    ./terminal # Kitty, zsh, Prompt, Kommandozeilen-Werkzeuge
  ];

  _module.args.theme = import ../theme { inherit pkgs; };

  home.username = user;
  home.homeDirectory = "/home/${user}";

  # Wie system.stateVersion: beim ersten Einrichten festgelegt, nicht ändern.
  home.stateVersion = "26.05";
}
