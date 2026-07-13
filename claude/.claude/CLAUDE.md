# Global Claude Code Patterns -- Workstation: thinkpad-x1

## Work Autonomously Until Done

Do not ask for review, confirmation, or approval until the task is fully complete. Keep working through all known issues until every quality gate passes. The only reason to stop is a genuine blocker requiring information only the user can provide.

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

**FULL ACCOUNT ACCESS (Geoff, 2026-07-06): the CLAUDE_CODE Cloudflare API token + the
Cloudflare MCP plugin have full access to the glw907 account (120c269ad6d3dfbe6d63a0bb53758ca0)
— zones, DNS, Workers, Access apps/policies, D1, R2. Make changes directly when a task
needs them (DNS records, worker domains, Access policies); don't treat Cloudflare state as
read-only or ask permission for routine wiring. The account holds BOTH the cairn-family
sites AND the aksailingclub.org estate (asc-staging, asc-handbook, asc-ops, the live site
worker, SendGrid/Resend mail DNS).** Access-protected ASC sites (dev/staging) are reachable
non-interactively via the service token in `~/.local/secrets`
(`ASC_ACCESS_CLIENT_ID`/`ASC_ACCESS_CLIENT_SECRET`, CF-Access-Client-* headers); the full
process is the `asc-cloudflare-access` memory in the cairn project. The MCP plugin's token
is read-only for Access/Workers-domain writes; use curl with `$CLOUDFLARE_API_TOKEN` for
writes.

- `npx wrangler deploy` / `dev` / `secret put NAME` / `tail`
- `CLOUDFLARE_API_TOKEN` in `~/.bashrc` -- Wrangler picks it up automatically

## API-First Policy

Use API or CLI first for external services -- never suggest the web dashboard unless the API cannot do it. Check `.claude/instructions/api-access.md` in each project for the specific access inventory.

## Secrets

- **Never commit**: API tokens, passwords, keys, `.env` files with real values
- **Local dev**: `~/.bashrc` (non-sensitive) or `~/.local/secrets` (sensitive, sourced from 1Password)
- **CI/CD**: GitHub Actions secrets | **Runtime**: Cloudflare Workers secrets
- **1Password: ONE prompt, never a loop.** Each `op` call can trigger a desktop approval, so a
  loop of `op item get`/`op read` calls spams Geoff with prompts. Fetch once with a single
  `op item get <id> --format json` and parse every field locally; batch a multi-item need into
  one `op item list --format json`. A repeated prompt is a defect against Geoff's attention.
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
- **Check the stores before claiming a secret is missing.** Status docs and memories record
  intent at write time; the stores record what actually happened. Before telling Geoff a
  credential is missing or still owed, check in order: `npx wrangler secret list` (per worker),
  `~/.local/secrets`, the workstation age registry (`~/.dotfiles/secrets/registry.md`),
  per-project stores (any repo's `secrets/` dir + sync script — the ASC one is
  `aksailingclub-legacy/secrets/` with its own registry and worker map), and the estate
  inventory above. If none of them has it, it isn't a managed secret — treat that as the
  finding, not "Geoff owes a paste." Name-only checks, never print values. A wrong "you still
  owe me X" costs Geoff attention and erodes trust in real gap reports. (Born 2026-07-07,
  twice: a stale STATUS line said the Stripe key was pending while the worker held it; then
  the Discord webhooks sat "on Geoff's queue" while the ASC store had all seven.)

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

Any UI work that must MATCH an existing reference — a site rebuild, a theme port, a design
migration — invokes the `visual-fidelity` skill at the start and uses the `visual-verifier`
agent as the grading gate. The core rules, even without the skill: reference screenshots
before any plan (never build from a verbal description of a design); the context that
built the UI never grades it (fresh-context verifier, then my own read of the renders);
nothing deploys to production without at least one full-page render read in the main loop;
user-facing sites get Geoff's before/after. Born from two same-day production visual
misses whose mechanical gates were all green (cairn, 2026-07-05).

