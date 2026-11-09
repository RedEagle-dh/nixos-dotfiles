{ lib, pkgs, ... }:

let
  inherit (pkgs.stdenv.hostPlatform) isDarwin;

  # 16–18 belegt caelestia mit den Akzentfarben des aktuellen Schemas, auf dem Mac fest kitty
  # (home/darwin/terminal.nix)
  slots = {
    text = "37";
    primary = "38;5;16";
    secondary = "38;5;17";
    tertiary = "38;5;18";
  };
  color = name: "\\u001b[${slots.${name}}m";

  # macOS kennt weder `uptime -p` noch free und hostnamectl – Ausgabe wie unter Linux
  macUptime = pkgs.writeShellScript "uptime-pretty" ''
    # "{ sec = 1793352772, usec = 168060 } …" – nur sec, nicht usec
    boot=$(/usr/sbin/sysctl -n kern.boottime | /usr/bin/sed -E 's/^\{ sec = ([0-9]+),.*/\1/')
    s=$(( $(/bin/date +%s) - boot ))
    d=$(( s / 86400 )); h=$(( s % 86400 / 3600 )); m=$(( s % 3600 / 60 ))
    out=""
    unit() { [ "$1" -gt 0 ] && out="$out''${out:+, }$1 $2$([ "$1" -gt 1 ] && echo s)"; }
    unit $d day; unit $h hour; unit $m minute
    echo "''${out:-0 minutes}"
  '';
  uptimeModule =
    if isDarwin then
      ''{ "type": "command", "key": "│   uptime", "text": "${macUptime}", "format": "{>22} │" }''
    else
      ''{ "type": "command", "key": "│   uptime", "text": "${pkgs.procps}/bin/uptime -p | cut -d ' ' -f 2-", "format": "{>22} │" }'';
  memModule =
    if isDarwin then
      ''{ "type": "memory", "key": "│ {$3}{$1}  mem   ", "format": "{$3}{used>10} / {total}{$1} │" }''
    else
      ''
        {
            "type": "command",
            "key": "│ {$3}{$1}  mem   ",
            "text": "free -m | awk 'NR==2{printf \"%.2f GiB / %.2f GiB\",$3/1024,$2/1024}'",
            "format": "{$3}{>22}{$1} │"
        }'';
  # Das packages-Modul zählt die Nix-Pakete bei jedem Start neu (~55 ms von ~70 ms) – daher die Zahl
  # zwischenspeichern, neu gezählt wird nur, wenn sich System- oder Nutzerprofil geändert haben
  pkgCountConfig = pkgs.writeText "fastfetch-pkg-count.jsonc" ''
    { "logo": null, "display": { "key": { "type": "none" } }, "modules": [{ "type": "packages", "format": "{all}" }] }
  '';
  pkgCount = pkgs.writeShellScript "fastfetch-pkg-count" ''
    cache="''${XDG_CACHE_HOME:-$HOME/.cache}/fastfetch/pkg-count"
    key=$(readlink -f /run/current-system "/etc/profiles/per-user/$USER" | tr '\n' ' ')
    if [ -r "$cache" ] && [ "$(head -n1 "$cache")" = "$key" ]; then
      tail -n1 "$cache"
      exit
    fi
    n=$(fastfetch -c ${pkgCountConfig} --pipe true)
    mkdir -p "''${cache%/*}" && printf '%s\n%s\n' "$key" "$n" > "$cache"
    echo "$n"
  '';
  # Auf dem Mac zählt das Modul auch Homebrew mit – dort bleibt es beim eingebauten
  pkgsModule =
    if isDarwin then
      ''{ "type": "packages", "key": "│   pkgs  ", "format": "{all>22} │" }''
    else
      ''{ "type": "command", "key": "│   pkgs  ", "text": "${pkgCount}", "format": "{>22} │" }'';
  hostnameCmd = if isDarwin then "scutil --get LocalHostName" else "hostnamectl hostname";
  distroIcon = if isDarwin then "" else "󰻀";

  # figlet -f slant, eine Spalte eingerückt
  banner = lib.concatMapStrings (line: " ${line}\n") (
    if isDarwin then
      [
        "                         ____  _____"
        "   ____ ___  ____ ______/ __ \\/ ___/"
        "  / __ `__ \\/ __ `/ ___/ / / /\\__ \\"
        " / / / / / / /_/ / /__/ /_/ /___/ /"
        "/_/ /_/ /_/\\__,_/\\___/\\____//____/"
      ]
    else
      [
        "    _   ___      ____  _____"
        "   / | / (_)  __/ __ \\/ ___/"
        "  /  |/ / / |/_/ / / /\\__ \\"
        " / /|  / />  </ /_/ /___/ /"
        "/_/ |_/_/_/|_|\\____//____/"
      ]
  );
in
{
  shared.tools.fastfetch = null;

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
            ${uptimeModule},
            { "type": "shell", "key": "│ {$2}{$1}  shell ", "format": "{$2}{pretty-name>22}{$1} │" },
            ${memModule},
            ${pkgsModule},
            { "type": "command", "key": "│ {$2}{$1}  user  ", "text": "echo $USER", "format": "{$2}{>22}{$1} │" },
            { "type": "command", "key": "│   hname ", "text": "${hostnameCmd}", "format": "{>22} │" },
            { "type": "os", "key": "│ {$4}${distroIcon}{$1}  distro", "format": "{$4}{pretty-name>22}{$1} │" },
            { "type": "custom", "key": "╰───────────────────────────────────╯" },
            "break"
        ]
    }
  '';

  # Vor compinit und den Plugins (ab 550), damit die Ausgabe nicht erst nach dem ganzen Init kommt;
  # nach den Farbsequenzen von caelestia (400)
  programs.zsh.initContent = lib.mkOrder 450 ''
    printf '${builtins.replaceStrings [ "\\u001b" ] [ "\\e" ] (color "primary")}'
    command cat <<'EOF'
    ${banner}EOF
    printf '\e[0m'
    fastfetch --key-padding-left 5
  '';
}
