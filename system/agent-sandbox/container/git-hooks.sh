#!/bin/sh
# Alle Hooks in /etc/git/hooks zeigen auf dieses Skript (core.hooksPath in /etc/gitconfig).
#
# commit-msg: entfernt Hinweise auf Agents aus der Commit-Nachricht, falls einer trotz Anweisung
# welche schreibt. Danach läuft der Hook des Repos selbst (.git/hooks/<name>), den core.hooksPath
# sonst abschalten würde.
#
# Lücke: Repos mit eigenem core.hooksPath (husky, lefthook) überspringen dieses Skript ganz.
hook=$(basename "$0")

if [ "$hook" = commit-msg ]; then
  sed -i -E \
    -e '/^co-authored-by:.*(claude|codex|openai|anthropic|copilot|cursor|gemini)/Id' \
    -e '/generated (with|by) .*(claude|codex|openai|anthropic|copilot)/Id' \
    "$1"
fi

repo_hook="$(git rev-parse --git-common-dir)/hooks/$hook"
if [ -x "$repo_hook" ]; then
  exec "$repo_hook" "$@"
fi
exit 0
