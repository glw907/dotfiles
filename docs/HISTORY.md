# History

Per-pass ledger, newest first. Current state lives in `docs/STATUS.md`;
strategic initiatives spanning passes live in `ROADMAP.md`.

## 2026-08-30 -- Bluefin repo reorg pass

Rewrote the repo end to end for the Mint-to-Bluefin DX migration completed
the same day: purged dead Mint-desktop, apt, Node-version-manager, and aerc
content and consumed migration artifacts (`MIGRATION-RUNBOOK.md`,
`CLAUDE-md-draft.md`, `inventory/`, `themes/`, `wallpapers/`, `android/`),
cleaned `.bashrc` of the Node-version-manager block and dead PATH segments,
fixed the `contacts` package's
`vdirsyncer.service` path and the aerc-era Fastmail token directory,
rescoped `bluefin/flatpaks.txt` to deliberate-only installs, single-sourced
the Stow package list into `bluefin/stow-packages.txt`, adopted `mise` and
`planner` as tracked packages, deduped the vale install path onto Homebrew,
rewrote `workstation-update` for the `ujust`-based Bluefin update flow,
deployed the staged Android udev rule live, and rewrote the root README,
`bluefin/README.md`, the CLAUDE.md Dotfiles Management section, and
`tui-testing.md` to match.

**What the gate caught**: the Python comment gate (`ruff` D rules via
`scripts/check-py-comments.sh`) and `bash -n` syntax checks on every touched
script; the `test_vale_hook.py` suite confirming vale-hook still passed
after the install-path change; a repo-wide grep sweep for stale Mint-era
terms catching leftover references the manual pass missed on the first
sweep.

**What a later pass should not rediscover**:

- **The vale dual-install-path bug**: `scripts/install-vale.sh` and the
  Brewfile `vale` formula both installed a `vale` binary, and an untracked
  copy at `~/.local/bin/vale` shadowed the Homebrew one on PATH ahead of it.
  Brewfile wins; `install-vale.sh` is deleted, and the untracked binary
  removed. If `vale` behaves unexpectedly again, check `command -v vale`
  resolves to the linuxbrew path before assuming a config problem.
- **The vdirsyncer.service `/usr/bin` bug**: the unit's `ExecStart` pointed
  at `/usr/bin/vdirsyncer`, which does not exist on Bluefin -- `uv tool
  install` puts CLI shims in `~/.local/bin`, not `/usr/bin`. Any systemd
  user unit wrapping a uv-tool binary needs the `~/.local/bin` (or `%h/.local/bin`)
  path, never an assumed system path.
- **The udev rule that was staged but never deployed**: `bluefin/etc/udev/51-android.rules`
  existed in the repo from the migration but was never installed to
  `/etc/udev/rules.d/`; the live system still ran the old Mint `plugdev`
  rule until this pass ran `setup_etc_drops` for real. A file present under
  `bluefin/etc/` is not evidence it is live -- check `/etc` directly.
- **`ruff` missing from the uv tool set post-migration**: the Python
  comment gate depends on it, and the migration's `uv tool install` pass had
  not covered it. Installed via `uv tool install ruff`; `bootstrap.sh`'s
  `setup_mise_uv` now lists it alongside `khard`, `vdirsyncer`, `yt-dlp`.

Budgets: recorded at pass close.
