# desktop.nix – Hyprland-Desktop für NixOS 26.05
# Zielhardware: Ryzen 7 5800X3D, RTX 4080, Btrfs auf NVMe
#
# Einbinden: in /etc/nixos/configuration.nix bei `imports` ergänzen:
#   imports = [ ./hardware-configuration.nix ./desktop.nix ];
# Danach: sudo nixos-rebuild switch  →  reboot

{ config, pkgs, ... }:

let
  user = "dave"; # ← dein Benutzername aus dem Installer
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

  # Bildschirmsperre (Tastenkürzel selbst binden) + Idle-Daemon
  programs.hyprlock.enable = true; # aktiviert automatisch auch hypridle

  # Statusleiste – startet automatisch mit der Hyprland-Sitzung
  programs.waybar.enable = true;

  # Passwortabfragen grafischer Programme (z. B. Mounten, GParted) –
  # startet ebenfalls automatisch mit der Sitzung
  systemd.packages = [ pkgs.hyprpolkitagent ];
  systemd.user.services.hyprpolkitagent.wantedBy = [ "graphical-session.target" ];

  # ───────────────────────── Login ─────────────────────────
  # Normaler Text-Login auf der ersten Konsole (Ctrl+Alt+F1). Nach dem Login
  # startet Hyprland automatisch. Auf den anderen Konsolen (F2–F6) bleibt es
  # bei einer normalen Shell – praktisch zum Reparieren.
  systemd.defaultUnit = "graphical.target"; # braucht uwsm für den Start
  environment.loginShellInit = ''
    if uwsm check may-start; then
      exec uwsm start -e -D Hyprland hyprland.desktop
    fi
  '';

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
  # hardware.bluetooth.enable = true;  # falls dein PC Bluetooth hat

  # ───────────────────────── Schriften ─────────────────────────
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-color-emoji
    nerd-fonts.jetbrains-mono # Icons für Waybar & Terminal
  ];

  # ───────────────────────── Programme ─────────────────────────
  programs.firefox.enable = true;
  programs.nix-ld.enable = true; # vorkompilierte Fremd-Binaries lauffähig machen

  environment.systemPackages = with pkgs; [
    # Was die Hyprland-Standardconfig per Tastenkürzel aufruft
    kitty # Terminal          (Super+Q)
    hyprlauncher # App-Starter (Super+R)
    kdePackages.dolphin # Dateimanager (Super+E)

    # Bausteine für einen kompletten Desktop
    mako # Benachrichtigungen   (in hyprland.lua autostarten)
    hyprpaper # Hintergrundbild (in hyprland.lua autostarten)
    grim # Screenshot
    slurp # Bereich auswählen (für Screenshots)
    wl-clipboard # Zwischenablage: wl-copy / wl-paste
    networkmanagerapplet # WLAN/LAN im Tray
    pavucontrol # Lautstärke & Audiogeräte
    playerctl # Medientasten

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
}