## Claude Code Agent Usage

Do not provide human-scale time estimates. Describe relative complexity: "quick", "straightforward", "multi-step". Focus on sequencing, dependencies, and testing steps.

## Model economy (Fable conducts)

Two co-equal budgets govern every initiative at the same quality bar: total tokens spent and
Geoff's attended time. **Clock time is explicitly NOT a budget (Geoff, 2026-07-13): prefer the
serial, cheaper path over parallelism or inline main-loop work bought at token cost, and never
trade tokens or an extra Geoff interaction to finish sooner.** The frontier conductor is for
high-ROI judgment only (planning, orchestrating, dispatch decisions, triage, final prose);
everything mechanical goes to the cheapest agent suited to the task, and a frontier-conducted
session keeps its own turn count low by batching tool calls and dispatching reads and edits.
Neither budget means minimal main-model usage, and they trade against each other.
When they conflict, spend the budget that can buy the thing: tokens for anything research,
verification, or a retry can resolve; attended time only for taste, priorities, and product
forks. Asking Geoff what a search could answer misroutes his time; dispatching so cheap that he
must correct the rework misroutes both. Fable output costs $50/MTok (2x Opus 4.8, ~3x Sonnet 5, 10x Haiku 4.5) and draws from a
tighter rate-limit bucket than any other model, so its seat is the judgment that prevents rework:
brainstorming, specs, plan authorship, dispatch decisions, diff review and finding triage,
synthesis, post-mortems, and final user-facing prose. Never downshift the planner. A weak plan
compounds into downstream rework that exceeds the savings; a cheap implementer executing a
frontier-authored plan is the stable configuration.

Volume work never runs in the main loop. If the main loop is implementing, bulk-reading files, or
grinding mechanical edits, that is the leak; dispatch it. Well-specified implementation goes to the
Sonnet-pinned implementer agents. Reviewer agents keep their Opus pins: with a Fable conductor and
Sonnet implementers, the Opus review gate is also cross-model diversity, which counters the
correlated blind spots of same-model self-review.

Unpinned agents inherit the main model. `general-purpose`, `Plan`, the `claude` catch-all, and
Workflow `agent()` calls without a `model` option all run on Fable at main-loop price unless told
otherwise, so every dispatch to an unpinned agent carries an explicit model: `sonnet` by default,
`haiku` for mechanical search and file discovery (Explore is already Haiku). Upshift a single
dispatch (`model: opus` or `model: fable`) only for novel correctness-critical logic the plan does
not fully specify.

