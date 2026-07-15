# Global Claude Code Patterns -- Workstation: thinkpad-x1

## Work Autonomously Until Done

Do not ask for review, confirmation, or approval until the task is fully complete. Keep working through all known issues until every quality gate passes. The only reason to stop is a genuine blocker requiring information only the user can provide.

## Search before you spelunk (Geoff, 2026-07-13)

When a symptom looks framework- or library-specific (a form that will not submit, a build that
fails in one runtime, an API rejecting a shaped request), spend one web search on the exact
symptom BEFORE opening an interactive debugging loop: a documented quirk or GitHub issue often
names the cause in one shot that hands-on probing reaches only after many expensive main-model
turns (proven twice 2026-07-13, when one search found the SvelteKit remote-form cause a long
browser loop had missed). Both budgets favor the search. Corollary: never read a file's
"current state" to draw conclusions while a background agent is editing it; you will read a
half-applied change. Verify against committed state or wait for the agent.

## One executor per worktree (Geoff, 2026-07-14)

Before launching ANY executor into a repo or worktree (a Workflow, an implementer dispatch,
inline main-loop edits), verify no live executor is already working it: `pgrep -f <worktree
path>`, `git status` for warm uncommitted changes you did not author, other sessions' workflow
journal mtimes, and the status docs (a "fresh session executes this" line means one may
already be running; when in doubt, one sentence to Geoff beats a race). Warm uncommitted code
at dispatch time is a stop-and-investigate signal, never free progress. If a live executor is
found, stand down or coordinate: two conductors never both run a close ritual, merge, or
release on one branch. Mid-flight contention recovery is verify-not-duplicate: stop editing
contested files, wait for the other's commit, verify it against the acceptance criteria,
report it as verified. (Born 2026-07-14: two workflows raced the cairn nav-layout plan in one
worktree; ~1.2M duplicated tokens, zero corruption.)

## Machine Environment

- **OS**: Linux Mint 22.3 "Zena" (Ubuntu 24.04 base), Cinnamon desktop
- **Shell**: bash | **Editor**: neovim (primary), micro (quick edits)
- **Key paths**: `~/Projects/` (all repos), `~/.dotfiles/` (config), `~/.local/bin/` (scripts)
- **Dev tools**: Python 3.12, Java 17 (OpenJDK), Node/nvm, Git 2.43, Go 1.26.1 (/usr/local/go)
- **Android SDK**: `~/Android/` -- `ANDROID_HOME` set in .bashrc

## Sysadmin Preferences

- **Troubleshooting**: Search web after 1-2 failed attempts -- include "Linux Mint 22" in queries
- **sudo**: Always `sudo -A`. Decrypted automatically by `claude-askpass`. If the age file is missing or stale, run `claude-sudo-setup` (requires 1Password desktop app running and unlocked).
- **Packages**: apt for system/CLI tools; flatpak for GUI apps
- **Destructive ops**: Show dry-run or confirmation step first

## System Organization

- Home dir (`~/`) should have minimal loose files
- Scripts -> `~/.local/bin/` | Configs -> `~/.config/`
- When modifying configs: check if they belong in `~/.dotfiles/`

## Dotfiles Management

- **Location**: `~/.dotfiles` (git: github.com/glw907/workstation), managed via GNU Stow
- **Stow packages**: `bash`, `bin`, `claude`, `git`, `kitty`, `contacts`
- **Sync script**: `~/.dotfiles/sync-dotfiles.sh` -- checks stow status, git drift
- Adding new tracked script: copy to `~/.dotfiles/bin/.local/bin/`, then `cd ~/.dotfiles && stow -R bin`

## Git Conventions

- **Before committing code changes, run Anthropic's official `code-simplifier` agent** over the code you just changed (dispatch the `code-simplifier` subagent). It refines recently-modified code for clarity, consistency, and maintainability while preserving behavior; review and apply its refinements, then commit. Docs-only commits don't need it. Skip only when explicitly told to. (poplar keeps its own Go-aware `simplify` skill.)
- Imperative mood: "Add feature" not "Added feature"
- Co-authored footer: `Co-Authored-By: Claude <noreply@anthropic.com>`
- Commit specific files, not `git add -A`
- Never commit .env files or secrets; never force push to main/master

## Go Development

**MANDATORY: Invoke the `go-conventions` skill before writing ANY Go code.** Every Go file, function, test, and error message must conform. (For bubbletea UI work, additionally invoke `elm-conventions`.)

## Cloudflare / Wrangler

