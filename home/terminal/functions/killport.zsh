# Beendet Prozesse, die auf einem Port LAUSCHEN. Usage: killport 3000 3001
killport() {
  if (( $# == 0 )); then
    print -u2 "Usage: killport <port> [port...]"
    return 1
  fi

  local port out
  for port in "$@"; do
    # -sTCP:LISTEN ist entscheidend: ohne diesen Filter trifft lsof auch
    # ausgehende Verbindungen auf den Port — 'killport 443' würde dann
    # Browser, Mail und Editor mit abräumen.
    out=$(lsof -ti tcp:"$port" -sTCP:LISTEN 2>/dev/null)
    if [[ -z $out ]]; then
      print "Port $port: kein lauschender Prozess"
      continue
    fi

    local pids=(${=out})
    print "Port $port: ${(j:, :)pids} ($(ps -o comm= -p ${pids[1]} 2>/dev/null | xargs basename 2>/dev/null))"

    # Erst höflich fragen — Dev-Server dürfen Sockets und Lockfiles aufräumen.
    kill ${pids} 2>/dev/null

    local waited=0
    while (( waited < 20 )); do
      sleep 0.1
      (( waited++ ))
      [[ -z $(lsof -ti tcp:"$port" -sTCP:LISTEN 2>/dev/null) ]] && break
    done

    local alive=$(lsof -ti tcp:"$port" -sTCP:LISTEN 2>/dev/null)
    if [[ -n $alive ]]; then
      kill -9 ${=alive} 2>/dev/null
      print "  SIGTERM ignoriert -> SIGKILL"
    else
      print "  beendet"
    fi
  done
}
