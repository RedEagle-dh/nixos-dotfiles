# home/terminal.nix – Kitty und die Shell (bash).
#
# Kitty ist leicht durchsichtig; Hyprland legt Milchglas dahinter.
# In der Shell: Prompt mit Git-Status (starship), `z ordner` springt in oft
# benutzte Ordner (zoxide), `ls` mit Icons (eza), `bat` statt `cat` mit
# Syntaxfarben, Strg+R durchsucht den Verlauf (fzf).

{ pkgs, ... }:

let
  theme = import ../theme { inherit pkgs; };
  c = theme.colors;
  hex = name: "#${c.${name}}";
in
{
  programs.kitty = {
    enable = true;
    font = {
      inherit (theme.fonts.mono) name package size;
    };
    settings = {
      background_opacity = "0.9";
      window_padding_width = 14;
      confirm_os_window_close = 0;
      enable_audio_bell = false;
      scrollback_lines = 20000;
      cursor_shape = "beam";
      cursor_trail = 3; # Cursor zieht beim Springen einen kurzen Schweif
      url_style = "curly";
      tab_bar_edge = "bottom";
      tab_bar_style = "powerline";
      tab_powerline_style = "slanted";

      # Farben: Rosé Pine
      foreground = hex "text";
      background = hex "base";
      selection_foreground = hex "text";
      selection_background = hex "highlightMed";
      cursor = hex "highlightHigh";
      cursor_text_color = hex "text";
      url_color = hex "iris";
      active_tab_foreground = hex "text";
      active_tab_background = hex "overlay";
      inactive_tab_foreground = hex "muted";
      inactive_tab_background = hex "base";
      tab_bar_background = hex "base";
      active_border_color = hex "pine";
      inactive_border_color = hex "highlightMed";

      color0 = hex "overlay";
      color8 = hex "muted";
      color1 = hex "love";
      color9 = hex "love";
      color2 = hex "pine";
      color10 = hex "pine";
      color3 = hex "gold";
      color11 = hex "gold";
      color4 = hex "foam";
      color12 = hex "foam";
      color5 = hex "iris";
      color13 = hex "iris";
      color6 = hex "rose";
      color14 = hex "rose";
      color7 = hex "text";
      color15 = hex "text";
    };
    keybindings = {
      "ctrl+shift+enter" = "new_window_with_cwd";
      "ctrl+shift+t" = "new_tab_with_cwd";
    };
  };

  # ───────────────────────── Shell ─────────────────────────
  programs.bash = {
    enable = true;
    historyControl = [
      "ignoredups"
      "erasedups"
    ];
    historySize = 50000;
    shellAliases = 
      {
      ".." = "cd ..";
      "..." = "cd ../..";
      "nhs" = "nh os boot";
      "nhb" = "nh os switch";
    };
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;
      format = "$directory$git_branch$git_status$nix_shell$python$nodejs$bun$rust$cmd_duration$line_break$character";

      directory = {
        style = "bold ${hex "iris"}";
        truncation_length = 3;
        truncate_to_repo = true;
        read_only = " 󰌾";
      };
      git_branch = {
        format = "[$symbol$branch]($style) ";
        symbol = " ";
        style = hex "rose";
      };
      git_status = {
        format = "([$all_status$ahead_behind]($style) )";
        style = hex "love";
      };
      nix_shell = {
        format = "[$symbol$name]($style) ";
        symbol = " ";
        style = hex "foam";
      };
      python.format = "[$symbol($version )]($style)";
      nodejs.format = "[$symbol($version )]($style)";
      bun.format = "[$symbol($version )]($style)";
      rust.format = "[$symbol($version )]($style)";
      cmd_duration = {
        format = "[ $duration]($style) ";
        style = hex "gold";
        min_time = 2000;
      };
      character = {
        success_symbol = "[❯](bold ${hex "iris"})";
        error_symbol = "[❯](bold ${hex "love"})";
      };
    };
  };

  programs.zoxide.enable = true;

  programs.eza = {
    enable = true; # ls, ll, la, lt
    icons = "auto";
    git = true;
  };

  programs.bat = {
    enable = true;
    config.theme = "ansi"; # nutzt die Terminalfarben → passt zur Palette
  };

  programs.fzf = {
    enable = true;
    colors = {
      fg = hex "subtle";
      "fg+" = hex "text";
      bg = "-1";
      "bg+" = hex "overlay";
      hl = hex "rose";
      "hl+" = hex "rose";
      border = hex "highlightMed";
      header = hex "pine";
      gutter = "-1";
      spinner = hex "gold";
      info = hex "foam";
      pointer = hex "iris";
      marker = hex "love";
      prompt = hex "subtle";
    };
  };

  programs.btop = {
    enable = true; # Systemmonitor (Klick auf CPU/RAM/GPU in der Leiste)
    settings = {
      color_theme = "TTY"; # nutzt die Terminalfarben
      theme_background = false;
      rounded_corners = true;
    };
  };
}