**FULL ACCOUNT ACCESS (Geoff, 2026-07-06): the CLAUDE_CODE Cloudflare API token + the MCP
plugin cover the whole glw907 account (120c269ad6d3dfbe6d63a0bb53758ca0) — zones, DNS,
Workers, Access, D1, R2 — holding BOTH the cairn-family sites AND the aksailingclub.org
estate. Make routine changes directly; never treat Cloudflare state as read-only.** The MCP
token is read-only for Access/Workers-domain writes; use curl with `$CLOUDFLARE_API_TOKEN`
for those. Access-protected ASC sites are reachable non-interactively via the service token
in `~/.local/secrets` (`ASC_ACCESS_CLIENT_ID`/`SECRET`, CF-Access-Client-* headers; full
process: the `asc-cloudflare-access` memory in the cairn project).

- `npx wrangler deploy` / `dev` / `secret put NAME` / `tail`
- `CLOUDFLARE_API_TOKEN` in `~/.local/secrets` (sourced for interactive shells only; a
  script must `source ~/.local/secrets` itself). Exact scopes: the estate inventory doc
  below, the canonical record every project defers to.

## API-First Policy

Use API or CLI first for external services -- never suggest the web dashboard unless the API cannot do it. Check `.claude/instructions/api-access.md` in each project for the specific access inventory.

## Secrets

- **Never commit**: API tokens, passwords, keys, `.env` files with real values
- **Local dev**: `~/.bashrc` (non-sensitive) or `~/.local/secrets` (sensitive, sourced from 1Password)
- **CI/CD**: GitHub Actions secrets | **Runtime**: Cloudflare Workers secrets
- **1Password: ONE prompt, never a loop.** Each `op` call can trigger a desktop approval.
  Fetch once (`op item get <id> --format json`, or `op item list --format json` for several
  items) and parse locally. A repeated prompt is a defect against Geoff's attention.
- **Installing a NEW long-lived secret, every project (Geoff, 2026-07-13): the workstation
  age store is the origin, never a loose file and never only `wrangler secret put`.** The flow:
  `~/.dotfiles/scripts/secrets/secret-set.sh NAME --value|--file|--b64-file` (writes
  `values.age`, regenerates `~/.local/secrets`; 1Password holds only the age key, fetched once
  per session), then document scope + rotation in `~/.dotfiles/secrets/registry.md`, add the
  worker to `sync.sh`'s WORKER_SECRETS routing if a Worker consumes it, push with
  `sync.sh --worker NAME`, and confirm with `sync.sh --verify`. Delete any loose key file once
  stored; the upstream issuer (GCP IAM, GitHub App settings, ...) is the mint-a-new-one origin.
  Exception: ASC secrets use the ASC per-project store (`aksailingclub-legacy/secrets/`), and
  per-site rotatable HMAC keys (MAGIC_LINK_SECRET/SESSION_SECRET) stay worker-only by design.
- **Cloudflare estate + how each secret is reached**: `~/.claude/docs/cloudflare-estate-inventory.md`
  (values-free inventory of D1/R2/workers/Access + the authorization model; worker secrets are
  write-only, so a value comes from its origin store, not the worker). Read it before hunting a
  credential or provisioning infra.
