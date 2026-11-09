# cloud-init für den Container: läuft beim allerersten Start einmal. Legt den Nutzer an, installiert
# die Pakete aus Ubuntu und ruft dann provision auf, das den Rest erledigt (files.nix, provision.sh).
#
# Bewusst klein und von Hand als YAML geschrieben, ohne Anführungszeichen und Backslashes: der
# YAML-Generator der Preseed-Datei bricht Escape-Sequenzen in langen Zeilen falsch um.
{ lib }:

let
  packages = [
    "build-essential"
    "ca-certificates"
    "curl"
    "docker-buildx"
    "docker-compose-v2"
    "docker.io"
    "fd-find"
    "git"
    "jq"
    "openssh-client"
    "openssh-server"
    "python3"
    "python3-pip"
    "python3-venv"
    "ripgrep"
    "unzip"
    "zip"
  ];
in
# uid 1000 passt zu uid/gid des ssh-agent-Sockets in incus.nix. sudo im Container ist unkritisch:
# Docker macht ohnehin root, Geheimnisse liegen dort keine
''
  #cloud-config
  users:
    - name: dev
      uid: 1000
      shell: /bin/bash
      lock_passwd: true
      sudo: ALL=(ALL) NOPASSWD:ALL
  package_update: true
  package_upgrade: true
  packages:
  ${lib.concatMapStringsSep "\n" (p: "  - ${p}") packages}
  runcmd:
    - /opt/agent-sandbox/provision
''
