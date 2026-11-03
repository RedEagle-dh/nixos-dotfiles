#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

claude=https://downloads.claude.ai/claude-code-releases
version=$(curl -fsSL "$claude/latest")
curl -fsSL "$claude/$version/manifest.zst.json" -o claude-code.json

t3=pingdotgg/t3code
tag=$(curl -fsSL "https://api.github.com/repos/$t3/releases?per_page=30" |
  grep -o '"tag_name": *"v[^"]*-nightly\.[^"]*"' | head -1 | cut -d'"' -f4)
sha=$(curl -fsSL "https://github.com/$t3/releases/download/$tag/nightly-linux.yml" | sed -n 's/^sha512: //p')
printf '{\n  "version": "%s",\n  "hash": "sha512-%s"\n}\n' "${tag#v}" "${sha:?}" >t3code-nightly.json

echo "claude-code $version, t3code ${tag#v}"

# T3-Server im Agent-Container (system/agent-sandbox) auf dieselbe Version wie die App. `t3 update`
# lädt die Runtime aus demselben Release (t3-<version>-linux-x64.tar.gz) und startet den Dienst neu,
# laufende Agent-Turns brechen dabei ab. Die App selbst bekommt die Version erst mit dem Rebuild
if command -v incus >/dev/null && incus info t3 >/dev/null 2>&1; then
  incus exec t3 -- runuser -l dev -c "t3 update ${tag#v} --yes"
else
  echo "T3-Server nicht aktualisiert: kein incus oder kein Container t3 (nur auf dem Desktop möglich)" >&2
fi
