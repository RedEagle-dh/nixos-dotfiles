# home/notifications.nix – Benachrichtigungen (mako) und "Nicht stören".
#   Super+N           schließen
#   Super+Umschalt+N  letzte zurückholen
#   Super+Strg+N      "Nicht stören" an/aus (auch Klick auf die Glocke in der Leiste)

{ pkgs, theme, ... }:

let
  c = theme.colors;

  notifications = pkgs.writeShellApplication {
    name = "notifications";
    runtimeInputs = [ pkgs.mako ];
    text = ''
      case "''${1:-}" in
        toggle-dnd)
          makoctl mode -t do-not-disturb >/dev/null
          qs ipc call notifications refresh >/dev/null 2>&1 || true # Glocke in der Leiste sofort aktualisieren
          ;;
        *) echo "Aufruf: notifications toggle-dnd" >&2; exit 1 ;;
      esac
    '';
  };
in
{
  home.packages = [
    notifications
    pkgs.libnotify # notify-send
  ];

  services.mako = {
    enable = true;
    settings = {
      font = "${theme.fonts.ui.name} 11";
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
      # Lautstärke-Anzeige (audio.nix): kleiner Balken unten in der Mitte
      "category=osd" = {
        anchor = "bottom-center";
        width = 300;
        height = 80;
        margin = 60;
        border-color = "#${c.foam}";
        progress-color = "over #${c.pine}";
        format = "<b>%s</b>  %b";
      };
      # Nicht stören: nichts anzeigen, aber alles sammeln
      "mode=do-not-disturb" = {
        invisible = 1;
      };
    };
  };
}
