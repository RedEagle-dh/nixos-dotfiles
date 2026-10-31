{ ... }:

{
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    # Für Akkustand von Headsets
    settings.General.Experimental = true;
  };
}
