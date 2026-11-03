#!/bin/sh
# gh mit dem fine-grained Token des Repo-Besitzers. Ein Token gilt immer nur für einen Besitzer
# (Nutzer oder Org), gh kennt aber nur einen Token pro Host – darum wählt dieses Skript ihn bei
# jedem Aufruf. Liegt in /usr/local/bin und steht damit im PATH vor dem echten /usr/bin/gh.
#
# Tokens: ~/.config/gh-tokens/<besitzer in Kleinbuchstaben>, z. B. ~/.config/gh-tokens/eventmate-bot
# Besitzer: aus -R/--repo, sonst aus dem origin des Repos im aktuellen Verzeichnis.
owner=""
prev=""
for arg in "$@"; do
  case "$prev" in
    -R | --repo) owner=$arg ;;
  esac
  case "$arg" in
    --repo=*) owner=${arg#--repo=} ;;
  esac
  prev=$arg
done
if [ -z "$owner" ]; then
  owner=$(git remote get-url origin 2>/dev/null || true)
fi

# git@github.com:Owner/repo.git, https://github.com/Owner/repo, Owner/repo → owner
owner=${owner#*github.com[:/]}
owner=${owner%%/*}
owner=$(printf '%s' "$owner" | tr '[:upper:]' '[:lower:]')

token_file="$HOME/.config/gh-tokens/$owner"
# Ohne erkennbaren Besitzer den Standard-Token (Symlink "default", z. B. auf redeagle-dh). Das
# betrifft vor allem T3 selbst: es fragt `gh auth token` im eigenen Arbeitsverzeichnis statt im
# Repo und nutzt dann einen Token für ganz github.com
if [ -z "$owner" ] || [ ! -r "$token_file" ]; then
  token_file="$HOME/.config/gh-tokens/default"
fi
if [ -r "$token_file" ]; then
  GH_TOKEN=$(cat "$token_file")
  export GH_TOKEN
fi
exec /usr/bin/gh "$@"
