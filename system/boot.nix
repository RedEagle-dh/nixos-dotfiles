{
  lib,
  pkgs,
  theme,
  ...
}:

let
  menuTimeout = 5;

  windowsEfiPartition = "a56ea599-cf51-42bd-a406-dfbed40ae3f5";

  esp = "/boot";
  refindDir = "EFI/refind";

  # Ohne Patch malt rEFInd das Hintergrundbild doppelt und langsam, die Icons erst danach
  refind = pkgs.refind.overrideAttrs (old: {
    patches = old.patches ++ [ ./refind-fast-banner.patch ];
  });

  refindConf = pkgs.writeText "refind.conf" ''
    timeout ${toString menuTimeout}
    default_selection NixOS
    scanfor manual
    hideui hints,badges,arrows,editor,label
    use_graphics_for linux,windows

    # Die NVIDIA-Firmware startet sonst in niedriger Auflösung
    resolution max

    # Leeres "showtools" reicht in 0.14.2 nicht: Jeder Eintrag überschreibt nur
    # einen der 12 Standardplätze – also alle mit einem Werkzeug füllen, das es nicht gibt
    showtools ${lib.concatStringsSep "," (lib.replicate 12 "gdisk")}

    # Ohne vorhandenen Icon-Ordner schaltet rEFInd in den Textmodus
    icons_dir theme
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

      mapfile -t files < <(
        for f in "$entries"/nixos-*.conf; do
          echo "$(field version "$f" | sed -n 's/^Generation \([0-9]*\).*/\1/p') $f"
        done | sort -k 1,1nr | cut -d ' ' -f 2-
      )

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
    configurationLimit = 10;

    extraFiles = {
      "${refindDir}/refind_x64.efi" = "${refind}/share/refind/refind_x64.efi";
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

    extraInstallCommands = lib.getExe refindUpdate;
  };

  boot.loader.efi.canTouchEfiVariables = true;
}
