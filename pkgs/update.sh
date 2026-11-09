#!/usr/bin/env bash
# nhu: Flake-Inputs und die eigenen Pakete in pkgs/ aktualisieren, jedes für sich. Scheitert eins –
# Abruf, Hash oder Bau –, bleibt es auf dem alten Stand und der Rest läuft weiter. Was nicht geklappt
# hat, steht in der Übersicht am Ende
set -uo pipefail

if ! command -v prefetch-npm-deps >/dev/null; then
  exec nix shell nixpkgs#nodejs nixpkgs#jq nixpkgs#prefetch-npm-deps -c "$0" "$@"
fi

cd "$(dirname "${BASH_SOURCE[0]}")"
flake=$(cd .. && pwd)
system=$(nix eval --impure --raw --expr builtins.currentSystem)

# Ohne Token erlaubt die GitHub-API nur 60 Anfragen pro Stunde und IP, danach 403
token=${GITHUB_TOKEN:-$(gh auth token 2>/dev/null || true)}
gh_api() {
  if [ -n "$token" ]; then
    curl -fsSL -H "Authorization: Bearer $token" "$@"
  else
    curl -fsSL "$@"
  fi
}
# Dasselbe Limit gilt für nix beim Holen der Flake-Inputs
if [ -n "$token" ]; then
  NIX_CONFIG=$(printf '%s\n%s' "${NIX_CONFIG:-}" "access-tokens = github.com=$token")
  export NIX_CONFIG
fi

updated=() current=() failed=() notes=()

# ---- Flake-Inputs

lock_date() {
  jq -r --arg input "$1" \
    '.nodes[.nodes.root.inputs[$input]].locked.lastModified // 0 | strftime("%Y-%m-%d")' \
    "$flake/flake.lock"
}
lock_hash() {
  jq -r --arg input "$1" '.nodes[.nodes.root.inputs[$input]].locked.narHash' "$flake/flake.lock"
}

# Einzeln statt `nix flake update`: Ist ein Input nicht erreichbar (github.com mit 504 o. Ä.),
# bekommen die anderen trotzdem ihr Update
for input in $(jq -r '.nodes.root.inputs | keys[]' "$flake/flake.lock"); do
  old=$(lock_date "$input") old_hash=$(lock_hash "$input")
  if nix flake update "$input" --flake "$flake"; then
    if [ "$(lock_hash "$input")" = "$old_hash" ]; then
      current+=("$input")
    else
      updated+=("$input $old → $(lock_date "$input")")
    fi
  else
    failed+=("$input: Update gescheitert, bleibt beim Stand vom $old")
  fi
done

# ---- Eigene Pakete

# Was es davon für dieses System gibt (packages in flake.nix) – nur das lässt sich hier bauen. Die
# Pakete braucht nur der Desktop, auf dem Mac aktualisiert nhu nur ihre Versionen
if ! buildable=$(nix eval --json "$flake#packages" --apply "p: builtins.attrNames (p.\"$system\" or { })"); then
  buildable='[]'
  notes+=("Pakete nicht testweise gebaut: packages lässt sich nicht auswerten (Fehler oben)")
fi

# package <Name> <Attribut in packages> <Funktion> <Datei mit .version> [weitere Dateien …]
# Die Funktion holt die neue Version und schreibt die Dateien. Danach wird das Paket gebaut, sofern es
# eins für dieses System ist. Scheitert eins von beidem, kommen die alten Dateien zurück
package() {
  local name=$1 attr=$2 fn=$3
  shift 3
  local backup file n status changed=false old new
  backup=$(mktemp -d)
  n=0
  for file in "$@"; do
    cp "$file" "$backup/$n"
    n=$((n + 1))
  done
  old=$(jq -r .version "$1")

  printf '\n==> %s\n' "$name" >&2
  # Subshell mit set -e: bricht beim ersten Fehler ab, ohne nhu mitzunehmen. Nicht in `if`,
  # dort wäre set -e wirkungslos
  (
    set -e
    "$fn"
  )
  status=$?

  n=0
  for file in "$@"; do
    cmp -s "$file" "$backup/$n" || changed=true
    n=$((n + 1))
  done

  if [ "$status" -ne 0 ]; then
    failed+=("$name: Update gescheitert, bleibt bei $old")
  elif ! $changed; then
    current+=("$name")
  else
    new=$(jq -r .version "$1")
    local change="$old → $new"
    if [ "$new" = "$old" ]; then change="$new (neue Hashes)"; fi
    if ! jq -e --arg attr "$attr" 'index($attr)' <<<"$buildable" >/dev/null; then
      updated+=("$name $change – nicht gebaut, gibt es nicht für $system")
    elif nix build --no-link "$flake#$attr"; then
      updated+=("$name $change")
    else
      failed+=("$name $new: Bau gescheitert, bleibt bei $old")
      status=1
    fi
  fi

  if [ "$status" -ne 0 ]; then
    n=0
    for file in "$@"; do
      cp "$backup/$n" "$file"
      n=$((n + 1))
    done
  fi
  rm -rf "$backup"
}

