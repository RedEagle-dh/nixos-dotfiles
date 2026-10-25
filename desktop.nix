# desktop.nix – Hyprland-Desktop für NixOS 26.05, System-Teil
# Zielhardware: Ryzen 7 5800X3D, RTX 4080, Btrfs auf NVMe
#
# Hier steht alles, was das System betrifft: Treiber, Dienste, Login, Schriften.
# Wie der Desktop aussieht und sich bedient (Hyprland, Leiste, Tastenkürzel …),
# steht unter home/ – das verwaltet Home Manager.

{ config, pkgs, ... }:

let
  user = "dave"; # ← dein Benutzername aus dem Installer
  theme = import ./theme { inherit pkgs; };

  # Login-Bildschirm: Theme "sddm-astronaut", umgefärbt auf die Palette aus
  # theme/ und mit demselben Hintergrundbild wie der Desktop
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
  # ───────────────────────── Unfreie Pakete ─────────────────────────
  # Nötig für den NVIDIA-Treiber (und später z. B. Steam, Discord, VS Code).
  nixpkgs.config.allowUnfree = true;

  # ───────────────────────── NVIDIA RTX 4080 ─────────────────────────
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # 32-Bit-Treiber für Steam/Proton
  };
  services.xserver.videoDrivers = [ "nvidia" ]; # heißt so, gilt aber auch für Wayland

  # Treiber schon in der frühen Bootphase laden ("Early KMS"). Sonst übernimmt die
  # Karte erst, wenn der Login-Bildschirm schon läuft → schwarzer Bildschirm mit "_".
  boot.initrd.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_drm" ];
  hardware.nvidia = {
    open = true; # offene Kernelmodule – für RTX 20xx und neuer empfohlen
    modesetting.enable = true; # Pflicht für Wayland/Hyprland
    nvidiaSettings = true; # GUI-Tool "nvidia-settings"

    # Nur einschalten, falls das Bild nach Standby kaputt ist oder Apps abstürzen:
    # powerManagement.enable = true;
  };

  # ───────────────────────── Hyprland ─────────────────────────
  # UWSM verbindet Hyprland sauber mit systemd (vom NixOS-Wiki empfohlen).
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true; # für ältere X11-Programme und viele Spiele
  };

  # Electron-/Chromium-Apps (VS Code, Discord, Obsidian …) nativ unter Wayland
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Bildschirmsperre + Idle-Daemon. Das Aussehen steht in home/hyprland.nix;
  # hier geht es nur um die Passwortprüfung (PAM) und den Dienst.
  programs.hyprlock.enable = true; # aktiviert automatisch auch hypridle

  # Statusleiste – startet automatisch mit der Hyprland-Sitzung (Aussehen: home/waybar.nix)
  programs.waybar.enable = true;

  # Passwortabfragen grafischer Programme (z. B. Mounten, GParted) –
  # startet ebenfalls automatisch mit der Sitzung
  systemd.packages = [ pkgs.hyprpolkitagent ];
  systemd.user.services.hyprpolkitagent.wantedBy = [ "graphical-session.target" ];

  # ───────────────────────── Login ─────────────────────────
  # Grafischer Login-Bildschirm (SDDM) mit Uhr, Datum und Buttons zum
  # Ausschalten/Neustarten. SDDM läuft selbst unter Wayland – ein X-Server ist
  # nicht nötig. Auf den Konsolen Ctrl+Alt+F2–F6 gibt es weiterhin einen
  # Text-Login – praktisch zum Reparieren.
  services.displayManager = {
    sddm = {
      enable = true;
      wayland.enable = true;
      theme = "${loginTheme}/share/sddm/themes/sddm-astronaut-theme";
      extraPackages = [ loginTheme ]; # Qt-Module, die das Theme braucht
    };
    # Hyprland wie bisher über UWSM starten. Die "nackte" Hyprland-Sitzung
    # startet graphical-session.target nicht – dann fehlen Waybar & Polkit-Agent.
    defaultSession = "hyprland-uwsm";
  };

  # ───────────────────────── Sound ─────────────────────────
  security.rtkit.enable = true;
  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true; # Kompatibilität für PulseAudio-Apps
    wireplumber.enable = true;
  };

  # ───────────────────────── Desktop-Dienste ─────────────────────────
  networking.networkmanager.enable = true;
  security.polkit.enable = true;
  services.gnome.gnome-keyring.enable = true; # Passwortspeicher (Browser, VS Code, WLAN)
  security.pam.services.login.enableGnomeKeyring = true; # Keyring beim Login entsperren
  programs.dconf.enable = true; # GTK-Einstellungen
  services.udisks2.enable = true; # USB-Sticks einhängen
  services.gvfs.enable = true; # Papierkorb, Netzlaufwerke im Dateimanager
  services.gnome.sushi.enable = true; # Leertaste im Dateimanager = Schnellvorschau
  # hardware.bluetooth.enable = true;  # falls dein PC Bluetooth hat

  # ───────────────────────── Schriften ─────────────────────────
  # Systemweit, damit auch der Login-Bildschirm sie findet
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-color-emoji
    theme.fonts.ui.package # Inter – Oberflächen
    theme.fonts.mono.package # JetBrains Mono mit Icons – Terminal, Leiste
  ];
  # Programme ohne eigene Schriftwahl bekommen dieselben Schriften
  fonts.fontconfig.defaultFonts = {
    sansSerif = [
      theme.fonts.ui.name
      "Noto Sans"
    ];
    monospace = [ theme.fonts.mono.name ];
    emoji = [ "Noto Color Emoji" ];
  };

  # ───────────────────────── Programme ─────────────────────────
  # Desktop-Programme (Terminal, Starter, Screenshots …) stehen in home/.
  programs.firefox.enable = true;
  programs.nix-ld.enable = true; # vorkompilierte Fremd-Binaries lauffähig machen

  programs._1password.enable = true;
  programs._1password-gui.enable = {
    enable = true;
    polkitPolicyOwners = [ user ];
  };

  # Dateimanager Nautilus mit "In Kitty öffnen" im Rechtsklickmenü
  programs.nautilus-open-any-terminal = {
    enable = true;
    terminal = "kitty";
  };

  environment.systemPackages = with pkgs; [
    nautilus # Dateimanager (Super+E)

    # Basics
    git
    vim
    btop
    wget
    curl
    unzip
    bun
  ];

  # ───────────────────────── Docker mit GPU ─────────────────────────
  virtualisation.docker.enable = true;
  hardware.nvidia-container-toolkit.enable = true; # GPU im Container: --device nvidia.com/gpu=all
  users.users.${user}.extraGroups = [ "docker" ]; # wird zu den Gruppen aus dem Installer ergänzt

  # ───────────────────────── Swap ─────────────────────────
  # Komprimierter Swap im RAM statt Swap-Partition: fängt Lastspitzen ab
  # (große Builds, LLM-Experimente), ohne dass das System einfriert.
  zramSwap.enable = true;

  # ───────────────────────── Btrfs & Aufräumen ─────────────────────────
  # Prüft monatlich alle Btrfs-Dateisysteme auf Datenfehler.
  # Schaltet sich nur ein, wenn überhaupt ein Btrfs-Dateisystem vorhanden ist –
  # die Datei funktioniert also mit ext4 genauso.
  services.btrfs.autoScrub = {
    enable = builtins.any (fs: fs.fsType == "btrfs") (builtins.attrValues config.fileSystems);
    interval = "monthly";
  };

  boot.loader.systemd-boot.configurationLimit = 10; # max. 10 Generationen im Bootmenü, /boot läuft nicht voll
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };
  nix.settings.auto-optimise-store = true; # identische Dateien im /nix/store zusammenlegen
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ]; # dieses Repo ist ein Flake
}
