#!/usr/bin/env bash
# Richtet den Agent-Container ein. Läuft beim ersten Start über cloud-init (runcmd) und lässt sich
# jederzeit erneut ausführen, z. B. nach einem Rebuild mit geänderten Dateien: sudo provision-agent
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

# Als dev in einer Login-Shell, damit /etc/profile.d/50-agent.sh PATH setzt (mise, ~/.local/bin)
as_dev() { runuser -l dev -c "$1"; }

# Dateien aus dem Dotfiles-Repo (files.nix) an ihren Platz, Incus hängt sie unter /opt ein
/opt/agent-sandbox/install-files
ln -sf /opt/agent-sandbox/provision /usr/local/sbin/provision-agent
# Geänderte Drop-ins (t3code.service.d) bekannt machen. Neu gestartet wird T3 bewusst nicht, das
# würde laufende Agents abbrechen: bei Bedarf selbst `systemctl --user restart t3code`
if [ -d /run/user/1000/systemd ]; then
  runuser -u dev -- env XDG_RUNTIME_DIR=/run/user/1000 systemctl --user daemon-reload || true
fi

# Jeder Hook-Name zeigt auf dasselbe Skript, siehe /etc/git/hooks/run
for hook in applypatch-msg pre-applypatch post-applypatch pre-commit pre-merge-commit \
  prepare-commit-msg commit-msg post-commit pre-rebase post-checkout post-merge pre-push \
  post-rewrite; do
  ln -sf run "/etc/git/hooks/$hook"
done

# GitHub CLI aus dem offiziellen Repo, die aus Ubuntu ist zu alt
if [ ! -f /etc/apt/sources.list.d/github-cli.list ]; then
  install -d -m 0755 /etc/apt/keyrings
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    -o /etc/apt/keyrings/githubcli-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    >/etc/apt/sources.list.d/github-cli.list
  apt-get update
fi
apt-get install -y gh

# Docker ohne sudo; Nutzerdienste von dev (T3) laufen ab dem Booten, ohne Login
usermod -aG docker dev
loginctl enable-linger dev

# Node, pnpm und bun über mise: Projekte können eigene Versionen festlegen (.nvmrc, mise.toml)
as_dev 'command -v mise >/dev/null || curl -fsSL https://mise.run | sh'
as_dev 'mise use -g node@lts pnpm@latest bun@latest'
# Codex braucht Node, darum erst danach
as_dev 'mise use -g npm:@openai/codex@latest'
# Grafana-MCP-Server (fertiges Binary aus den GitHub-Releases), gestartet über grafana-mcp
as_dev "mise use -g 'github:grafana/mcp-grafana[asset_pattern=mcp-grafana_Linux_x86_64.tar.gz]@latest'"

# Nix als Werkzeug für die Nix-Repos (nix fmt im pre-commit-Hook, nix eval, nix flake check). Das
# System bleibt Ubuntu. Einzelnutzer-Installation: kein Daemon, keine Build-Nutzer, /nix gehört dev.
# Flakes schaltet ~/.config/nix/nix.conf aus files.nix ein
if [ ! -x /home/dev/.nix-profile/bin/nix ]; then
  install -d -m 0755 -o dev -g dev /nix
  as_dev 'curl -fsSL https://nixos.org/nix/install | sh -s -- --no-daemon --no-channel-add --no-modify-profile'
fi
# Links in /usr/local/bin statt PATH-Eintrag: liegt schon in jedem PATH, auch im laufenden T3-Dienst
for bin in /home/dev/.nix-profile/bin/nix*; do
  ln -sf "$bin" /usr/local/bin/
done
as_dev 'command -v claude >/dev/null || curl -fsSL https://claude.ai/install.sh | bash'

# Systembibliotheken für Playwright-Chromium. Die Browser selbst lädt jedes Projekt passend zu
# seiner Playwright-Version: npx playwright install chromium
node_bin=$(as_dev 'dirname "$(mise which node)"')
PATH="$node_bin:$PATH" npx -y playwright install-deps chromium

# Grafana-Instanzen aus ~/.config/mcp/grafana-*.env bei Claude und Codex anmelden (braucht beide)
as_dev register-grafana-mcp
