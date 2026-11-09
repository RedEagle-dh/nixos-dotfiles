# Agent-Sandbox: T3 Code und seine Agents laufen in einem Incus-Container ("t3", Ubuntu) statt als
# dave auf dem Desktop. Als dave könnten sie alles lesen, was dave lesen kann (Schlüssel, Tokens,
# Keyring, Browser), und über die docker-Gruppe wären sie root.
#
#   incus.nix       Bridge, Speicher und das Profil "agent" (Limits, Docker im Container, Sockets,
#                   ~/developer und die Skills des Hosts)
#   firewall.nix    Netz wie jedes LAN-Gerät; nur T3s Port ist auf Caddy (pi5) beschränkt
#   git-broker.nix  ssh-agent mit dem Git-Schlüssel; der Container bekommt nur den Socket
#   open-in-zed.nix "Open in Zed" aus T3 öffnet den Ordner im Zed des Hosts, ohne SSH (vom Mac
#                   per SSH über den Desktop, home/darwin/ssh.nix)
#   container/      Das Ubuntu im Container: cloud-init.nix (Nutzer, Pakete) ruft provision.sh auf
#                   (mise, Claude, Codex, Playwright); files.nix (git, ssh, Wrapper) hängt Incus
#                   unter /opt/agent-sandbox ein. Nach Änderungen: Rebuild, dann im Container
#                   `sudo provision-agent`
#
# Einmalig nach dem ersten Rebuild. Den mit `nixos-rebuild boot` machen und neu starten: die Firewall
# wechselt von iptables auf nftables, das sollte nicht im laufenden Betrieb passieren.
#   1. Schlüssel anlegen und bei GitHub/Forgejo eintragen: siehe git-broker.nix
#   2. Container anlegen, cloud-init braucht ein paar Minuten:
#        incus launch images:ubuntu/24.04/cloud t3 --profile agent
#        incus exec t3 -- cloud-init status --wait
#   3. GitHub-Tokens, einer pro Besitzer, Dateiname = Besitzer in Kleinbuchstaben. Fragt nacheinander
#      (zsh: Text nach "?" ist der Prompt, -s zeigt die Eingabe nicht an):
#        for owner in redeagle-dh modlogtv eventmate-bot benz-walter n2-stickstoff; do
#          read -rs "TOKEN?Token für $owner: " && echo
#          printf '%s' "$TOKEN" | incus exec t3 -- su - dev -c \
#            "umask 077; mkdir -p ~/.config/gh-tokens; cat > ~/.config/gh-tokens/$owner"
#        done; unset TOKEN
#      Standard-Token für Aufrufe ohne Repo (T3 selbst fragt so nach, siehe container/gh.sh):
#        incus exec t3 -- su - dev -c 'ln -sfn redeagle-dh ~/.config/gh-tokens/default'
#      Prüfen: incus exec t3 -- su - dev -c 'gh pr list -R eventmate-bot/eventmate_mono --limit 1'
#      Grafana (MCP, je Instanz): ~/.config/mcp/grafana-<name>.env im Container anlegen, dann
#      `register-grafana-mcp` (meldet sie global als grafana-<name> an), siehe container/grafana-mcp.sh
#   4. Die Server-Runtime des bisherigen t3-Dienstes (nicht die Desktop-App) in den Container
#      kopieren und dort als Dienst einrichten. Die Runtime ist ein normales Linux-Programm ohne
#      Bezug auf /nix/store, läuft also unverändert auf Ubuntu. Version = die, die der Dienst nutzt:
#        v=$(sed -n 's/.*"activeVersion": *"\([^"]*\)".*/\1/p' ~/.t3/runtime/service-state.json)
#      Per tar statt `incus file push -r`: das legt bei fehlendem Zielordner nur den Inhalt ab
#      (wie cp -r), der Versionsordner fehlt dann. tar packt dagegen als dev aus, kein chown nötig:
#        tar -C ~/.t3/runtime/versions -c "$v" | incus exec t3 -- runuser -u dev -- sh -c \
#          'mkdir -p /home/dev/.t3/runtime/versions && tar -C /home/dev/.t3/runtime/versions -x'
#        incus exec t3 -- su - dev -c "~/.t3/runtime/versions/$v/t3 up --lan --no-connect"
#        incus exec t3 -- su - dev -c "~/.t3/runtime/versions/$v/t3 browser setup"
#   5. Anmelden: `incus exec t3 -- su - dev`, dann `claude` (/login) und `codex login --device-auth`
#   6. Umstellen: im Homelab-Repo Caddy für t3 auf <desktop>:3774 zeigen lassen, den alten Dienst
#      stoppen (systemctl --user disable --now t3code.service) und in t3-host.nix Port 3773 und
#      linger entfernen
{
  imports = [
    ./incus.nix
    ./firewall.nix
    ./git-broker.nix
    ./open-in-zed.nix
  ];
}