claude_code() {
  local base=https://downloads.claude.ai/claude-code-releases version
  version=$(curl -fsSL "$base/latest")
  curl -fsSL "$base/$version/manifest.zst.json" -o claude-code.json
  jq -e .platforms claude-code.json >/dev/null
}

t3code() {
  local repo=pingdotgg/t3code release tag sha
  release=$(gh_api "https://api.github.com/repos/$repo/releases?per_page=30" |
    jq '[.[] | select(.tag_name | test("^v.*-nightly\\."))][0]')
  tag=$(jq -r .tag_name <<<"$release")
  # Assets über die API laden statt über github.com/…/releases/download: die Route liefert zeitweise
  # 504, während die API auf denselben Speicher weiterleitet und funktioniert. curl schickt den Token
  # bei der Weiterleitung auf release-assets.githubusercontent.com nicht mit
  asset() {
    gh_api -H 'Accept: application/octet-stream' \
      "$(jq -r --arg name "$1" '.assets[] | select(.name == $name) | .url' <<<"$release")"
  }
  sha=$(asset nightly-linux.yml | sed -n 's/^sha512: //p')
  printf '{\n  "version": "%s",\n  "hash": "sha512-%s"\n}\n' "${tag#v}" "${sha:?}" >t3code-nightly.json
}

command_code() {
  local cc npm_deps_hash
  cc=$(curl -fsSL https://registry.npmjs.org/command-code/latest)
  # Nicht local: der trap läuft erst beim Ende der Subshell aus package(), nach dieser Funktion
  cc_tmp=$(mktemp -d)
  trap 'rm -rf "$cc_tmp"' EXIT
  curl -fsSL "$(jq -r .dist.tarball <<<"$cc")" | tar xz -C "$cc_tmp"
  jq 'del(.devDependencies)' "$cc_tmp/package/package.json" >"$cc_tmp/package.json"
  (cd "$cc_tmp" && npm install --package-lock-only --ignore-scripts --no-audit --no-fund >/dev/null)
  cp "$cc_tmp/package-lock.json" command-code/package-lock.json
  npm_deps_hash=$(prefetch-npm-deps command-code/package-lock.json 2>/dev/null)
  jq -n --arg version "$(jq -r .version <<<"$cc")" --arg hash "$(jq -r .dist.integrity <<<"$cc")" \
    --arg npmDepsHash "$npm_deps_hash" '{$version, $hash, $npmDepsHash}' >command-code/source.json
}

package claude-code claude-code claude_code claude-code.json
package t3code t3code-nightly t3code t3code-nightly.json
package command-code command-code command_code command-code/source.json command-code/package-lock.json

# ---- Außerhalb von Nix

# Homebrew: aktuelle Liste der Formeln und Casks holen, das Upgrade selbst macht nhs
# (homebrew.onActivation.upgrade in darwin/homebrew.nix)
if command -v brew >/dev/null; then
  printf '\n==> Homebrew\n' >&2
  brew update || failed+=("Homebrew: brew update gescheitert")
fi

# T3-Server im Agent-Container (system/agent-sandbox) auf dieselbe Version wie die App. `t3 update`
# lädt die Runtime aus demselben Release (t3-<version>-linux-x64.tar.gz) und startet den Dienst neu,
# laufende Agent-Turns brechen dabei ab. Die App selbst bekommt die Version erst mit dem Rebuild
t3_version=$(jq -r .version t3code-nightly.json)
if command -v incus >/dev/null && incus info t3 >/dev/null 2>&1; then
  printf '\n==> T3-Server\n' >&2
  incus exec t3 -- runuser -l dev -c "t3 update $t3_version --yes" ||
    failed+=("T3-Server: nicht auf $t3_version aktualisiert – später mit nhu erneut versuchen")
else
  notes+=("T3-Server nicht aktualisiert: kein incus oder kein Container t3 (nur auf dem Desktop möglich)")
fi

# ---- Übersicht

printf '\nnhu – Übersicht\n' >&2
if [ ${#updated[@]} -gt 0 ]; then
  printf 'Aktualisiert:\n' >&2
  printf '  %s\n' "${updated[@]}" >&2
fi
if [ ${#current[@]} -gt 0 ]; then
  printf 'Schon aktuell: %s\n' "$(printf '%s, ' "${current[@]}" | sed 's/, $//')" >&2
fi
if [ ${#notes[@]} -gt 0 ]; then
  printf '%s\n' "${notes[@]}" >&2
fi
if [ ${#failed[@]} -gt 0 ]; then
  printf '\nÜbersprungen (alter Stand bleibt, Fehler oben):\n' >&2
  printf '  %s\n' "${failed[@]}" >&2
fi
