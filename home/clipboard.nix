# home/clipboard.nix – Zwischenablage-Verlauf (Super+V).
# cliphist merkt sich alles Kopierte; das Menü holt einen Eintrag zurück.

{ pkgs, ... }:

let
  clipboard-menu = pkgs.writeShellApplication {
    name = "clipboard-menu";
    runtimeInputs = [
      pkgs.fuzzel
      pkgs.cliphist
      pkgs.wl-clipboard
    ];
    text = ''
      # Gewählter Eintrag landet wieder in der Zwischenablage → Strg+V fügt ihn ein
      cliphist list \
        | fuzzel --dmenu --minimal-lines --with-nth 2 --prompt "󰅍  " --placeholder "Zwischenablage durchsuchen …" --width 60 \
        | cliphist decode \
        | wl-copy
    '';
  };
in
{
  home.packages = [
    clipboard-menu
    pkgs.wl-clipboard # wl-copy / wl-paste im Terminal
  ];

  services.cliphist = {
    enable = true;
    allowImages = true;
  };
}
