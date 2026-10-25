# home/audio.nix – Lautstärke-Tasten mit Anzeige und Medientasten.
# Wie die Anzeige aussieht, steht in notifications.nix (Abschnitt "category=osd").

{ pkgs, ... }:

let
  volume-osd = pkgs.writeShellApplication {
    name = "volume-osd";
    runtimeInputs = [
      pkgs.wireplumber
      pkgs.libnotify
      pkgs.gawk
    ];
    text = ''
      # Ändert die Lautstärke und zeigt sie kurz als Balken an
      idfile="''${XDG_RUNTIME_DIR:-/tmp}/volume-osd.id"
      device="@DEFAULT_AUDIO_SINK@"
      title="Lautstärke"

      case "''${1:-}" in
        up) wpctl set-mute "$device" 0; wpctl set-volume -l 1.0 "$device" 5%+ ;;
        down) wpctl set-volume "$device" 5%- ;;
        mute) wpctl set-mute "$device" toggle ;;
        mic-mute) device="@DEFAULT_AUDIO_SOURCE@"; title="Mikrofon"; wpctl set-mute "$device" toggle ;;
        *) echo "Aufruf: volume-osd up|down|mute|mic-mute" >&2; exit 1 ;;
      esac

      # "Volume: 0.45" oder "Volume: 0.45 [MUTED]"
      state=$(wpctl get-volume "$device")
      percent=$(awk '{ printf "%d", $2 * 100 + 0.5 }' <<<"$state")

      if [[ $state == *MUTED* ]]; then
        icon="audio-volume-muted"; text="Stumm"
        [[ $title == Mikrofon ]] && icon="microphone-sensitivity-muted"
      else
        icon="audio-volume-high"; text="$percent %"
        [[ $title == Mikrofon ]] && icon="audio-input-microphone"
        ((percent < 66)) && [[ $title != Mikrofon ]] && icon="audio-volume-medium"
        ((percent < 33)) && [[ $title != Mikrofon ]] && icon="audio-volume-low"
      fi

      # Vorherige Anzeige ersetzen statt neue zu stapeln
      replace=()
      [[ -s $idfile ]] && replace=(--replace-id "$(<"$idfile")")
      notify-send "''${replace[@]}" --print-id \
        --app-name volume-osd --category osd --icon "$icon" \
        --hint "int:value:$percent" --expire-time 1500 \
        "$title" "$text" >"$idfile"
    '';
  };
in
{
  home.packages = [
    volume-osd
    pkgs.pavucontrol # Lautstärke & Audiogeräte (Klick auf das Lautsprecher-Icon)
    pkgs.playerctl # Medientasten
  ];
}