- **Check the stores before claiming a secret is missing.** Status docs record intent; the
  stores record what happened. Before telling Geoff a credential is owed, check in order:
  `npx wrangler secret list` (per worker), `~/.local/secrets`, the age registry
  (`~/.dotfiles/secrets/registry.md`), per-project stores (a repo's `secrets/` dir + sync
  script; ASC's is `aksailingclub-legacy/secrets/`), and the estate inventory above. If none
  has it, that is the finding, not "Geoff owes a paste." Name-only checks, never print
  values. (Born 2026-07-07, twice, both false "you still owe me X" reports.)

## Email (poplar)

- **Client**: poplar, a bubbletea terminal email client built from `~/Projects/poplar/`
- **Account**: Fastmail via JMAP (primary), Gmail via IMAP (v1 target)
- **JMAP auth**: `$FASTMAIL_API_TOKEN` (in `~/.local/secrets`)
- **Binary**: `~/.local/bin/poplar`, installed via `make install`
- **API reference**: `~/.claude/instructions/fastmail-api.md` (JMAP endpoints, capabilities, examples)

## Neovim

- **Version**: 0.12.0-dev from `ppa:neovim-ppa/unstable`
- **nvim-journal**: `~/.config/nvim-journal/` -- jrnl-md editor with zen-mode + typewriter scrolling
- **Full setup docs**: `~/.claude/docs/neovim-setup.md` (read on demand)

## Visual fidelity (all projects, 2026-07-05)

Any UI work that must MATCH an existing reference (a rebuild, a theme port, a migration)
invokes the `visual-fidelity` skill at the start and gates on the `visual-verifier` agent.
Core rules even without the skill: reference screenshots before any plan (never build from a
verbal description); the context that built the UI never grades it; nothing deploys to
production without a full-page render read in the main loop; user-facing sites get Geoff's
before/after. (Born from two same-day production misses with all-green mechanical gates.)

## Claude Code Agent Usage

Do not provide human-scale time estimates. Describe relative complexity: "quick", "straightforward", "multi-step". Focus on sequencing, dependencies, and testing steps.

## Model economy (Fable conducts)

Two co-equal budgets govern every initiative at the same quality bar: total tokens spent and
Geoff's attended time. **Clock time is explicitly NOT a budget (Geoff, 2026-07-13): prefer the
serial, cheaper path, and never trade tokens or an extra Geoff interaction to finish sooner.**
When the budgets conflict, spend the one that can buy the thing: tokens for anything research,
verification, or a retry can resolve; attended time only for taste, priorities, and product
forks. Fable output costs $50/MTok (2x Opus 4.8, ~3x Sonnet 5, 10x Haiku 4.5) on the tightest
rate-limit bucket, so its seat is the judgment that prevents rework: brainstorming, specs,
plan authorship, dispatch decisions, diff review and finding triage, synthesis, post-mortems,
final user-facing prose. Never downshift the planner: a weak plan compounds into rework that
exceeds the savings; a cheap implementer executing a frontier-authored plan is the stable
configuration.

Volume work never runs in the main loop; if the main loop is implementing, bulk-reading, or
grinding mechanical edits, dispatch it. Well-specified implementation goes to the Sonnet-pinned
implementers. Reviewers keep their Opus pins: beside a Fable conductor and Sonnet implementers,
the Opus gate is also cross-model diversity against correlated self-review blind spots.

Unpinned agents (`general-purpose`, `Plan`, the `claude` catch-all, Workflow `agent()` calls
without `model`) inherit the main model at main-loop price, so every such dispatch carries an
explicit model: `sonnet` by default, `haiku` for mechanical search (Explore is already Haiku).
Upshift a single dispatch (`model: opus`/`fable`) only for novel correctness-critical logic
the plan does not fully specify. Effort is the second lever, cheaper than a model swap in both
directions: low on mechanical dispatches; raise it on a cheap model before upshifting the
model; the main loop stays at high, with xhigh/max reserved for a single hard decision (max
overthinks). Subagents start with zero context and read the dispatch literally: pre-extract
exactly what the task needs; whole-history pastes recreate the bloat the split removes. Trust
but verify the pins (silent failures have shipped in both directions): when a dispatch runs
surprisingly slow, expensive, or weak, check which model actually ran first.

## Post-Fable model economy (after the included-access window closes)

The Max-plan Fable window has been extended twice (2026-07-07 → 07-12 → **07-19**; Fable
draws up to 50% of weekly plan limits inside it). While it is open, "Fable conducts" stands;
the dates keep moving, so verify the current window online before declaring the doctrine
switched. After it truly closes, OPUS 4.8 CONDUCTS and Fable is a credit-metered specialist
governed by `~/.claude/docs/fable-post-cutoff-system.md`: batch-first (50% discount),
per-dispatch one-shots, rare cached sittings, and the SUGGESTION RULES baked there (never
silently spend Fable, never silently absorb Fable-tier work; propose job + mode + size in one
sentence and let Geoff decide). The rest of the model economy stands unchanged. **Self-check
at session start and on any cost signal: a Fable conductor without a deliberate,
Geoff-approved sitting gets flagged immediately with a recommendation to switch to Opus** (an
ecxc session silently burned ~1M tokens on 2026-07-13; the flag came from Geoff, not the
conductor — that order is the defect).

## Multi-agent workflows: suggest, never launch unprompted

The Workflow tool runs only on Geoff's explicit opt-in ("use a workflow"). When a task would
clearly benefit — a large pass's review gate (adversarial find-and-verify beats a flat
reviewer fan-out), a repo-wide audit or migration, a plan of mostly independent tasks, deep
multi-source research — suggest it in one sentence naming the shape and rough scale. Skip the
suggestion for small or already-verified work.

