# theme/plymouth.nix – Startbildschirm beim Hoch- und Herunterfahren.
#
# Zeigt das Hintergrundbild mit dem NixOS-Logo in den Akzentfarben und einem
# dezenten Spinner darunter. Fragt das System nach einem Passwort (z. B. für
# eine verschlüsselte Festplatte), erscheint dort stattdessen ein Eingabefeld.
# Danach übernimmt Hyprland mit demselben Hintergrundbild (Sperrbildschirm).
#
# Alle Grafiken entstehen beim Bauen aus SVG und sind für eine Bildhöhe von
# 1440 Pixeln gerendert; auf anderen Monitoren skaliert das Skript sie mit.

{
  pkgs,
  colors,
  wallpaper,
  nixosLogo,
}:

let
  inherit (pkgs) lib;
  c = colors;
  name = "splash";

  # Schrift für Passwortabfrage und Meldungen
  fontFile = "${pkgs.inter}/share/fonts/truetype/InterVariable.ttf";
  fontName = "Inter Variable";

  # Plymouth-Skripte erwarten Farben als drei Zahlen zwischen 0 und 1
  rgb =
    color:
    lib.concatMapStringsSep ", "
      (i: toString (lib.fromHexString (builtins.substring i 2 c.${color}) / 255.0))
      [
        0
        2
        4
      ];

  # Spinner: blasser Ring, darauf ein umlaufender Bogen – als Einzelbilder
  spinnerFrames = 60;
  spinnerFrame =
    i:
    pkgs.writeText "spinner-${toString i}.svg" ''
      <svg xmlns="http://www.w3.org/2000/svg" width="44" height="44" viewBox="0 0 44 44">
        <circle cx="22" cy="22" r="18" fill="none" stroke="#${c.text}" stroke-opacity="0.12" stroke-width="3"/>
        <circle cx="22" cy="22" r="18" fill="none" stroke="#${c.iris}" stroke-width="3"
                stroke-linecap="round" stroke-dasharray="30 83.1"
                transform="rotate(${toString (i * 360 / spinnerFrames)} 22 22)"/>
      </svg>
    '';

  # Eingabefeld für Passwörter und ein Punkt pro eingegebenem Zeichen
  field = pkgs.writeText "field.svg" ''
    <svg xmlns="http://www.w3.org/2000/svg" width="380" height="52" viewBox="0 0 380 52">
      <rect x="1" y="1" width="378" height="50" rx="25" fill="#${c.surface}" fill-opacity="0.85"
            stroke="#${c.highlightHigh}" stroke-width="1.5"/>
    </svg>
  '';
  bullet = pkgs.writeText "bullet.svg" ''
    <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 12 12">
      <circle cx="6" cy="6" r="5" fill="#${c.text}"/>
    </svg>
  '';

  script = pkgs.writeText "${name}.script" ''
    # Erzeugt von theme/plymouth.nix – Änderungen bitte dort.

    Window.SetBackgroundTopColor(${rgb "base"});
    Window.SetBackgroundBottomColor(${rgb "base"});

    screen_w = Window.GetWidth();
    screen_h = Window.GetHeight();
    scale = screen_h / 1440;

    fun scaled(image) {
      if (scale == 1)
        return image;
      return image.Scale(Math.Int(image.GetWidth() * scale), Math.Int(image.GetHeight() * scale));
    }

    fun centered_x(image) {
      return Math.Int((screen_w - image.GetWidth()) / 2);
    }

    font = "${fontName} " + Math.Int(13 * scale);

    # --- Hintergrund und Logo -------------------------------------------------

    background = Sprite(Image("background.png").Scale(screen_w, screen_h));
    background.SetPosition(0, 0, -100);

    logo_image = scaled(Image("logo.png"));
    logo = Sprite(logo_image);
    logo.SetPosition(centered_x(logo_image), Math.Int((screen_h - logo_image.GetHeight()) / 2), 10);

    # --- Spinner -------------------------------------------------------------

    for (i = 0; i < ${toString spinnerFrames}; i++)
      spinner_frames[i] = scaled(Image("spinner-" + i + ".png"));

    lower_y = Math.Int(screen_h * 0.76);
    spinner = Sprite(spinner_frames[0]);
    spinner.SetPosition(centered_x(spinner_frames[0]), lower_y, 10);

    # --- Passwortabfrage (unsichtbar, bis jemand fragt) -----------------------

    field_image = scaled(Image("field.png"));
    field_x = centered_x(field_image);
    field = Sprite(field_image);
    field.SetPosition(field_x, lower_y, 20);

    bullet_image = scaled(Image("bullet.png"));
    bullet_step = Math.Int(bullet_image.GetWidth() * 1.8);
    bullet_max = Math.Int((field_image.GetWidth() - 2 * field_image.GetHeight()) / bullet_step);
    bullet_y = lower_y + Math.Int((field_image.GetHeight() - bullet_image.GetHeight()) / 2);
    bullet_count = 0;

    prompt = Sprite();
    answer = Sprite();
    message = Sprite();

    # --- Zustand: 0 = Spinner, 1 = Eingabefeld --------------------------------

    asking = 0;
    has_answer = 0;
    has_message = 0;
    tick = 0;

    fun refresh() {
      global.tick = global.tick + 1;
      fade = Math.Min(global.tick / 25, 1); # in einer halben Sekunde einblenden

      background.SetOpacity(fade);
      logo.SetOpacity(fade);
      message.SetOpacity(fade * global.has_message);

      spinner.SetImage(spinner_frames[Math.Int(global.tick / 1.2) % ${toString spinnerFrames}]);
      spinner.SetOpacity(fade * (1 - global.asking));

      field.SetOpacity(global.asking);
      prompt.SetOpacity(global.asking);
      answer.SetOpacity(global.asking * global.has_answer);
      for (i = 0; i < global.bullet_count; i++)
        global.bullets[i].SetOpacity(global.asking);
    }
    Plymouth.SetRefreshFunction(refresh);

    fun show_prompt(text) {
      global.asking = 1;
      image = Image.Text(text, ${rgb "subtle"}, 1, font);
      prompt.SetImage(image);
      prompt.SetPosition(centered_x(image), lower_y - image.GetHeight() - Math.Int(14 * scale), 20);
    }

    fun show_bullets(count) {
      count = Math.Min(count, bullet_max);
      start = Math.Int((screen_w - count * bullet_step + bullet_step - bullet_image.GetWidth()) / 2);
      for (i = 0; i < count; i++) {
        if (i >= global.bullet_count) {
          global.bullets[i] = Sprite(bullet_image);
          global.bullets[i].SetZ(30);
          global.bullet_count = i + 1;
        }
        global.bullets[i].SetPosition(start + i * bullet_step, bullet_y, 30);
      }
      # Überzählige Punkte (nach Löschen) aus dem Bild schieben
      for (i = count; i < global.bullet_count; i++)
        global.bullets[i].SetPosition(-1000, -1000, 30);
    }

    fun display_password(text, count) {
      show_prompt(text);
      global.has_answer = 0;
      show_bullets(count);
    }
    Plymouth.SetDisplayPasswordFunction(display_password);

    fun display_question(text, entry) {
      show_prompt(text);
      show_bullets(0);
      image = Image.Text(entry, ${rgb "text"}, 1, font);
      answer.SetImage(image);
      global.has_answer = 1;
      answer.SetPosition(centered_x(image), lower_y + Math.Int((field_image.GetHeight() - image.GetHeight()) / 2), 30);
    }
    Plymouth.SetDisplayQuestionFunction(display_question);

    fun display_normal() {
      global.asking = 0;
    }
    Plymouth.SetDisplayNormalFunction(display_normal);

    # Meldungen vom System (selten, z. B. Dateisystemprüfung) klein am unteren Rand
    fun display_message(text) {
      image = Image.Text(text, ${rgb "subtle"}, 1, font);
      message.SetImage(image);
      message.SetPosition(centered_x(image), Math.Int(screen_h * 0.92), 20);
      global.has_message = 1;
    }
    Plymouth.SetMessageFunction(display_message);

    fun hide_message(text) {
      global.has_message = 0;
    }
    Plymouth.SetHideMessageFunction(hide_message);
  '';
in
pkgs.runCommand "plymouth-theme-${name}"
  {
    nativeBuildInputs = [ pkgs.resvg ];
    passthru = { inherit name fontFile; };
  }
  ''
    dir=$out/share/plymouth/themes/${name}
    mkdir -p $dir

    cp ${wallpaper} $dir/background.png
    resvg --width 200 --height 200 ${nixosLogo} $dir/logo.png
    resvg ${field} $dir/field.png
    resvg ${bullet} $dir/bullet.png
    ${lib.concatMapStrings (i: ''
      resvg ${spinnerFrame i} $dir/spinner-${toString i}.png
    '') (lib.range 0 (spinnerFrames - 1))}

    cp ${script} $dir/${name}.script
    cat > $dir/${name}.plymouth <<EOF
    [Plymouth Theme]
    Name=${name}
    Description=Startbildschirm in den Farben aus theme/
    ModuleName=script

    [script]
    ImageDir=$dir
    ScriptFile=$dir/${name}.script
    EOF
  ''
