# system/boot.nix – Bootloader (Limine).
#
# Das Bootmenü bleibt beim normalen Start unsichtbar. Wer während der kurzen
# Wartezeit eine Taste drückt, bekommt es zu sehen: mit allen älteren
# NixOS-Generationen (falls ein Update etwas kaputt gemacht hat) und Windows.
# Aussehen aus theme/: Hintergrundbild und Farbpalette.
#
# Notausgang, falls Limine selbst nicht startet: im Boot-Menü des Mainboards
# (meist F8 oder F11) "Linux Boot Manager" (altes systemd-boot) oder
# "Windows Boot Manager" wählen.

{ theme, ... }:

let
  c = theme.colors;

  # Windows liegt auf der anderen SSD mit eigener EFI-Partition.
  # Partitions-ID nachschauen: lsblk -o NAME,PARTUUID,PARTTYPENAME
  windowsEfiPartition = "a56ea599-cf51-42bd-a406-dfbed40ae3f5";
in
{
  boot.loader.limine = {
    enable = true;

    # Max. 10 Generationen im Bootmenü, damit /boot nicht vollläuft
    maxGenerations = 10;

    # Menü nur zeigen, wenn während der Wartezeit eine Taste gedrückt wird
    extraConfig = ''
      quiet: yes
    '';

    style = {
      wallpapers = [ theme.bootWallpaper ];
      interface = {
        branding = "NixOS";
        brandingColor = c.iris;
        helpHidden = true; # Tastenhilfe ausblenden: Pfeiltasten + Enter genügen
      };
      graphicalTerminal = {
        font.scale = "2x2"; # Standardschrift ist auf 1440p winzig
        # Reihenfolge: schwarz, rot, grün, gelb, blau, magenta, cyan, weiß
        palette = "${c.overlay};${c.love};${c.pine};${c.gold};${c.foam};${c.iris};${c.rose};${c.text}";
        brightPalette = "${c.muted};${c.love};${c.pine};${c.gold};${c.foam};${c.iris};${c.rose};${c.text}";
        foreground = c.text;
        brightForeground = c.text;
      };
    };

    extraEntries = ''
      /Windows
        protocol: efi
        path: guid(${windowsEfiPartition}):/EFI/Microsoft/Boot/bootmgfw.efi
    '';
  };

  boot.loader.efi.canTouchEfiVariables = true;

  # Sekunden, in denen ein Tastendruck das Menü öffnet
  boot.loader.timeout = 2;
}
