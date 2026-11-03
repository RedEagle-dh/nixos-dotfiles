#!/bin/sh
# grafana-mcp <name> [weitere mcp-grafana-Flags]
# Startet den Grafana-MCP-Server (stdio, nur lesend) für eine Grafana-Instanz. Claude und Codex
# starten ihn selbst. URL und Token stehen pro Instanz in ~/.config/mcp/grafana-<name>.env:
#   GRAFANA_URL=https://grafana.dave.haus
#   GRAFANA_SERVICE_ACCOUNT_TOKEN=glsa_…        (Service Account mit Rolle Viewer)
#   GRAFANA_MCP_TOOLS=…                         (optional, siehe unten)
# Loki und Prometheus fragt der Server über die Datenquellen dieser Grafana ab.
# Angemeldet wird jede Instanz als grafana-<name>, global bei Claude und Codex:
# register-grafana-mcp (läuft auch in provision.sh).
#
# Nur die Werkzeuge fürs Debuggen: 22 statt 62, ~5,8k statt ~14k Tokens an Definitionen (gezählt
# mit o200k). Claude und Codex laden MCP-Werkzeuge zwar erst bei Bedarf (Tool Search), aber weniger
# Werkzeuge heißt weniger Rauschen bei der Suche. Mehr für eine Instanz, z. B. Traces und Alerts:
#   GRAFANA_MCP_TOOLS=search,datasource,prometheus,loki,dashboard,tempo,alerting
set -eu
name=${1:?usage: grafana-mcp <name>}
shift

env_file="$HOME/.config/mcp/grafana-$name.env"
if [ ! -r "$env_file" ]; then
  echo "grafana-mcp: $env_file fehlt" >&2
  exit 1
fi

set -a
. "$env_file"
set +a
exec mcp-grafana --disable-write \
  --enabled-tools="${GRAFANA_MCP_TOOLS:-search,datasource,prometheus,loki,dashboard}" "$@"
