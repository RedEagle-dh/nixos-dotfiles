# Nur Mac: Apps ohne Linux-Fassung in nixpkgs und Werkzeuge für Apple-Plattformen.
# Systemnahe Apps (Helfer, Bedienungshilfen) in darwin/apps.nix, Casks in darwin/homebrew.nix
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    tableplus
    whatsapp-for-mac
    chatgpt

    # Xcode-Projekte
    xcodegen
    cocoapods
  ];

  # Ersatz für MacTeX (komplettes TeX Live)
  programs.texlive = {
    enable = true;
    extraPackages = tpkgs: { inherit (tpkgs) scheme-full; };
  };
}
