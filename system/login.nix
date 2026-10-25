# system/login.nix – Grafischer Login-Bildschirm (SDDM).
#
# Uhr, Datum, Passwortfeld, Buttons zum Ausschalten/Neustarten – in den Farben
# und mit dem Hintergrundbild aus theme/. SDDM läuft selbst unter Wayland,
# ein X-Server ist nicht nötig. Auf Strg+Alt+F2–F6 gibt es weiterhin einen
# Text-Login zum Reparieren.

{ pkgs, theme, ... }:

let
  # Theme "sddm-astronaut", umgefärbt auf die Palette aus theme/
  loginTheme = pkgs.sddm-astronaut.override {
    embeddedTheme = "astronaut";
    themeConfig =
      let
        c = name: ''"#${theme.colors.${name}}"'';
      in
      {
        Background = ''"${theme.wallpaper}"'';
        Font = ''"${theme.fonts.ui.name}"'';
        DateFormat = ''"dddd, d. MMMM"'';
        HideVirtualKeyboard = "true";

        HeaderTextColor = c "text";
        DateTextColor = c "subtle";
        TimeTextColor = c "text";
        FormBackgroundColor = c "base";
        BackgroundColor = c "base";
        DimBackgroundColor = c "base";
        LoginFieldBackgroundColor = c "overlay";
        PasswordFieldBackgroundColor = c "overlay";
        LoginFieldTextColor = c "text";
        PasswordFieldTextColor = c "text";
        UserIconColor = c "iris";
        PasswordIconColor = c "iris";
        PlaceholderTextColor = c "subtle";
        WarningColor = c "love";
        LoginButtonTextColor = c "base";
        LoginButtonBackgroundColor = c "iris";
        SystemButtonsIconsColor = c "text";
        SessionButtonTextColor = c "subtle";
        VirtualKeyboardButtonTextColor = c "subtle";
        DropdownTextColor = c "text";
        DropdownSelectedBackgroundColor = c "highlightMed";
        DropdownBackgroundColor = c "surface";
        HighlightTextColor = c "base";
        HighlightBackgroundColor = c "iris";
        HighlightBorderColor = c "iris";
        HoverUserIconColor = c "rose";
        HoverPasswordIconColor = c "rose";
        HoverSystemButtonsIconsColor = c "rose";
        HoverSessionButtonTextColor = c "rose";
        HoverVirtualKeyboardButtonTextColor = c "rose";
      };
  };
in
{
  services.displayManager = {
    sddm = {
      enable = true;
      wayland.enable = true;
      theme = "${loginTheme}/share/sddm/themes/sddm-astronaut-theme";
      extraPackages = [ loginTheme ]; # Qt-Module, die das Theme braucht
    };
    # Hyprland über UWSM starten. Die "nackte" Hyprland-Sitzung startet
    # graphical-session.target nicht – dann fehlen Leiste & Polkit-Agent.
    defaultSession = "hyprland-uwsm";
  };
}
