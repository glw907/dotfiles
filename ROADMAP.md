# Roadmap

Strategic initiatives for the workstation repo: work spanning passes, or
standing decisions other work is measured against. Managed by `/log-project`.
Current state lives in `docs/STATUS.md`; the per-pass ledger in
`docs/HISTORY.md`.

## Planned

- **Git history purge**: the public repo's history carries a dead Cloudflare
  token (2026-01-30 to 2026-03-19), a Firefox places.sqlite with expired
  session JWTs, and browser bookmark exports (see `secrets/registry.md`'s
  exposure post-mortem). All credentials verified dead 2026-08-30, so this is
  privacy hygiene, not incident response. Needs `git filter-repo` plus a
  force-push to main, which standing convention forbids; runs only on Geoff's
  explicit go.
- **musicbox repo split**: the music-VPS spec and plan
  (`docs/superpowers/{specs,plans}/2026-08-30-music-vps-*`) describe a Hetzner
  server, another machine's config. They move to their own repo before server
  artifacts accrete; coordinate with the music session that owns them.

## Someday

- **Devcontainers** for the SvelteKit/Cloudflare site repos: logged per repo
  (907-life #2, ecxc-ski #39, xcathletes-org #4, the ASC STATUS chore), built
  as each repo matures. Research: `bluefin/devenv-research.md`.
- **kitty harness replacement**: kitty exists only as the `tui-visual-verify`
  capture platform (XWayland-forced). When a Wayland-native or
  terminal-agnostic capture method proves out, the harness moves and kitty
  leaves the machine entirely.
- **Custom uBlue image** for the second workstation: bakes the devmode rebase
  and Flatpak set into the image instead of undoing defaults per machine. An
  explicit later decision, not assumed.
- **bootstrap.sh restore split**: the restore phase is two-thirds of the file
  and a different risk class (destructive, run cold). Split into
  `bluefin/restore.sh` with shared helpers when workstation #2 lands.
