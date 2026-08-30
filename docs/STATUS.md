# Status

Dotfiles and machine configuration for one Bluefin DX workstation
(`thinkpad-x1`, Fedora 44 base, `bootc`/`ostree`). GNU Stow links tracked
config into `$HOME`; `bluefin/` holds the fresh-machine provisioning
artifacts. github.com/glw907/workstation.

## Current state

Post-migration reorg complete: the repo describes the Bluefin machine as it
actually stands, not the retired Mint 22 desktop setup.

- **Stow packages** (single source: `bluefin/stow-packages.txt`): `bash beets
  bin claude contacts git kitty mise vale`. `bluefin/bootstrap.sh` and
  `check-drift` both read that file.
- **Layered RPMs** (`bluefin/layered-packages.txt`): `1password
  1password-cli firefox chromium`, kept deliberately minimal and
  change-controlled through `docs/MIGRATION-BRIEF.md`.
- **CLI tools**: Homebrew (`bluefin/Brewfile`) for most formulae; `uv tool
  install` for Python CLIs (`khard`, `vdirsyncer`, `yt-dlp`, `ruff`, `jrnl`,
  `beets`); `mise` for per-project Node.
- **Flatpaks** (`bluefin/flatpaks.txt`): deliberate installs beyond
  Bluefin's stock set only.
- **Secrets**: age-encrypted in `secrets/values.age`, synced by
  `scripts/secrets/sync.sh`; architecture and inventory in
  `secrets/registry.md`. Write-time guards: claude-secret-guard hook,
  gitleaks pre-commit, GitHub push protection.
- **Gate**: `scripts/check.sh` (shell syntax, ruff-D, tests, vale fixtures,
  gitleaks).

## Immediate next action

None. Steady state: routine `workstation-update` runs; `check-drift`
reconciles every manifest against the live machine (weekly
`check-drift.timer` notifies on drift; every install records itself in its
tier's manifest same-session, per bluefin-admin.md). No pass is in flight.

## Open items

Strategic and standing items live in `ROADMAP.md` (history purge decision,
musicbox repo split, devcontainers, kitty-harness replacement, custom uBlue
image, restore split).

## History

Per-pass ledger: `docs/HISTORY.md`.
