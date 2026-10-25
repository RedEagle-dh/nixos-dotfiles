# home/menus/emoji.nix – Emoji-Auswahl (Super+.).

{ pkgs, ... }:

let
  emoji-menu = pkgs.writeShellApplication {
    name = "emoji-menu";
    runtimeInputs = [
      pkgs.rofimoji
      pkgs.fuzzel
      pkgs.wtype
      pkgs.wl-clipboard
    ];
    text = ''
      # Tippt das gewählte Emoji direkt ins aktive Fenster
      rofimoji --selector fuzzel --action type --skin-tone neutral --prompt "󰞅  " \
        --selector-args="--placeholder 'Emoji suchen (englische Begriffe) …' --width 50"
    '';
  };
in
{
  home.packages = [ emoji-menu ];
}
