# home/waybar/clock.nix – mittlere Insel: Datum & Uhrzeit, Kalender beim Drüberfahren.

{ theme, ... }:

let
  c = theme.colors;
in
{
  programs.waybar.settings.main.clock = {
    format = "{:%a %d. %b   %H:%M}";
    locale = "de_DE.UTF-8";
    tooltip-format = "<tt>{calendar}</tt>";
    calendar = {
      mode = "month";
      weeks-pos = "left";
      on-scroll = 1;
      format = {
        months = "<span color='#${c.rose}'><b>{}</b></span>";
        weekdays = "<span color='#${c.subtle}'>{}</span>";
        weeks = "<span color='#${c.muted}'>{}</span>";
        days = "<span color='#${c.text}'>{}</span>";
        today = "<span color='#${c.base}' background='#${c.iris}'><b>{}</b></span>";
      };
    };
    actions = {
      on-scroll-up = "shift_up";
      on-scroll-down = "shift_down";
      on-click-right = "mode"; # Monats- ↔ Jahresansicht
    };
  };
}
