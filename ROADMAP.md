# Roadmap

Strategic initiatives for the workstation repo: work spanning passes, or
standing decisions other work is measured against. Managed by `/log-project`.
Current state lives in `docs/STATUS.md`; the per-pass ledger in
`docs/HISTORY.md`.

## Planned

- **musicbox repo split**: the music-VPS spec, plan, and library design
  (`docs/superpowers/plans/2026-08-30-music-vps-build.md`,
  `docs/superpowers/specs/2026-08-30-music-vps-build-design.md`,
  `docs/superpowers/specs/2026-08-30-music-library-design.md`) describe a
  Hetzner server, another machine's config. They move to their own repo
  before server artifacts accrete; coordinate with the music session that
  owns them.

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
