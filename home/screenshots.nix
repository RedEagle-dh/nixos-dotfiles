# home/screenshots.nix – Screenshots (Druck, Super+Umschalt+S …) und Farbpipette.
# Screenshots landen in der Zwischenablage und unter ~/Pictures/Screenshots.

{ config, pkgs, ... }:

let
  screenshotDir = "${config.home.homeDirectory}/Pictures/Screenshots";

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
in
{
  home.packages = [
    screenshot
    pkgs.hyprpicker # Farbpipette (Super+Umschalt+C); friert auch das Bild beim Screenshot ein
  ];

  xdg.userDirs.extraConfig.SCREENSHOTS = screenshotDir;
}
