{
  pkgs,
  colors,
  width ? 3840,
  height ? 2160,
}:

let
  inherit (pkgs) lib;
  c = colors;

  ribbon =
    {
      lines,
      start,
      c1,
      c2,
      end,
      colorA,
      colorB,
      strength,
    }:
    lib.concatMapStrings (
      i:
      let
        t = i * 1.0 / (lines - 1);
        y = p: toString (builtins.elemAt p 0 + builtins.elemAt p 1 * t);
        opacity = toString (0.04 + strength * (1 - (2 * t - 1) * (2 * t - 1)));
        color = if lib.mod i 2 == 0 then colorA else colorB;
      in
      ''
        <path d="M -200 ${y start} C 1100 ${y c1}, 2500 ${y c2}, 4040 ${y end}"
              stroke="#${color}" stroke-opacity="${opacity}" stroke-width="2.2"/>
      ''
    ) (lib.range 0 (lines - 1));

  svg = pkgs.writeText "wallpaper.svg" ''
    <svg xmlns="http://www.w3.org/2000/svg" width="3840" height="2160" viewBox="0 0 3840 2160">
      <defs>
        <filter id="clouds" x="-50%" y="-50%" width="200%" height="200%">
          <feGaussianBlur stdDeviation="240"/>
        </filter>
        <filter id="glow" x="-5%" y="-30%" width="110%" height="160%">
          <feGaussianBlur stdDeviation="14" result="blur"/>
          <feMerge><feMergeNode in="blur"/><feMergeNode in="SourceGraphic"/></feMerge>
        </filter>
        <filter id="grain" x="0" y="0" width="100%" height="100%">
          <feTurbulence type="fractalNoise" baseFrequency="0.85" numOctaves="2" stitchTiles="stitch"/>
          <feColorMatrix type="saturate" values="0"/>
          <feComponentTransfer><feFuncA type="linear" slope="0.06"/></feComponentTransfer>
        </filter>
        <radialGradient id="vignette" cx="50%" cy="45%" r="75%">
          <stop offset="55%" stop-color="#000000" stop-opacity="0"/>
          <stop offset="100%" stop-color="#000000" stop-opacity="0.5"/>
        </radialGradient>
      </defs>

      <rect width="3840" height="2160" fill="#${c.base}"/>

      <g filter="url(#clouds)">
        <ellipse cx="650"  cy="1900" rx="1150" ry="720" fill="#${c.pine}" opacity="0.60"/>
        <ellipse cx="1150" cy="450"  rx="950"  ry="560" fill="#${c.iris}" opacity="0.28"/>
        <ellipse cx="3250" cy="1800" rx="900"  ry="600" fill="#${c.iris}" opacity="0.20"/>
        <ellipse cx="2500" cy="2200" rx="850"  ry="420" fill="#${c.love}" opacity="0.26"/>
        <ellipse cx="3400" cy="300"  rx="750"  ry="420" fill="#${c.foam}" opacity="0.12"/>
      </g>

      <g fill="none" stroke-linecap="round" filter="url(#glow)">
    ${ribbon {
      lines = 22;
      start = [
        1650
        200
      ];
      c1 = [
        1050
        380
      ];
      c2 = [
        1650
        (-260)
      ];
      end = [
        980
        220
      ];
      colorA = c.rose;
      colorB = c.love;
      strength = 0.12;
    }}
    ${ribbon {
      lines = 30;
      start = [
        1500
        260
      ];
      c1 = [
        650
        520
      ];
      c2 = [
        2050
        (-420)
      ];
      end = [
        760
        300
      ];
      colorA = c.iris;
      colorB = c.rose;
      strength = 0.32;
    }}
      </g>

      <rect width="3840" height="2160" fill="url(#vignette)"/>
      <rect width="3840" height="2160" filter="url(#grain)"/>
    </svg>
  '';
in
pkgs.runCommand "wallpaper.png" { nativeBuildInputs = [ pkgs.resvg ]; } ''
  resvg --width ${toString width} --height ${toString height} ${svg} $out
''
