# "Open in Zed" in T3 Code für Projekte im Container. T3 kennt für ein entferntes Environment nur
# Zed über SSH (zed://ssh/<nutzer>@<host>/<pfad>), und auch das nur, wenn der Server dort einen sshd
# sieht. ~/developer liegt im Container aber unter demselben Pfad wie auf dem Host (incus.nix), also
# öffnet Zed hier einfach den Ordner auf dem Host, ganz ohne SSH:
#
#   1. Im Container lauscht ein Platzhalter auf 127.0.0.1:22 (container/files.nix). T3 prüft nur, ob
#      sich dort eine Verbindung aufbauen lässt, und meldet dann dev@t3.local als Ziel
#   2. Die Desktop-App ruft zed://ssh/dev@t3.local/<pfad> auf
#   3. Der Handler unten öffnet <pfad> mit dem Zed des Hosts. Andere zed://-Links gehen wie bisher
#      direkt an Zed
#
# Worktrees, die T3 unter ~/.t3/worktrees anlegt, gibt es nur im Container. Wer die auch öffnen will:
# in T3 unter Einstellungen das Worktree-Verzeichnis nach ~/developer legen
{
  lib,
  pkgs,
  user,
  ...
}:

let
  s = import ./settings.nix;
  developer = "/home/${user}/developer";

  handler = pkgs.writeShellApplication {
    name = "zed-url-handler";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.libnotify
    ];
    # zeditor bewusst aus PATH: das Paket aus programs.zed-editor ist mit nixd & Co. umhüllt
    text = ''
      url=''${1:-}
      rest=''${url#zed://ssh/}
      host=''${rest%%/*}
      host=''${host##*@}

      if [[ $url != zed://ssh/* || $host != "${s.container}.local" ]]; then
        exec zeditor "$url"
      fi

      # T3 kodiert jeden Pfadteil mit encodeURIComponent, %XX wird wieder zum Zeichen
      encoded=''${rest#*/}
      [[ $rest == */* ]] || encoded=
      path=$(printf '%b' "/''${encoded//%/\\x}")

      # Nur was nach dem Auflösen von Symlinks wirklich unter ~/developer liegt: Agents können dort
      # Links auf beliebige Stellen des Hosts anlegen
      if real=$(realpath -e -- "$path" 2>/dev/null) &&
        [[ $real == "${developer}" || $real == "${developer}"/* ]]; then
        exec zeditor "$real"
      fi

      notify-send --app-name=Zed "Nicht auf dem Host" "$path liegt nicht unter ~/developer"
      exit 1
    '';
  };
in
{
  home-manager.users.${user} = {
    xdg.desktopEntries.zed-url-handler = {
      name = "Zed (Links aus T3)";
      exec = "${lib.getExe handler} %u";
      mimeType = [ "x-scheme-handler/zed" ];
      noDisplay = true;
    };
    xdg.mimeApps.defaultApplications."x-scheme-handler/zed" = "zed-url-handler.desktop";
  };
}
