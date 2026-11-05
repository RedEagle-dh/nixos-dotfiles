# Entwicklungswerkzeuge auf Desktop und Mac. Gibt es ein Home-Manager-Modul, dann darüber.
# Versionen pro Projekt kommen aus dessen Flake, hier steht nur der globale Stand
{ lib, pkgs, ... }:

let
  inherit (pkgs.stdenv.hostPlatform) isLinux isDarwin;

  # nixpkgs hat für opencodes node_modules einen falschen Hash (Hash mismatch auf beiden Systemen),
  # behoben in NixOS/nixpkgs#582675. Greift nur, solange der alte Hash drinsteht – nach einem
  # `nix flake update` mit dem Fix wirkungslos, dann diesen Block entfernen
  brokenHash = "sha256-xfOVcw1+waLVNhFDwzOtzxrUSQEogvn88YomydOlhwc=";
  opencode =
    if pkgs.opencode.node_modules.outputHash == brokenHash then
      pkgs.opencode.overrideAttrs (old: {
        node_modules = old.node_modules.overrideAttrs {
          outputHash =
            if isDarwin then
              "sha256-dIveiaiPFGSItwLyeMuPDxTE9gpvvnlTCB/+nG24qCc="
            else
              "sha256-prx9dX7kUvs/E3zopkaPk5LXh3xJAy5sZeum/W8L7cA=";
        };
      })
    else
      pkgs.opencode;
in
{
  home.packages =
    with pkgs;
    [
      # Sprachen, Build – Java, Maven und Gradle in neovim/default.nix
      bun
      nodejs
      rustup
      cmake
      protobuf
      pipx

      # Kubernetes
      kubectl
      kubernetes-helm
      helmfile
      kind
      stern
      kubectx
      kn

      # Container
      dive
      hadolint
      trivy

      # Cloud, Secrets, Git-Hosting
      openstackclient
      stripe-cli
      terraform
      mcp-grafana
      sops
      age
      forgejo-cli

      # Prüfen, Messen
      actionlint
      shellcheck
      k6
      tokei
      httpie

      # Medien, Dateien
      ffmpeg
      exiftool
      libjxl
      poppler-utils
      tree
      yq-go
      wget

      # Netzwerk, Hardware
      nmap
      iperf3
      mtr
      socat
      lftp
      mediamtx
      smartmontools
      squashfsTools
      dtc

      # KI
      ollama
      omp
    ]
    # Auf dem Mac aus brew (darwin/homebrew.nix), nixpkgs baut sie dort nicht
    ++ lib.optionals isLinux [
      ubootTools # mkimage
      librealsense # hängt an v4l-utils
    ]
    ++ lib.optionals isDarwin [
      docker-client # Linux: kommt mit virtualisation.docker
      watch # Linux: Teil von procps
    ];

  programs = {
    go.enable = true;
    awscli.enable = true;
    k9s.enable = true;
    jq.enable = true;
    micro.enable = true;
    ripgrep.enable = true;
    fd.enable = true;
    gpg.enable = true;
    opencode = {
      enable = true;
      package = opencode;
    };
  };
}
