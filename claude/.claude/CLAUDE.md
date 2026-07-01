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

- `npx wrangler deploy` / `dev` / `secret put NAME` / `tail`
- `CLOUDFLARE_API_TOKEN` in `~/.bashrc` -- Wrangler picks it up automatically

## API-First Policy

Use API or CLI first for external services -- never suggest the web dashboard unless the API cannot do it. Check `.claude/instructions/api-access.md` in each project for the specific access inventory.

## Secrets

- **Never commit**: API tokens, passwords, keys, `.env` files with real values
- **Local dev**: `~/.bashrc` (non-sensitive) or `~/.local/secrets` (sensitive, sourced from 1Password)
- **CI/CD**: GitHub Actions secrets | **Runtime**: Cloudflare Workers secrets

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

## Claude Code Agent Usage

Do not provide human-scale time estimates. Describe relative complexity: "quick", "straightforward", "multi-step". Focus on sequencing, dependencies, and testing steps.

## Model economy (Fable conducts)

Two co-equal budgets govern every initiative at the same quality bar: total tokens spent and
Geoff's attended time. Neither means minimal main-model usage, and they trade against each other.
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

## Multi-agent workflows: suggest, never launch unprompted

The Workflow tool orchestrates fleets of subagents deterministically, and it runs only on my explicit opt-in. When a task would clearly benefit, suggest it rather than staying silent. Name what the workflow would do and the rough scale, and note that "use a workflow" is the opt-in phrase. Qualifying moments include the review gate of a large pass (an adversarial find-and-verify sweep catches more than a flat reviewer fan-out), a repo-wide audit or migration, a plan whose tasks are mostly independent, and deep multi-source research. The suggestion costs one sentence; skip it for small or already-verified work.

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
