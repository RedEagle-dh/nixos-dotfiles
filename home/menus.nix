# home/menus.nix – App-Starter, Benachrichtigungen und kleine Helfer.
#
# Alle Menüs nutzen fuzzel und sehen deshalb gleich aus:
#   Super+Leertaste  Programme        Super+V   Zwischenablage-Verlauf
#   Super+Esc        Power-Menü        Super+.   Emojis
#   Super+F1         Tastenkürzel-Übersicht
#
# Die Helfer sind kleine Shell-Skripte; die Tastenkürzel in hypr/keybinds.lua
# rufen sie über ihren Namen auf (z. B. "power-menu").

{ config, lib, pkgs, ... }:

let
  theme = import ../theme { inherit pkgs; };
  c = theme.colors;
  ui = theme.fonts.ui.name;
  mono = theme.fonts.mono.name;

  # Menü im einheitlichen Stil: fuzzel liest Zeilen und gibt die gewählte aus
  menu = ''fuzzel --dmenu --minimal-lines'';

  power-menu = pkgs.writeShellApplication {
    name = "power-menu";
    runtimeInputs = [ pkgs.fuzzel ];
    text = ''
      choice=$(printf '%s\n' \
        "  Sperren" \
        "󰍃  Abmelden" \
        "󰤄  Bereitschaft" \
        "  Neu starten" \
        "  Ausschalten" \
        | ${menu} --prompt "  " --placeholder "Was möchtest du tun?" --width 28) || exit 0

      case "$choice" in
        *Sperren) loginctl lock-session ;;
        *Abmelden) uwsm stop ;;
        *Bereitschaft) systemctl suspend ;;
        *"Neu starten") systemctl reboot ;;
        *Ausschalten) systemctl poweroff ;;
      esac
    '';
  };

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
        | ${menu} --with-nth 2 --prompt "󰅍  " --placeholder "Zwischenablage durchsuchen …" --width 60 \
        | cliphist decode \
        | wl-copy
    '';
  };

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
        def label: {
          "Return": "Enter", "space": "Leertaste", "period": ".", "Print": "Druck",
          "Escape": "Esc", "Tab": "Tab", "left": "←", "right": "→", "up": "↑", "down": "↓",
          "mouse:272": "Linke Maustaste", "mouse:273": "Rechte Maustaste",
          "mouse_down": "Mausrad", "mouse_up": "Mausrad",
          "XF86AudioRaiseVolume": "Lauter-Taste", "XF86AudioLowerVolume": "Leiser-Taste",
          "XF86AudioMute": "Stumm-Taste", "XF86AudioMicMute": "Mikrofon-Taste",
          "XF86AudioPlay": "Play-Taste", "XF86AudioNext": "Weiter-Taste", "XF86AudioPrev": "Zurück-Taste"
        }[.] // .;
        .[] | select(.has_description)
        | ((.modmask | mods) + [(.key | label)] | join(" + ")) as $combo
        | "\(.description)  ·  \($combo)"
      ' | ${menu} --prompt "  " --placeholder "Tastenkürzel suchen …" --width 70 --lines 18 >/dev/null || true
    '';
  };

  screenshot = pkgs.writeShellApplication {
    name = "screenshot";
    runtimeInputs = [
      pkgs.grimblast
      pkgs.satty
      pkgs.wl-clipboard
      pkgs.coreutils
    ];
    text = ''
      dir="${config.xdg.userDirs.extraConfig.SCREENSHOTS}"
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

  notifications = pkgs.writeShellApplication {
    name = "notifications";
    runtimeInputs = [ pkgs.mako ];
    text = ''
      case "''${1:-}" in
        toggle-dnd)
          makoctl mode -t do-not-disturb >/dev/null
          pkill -RTMIN+8 waybar || true # Glocke in der Leiste sofort aktualisieren
          ;;
        status) # für die Leiste
          if makoctl mode | grep -qx do-not-disturb; then
            printf '%s\n' '{"text": "󰂛", "class": "dnd", "tooltip": "Nicht stören ist an\nKlick: wieder einschalten"}'
          else
            printf '%s\n' '{"text": "󰂚", "class": "normal", "tooltip": "Benachrichtigungen\nKlick: nicht stören · Rechtsklick: letzte zurückholen"}'
          fi
          ;;
        *) echo "Aufruf: notifications toggle-dnd|status" >&2; exit 1 ;;
      esac
    '';
  };
in
{
  home.packages = [
    power-menu
    clipboard-menu
    emoji-menu
    keybind-help
    screenshot
    volume-osd
    notifications
    pkgs.hyprpicker # Farbpipette (Super+Umschalt+C)
    pkgs.wl-clipboard
    pkgs.libnotify
  ];

  # ───────────────────────── App-Starter ─────────────────────────
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        font = "${ui}:size=13,${mono}:size=13";
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

  # ───────────────────────── Benachrichtigungen ─────────────────────────
  services.mako = {
    enable = true;
    settings = {
      font = "${ui} 11";
      background-color = "#${c.surface}eb";
      text-color = "#${c.text}";
      border-color = "#${c.iris}";
      progress-color = "over #${c.highlightMed}";
      border-size = 2;
      border-radius = 14;
      padding = "14,16";
      margin = 14;
      width = 380;
      height = 160;
      icons = true;
      max-icon-size = 48;
      icon-path = "${theme.icons.package}/share/icons/${theme.icons.name}";
      default-timeout = 6000;
      max-visible = 5;
      layer = "top"; # im Vollbild (Spiele, Videos) nicht im Weg
      anchor = "top-right";
      format = ''<b>%s</b>\n%b'';

      "urgency=low" = {
        border-color = "#${c.highlightHigh}";
      };
      "urgency=critical" = {
        border-color = "#${c.love}";
        default-timeout = 0; # bleibt, bis man sie wegklickt
      };
      # Lautstärke-Anzeige: kleiner Balken unten in der Mitte
      "category=osd" = {
        anchor = "bottom-center";
        width = 300;
        height = 80;
        margin = 60;
        border-color = "#${c.foam}";
        progress-color = "over #${c.pine}";
        format = "<b>%s</b>  %b";
      };
      # Nicht stören (Super+Strg+N): nichts anzeigen, aber alles sammeln
      "mode=do-not-disturb" = {
        invisible = 1;
      };
    };
  };

  # ───────────────────────── Hintergrunddienste ─────────────────────────
  services.cliphist = {
    enable = true; # merkt sich alles Kopierte (Super+V)
    allowImages = true;
  };

  # WLAN/LAN-Icon in der Leiste (Rechtsklick: Netzwerke, VPN)
  services.network-manager-applet.enable = true;
  xsession.preferStatusNotifierItems = true; # Icon-Variante, die die Leiste anzeigen kann
}
