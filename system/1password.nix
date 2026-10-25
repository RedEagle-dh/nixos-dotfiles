# system/1password.nix – 1Password.
#
# Muss ins System, nicht in Home Manager: Das Modul legt eine Benutzergruppe,
# Hilfsprogramme mit besonderen Rechten (Browser-Erweiterung, `op`) und eine
# Polkit-Regel an.

{ user, ... }:

{
  programs._1password.enable = true; # Kommandozeile `op`
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ user ]; # Entsperren mit dem Systempasswort
  };
}
