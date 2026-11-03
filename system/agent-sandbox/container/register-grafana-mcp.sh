#!/bin/sh
# register-grafana-mcp
# Meldet jede Grafana-Instanz aus ~/.config/mcp/grafana-<name>.env als MCP-Server grafana-<name>
# an, global bei Claude (Scope user) und Codex: dieselben Namen in beiden, in jedem Projekt.
# Schon angemeldete Server bleiben, wie sie sind. Als dev ausführen; provision.sh ruft es auf.
set -eu

for env_file in "$HOME"/.config/mcp/grafana-*.env; do
  [ -e "$env_file" ] || continue
  server=$(basename "$env_file" .env) # grafana-<name>
  name=${server#grafana-}

  if claude mcp get "$server" >/dev/null 2>&1; then
    echo "claude: $server schon angemeldet"
  else
    claude mcp add -s user "$server" -- grafana-mcp "$name"
  fi

  if codex mcp get "$server" >/dev/null 2>&1; then
    echo "codex:  $server schon angemeldet"
  else
    codex mcp add "$server" -- grafana-mcp "$name"
  fi
done
