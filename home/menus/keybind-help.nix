# home/menus/keybind-help.nix – Übersicht aller Tastenkürzel (Super+F1).
# Liest die Kürzel samt Beschreibung direkt aus dem laufenden Hyprland –
# die Beschreibungen stehen in hyprland/keybinds.lua.

{ pkgs, ... }:

let
  keybind-help = pkgs.writeShellApplication {
    name = "keybind-help";
    runtimeInputs = [
      pkgs.jq
      pkgs.fuzzel
    ];
    text = ''
      # Liest alle Kürzel samt Beschreibung direkt aus dem laufenden Hyprland
      hyprctl binds -j | jq -r '
        def bit($b): ((. / $b) | floor) % 2 == 1;
        def mods: [
          (if bit(64) then "Super" else empty end),
          (if bit(4)  then "Strg" else empty end),
          (if bit(8)  then "Alt" else empty end),
          (if bit(1)  then "Umschalt" else empty end)
        ];
        def keyname: {
          "Return": "Enter", "space": "Leertaste", "period": ".", "Print": "Druck",
          "Escape": "Esc", "Tab": "Tab", "left": "←", "right": "→", "up": "↑", "down": "↓",
          "mouse:272": "Linke Maustaste", "mouse:273": "Rechte Maustaste",
          "mouse_down": "Mausrad ↓", "mouse_up": "Mausrad ↑",
          "XF86AudioRaiseVolume": "Lauter-Taste", "XF86AudioLowerVolume": "Leiser-Taste",
          "XF86AudioMute": "Stumm-Taste", "XF86AudioMicMute": "Mikrofon-Taste",
          "XF86AudioPlay": "Play-Taste", "XF86AudioNext": "Weiter-Taste", "XF86AudioPrev": "Zurück-Taste",
          "XF86AudioStop": "Stopp-Taste", "comma": ",", "ssharp": "ß", "dead_acute": "´", "numbersign": "#",
          "Page_Up": "Bild↑", "Page_Down": "Bild↓", "BackSpace": "Rücktaste", "Delete": "Entf"
        }[.] // .;
        .[] | select(.has_description)
        | (if .key == "SUPER_L" then "Super (antippen)"
           else (.modmask | mods) + [(.key | keyname)] | join(" + ") end) as $combo
        | "\(.description)  ·  \($combo)"
      ' | fuzzel --dmenu --minimal-lines --prompt "  " --placeholder "Tastenkürzel suchen …" --width 70 --lines 18 >/dev/null || true
    '';
  };
in
{
  home.packages = [ keybind-help ];
}
