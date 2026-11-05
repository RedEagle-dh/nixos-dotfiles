# Systemnahe Mac-Apps mit Helfern oder Bedienungshilfe-Rechten – systemweit, landen als Kopie unter
# /Applications/Nix Apps. Alle sind die unveränderte, signierte App des Herstellers
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    orbstack
    aldente
    raycast
    mos
  ];
}
