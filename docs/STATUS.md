# Status

Dotfiles and machine configuration for one Bluefin DX workstation
(`thinkpad-x1`, Fedora 44 base, `bootc`/`ostree`). GNU Stow links tracked
config into `$HOME`; `bluefin/` holds the fresh-machine provisioning
artifacts. github.com/glw907/workstation.

## Current state

Post-migration reorg complete: the repo describes the Bluefin machine as it
actually stands, not the retired Mint 22 desktop setup.

- **Stow packages** (single source: `bluefin/stow-packages.txt`): `bash beets
  bin claude contacts git kitty mise vale`. Both `bluefin/bootstrap.sh` and
  `sync-dotfiles.sh` read that file.
- **Layered RPMs** (`bluefin/layered-packages.txt`): `1password
  1password-cli firefox chromium`, kept deliberately minimal and
  change-controlled through `MIGRATION-BRIEF.md`.
- **CLI tools**: Homebrew (`bluefin/Brewfile`) for most formulae; `uv tool
  install` for Python CLIs (`khard`, `vdirsyncer`, `yt-dlp`, `ruff`, `jrnl`);
  `mise` for per-project Node.
- **Flatpaks** (`bluefin/flatpaks.txt`): deliberate installs beyond
  Bluefin's stock set only.
- **Secrets**: age-encrypted in `secrets/values.age`, synced by
  `scripts/secrets/sync.sh`; see `docs/secrets.md`.

## Immediate next action

None. Steady state: routine `workstation-update` runs and `sync-dotfiles.sh`
drift checks. No pass is in flight.

## Open items

- **Devcontainers** for SvelteKit/Cloudflare project repos: not started,
  revisit as those repos mature enough to need isolation from the host
  toolchain.
- **kitty as the `tui-visual-verify` gate platform**: kitty is installed for
  no other reason than that harness (XWayland-forced, `xdotool` +
  ImageMagick `import`). It awaits a Wayland-native replacement; when one
  exists, kitty can drop out of the Stow package and Brewfile entirely.
- **Custom uBlue image**: an explicit later decision for the second
  workstation, not assumed. The current path (stock ISO + `bootstrap.sh`) is
  the baseline until that decision is made.

## History

Per-pass ledger: `docs/HISTORY.md`.
