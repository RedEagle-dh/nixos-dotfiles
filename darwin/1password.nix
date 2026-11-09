# Wie system/1password.nix. Die App liegt als Cask unter /Applications (Git-Signatur in
# home/terminal/git.nix), `op` kommt nach /opt/homebrew/bin.
# SSH-Agent und Git-Signatur brauchen die laufende App: in 1Password "Beim Anmelden starten" einschalten
{ ... }:

{
  homebrew.casks = [
    "1password"
    "1password-cli"
  ];
}
