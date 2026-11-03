#!/bin/sh
# forgejo-pr "<Titel>" [<beschreibung.md>]
# Öffnet oder aktualisiert den Forgejo-PR des aktuellen Branches per AGit: ein Push nach
# refs/for/<ziel> legt den PR an, über SSH, ganz ohne API-Token. Gleicher Branch = gleicher PR,
# force-push=true ersetzt dessen Stand (auch nach Rebase).
# Ziel-Branch: $FORGEJO_BASE, sonst der Standard-Branch von origin, sonst main.
set -eu

if [ $# -lt 1 ]; then
  echo "usage: forgejo-pr <title> [description.md]" >&2
  exit 2
fi

branch=$(git symbolic-ref --short HEAD)
base=${FORGEJO_BASE:-$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null | sed 's|^origin/||' || true)}
base=${base:-main}
if [ "$branch" = "$base" ]; then
  echo "forgejo-pr: switch to a feature branch first" >&2
  exit 1
fi

# Topic = Name des PRs bei Forgejo, ohne Schrägstriche
topic=$(printf '%s' "$branch" | tr '/' '-')

if [ $# -ge 2 ]; then
  # Zeilenumbrüche gehen in Push-Optionen nicht, Forgejo dekodiert {base64}…
  git push origin "HEAD:refs/for/$base" -o "topic=$topic" -o "title=$1" -o force-push=true \
    -o "description={base64}$(base64 -w0 <"$2")"
else
  git push origin "HEAD:refs/for/$base" -o "topic=$topic" -o "title=$1" -o force-push=true
fi
