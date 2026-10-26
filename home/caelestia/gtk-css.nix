{ lib }:

{
  accent,
  onAccent,
  error,
  onError,
  success,
  warning,
  onStatus,
  window,
  view,
  fg,
  headerbar,
  sidebar,
  secondarySidebar,
  card,
  popover,
  border,
}:
let
  shade = "rgba(0, 0, 0, 0.36)";
  colors = {
    accent_color = accent;
    accent_bg_color = accent;
    accent_fg_color = onAccent;
    destructive_color = error;
    destructive_bg_color = error;
    destructive_fg_color = onError;
    error_color = error;
    error_bg_color = error;
    error_fg_color = onError;
    success_color = success;
    success_bg_color = success;
    success_fg_color = onStatus;
    warning_color = warning;
    warning_bg_color = warning;
    warning_fg_color = onStatus;

    window_bg_color = window;
    window_fg_color = fg;
    view_bg_color = view;
    view_fg_color = fg;
    headerbar_bg_color = headerbar;
    headerbar_fg_color = fg;
    headerbar_border_color = border;
    headerbar_backdrop_color = window;
    headerbar_shade_color = shade;
    headerbar_darker_shade_color = "rgba(0, 0, 0, 0.9)";
    sidebar_bg_color = sidebar;
    sidebar_fg_color = fg;
    sidebar_backdrop_color = window;
    sidebar_border_color = border;
    sidebar_shade_color = shade;
    secondary_sidebar_bg_color = secondarySidebar;
    secondary_sidebar_fg_color = fg;
    secondary_sidebar_backdrop_color = window;
    secondary_sidebar_border_color = border;
    secondary_sidebar_shade_color = shade;
    card_bg_color = card;
    card_fg_color = fg;
    card_shade_color = shade;
    dialog_bg_color = popover;
    dialog_fg_color = fg;
    popover_bg_color = popover;
    popover_fg_color = fg;
    popover_shade_color = shade;
    thumbnail_bg_color = popover;
    thumbnail_fg_color = fg;
    shade_color = shade;
    scrollbar_outline_color = "rgba(0, 0, 0, 0.5)";
  };

  definedColors = lib.concatStrings (
    lib.mapAttrsToList (name: value: "@define-color ${name} ${value};\n") colors
  );
  cssVariables = lib.concatStrings (
    lib.mapAttrsToList (
      name: value: "  --${builtins.replaceStrings [ "_" ] [ "-" ] name}: ${value};\n"
    ) colors
  );
in
{
  gtk3 = definedColors;
  gtk4 = definedColors + ":root {\n${cssVariables}}\n";
}
