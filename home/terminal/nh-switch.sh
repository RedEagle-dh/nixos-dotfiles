# nhs: nh os|darwin switch, das Pakete überspringt, deren Bau scheitert. Dann sucht es die Pakete, die
# nicht gebaut wurden, baut das System ohne sie (NHS_SKIP, siehe pkgs/default.nix) und schaltet
# trotzdem um. Welche fehlen, steht am Ende – das nächste nhs versucht sie wieder.
# flake, platform (os|darwin), darwin_host und analysis (nh-switch.nix) setzt nh.nix davor

if [ "$platform" = darwin ]; then
  configs=darwinConfigurations
  host=$darwin_host
else
  configs=nixosConfigurations
  host=$(uname -n)
fi

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

skip=()    # Store-Pfade der übersprungenen Pakete
skipped=() # deren Namen für die Übersicht

# Gescheiterte Pakete als "<Store-Pfad>\t<Name>": im System gebraucht, aber nicht im Store. Nach
# einem Bau mit --keep-going steht dort alles, was sich bauen ließ – was fehlt, ist selbst
# gescheitert oder hängt an etwas Gescheitertem. Läuft in `if`, wo errexit nicht greift – daher die
# return
failed_packages() {
  NHS_FLAKE=$flake NHS_CONFIGS=$configs NHS_HOST=$host NHS_SKIP="${skip[*]}" \
    nix eval --impure --json --file "$analysis" >"$tmp/system.json" || return
  nix-store --query --requisites "$(jq -r .toplevel "$tmp/system.json")" >"$tmp/closure" || return
  jq -r '.packages[] | [.drvPath, .built, .path, .name] | @tsv' "$tmp/system.json" |
    sort -u >"$tmp/packages" || return

  # Pakete, die das System braucht, und davon die, deren Ausgabe fehlt
  awk -F '\t' 'NR == FNR { used[$0]; next } $1 in used' "$tmp/closure" "$tmp/packages" >"$tmp/used"
  cut -f 2 "$tmp/used" | xargs nix-store --check-validity --print-invalid >"$tmp/invalid" || return
  awk -F '\t' 'NR == FNR { invalid[$0]; next } $2 in invalid { print $3 "\t" $4 }' "$tmp/invalid" "$tmp/used"
}

for _ in 1 2 3; do
  args=(--keep-going --hostname "$host" --out-link "$tmp/result")
  if [ ${#skip[@]} -gt 0 ]; then
    args+=(--impure)
  fi

  if NHS_SKIP="${skip[*]}" nh "$platform" switch "${args[@]}" "$flake"; then
    if [ ${#skipped[@]} -gt 0 ]; then
      printf '\nnhs: umgeschaltet, aber ohne diese Pakete (Bau gescheitert, Fehler oben):\n' >&2
      printf '  %s\n' "${skipped[@]}" >&2
      printf 'Eigene Pakete aus pkgs/, die es auch in nixpkgs gibt, kommen solange von dort, wenn die baut.\n' >&2
    fi
    exit 0
  fi

  # Gebaut, aber das Umschalten ist gescheitert – daran ändert Überspringen nichts
  if [ -e "$tmp/result" ]; then
    exit 1
  fi

  printf '\nnhs: Bau gescheitert, suche die Pakete, an denen es liegt …\n' >&2
  if ! failed_packages >"$tmp/failed"; then
    printf 'nhs: Auswertung gescheitert (Fehler oben), nichts umgeschaltet\n' >&2
    exit 1
  fi

  new=()
  while IFS=$'\t' read -r path name; do
    if [[ " ${skip[*]} " != *" $path "* ]]; then
      skip+=("$path")
      skipped+=("$name")
      new+=("$name")
    fi
  done <"$tmp/failed"

  if [ ${#new[@]} -eq 0 ]; then
    printf 'nhs: Der Fehler liegt an keinem Paket, das sich überspringen lässt – nichts umgeschaltet\n' >&2
    exit 1
  fi
  printf 'nhs: baue ohne %s\n\n' "${new[*]}" >&2
done

printf 'nhs: Bau scheitert auch ohne %s – nichts umgeschaltet\n' "${skipped[*]}" >&2
exit 1
