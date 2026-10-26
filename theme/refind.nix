{
  pkgs,
  colors,
  wallpaper,
  nixosLogo,
}:

let
  c = colors;

  # rEFInd zeichnet den Auswahlrahmen 9/8 so groß wie die Icons
  iconSize = 256;
  selectionSize = iconSize * 9 / 8;

  windowsLogo = pkgs.writeText "windows.svg" ''
    <svg xmlns="http://www.w3.org/2000/svg" width="256" height="256" viewBox="0 0 256 256">
      <g fill="#${c.foam}">
        <rect x="60" y="60" width="64" height="64" rx="6"/>
        <rect x="132" y="60" width="64" height="64" rx="6"/>
        <rect x="60" y="132" width="64" height="64" rx="6"/>
        <rect x="132" y="132" width="64" height="64" rx="6"/>
      </g>
    </svg>
  '';

  selection =
    size:
    let
      s = toString size;
      inner = toString (size - 4);
      radius = toString (size / 5);
    in
    pkgs.writeText "selection-${s}.svg" ''
      <svg xmlns="http://www.w3.org/2000/svg" width="${s}" height="${s}" viewBox="0 0 ${s} ${s}">
        <rect x="2" y="2" width="${inner}" height="${inner}" rx="${radius}"
              fill="#${c.overlay}" fill-opacity="0.55"
              stroke="#${c.iris}" stroke-opacity="0.9" stroke-width="3"/>
      </svg>
    '';

  # Zeichen müssen schwarz sein – rEFInd invertiert sie auf dunklem Grund selbst.
  fontScript = pkgs.writeText "make-font.py" ''
    import sys
    from PIL import Image, ImageDraw, ImageFont

    path, size, color, out = sys.argv[1], int(sys.argv[2]), sys.argv[3], sys.argv[4]
    font = ImageFont.truetype(path, size)
    ascent, descent = font.getmetrics()
    width, height = round(font.getlength("M")), ascent + descent
    rgba = tuple(int(color[i : i + 2], 16) for i in (0, 2, 4)) + (255,)

    image = Image.new("RGBA", (width * 96, height), (0, 0, 0, 0))
    draw = ImageDraw.Draw(image)
    for i, char in enumerate([chr(n) for n in range(32, 127)] + ["?"]):
        draw.text((i * width, 0), char, font=font, fill=rgba)
    image.save(out)
  '';
  fontFile = "${pkgs.nerd-fonts.jetbrains-mono}/share/fonts/truetype/NerdFonts/JetBrainsMono/JetBrainsMonoNerdFontMono-Regular.ttf";
in
pkgs.runCommand "refind-theme"
  {
    nativeBuildInputs = [
      pkgs.resvg
      pkgs.imagemagick
      (pkgs.python3.withPackages (ps: [ ps.pillow ]))
    ];
    passthru = { inherit iconSize; };
  }
  ''
    mkdir -p $out
    cp ${wallpaper} $out/background.png

    resvg --width 176 --height 176 ${nixosLogo} logo.png
    magick logo.png -background none -gravity center -extent ${toString iconSize}x${toString iconSize} $out/os_nixos.png
    resvg ${windowsLogo} $out/os_windows.png

    resvg ${selection selectionSize} $out/selection_big.png
    resvg ${selection 64} $out/selection_small.png

    python3 ${fontScript} ${fontFile} 26 000000 $out/font.png
  ''
