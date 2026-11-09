# Entwicklungswerkzeuge auf Desktop und Mac. Gibt es ein Home-Manager-Modul, dann darüber.
# Versionen pro Projekt kommen aus dessen Flake, hier steht nur der globale Stand
{ pkgs, ... }:

let
  inherit (pkgs.stdenv.hostPlatform) isDarwin;

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
  # Unter Linux aus nixpkgs, auf dem Mac aus Homebrew (home/packages.nix):
  # nixpkgs-Attribut = Homebrew-Formel, null = derselbe Name
  shared.tools = {
    # Sprachen, Build
    bun = null;
    nodejs = "node";
    rustup = null;
    cmake = null;
    protobuf = null;
    pipx = null;
    maven = null;
    gradle = null;

    # Kubernetes
    kubectl = "kubernetes-cli";
    kubernetes-helm = "helm";
    helmfile = null;
    kind = null;
    stern = null;
    kubectx = null;
    kn = null;

    # Container
    dive = null;
    hadolint = null;
    trivy = null;

    # Cloud, Secrets, Git-Hosting
    openstackclient = null;
    stripe-cli = null;
    terraform = "hashicorp/tap/terraform"; # homebrew/core führt es wegen der BSL-Lizenz nicht mehr
    mcp-grafana = null;
    sops = null;
    age = null;
    forgejo-cli = null;

    # Prüfen, Messen
    actionlint = null;
    shellcheck = null;
    k6 = null;
    tokei = null;
    httpie = null;

    # Medien, Dateien
    ffmpeg = null;
    exiftool = null;
    libjxl = "jpeg-xl";
    poppler-utils = "poppler";
    tree = null;
    yq-go = "yq";
    wget = null;

    # Netzwerk, Hardware
    nmap = null;
    iperf3 = null;
    mtr = null;
    socat = null;
    lftp = null;
    mediamtx = null;
    smartmontools = null;
    squashfsTools = "squashfs";
    dtc = null;
    ubootTools = "u-boot-tools"; # mkimage
    librealsense = null;

    # KI
    ollama = null;
  };

  # Nur Mac: unter Linux kommt docker mit virtualisation.docker, watch mit procps
  brew.formulas = [
    "docker"
    "watch"
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
    # JDK für Maven, Gradle und Projekte ohne eigenes
    java.enable = true;
  };
}
