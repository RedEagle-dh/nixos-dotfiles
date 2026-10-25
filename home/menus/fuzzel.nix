# home/menus/fuzzel.nix – Aussehen von fuzzel: Zwischenablage, Emojis, Kürzel-Übersicht.
# Als Programm-Starter dient caelestia; fuzzel ginge aber auch (Befehl: fuzzel).

{ theme, ... }:

let
  c = theme.colors;
in
{
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        font = "${theme.fonts.ui.name}:size=13,${theme.fonts.mono.name}:size=13";
        prompt = ''"  "'';
        placeholder = ''"Programm suchen …"'';
        icon-theme = theme.icons.name;
        terminal = "kitty";
        layer = "overlay";
        width = 42;
        lines = 9;
        horizontal-pad = 24;
        vertical-pad = 18;
        inner-pad = 12;
        line-height = 28;
        image-size-ratio = 0.5;
        show-actions = false;
      };
      colors = {
        background = "${c.base}eb";
        text = "${c.text}ff";
        prompt = "${c.iris}ff";
        placeholder = "${c.muted}ff";
        input = "${c.text}ff";
        match = "${c.rose}ff";
        selection = "${c.overlay}ff";
        selection-text = "${c.text}ff";
        selection-match = "${c.rose}ff";
        counter = "${c.muted}ff";
        border = "${c.iris}cc";
      };
      border = {
        width = 2;
        radius = 16;
        selection-radius = 10;
      };
    };
  };
}
