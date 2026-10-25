# home/terminal/fastfetch.nix – Begrüßung beim Öffnen eines Terminals:
# NixOS-Schriftzug und eine Box mit Systeminfos (Layout wie bei caelestia,
# Farben vom Farbschema von caelestia). Von Hand aufrufen: fastfetch

{ lib, pkgs, ... }:

let
  # Terminal-Farbcodes. 16–18 belegt caelestia mit den Akzentfarben seines
  # Farbschemas – sie wechseln also mit dem Hintergrundbild.
  slots = {
    text = "37";
    primary = "38;5;16";
    secondary = "38;5;17";
    tertiary = "38;5;18";
  };
  color = name: "\\u001b[${slots.${name}}m";
in
{
  home.packages = [ pkgs.fastfetch ];

  # Platzhalter in den Einträgen: {$1} Text, {$2}–{$4} erste bis dritte Akzentfarbe
  xdg.configFile."fastfetch/config.jsonc".text = ''
    {
        "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
        "logo": null,
        "display": {
            "separator": "  ",
            "color": "white",
            "constants": ["${color "text"}", "${color "primary"}", "${color "secondary"}", "${color "tertiary"}"]
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

  # Schriftzug in der Akzentfarbe, darunter die Box – bei jedem neuen Terminal
  programs.zsh.initContent = lib.mkOrder 1500 ''
    printf '${builtins.replaceStrings [ "\\u001b" ] [ "\\e" ] (color "primary")}'
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
