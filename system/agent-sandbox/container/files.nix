# Dateien für den Container. Nix baut sie in ein Verzeichnis, das Incus schreibgeschützt nach
# /opt/agent-sandbox einhängt (Disk-Device in incus.nix); provision.sh installiert sie von dort.
#
# Nicht über cloud-init write_files, weil der YAML-Generator der Preseed-Datei (remarshal) lange
# Zeilen an Escape-Sequenzen falsch umbricht: aus "\n" wurde " n", Skripte kamen kaputt an. So geht
# kein Dateiinhalt durch YAML, und Änderungen brauchen keinen neuen Container: nach dem Rebuild im
# Container `sudo provision-agent`.
{
  lib,
  pkgs,
  s,
}:

let
  gitconfig = lib.generators.toGitINI {
    user = { inherit (s.git) name email; };
    # Signiert wird mit dem ersten Schlüssel im ssh-agent des Hosts, user.signingkey bleibt leer
    gpg.format = "ssh";
    gpg.ssh.defaultKeyCommand = "/usr/local/bin/git-signing-key";
    commit.gpgsign = true;
    tag.gpgsign = true;
    # Hooks für alle Repos, siehe git-hooks.sh
    core.hooksPath = "/etc/git/hooks";
    init.defaultBranch = "main";
    push.autoSetupRemote = true;
    fetch.prune = true;
    # HTTPS-URLs (z. B. beim Klonen aus T3 auf dem Handy) laufen trotzdem über SSH
    url."git@github.com:".insteadOf = "https://github.com/";
    url."ssh://git@git.dave.haus:${toString s.forgejoSshPort}/".insteadOf = [
      "https://git.dave.haus/"
      # Alte Remotes direkt auf den server: der ist aus dem Container nicht erreichbar
      "ssh://git@192.168.188.81:2222/"
    ];
  };

  # Ohne passenden Eintrag bricht ssh ab, statt nachzufragen (keine Abfrage ohne Terminal)
  knownHosts = ''
    github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl
    [git.dave.haus]:${toString s.forgejoSshPort} ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ0h1Ui2NmwuJTSVJ06T/c+PnvJNAmaFj9PWzKu+24iB
  '';

  sshConfig = ''
    # Alle SSH-Verbindungen über den ssh-agent des Hosts
    Host *
        IdentityAgent ${s.containerAgentSocket}
  '';

  # Für gpg.ssh.defaultKeyCommand: erwartet den öffentlichen Schlüssel mit "key::" davor
  gitSigningKey = ''
    #!/bin/sh
    keys=$(SSH_AUTH_SOCK=''${SSH_AUTH_SOCK:-${s.containerAgentSocket}} ssh-add -L) || exit 1
    printf 'key::%s\n' "$(printf '%s\n' "$keys" | head -n 1)"
  '';

  # Umgebung für T3 und alles, was es startet (Agents, deren Shells), als Drop-in für den Dienst,
  # den `t3 up` anlegt. environment.d reicht unter Ubuntu nicht: /etc/environment kommt dort als
  # 99-environment.conf zuletzt und ersetzt PATH, und gpg-agent-ssh.socket setzt SSH_AUTH_SOCK beim
  # Start auf seinen eigenen Socket. Environment= im Dienst schlägt beides
  t3ServiceEnv = ''
    [Service]
    Environment=PATH=/home/dev/.local/share/mise/shims:/home/dev/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
    Environment=SSH_AUTH_SOCK=${s.containerAgentSocket}
  '';

  # Dasselbe für Login-Shells (incus exec t3 -- su - dev)
  profile = ''
    export SSH_AUTH_SOCK=${s.containerAgentSocket}
    export PATH="$HOME/.local/share/mise/shims:$HOME/.local/bin:$PATH"
  '';

  # `t3` startet die aktive Runtime, die auch der Dienst nutzt. `t3 update` stellt activeVersion um,
  # danach zeigt der Befehl automatisch auf die neue Version (pkgs/update.sh nutzt das)
  t3Launcher = ''
    #!/bin/sh
    home=''${T3CODE_HOME:-$HOME/.t3}
    v=$(sed -n 's/.*"activeVersion": *"\([^"]*\)".*/\1/p' "$home/runtime/service-state.json")
    exec "$home/runtime/versions/$v/t3" "$@"
  '';

  # Nix im Container (provision.sh): Flakes an, die Repos nutzen sie
  nixConfig = ''
    experimental-features = nix-command flakes
  '';

  ghConfig = ''
    git_protocol: ssh
    prompt: disabled
  '';

  # Kein "Co-Authored-By: Claude" und kein "Generated with Claude Code"
  claudeSettings = builtins.toJSON {
    attribution = {
      commit = "";
      pr = "";
      sessionUrl = false;
    };
  };

  # target: Pfad im Container. text oder source: Inhalt. mode: Standard 0644.
  # once: nur anlegen, wenn es die Datei noch nicht gibt (Programme schreiben selbst hinein)
  files = [
    {
      target = "/etc/gitconfig";
      text = gitconfig;
    }
    {
      target = "/etc/ssh/ssh_known_hosts";
      text = knownHosts;
    }
    {
      target = "/etc/ssh/ssh_config.d/50-agent.conf";
      text = sshConfig;
    }
    {
      target = "/etc/profile.d/50-agent.sh";
      text = profile;
    }
    {
      target = "/etc/git/hooks/run";
      source = ./git-hooks.sh;
      mode = "0755";
    }
    {
      target = "/usr/local/bin/git-signing-key";
      text = gitSigningKey;
      mode = "0755";
    }
    {
      target = "/usr/local/bin/gh";
      source = ./gh.sh;
      mode = "0755";
    }
    {
      target = "/usr/local/bin/t3";
      text = t3Launcher;
      mode = "0755";
    }
    {
      target = "/usr/local/bin/forgejo-pr";
      source = ./forgejo-pr.sh;
      mode = "0755";
    }
    {
      target = "/usr/local/bin/grafana-mcp";
      source = ./grafana-mcp.sh;
      mode = "0755";
    }
    {
      target = "/home/dev/.config/systemd/user/t3code.service.d/50-agent.conf";
      text = t3ServiceEnv;
    }
    {
      target = "/home/dev/.config/nix/nix.conf";
      text = nixConfig;
    }
    {
      target = "/home/dev/.config/gh/config.yml";
      text = ghConfig;
      once = true;
    }
    {
      target = "/home/dev/.claude/settings.json";
      text = claudeSettings;
      once = true;
    }
    {
      target = "/home/dev/.claude/CLAUDE.md";
      source = ./AGENTS.md;
    }
    {
      target = "/home/dev/.codex/AGENTS.md";
      source = ./AGENTS.md;
    }
  ];

  source = f: f.source or (pkgs.writeText "agent-sandbox-file" f.text);

  # Eine install-Zeile pro Datei. Dateien im Home legt dev selbst an, sonst gehörten sie und neue
  # Verzeichnisse (~/.config …) root
  installLine =
    f:
    let
      cmd = "install -D -m ${f.mode or "0644"} \"$src${f.target}\" '${f.target}'";
      asOwner = if lib.hasPrefix "/home/dev/" f.target then "runuser -u dev -- ${cmd}" else cmd;
    in
    if f.once or false then "[ -e '${f.target}' ] || ${asOwner}\n" else "${asOwner}\n";

  installFiles = pkgs.writeText "install-files" (
    ''
      #!/bin/sh
      # Erzeugt aus files.nix: legt die Dateien aus /opt/agent-sandbox/root an ihren Platz
      set -eu
      src=/opt/agent-sandbox/root
    ''
    + lib.concatMapStrings installLine files
  );
in
pkgs.runCommand "agent-sandbox-files" { } ''
  ${lib.concatMapStrings (f: "install -D -m 0444 ${source f} $out/root${f.target}\n") files}
  install -D -m 0555 ${installFiles} $out/install-files
  install -D -m 0555 ${./provision.sh} $out/provision
''
