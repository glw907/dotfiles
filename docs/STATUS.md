# Status

Dotfiles and machine configuration for one Bluefin DX workstation
(`thinkpad-x1`, Fedora 44 base, `bootc`/`ostree`). GNU Stow links tracked
config into `$HOME`; `bluefin/` holds the fresh-machine provisioning
artifacts. github.com/glw907/workstation.

## Current state

Post-migration reorg complete: the repo describes the Bluefin machine as it
actually stands, not the retired Mint 22 desktop setup.

- **Stow packages** (single source: `bluefin/stow-packages.txt`): `bash beets
  bin claude contacts git kitty mise upkeep vale`. `bluefin/bootstrap.sh` and
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

Execute the docs-standard Claude infrastructure pass,
`docs/superpowers/plans/2026-09-08-docs-standard-claude-infra.md` (plan one of three for the
cairn documentation standard; approved 2026-09-08). Main-loop dispatch per task through the
implementer-review-gate chain; gate `bash ~/.dotfiles/scripts/check.sh`.

Checkpoint after task 3 (2026-09-08): done 1a (c523f0b), 1b (fc143ec, c217769, 064168f), 2
(7f63c0e, ecf31ab), 3 (019e1e8, f1a3ec5); next task 4 (review agents), then 5 (skills), 6
(CLAUDE.md candidate document, the split point, owner-blocked). Rulings taken: the review agents
carry no profile flag and refuse nothing without a corpus; the tell scanner is the canonical
instrument (MEASURES.md); the two-headed-heading tell is sourced to the register ruling, not
Google. Spend is inside the 0.6M ceiling. The three open items from the 2026-09-04 Fable 5.1
pass queue behind this pass.

## Open items

Strategic and standing items live in `ROADMAP.md` (history purge decision,
musicbox repo split, devcontainers, kitty-harness replacement, custom uBlue
image, restore split).

## History

Per-pass ledger: `docs/HISTORY.md`.
