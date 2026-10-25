# home/terminal/fastfetch.nix – Begrüßung beim Öffnen eines Terminals:
# NixOS-Schriftzug und eine Box mit Systeminfos (Layout wie bei caelestia,
# Farben aus theme/default.nix). Von Hand aufrufen: fastfetch

{
  lib,
  pkgs,
  theme,
  ...
}:

let
  # Terminal-Farbcode (True Color) für eine Farbe aus der Palette
  color =
    name:
    let
      hex = theme.colors.${name};
      channel = i: toString (lib.fromHexString (builtins.substring i 2 hex));
    in
    "\\u001b[38;2;${channel 0};${channel 2};${channel 4}m";
in
{
  home.packages = [ pkgs.fastfetch ];

  # Platzhalter in den Einträgen: {$1} Text, {$2} Iris, {$3} Foam, {$4} Rosé
  xdg.configFile."fastfetch/config.jsonc".text = ''
    {
        "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
        "logo": null,
        "display": {
            "separator": "  ",
            "color": "white",
            "constants": ["${color "text"}", "${color "iris"}", "${color "foam"}", "${color "rose"}"]
        },
        "modules": [
            "break",
            { "type": "custom", "key": "╭───────────────────────────────────╮" },
            { "type": "kernel", "key": "│ {$2}{$1}  kernel", "format": "{$2}{release>22}{$1} │" },
            { "type": "command", "key": "│   uptime", "text": "${pkgs.procps}/bin/uptime -p | cut -d ' ' -f 2-", "format": "{>22} │" },
            { "type": "shell", "key": "│ {$2}{$1}  shell ", "format": "{$2}{pretty-name>22}{$1} │" },
            {
                "type": "command",
                "key": "│ {$3}{$1}  mem   ",
                "text": "free -m | awk 'NR==2{printf \"%.2f GiB / %.2f GiB\",$3/1024,$2/1024}'",
                "format": "{$3}{>22}{$1} │"
            },
            { "type": "packages", "key": "│   pkgs  ", "format": "{all>22} │" },
            { "type": "command", "key": "│ {$2}{$1}  user  ", "text": "echo $USER", "format": "{$2}{>22}{$1} │" },
            { "type": "command", "key": "│   hname ", "text": "hostnamectl hostname", "format": "{>22} │" },
            { "type": "os", "key": "│ {$4}󰻀{$1}  distro", "format": "{$4}{pretty-name>22}{$1} │" },
            { "type": "custom", "key": "╰───────────────────────────────────╯" },
            "break"
        ]
    }
  '';

  # Schriftzug in Iris, darunter die Box – bei jedem neuen Terminal
  programs.zsh.initContent = lib.mkOrder 1500 ''
    printf '${builtins.replaceStrings [ "\\u001b" ] [ "\\e" ] (color "iris")}'
    cat <<'EOF'
         _   ___      ____  _____
        / | / (_)  __/ __ \/ ___/
       /  |/ / / |/_/ / / /\__ \
      / /|  / />  </ /_/ /___/ /
     /_/ |_/_/_/|_|\____//____/
    EOF
    printf '\e[0m'
    fastfetch --key-padding-left 5
  '';
}
