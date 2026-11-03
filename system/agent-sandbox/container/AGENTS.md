# Environment

You run in an isolated Ubuntu container ("t3") on David's desktop. You have passwordless sudo,
Docker, and apt. Node, pnpm and bun come from mise (`mise use node@22` etc. per project).

- The home network is reachable, but you have no credentials for its machines (pi5, server, dns,
  dns2, router). Don't try to log in to them or to the web services behind *.dave.haus.
- Git authentication and commit signing go through an ssh-agent on the host. There is no key file
  in this container; don't look for one. Commits are signed automatically.

# Git

- Clone GitHub as `git@github.com:<owner>/<repo>.git` and Forgejo as
  `ssh://git@git.dave.haus:2222/<owner>/<repo>.git`. HTTPS URLs are rewritten to SSH automatically.
- Commits are authored by David. Never add `Co-authored-by` trailers, "Generated with …" lines or
  any other mention of an AI, agent or tool to commit messages, PR titles or PR descriptions.
- Don't push to the default branch. Work on a branch and open a pull request.

# Pull requests

- GitHub: `gh pr create --title "…" --body-file pr.md`. The right token for the repository's owner
  is picked automatically. Use `gh pr view --json …` (plain `gh pr view` can fail with these tokens),
  and `gh run list` / `gh run view --log-failed` for CI results.
- Forgejo (git.dave.haus): `forgejo-pr "<title>" pr.md` on the feature branch. Run it again after
  new commits to update the same pull request.

# Checking your work

- Run the project's type check (`tsc --noEmit` or the package script), linter and tests before you
  call a task done.
- For UI changes, start the dev server and check the page with Playwright
  (`npx playwright install chromium` once per project): take screenshots and look at them.
- `docker` and `docker compose` work as usual. Stop containers you started when you're done.
- `nix` (with flakes) is installed as a tool for Nix repos: `nix fmt`, `nix flake check`,
  `nix eval`, `nix build` of single packages. Use it to check your changes before a PR. This is
  not NixOS: never run `nixos-rebuild`, deploy scripts or anything that changes a machine.

# Debugging with production data

- If the project has a `grafana` MCP server, use it to look at dashboards, Loki logs and Prometheus
  metrics when you investigate a bug. It is read-only. Each project's server points at that
  project's own Grafana. In Codex the servers are named `grafana-<instance>`; use the one for
  the project you are working on.
