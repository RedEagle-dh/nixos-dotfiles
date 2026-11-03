# Agent-Skills für Claude Code. Quelle ist ~/.agents/skills/ (Repo RedEagle-dh/.agents, gepflegt
# mit der skills-CLI); Codex, OpenCode & Co. lesen dort direkt, Claude Code nur ~/.claude/skills/.
# Jeder Switch legt dort pro Skill einen relativen Symlink an und räumt Links zu gelöschten Skills weg.
#
# Aktivierungsskript statt home.file bzw. programs.claude-code.skills: die würden die Skills in den
# Store kopieren (read-only, skills add/update ginge nicht mehr) oder ~/.claude/skills/ komplett
# übernehmen, samt dem von Claude selbst verwalteten synced/. Außerdem darf ein reiner Flake
# ~/.agents nicht per readDir lesen.
# Neue Skills aus `git pull` / `skills add` werden beim nächsten Switch verlinkt.

{ config, lib, ... }:

let
  home = config.home.homeDirectory;
in
{
  home.activation.agentSkills = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    src="${home}/.agents/skills"
    dst="${home}/.claude/skills"

    if [ -d "$src" ]; then
      run mkdir -p "$dst"
      for d in "$src"/*/; do
        [ -d "$d" ] || continue
        n=$(basename "$d")
        # Bestehendes (Link, Kopie, Ordner) nie überschreiben
        [ -e "$dst/$n" ] || [ -L "$dst/$n" ] || run ln -s "../../.agents/skills/$n" "$dst/$n"
      done
    else
      warnEcho "$src fehlt – Skills nicht verlinkt. Erst klonen: git clone git@github.com:RedEagle-dh/.agents.git ~/.agents"
    fi

    # Nur eigene, ins Leere zeigende Links entfernen; synced/ und alles andere bleibt
    for l in "$dst"/*; do
      [ -L "$l" ] || continue
      case "$(readlink "$l")" in
        ../../.agents/skills/*) [ -e "$l" ] || run rm "$l" ;;
      esac
    done
  '';
}
