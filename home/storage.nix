# Eigene Subvolumes, damit snapper sie nicht mitnimmt. Schon ein normaler Ordner?
# Umwandeln (Launcher vorher beenden):
#   mv <ordner> <ordner>.alt && btrfs subvolume create <ordner>
#   cp -a --reflink=always <ordner>.alt/. <ordner>/ && rm -rf <ordner>.alt

{
  config,
  lib,
  pkgs,
  ...
}:

let
  home = config.home.homeDirectory;
  folders = [
    "${home}/.local/share/Steam"
    "${home}/Games"
    "${home}/.config/heroic/tools"
    "${home}/.local/share/umu"
  ];
in
{
  home.activation.gameSubvolumes = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    for dir in ${lib.escapeShellArgs folders}; do
      if [ ! -e "$dir" ]; then
        run mkdir -p "$(dirname "$dir")"
        run ${pkgs.btrfs-progs}/bin/btrfs -q subvolume create "$dir" \
          || warnEcho "Konnte $dir nicht als Subvolume anlegen"
      elif [ "$(stat -c %i "$dir")" != 256 ]; then # 256 = Wurzel eines Subvolumes
        warnEcho "$dir ist ein normaler Ordner und landet in den Snapshots – umwandeln: siehe home/storage.nix"
      fi
    done
  '';
}
