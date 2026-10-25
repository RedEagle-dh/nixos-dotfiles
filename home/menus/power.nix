# home/menus/power.nix – Power-Menü (Super+Esc, Power-Knopf in der Leiste).

{ pkgs, ... }:

let
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
        | fuzzel --dmenu --minimal-lines --prompt "  " --placeholder "Was möchtest du tun?" --width 28) || exit 0

      case "$choice" in
        *Sperren) loginctl lock-session ;;
        *Abmelden) uwsm stop ;;
        *Bereitschaft) systemctl suspend ;;
        *"Neu starten") systemctl reboot ;;
        *Ausschalten) systemctl poweroff ;;
      esac
    '';
  };
in
{
  home.packages = [ power-menu ];
}
