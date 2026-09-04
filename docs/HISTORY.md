# History

Per-pass ledger, newest first. Current state lives in `docs/STATUS.md`;
strategic initiatives spanning passes live in `ROADMAP.md`.

## 2026-09-04 -- Fable 5.1 model, effort, and skill update

Fable 5.1 (shipped 2026-09-01; same $10/$50, cache reads $0.25/MTok) became
the session model on 2026-09-04. This pass tuned the configuration around
it (plan `docs/superpowers/plans/2026-09-04-fable-5-1-infra-update.md`,
spec `docs/superpowers/specs/2026-09-04-fable-5-1-infra-update-design.md`,
revised after a three-lens adversarial review of 49 findings).
`CLAUDE_CODE_SUBAGENT_MODEL` moved from a `.bashrc` export of `inherit` to
a settings `env` entry of `sonnet`, so dispatches without a model
(general-purpose, claude, Workflow agent() without model) stopped running
at Fable price; pins still win, proven by session-pinned transcript.
CLAUDE.md gained the effort rule (conducting at `high`, raise for research
turns, `max` for one adjudication, no standing `medium`) and landed at
5,986 tokens under its 6,000 budget. The model-economy doc update (plan
task 3) waits on another session's uncommitted edit to the same file and
is carried in STATUS. An Opus prompt audit wrote
`docs/superpowers/plans/2026-09-04-prompt-audit-report.md` (nothing
applied). `site-pass`'s start and discipline sections were restated as
outcomes and constraints with every rule kept and the pass-end ritual
byte-identical, as a measured experiment. A monthly `model-review.timer`
and a ROADMAP Active entry put the review on a cadence; first due
2026-10-01.

**What a later pass should not rediscover**:

- **The `.bashrc` comment was wrong about precedence.** It claimed a
  global `CLAUDE_CODE_SUBAGENT_MODEL` would override frontmatter. The
  documented order is per-dispatch model, then frontmatter, then the
  variable, then the session model. The variable never reaches `Explore`
  or `Plan`, and forcing it onto them would override every pin.
- **A settings `env` value beats the shell and reaches running
  sessions.** `.bashrc` was the weakest home for this variable.
- **`/usage`'s plan-limit breakdown has no per-model share.** Plan bars
  are shared across models; attribution is by skill, subagent, plugin, and
  MCP server. The Session block's per-model token counts are session API
  totals, not plan draw. Do not plan a per-model pool measurement from it.
- **`/effort` persists per model into `settings.json`** through the stow
  symlink, so an interactive effort change is dotfiles drift.
- **CLAUDE.md sits at the budget edge.** `claude-context-budget` was
  already failing (6,034) before this pass; any addition is paid for in
  the same file.
- **The site-pass experiment is open.** Its verdict comes from the next
  ecxc-ski or 907-life pass's HISTORY numbers, recorded here when known.
  A worse result reverts commit 8a958fe.

Budgets: roughly 2.2M subagent tokens against a 1.5M ceiling. The plan's own
execution (the workflow run, the close-out, and one report fix) took about
1.0M; Geoff's same-day additions after the ceiling was set took the rest
(two adversarial review rounds, about 1.0M, and the outside-evidence
research, about 0.25M). Human touchpoints: the approval, the review
request, and the Workflow and monthly-cadence grants. One question (a
`/usage` baseline percentage) went unanswered and turned out to measure
nothing; the review round removed it. That question is the pass's one
interaction defect.

## 2026-08-30 -- Post-review fix pass

The adversarial three-lens review at the reorg close (correctness,
organization, secrets/idiom; findings in the session record, plan at
`docs/superpowers/plans/2026-08-30-post-review-fix-pass.md`) drove a same-day
fix pass. Security: the sudo cache moved to tmpfs, session context now
redacts export values, the auto-mode trust block scoped to the machine, and
three write-time guards landed (claude-secret-guard PreToolUse hook, gitleaks
pre-commit via `core.hooksPath`, GitHub secret scanning + push protection).
Fresh-machine: bootstrap gained the full uv tool set, `vale sync`, timer
enable, git-hook config, a fingerprint-checked 1Password key, a fixed kitty
install, and stopped routing workstation #2 into the migration restore.
Tooling: `check-drift` (a real stow probe) replaced sync-dotfiles.sh;
update-go and chromium-browser.md retired; tierguard's chained-command false
positive fixed. Organization: `scripts/check.sh` is now the one gate;
MIGRATION-BRIEF.md moved to `docs/`; docs/secrets.md merged into
`secrets/registry.md`; vale's tests joined `tests/`; completed plans moved to
`plans/archive/`; `ROADMAP.md` created.

**What a later pass should not rediscover**:

- **The 2026-01 token leak and its post-mortem** live in
  `secrets/registry.md` under CLOUDFLARE_API_TOKEN. The leaked value is dead
  (verified against the API). The history purge ran the same day on Geoff's
  go: git filter-repo over a mirror clone, HEAD tree verified identical,
  force-pushed (all commit SHAs before 2026-08-30 changed; the pre-purge
  bundle in `~/.local/state/` is the only place the old SHAs and the token
  still exist).
- **A stow package is pure payload**: the gate's own pytest run once wrote
  `__pycache__` into `bin/` and stow linked it into `~/.local/bin`.
  `PYTHONDONTWRITEBYTECODE=1` in check.sh plus `bin/.stow-local-ignore`
  prevent it; anything a tool generates inside a package will be stowed.
- **Hook bypass must be inline**: a PreToolUse hook cannot see per-command
  environment variables, so claude-secret-guard's bypass is the
  `secret-guard-allow` marker on the flagged line, not only the env var.
- **tierguard denies via JSON permissionDecision and exits 0**; testing it
  by exit code alone reads a deny as a pass.
- **devenv-research.md stays in `bluefin/`** deliberately: four site-repo
  backlog entries point at that path (2026-08-30).

Budgets: this pass ran inline (small cross-referenced edits; a chain would
have re-encoded the whole review into every dispatch), roughly 400k tokens
including the three-lens review itself. Human touchpoints: "start the work"
plus two mid-flight refinements (prevention infra, friction preference).

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
sweep. (Correction, same day: the sweep was incomplete — chromium-browser.md
and update-go still carried apt/dpkg content; the post-review fix pass above
retired both.)

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

Budgets: roughly 1.3M tokens of a 3M ceiling (exploration fan-out ~250k, the
execution workflow ~850k over 8 tasks with 16 agent dispatches, plus the
close-out remainder). Human touchpoints: the plan approval and one batched
four-question decision round; two implementer dispatches (T5, T7) were
blocked by the tool-permission classifier over live-system deletions and
finished in the main loop, with the deletion targets parked in
`~/.local/state/trash-2026-08-30/` instead of destroyed.