**Runaway guard, mandatory on any workflow expected to run past ~30 minutes.** Nothing
intervenes unless the main loop watches from outside (proven 2026-07-02: a sweep agent burned
~5 hours grooming its own agent-memory index). At launch, arm a background Bash guard polling
the workflow transcript dir every ~5 minutes, alarming on either signature: `journal.jsonl`
idle past ~25 minutes (stall), or any `agent-*.jsonl` past ~900KB and still growing (token
runaway; ~3.5-4 chars/token). Intervention: TaskStop, relaunch with `resumeFromRunId` (done
steps replay from cache). Prevention rides the prompts: memory-keeping agentTypes get an
explicit "skip agent-memory maintenance" line, and each step states a scope expectation so an
agent that blows past it self-reports. For expensive sweeps, add a hard turn-level token
target, which makes `agent()` calls throw at the ceiling.

## Initiative-scoped sessions (from the cairn arc ledger; globalized 2026-07-13)

One session per initiative, not one session per week: every turn re-reads the whole cached
conversation, so a long session's meter compounds even with disciplined steps (the cairn arc's
cost ledger was dominated by one five-day session's cache reads). When an initiative lands
(pass shipped, post-mortem recorded, STATUS pointed at the next action), close the session;
the pre-baked artifacts are the handoff. Mid-initiative clears follow the existing rule (exact
resume prompt, launch directory). The same force argues for batching questions and dispatching
reads within a session: each extra turn re-buys the context.

## Plan execution: same session by default

Plan and execute in one session; long context plus summarization removed the old reason to
hand off. Execution is orchestrate-and-verify: dispatch each plan task to the repo's
implementer (pinned Sonnet), review its diff, confirm the full gate before the next dispatch;
main-loop implementation or a model upshift only for novel correctness-critical logic the plan
does not fully specify. Before executing, still pre-bake the durable artifacts as crash
insurance: commit the plan, point the status doc at it as the immediate next action, refresh
the relevant memory — anything load-bearing lives in the plan, spec, status doc, or memory,
never only in the conversation. Do not run the `superpowers:writing-plans` "which execution
method?" question; same-session is the default. A deliberate clear is the exception, for a
brainstorm that ran long and noisy; when clearing, give the exact resume prompt and the launch
directory.

## Process proportionality (Fable-era superpowers)

The human gate is plan approval, once. After approval, execution runs to completion with no
per-task check-ins ("should I continue?" prompts and progress summaries waste Geoff's time);
the automated layers replace the mid-loop human: quality gates, the orchestrator's per-dispatch
diff review, the pass-end reviewer fan-out. Batch mid-execution judgment calls into one
combined question; stop early only for a genuine blocker or scope change.

Plans specify outcomes, constraints, and acceptance criteria per task, never implementation
code (embedded code is written twice; the implementer rewrites it anyway). Small tasks skip
the ceremony: a change touching a handful of files, fully specified by the request or existing
tests, adding no new public surface, schema, or auth behavior, goes straight to implementation
through the gates and code-simplifier. Do not add verification-reminder ceremony on top of the
mechanical gates; when the track is genuinely unclear, ask in one sentence.

Score both budgets at pass end: tokens spent (from `/cost` or the usage console) and human
interaction points (every question, approval, and correction that pulled Geoff in; a question
that did not change the outcome is a defect). The trend across passes is the signal, so record
the numbers even when they look bad.

## Writing voice

Claude writes to a published external standard per audience, not a house voice. The
`writing-voice` output style (always on) carries the audience-invariant core; the
`writing-voice` skill is the on-demand router to each standard; the authoring charter
(`~/.claude/docs/authoring-charter.md`) is the umbrella. **Audience first**: before drafting,
name the audience and load its standard through the skill — developer docs follow Google,
editor copy Microsoft, agent-facing files Anthropic's Claude Code best practices, commits
Conventional Commits, code comments their language standard (Go Doc Comments via
go-conventions, TSDoc via ts-/svelte-conventions, PEP 257 via python-conventions). Site
content is the one personal voice, in the site repo's own content guide. Imitate the
standard's canonical exemplars. Vale (Google package on developer docs, Microsoft on editor
copy) plus the native comment linters are the deterministic net, fed back by `vale-hook` on
save; a clean run is necessary, never sufficient. Draft clean the first time.

The highest-frequency tells, inline so they are unmissable:
- One idea per sentence. Do not bridge two or three clauses into one.
- No "not X but Y" contrast frame. No reflexive three-item lists. No setup-colon payoff.
- No participial or connector openers ("Building on this", "Moreover", "Additionally").
- The em dash is banned in code comments (linter-enforced). Developer docs follow Google (no
  spaces); editor copy Microsoft; replies and commits go without. Overuse is a tell anywhere.
