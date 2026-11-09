# Nur Mac: Apps ohne Linux-Fassung und Werkzeuge für Apple-Plattformen, aus Homebrew.
# Systemnahe Apps (Helfer, Bedienungshilfen) in darwin/apps.nix, weitere Casks in darwin/homebrew.nix
{ ... }:

{
  brew.casks = [
    "tableplus"
    "whatsapp"
    "chatgpt"
    "mactex-no-gui" # komplettes TeX Live
  ];

  # Xcode-Projekte
  brew.formulas = [
    "xcodegen"
    "cocoapods"
  ];
}
