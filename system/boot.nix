# system/boot.nix – Bootmenü (rEFInd) und Bootloader (systemd-boot).
#
# Beim Start erscheint rEFInd: links Windows, rechts NixOS, im Hintergrund das
# Wallpaper. NixOS ist vorausgewählt und startet nach ein paar Sekunden von
# selbst – immer die neueste Generation. Ältere Generationen (falls ein Update
# etwas kaputt gemacht hat): NixOS markieren und Tab oder F2 drücken.
#
# Aufgabenteilung: systemd-boot verwaltet wie gewohnt Kernel und Generationen
# in /boot. Nach jedem Rebuild baut ein Skript daraus das rEFInd-Menü und
# setzt rEFInd an die erste Stelle der Bootreihenfolge.
#
# Notausgang, falls rEFInd nicht startet: im Boot-Menü des Mainboards
# (meist F8 oder F11) "Linux Boot Manager" (= systemd-boot) wählen.

{ pkgs, theme, ... }:

let
  menuTimeout = 5; # Sekunden bis NixOS von selbst startet

  # Windows liegt auf der anderen SSD mit eigener EFI-Partition.
  # Partitions-ID nachschauen: lsblk -o NAME,PARTUUID,PARTTYPENAME
  windowsEfiPartition = "a56ea599-cf51-42bd-a406-dfbed40ae3f5";

  esp = "/boot";
  refindDir = "EFI/refind";

  # Fester Teil von refind.conf. Die Reihenfolge der Einträge ist die
  # Reihenfolge der Icons (Windows links, NixOS rechts).
  refindConf = pkgs.writeText "refind.conf" ''
    timeout ${toString menuTimeout}
    default_selection NixOS
    scanfor manual
    showtools
    hideui hints,badges,arrows,editor
    resolution max
    use_graphics_for linux,windows

    banner theme/background.png
    banner_scale fillscreen
    big_icon_size ${toString theme.refind.iconSize}
    selection_big theme/selection_big.png
    selection_small theme/selection_small.png
    font theme/font.png

    menuentry "Windows" {
        icon /${refindDir}/theme/os_windows.png
        volume ${windowsEfiPartition}
        loader /EFI/Microsoft/Boot/bootmgfw.efi
        graphics on
    }
  '';

  # Läuft nach jedem Rebuild: hängt den NixOS-Eintrag an refind.conf an und
  # sorgt dafür, dass rEFInd als Erstes startet.
  refindUpdate = pkgs.writeShellApplication {
    name = "refind-update";
    runtimeInputs = with pkgs; [
      coreutils
      gnused
      gnugrep
      efibootmgr
      util-linux
    ];
    text = ''
      entries=${esp}/loader/entries

      field() { sed -n "s/^$1[[:space:]]\+//p" "$2" | head -n 1; }

      # Alle NixOS-Einträge von systemd-boot, neueste Generation zuerst
      mapfile -t files < <(
        for f in "$entries"/nixos-*.conf; do
          echo "$(field version "$f" | sed -n 's/^Generation \([0-9]*\).*/\1/p') $f"
        done | sort -k 1,1nr | cut -d ' ' -f 2-
      )

      # Standard laut systemd-boot (nach `nh os boot` die neue Generation)
      id=$(field preferred ${esp}/loader/loader.conf)
      [[ -n $id ]] || id=$(field default ${esp}/loader/loader.conf)
      id=''${id%.conf}
      default=''${files[0]}
      for f in "''${files[@]}"; do
        name=$(basename "$f" .conf)
        if [[ ''${name%%+*} == "$id" ]]; then default=$f; fi
      done

      stanza() {
        echo "$2loader $(field linux "$1")"
        echo "$2initrd $(field initrd "$1")"
        echo "$2options \"$(field options "$1" | tr -d '"')\""
      }

      conf=${esp}/${refindDir}/refind.conf
      {
        cat ${refindConf}
        echo
        echo 'menuentry "NixOS" {'
        echo "    icon /${refindDir}/theme/os_nixos.png"
        echo "    graphics on"
        stanza "$default" "    "
        for f in "''${files[@]}"; do
          [[ $f == "$default" ]] && continue
          version=$(field version "$f")
          label="Generation $(echo "$version" | sed -n 's/^Generation \([0-9]*\).*/\1/p')"
          label+="  -  $(echo "$version" | sed -n 's/.*built on //p')"
          label+="  -  Linux $(echo "$version" | sed -n 's/.*(Linux \([^)]*\)).*/\1/p')"
          special=$(field title "$f" | sed -n 's/.*(\(.*\))$/\1/p')
          [[ -n $special ]] && label+="  ($special)"
          echo "    submenuentry \"$label\" {"
          stanza "$f" "        "
          echo "    }"
        done
        echo "}"
      } > "$conf.tmp"
      mv "$conf.tmp" "$conf"

      # Booteintrag "rEFInd" anlegen bzw. an die erste Stelle setzen
      num=$(efibootmgr | sed -n 's/^Boot\([0-9A-Fa-f]\{4\}\)\*\{0,1\} rEFInd[[:space:]].*/\1/p' | head -n 1)
      if [[ -z $num ]]; then
        part=$(findmnt -n -o SOURCE ${esp})
        disk=/dev/$(lsblk -n -o PKNAME "$part")
        efibootmgr -q -c -d "$disk" -p "$(cat "/sys/class/block/$(basename "$part")/partition")" \
          -l '\${builtins.replaceStrings [ "/" ] [ "\\" ] refindDir}\refind_x64.efi' -L rEFInd
      else
        order=$(efibootmgr | sed -n 's/^BootOrder: //p')
        if [[ $order != "$num"* ]]; then
          rest=$(tr ',' '\n' <<< "$order" | grep -v -i -x "$num" | paste -s -d ,)
          efibootmgr -q -o "$num''${rest:+,$rest}"
        fi
      fi
    '';
  };
in
{
  boot.loader.systemd-boot = {
    enable = true;

    # Max. 10 Generationen, damit /boot nicht vollläuft
    configurationLimit = 10;

    # rEFInd selbst und sein Theme nach /boot kopieren
    extraFiles = {
      "${refindDir}/refind_x64.efi" = "${pkgs.refind}/share/refind/refind_x64.efi";
    }
    // builtins.listToAttrs (
      map
        (name: {
          name = "${refindDir}/theme/${name}";
          value = "${theme.refind}/${name}";
        })
        [
          "background.png"
          "os_nixos.png"
          "os_windows.png"
          "selection_big.png"
          "selection_small.png"
          "font.png"
        ]
    );

    extraInstallCommands = "${pkgs.lib.getExe refindUpdate}";
  };

  boot.loader.efi.canTouchEfiVariables = true;
}
