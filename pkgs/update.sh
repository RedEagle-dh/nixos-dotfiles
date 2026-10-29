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
