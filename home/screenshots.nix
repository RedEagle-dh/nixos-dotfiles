# home/screenshots.nix – Screenshots, Bildschirmaufnahmen und Farbpipette.
# Screenshots landen in der Zwischenablage und unter ~/Pictures/Screenshots,
# Aufnahmen unter ~/Videos/Recordings. Kürzel: siehe hyprland/keybinds.lua.

{ config, pkgs, ... }:

let
  screenshotDir = "${config.home.homeDirectory}/Pictures/Screenshots";
  recordingDir = "${config.home.homeDirectory}/Videos/Recordings";

  screenshot = pkgs.writeShellApplication {
    name = "screenshot";
    runtimeInputs = [
      pkgs.grimblast
      pkgs.satty
      pkgs.wl-clipboard
      pkgs.coreutils
    ];
    text = ''
      dir="${screenshotDir}"
      mkdir -p "$dir"
      export XDG_SCREENSHOTS_DIR="$dir"

      case "''${1:-area}" in
        area) grimblast --notify --freeze copysave area ;;
        screen) grimblast --notify copysave output ;;
        active) grimblast --notify copysave active ;;
        edit)
          # Bereich wählen, dann beschriften; Enter kopiert und speichert
          grimblast --freeze save area - | satty \
            --filename - \
            --output-filename "$dir/Screenshot_$(date +%Y%m%d_%H%M%S).png" \
            --copy-command wl-copy \
            --actions-on-enter save-to-clipboard,save-to-file,exit \
            --early-exit \
            --initial-tool arrow
          ;;
        *) echo "Aufruf: screenshot area|screen|active|edit" >&2; exit 1 ;;
      esac
    '';
  };

  # Bildschirmaufnahme an/aus: läuft schon eine, wird sie beendet und gespeichert
  record = pkgs.writeShellApplication {
    name = "record";
    runtimeInputs = [
      pkgs.wf-recorder
      pkgs.slurp
      pkgs.pulseaudio # pactl: Name des Ausgabegeräts für den Ton
      pkgs.libnotify
      pkgs.jq
      pkgs.procps
      pkgs.coreutils
    ];
    text = ''
      if pgrep -x wf-recorder >/dev/null; then
        pkill -INT -x wf-recorder
        exit 0
      fi

      dir="${recordingDir}"
      mkdir -p "$dir"
      file="$dir/Aufnahme_$(date +%Y%m%d_%H%M%S).mp4"
      monitor=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name')
      args=(--file "$file")

      case "''${1:-screen}" in
        screen) args+=(--output "$monitor") ;;
        sound) args+=(--output "$monitor" --audio="$(pactl get-default-sink).monitor") ;;
        region)
          geometry=$(slurp) || exit 0 # Esc bricht die Auswahl ab
          args+=(--geometry "$geometry")
          ;;
        *) echo "Aufruf: record screen|sound|region" >&2; exit 1 ;;
      esac

      notify-send -a Aufnahme -i media-record "Aufnahme läuft" "Dasselbe Kürzel noch einmal beendet sie"
      wf-recorder "''${args[@]}" || true
      notify-send -a Aufnahme -i video-x-generic "Aufnahme gespeichert" "$file"
    '';
  };
in
{
  home.packages = [
    screenshot
    record
    pkgs.hyprpicker # Farbpipette (Super+Umschalt+C); friert auch das Bild beim Screenshot ein
  ];

  xdg.userDirs.extraConfig.SCREENSHOTS = screenshotDir;
}
