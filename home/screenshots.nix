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

  record = pkgs.writeShellApplication {
    name = "record";
    runtimeInputs = [
      pkgs.wf-recorder
      pkgs.slurp
      pkgs.pulseaudio # pactl
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
          geometry=$(slurp) || exit 0
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
    pkgs.hyprpicker # braucht auch grimblast --freeze
  ];

  xdg.userDirs.extraConfig.SCREENSHOTS = screenshotDir;
}