Effort is the second lever, cheaper than a model swap in both directions: drop `effort` to low on
mechanical dispatches, and raise it on a cheap model before upshifting the model. The main loop
stays at high (Fable's default); reserve xhigh or max for a single hard decision, since max is
prone to overthinking.

Subagents start with zero context and read the dispatch literally. Pre-extract exactly what the
task needs; an under-specified dispatch returns incomplete work, and pasting whole history
recreates the context bloat the split exists to remove.

Trust but verify the pins: the model-pin mechanism has shipped silent failures in both directions
(per-dispatch `model` ignored; frontmatter pins not applied). When a dispatch runs surprisingly
slow, expensive, or weak, check which model actually ran before adjusting anything else.

## Post-Fable model economy (after the included-access window closes)

The Max-plan Fable window has been extended twice (2026-07-07 → 07-12 → **07-19**, per
Anthropic's announcements; Fable draws up to 50% of weekly plan limits inside it). While the
window is open, "Fable conducts" stands. The dates keep moving, so on any session where the
distinction matters, verify the current window online before declaring the doctrine switched.
After it truly closes, OPUS 4.8 CONDUCTS and Fable is a
credit-metered specialist governed by `~/.claude/docs/fable-post-cutoff-system.md`:
batch-first (50% discount), per-dispatch one-shots, rare cached sittings — and the
conductor's SUGGESTION RULES (baked there): never silently spend Fable, never silently
absorb Fable-tier work; propose the job + mode + size in one sentence and let Geoff
decide. The rest of the model economy (Sonnet volume, Opus review, pre-extraction,
guards) stands unchanged. **Self-check at session start and on any cost signal: if the
session is running Fable as conductor without a deliberate, Geoff-approved sitting, say so
immediately and recommend switching to Opus** (a Fable-conducted ecxc session silently
burned ~1M tokens on 2026-07-13; the flag came from Geoff, not the conductor — that order
is the defect).

## Multi-agent workflows: suggest, never launch unprompted

The Workflow tool orchestrates fleets of subagents deterministically, and it runs only on my explicit opt-in. When a task would clearly benefit, suggest it rather than staying silent. Name what the workflow would do and the rough scale, and note that "use a workflow" is the opt-in phrase. Qualifying moments include the review gate of a large pass (an adversarial find-and-verify sweep catches more than a flat reviewer fan-out), a repo-wide audit or migration, a plan whose tasks are mostly independent, and deep multi-source research. The suggestion costs one sentence; skip it for small or already-verified work.

**Runaway guard, mandatory on any workflow expected to run more than ~30 minutes.** Workflow
scripts cannot watch a clock or the filesystem, exact token counts arrive only at completion,
and an agent looping on cheap tool calls never errors, so nothing intervenes unless the main
loop watches from outside (proven 2026-07-02: a sweep agent burned ~5 hours trimming its own
agent-memory index). At launch, arm a background Bash guard polling the workflow transcript
dir every ~5 minutes, alarming on either signature: `journal.jsonl` idle past ~25 minutes (a
stall), or any single `agent-*.jsonl` past ~900KB and still growing (a token runaway; bytes
are the live proxy at roughly 3.5-4 chars per token). Intervention: TaskStop the workflow
task, relaunch with `resumeFromRunId` so completed steps replay from cache and only the live
step re-runs. Prevention rides the prompts: any workflow agent using a memory-keeping
agentType gets an explicit "skip agent-memory maintenance" line, and each step states a scope
or wall-clock expectation so an agent that blows past it self-reports instead of grinding.
For expensive sweeps, pair the soft guard with a hard turn-level token target, which makes
`agent()` calls throw at the ceiling.

## Initiative-scoped sessions (from the cairn arc ledger; globalized 2026-07-13)

One session per initiative, not one session per week. The cairn arc's cost ledger found its
token total dominated by cache reads from a single five-day session: every turn re-reads the
whole cached conversation, so a long session's meter compounds even when each step is
disciplined and the volume work is dispatched. When an initiative lands (pass shipped, post-
mortem recorded, STATUS pointed at the next action), close the session rather than rolling
into the next initiative; the pre-baked artifacts are the handoff. Mid-initiative clears
follow the existing rule (exact resume prompt, launch directory). Within a session, the same
force argues for batching questions and dispatching reads: each extra turn re-buys the
context.

## Plan execution: same session by default

Plan and execute in one session. Fable 5's long context plus automatic summarization removed the old reason to hand off, so the brainstorming that produced a plan no longer crowds out the execution. Execution is orchestrate-and-verify: dispatch each well-specified plan task to the repo's implementer agent (pinned Sonnet), review its diff, and confirm the full quality gate before the next dispatch. Implement a task in the main loop, or upshift the dispatch model, only when it carries novel correctness-critical logic the plan does not fully specify.

After authoring a plan, still pre-bake the durable artifacts before executing. Commit the plan, point the project's status doc at it as the immediate next action, and refresh any relevant memory. This is insurance for a crashed or interrupted session, not a handoff. Anything load-bearing must live in the plan, spec, status doc, or memory, never only in the conversation. Do not run the `superpowers:writing-plans` "which execution method?" handoff question; same-session orchestrate-and-verify is the default.

A deliberate context clear is now the exception, reserved for an initiative whose brainstorm ran long and noisy. When clearing, give the exact prompt to paste in the fresh session, including which directory to launch in. This remains the pre-bake half of the autonomy-and-handoff practice.

## Process proportionality (Fable-era superpowers)

The human gate is plan approval, once. Brainstorm and plan interactively; after the plan is
approved, execution runs to completion with no per-task check-ins, in the spirit of
`superpowers:subagent-driven-development` ("should I continue?" prompts and progress summaries
waste Geoff's time). Automated layers replace the mid-loop human: the repo's quality gates, the
orchestrator's diff review after each dispatch, and the reviewer fan-out at the pass end. Batch
judgment calls that arise mid-execution into one combined question instead of stopping per item;
stop early only for a genuine blocker or a scope change.

Plans specify outcomes, constraints, and acceptance criteria per task, never implementation code.
A plan that embeds code is written twice, because the implementer rewrites it anyway; describe
what done looks like (tests, seams, contracts) and let the implementer choose the code.

Small tasks skip the ceremony. When a change touches a handful of files, has its behavior fully
specified by the request or the existing tests, and adds no new public surface, schema, or auth
behavior, skip brainstorming and plan-writing and implement directly, still through the quality
gates and code-simplifier. Fable investigates before acting and verifies its own work, which
covers what the ceremony compensated for in smaller models; for the same reason, do not add
verification-reminder ceremony in the main loop on top of the mechanical gates. When the track
is genuinely unclear, ask which one in a single sentence, not a brainstorming loop.

Score both budgets at pass end. In the post-mortem, record two numbers: tokens spent (from
`/cost` or the usage console) and human interaction points, counting every question, approval,
and correction that pulled Geoff in. A question that did not change the outcome is a defect
against the second budget. No proven composite score exists for the pair; the trend across
passes is the signal, so record the numbers even when they look bad.

## Writing voice

Claude writes to a published external standard per audience, not a house voice. The
`writing-voice` output style is always on (set in settings.json) and carries the
audience-invariant core: plain voice, varied sentence length, the universal AI-writing
tells. The `writing-voice` skill is the on-demand router: it maps each audience to its
external standard and states the shape rules. The authoring charter
(`~/.claude/docs/authoring-charter.md`) is the umbrella over all of it.

**Audience first.** Every piece of prose has a standard. Before drafting, name the
audience and load its standard through the `writing-voice` skill: developer docs follow
the Google style guide, editor copy the Microsoft guide, agent-facing files Anthropic's
Claude Code best practices, commits Conventional Commits, and code comments their
language standard (Go Doc Comments, TSDoc, PEP 257). Site content is the one personal
voice and lives in the site repo with its own content guide. Imitate the standard's
canonical exemplars.

**Draft clean; the linter catches the residue.** Vale runs the Google package on
developer docs and the Microsoft package on editor copy, the deterministic net on docs
prose, and the `vale-hook` feeds its findings back as advisory context on save. The
native comment linters cover code comments (gofmt and go vet, ESLint jsdoc and tsdoc,
ruff `D`). A clean linter run is necessary, never sufficient, since it cannot judge
voice. Draft clean the first time from the standard's exemplars, and treat the hook
feedback as a revision trigger for prose you just wrote.

The highest-frequency tells, inline so they are unmissable without opening the standard:
- One idea per sentence. Do not bridge two or three clauses into one.
- No "not X but Y" contrast frame. No reflexive three-item lists. No setup-colon payoff.
- No participial or connector openers ("Building on this", "Moreover", "Additionally").
- The em dash is banned in code comments (a keyboard, grep, and monospace hygiene rule the linter
  enforces). Developer docs follow Google, which recommends it with no spaces; editor copy follows
  Microsoft; replies and commits go without. Overuse is a tell anywhere.

Code comments follow their stack's external standard: go-conventions for Go (Go Doc
Comments), ts-conventions and svelte-conventions for TS/Svelte (TSDoc), python-conventions
for Python (PEP 257).
