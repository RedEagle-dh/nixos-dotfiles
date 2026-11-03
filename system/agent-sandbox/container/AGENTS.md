# Environment

You run in an isolated Ubuntu container ("t3") on David's desktop. You have passwordless sudo,
Docker, and apt. Node, pnpm and bun come from mise (`mise use node@22` etc. per project).

- The home network is blocked on purpose (192.168.188.0/24, VPN ranges, *.dave.haus web services).
  Don't try to reach pi5, server/homelab, dns, dns2 or the router. Only Forgejo over SSH
  (git.dave.haus:2222) is reachable.
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
