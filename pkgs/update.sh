#!/usr/bin/env bash
set -euo pipefail

if ! command -v prefetch-npm-deps >/dev/null; then
  exec nix shell nixpkgs#nodejs nixpkgs#jq nixpkgs#prefetch-npm-deps -c "$0" "$@"
fi

cd "$(dirname "${BASH_SOURCE[0]}")"

claude=https://downloads.claude.ai/claude-code-releases
version=$(curl -fsSL "$claude/latest")
curl -fsSL "$claude/$version/manifest.zst.json" -o claude-code.json

t3=pingdotgg/t3code
tag=$(curl -fsSL "https://api.github.com/repos/$t3/releases?per_page=30" |
  grep -o '"tag_name": *"v[^"]*-nightly\.[^"]*"' | head -1 | cut -d'"' -f4)
sha=$(curl -fsSL "https://github.com/$t3/releases/download/$tag/nightly-linux.yml" | sed -n 's/^sha512: //p')
# Mac: der Hash der arm64-zip steht in der Zeile nach ihrer url
mac_sha=$(curl -fsSL "https://github.com/$t3/releases/download/$tag/nightly-mac.yml" |
  awk '/arm64\.zip$/ { getline; sub(/^ *sha512: /, ""); print; exit }')
printf '{\n  "version": "%s",\n  "hash": "sha512-%s",\n  "darwinHash": "sha512-%s"\n}\n' \
  "${tag#v}" "${sha:?}" "${mac_sha:?}" >t3code-nightly.json

cc=$(curl -fsSL https://registry.npmjs.org/command-code/latest)
cc_version=$(jq -r .version <<<"$cc")
cc_tmp=$(mktemp -d)
curl -fsSL "$(jq -r .dist.tarball <<<"$cc")" | tar xz -C "$cc_tmp"
jq 'del(.devDependencies)' "$cc_tmp/package/package.json" >"$cc_tmp/package.json"
(cd "$cc_tmp" && npm install --package-lock-only --ignore-scripts --no-audit --no-fund >/dev/null)
cp "$cc_tmp/package-lock.json" command-code/package-lock.json
jq -n --arg version "$cc_version" --arg hash "$(jq -r .dist.integrity <<<"$cc")" \
  --arg npmDepsHash "$(prefetch-npm-deps command-code/package-lock.json 2>/dev/null)" \
  '{$version, $hash, $npmDepsHash}' >command-code/source.json
rm -rf "$cc_tmp"

# Mac-Apps aus den Installern der Hersteller. Die Hashes liefern beide ohne Download mit:
# NetBird über die GitHub-API (digest), Tailscale als .sha256 neben dem Installer
nb=$(curl -fsSL https://api.github.com/repos/netbirdio/netbird/releases/latest)
nb_version=$(jq -r '.tag_name | ltrimstr("v")' <<<"$nb")
nb_sha=$(jq -r --arg name "netbird_${nb_version}_darwin_arm64.pkg" \
  '.assets[] | select(.name == $name) | .digest | ltrimstr("sha256:")' <<<"$nb")
nb_hash=$(nix hash convert --hash-algo sha256 --to sri "${nb_sha:?}")
jq -n --arg version "$nb_version" --arg hash "$nb_hash" '{$version, $hash}' >netbird-darwin.json

ts_version=$(curl -fsSL 'https://pkgs.tailscale.com/stable/?mode=json&os=darwin' | jq -r .MacZipsVersion)
ts_sha=$(curl -fsSL "https://pkgs.tailscale.com/stable/Tailscale-$ts_version-macos.pkg.sha256" | cut -d' ' -f1)
ts_hash=$(nix hash convert --hash-algo sha256 --to sri "${ts_sha:?}")
jq -n --arg version "$ts_version" --arg hash "$ts_hash" '{$version, $hash}' >tailscale-gui.json

echo "claude-code $version, t3code ${tag#v}, command-code $cc_version, netbird $nb_version, tailscale $ts_version"

# Homebrew: aktuelle Liste der Formeln und Casks holen, das Upgrade selbst macht nhs
# (homebrew.onActivation.upgrade in darwin/homebrew.nix)
if command -v brew >/dev/null; then
  brew update
fi

# T3-Server im Agent-Container (system/agent-sandbox) auf dieselbe Version wie die App. `t3 update`
# lädt die Runtime aus demselben Release (t3-<version>-linux-x64.tar.gz) und startet den Dienst neu,
# laufende Agent-Turns brechen dabei ab. Die App selbst bekommt die Version erst mit dem Rebuild
if command -v incus >/dev/null && incus info t3 >/dev/null 2>&1; then
  incus exec t3 -- runuser -l dev -c "t3 update ${tag#v} --yes"
else
  echo "T3-Server nicht aktualisiert: kein incus oder kein Container t3 (nur auf dem Desktop möglich)" >&2
fi
