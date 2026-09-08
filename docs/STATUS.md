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
  gitleaks, tellgrader go check).
- **Docs standard, plan one closed**: the tellgrader `docs-register` profile and opt-in
  discovery, `MEASURES.md` as the canonical measure definition, the output-style and voice-file
  updates, the path-grading Vale hook, the four review agents (including the new
  `figure-verifier`), and the two skills (`cairn-figure`; `writing-voice`'s renamed
  author-facing section). Unit 3c stays open: both `CLAUDE.md` files still owe the owner's
  four-line pick, ranked in
  `docs/superpowers/plans/2026-09-08-claude-md-displacement-candidates.md`, batched with the
  docs-standard corpus approval.

## Immediate next action

Open the hand-off document,
`~/.dotfiles/docs/superpowers/plans/2026-09-08-docs-standard-claude-infra-handoff.md`, and start plan two
of the cairn documentation standard (cairn's own toolset): its preflight verifies the six
artifacts the hand-off names, and its plan must add creating
`~/Projects/cairn-cms/.tellgrader.json` and wiring `figure-verifier` into its chain D. Separately,
the docs-standard corpus approval sitting still owes the `CLAUDE.md` four-line picks for both
files and the three open items carried from the 2026-09-04 Fable 5.1 pass.

## Open items

Strategic and standing items live in `ROADMAP.md` (history purge decision,
musicbox repo split, devcontainers, kitty-harness replacement, custom uBlue
image, restore split, the cairn documentation standard).

## History

Per-pass ledger: `docs/HISTORY.md`.
