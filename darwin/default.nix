# nix-darwin – Gegenstück zu configuration.nix + system/ für das MacBook
{ user, ... }:

{
  imports = [
    ./nix.nix
    ./homebrew.nix
    ./1password.nix
    ./vpn.nix
    ./apps.nix
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";

  # Name des Macs. LocalHostName ist der Name, nach dem darwin-rebuild den
  # Flake-Eintrag darwinConfigurations.elder sucht (ohne #…)
  networking = {
    hostName = "elder";
    localHostName = "elder";
    computerName = "elder";
  };

  # Aktivierung läuft als root – homebrew, system.defaults & Co. brauchen den eigentlichen Nutzer
  system.primaryUser = user;

  users.users.${user}.home = "/Users/${user}";

  # sudo per Touch ID statt Passwort (/etc/pam.d/sudo_local, übersteht macOS-Updates). reattach
  # macht Touch ID auch in tmux/zellij möglich
  security.pam.services.sudo_local = {
    touchIdAuth = true;
    reattach = true;
  };

  # Wie unter Linux (home/appearance.nix): dunkel, Akzentfarbe Lila. Greift nach Ab- und Anmelden
  system.defaults.NSGlobalDomain.AppleInterfaceStyle = "Dark";
  system.defaults.CustomUserPreferences.NSGlobalDomain = {
    AppleAccentColor = 5;
    AppleHighlightColor = "0.968627 0.831373 1.000000 Purple";
  };

  # Nie ändern – wie system.stateVersion unter NixOS
  system.stateVersion = 7;
}
