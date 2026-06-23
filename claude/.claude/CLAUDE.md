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

## Model economy

The frontier main model is expensive; spend it where it makes a substantial difference and default to cheaper models everywhere else. The main loop keeps the thinking work: brainstorming, specs, plans, research synthesis, review-finding triage, post-mortems, and final user-facing prose. Well-specified implementation goes to Sonnet-pinned implementer agents, with the main loop reviewing diffs and verifying gates between dispatches. Reviewer agents keep their deliberate Opus pins (model diversity at the review gate is a design choice, and they run once per pass). Upshift a single dispatch (`model: opus` or `model: fable`) only for novel correctness-critical logic the plan does not fully specify.

## Multi-agent workflows: suggest, never launch unprompted

The Workflow tool orchestrates fleets of subagents deterministically, and it runs only on my explicit opt-in. When a task would clearly benefit, suggest it rather than staying silent. Name what the workflow would do and the rough scale, and note that "use a workflow" is the opt-in phrase. Qualifying moments include the review gate of a large pass (an adversarial find-and-verify sweep catches more than a flat reviewer fan-out), a repo-wide audit or migration, a plan whose tasks are mostly independent, and deep multi-source research. The suggestion costs one sentence; skip it for small or already-verified work.

## Plan execution: same session by default

Plan and execute in one session. Fable 5's long context plus automatic summarization removed the old reason to hand off, so the brainstorming that produced a plan no longer crowds out the execution. Execution is orchestrate-and-verify: dispatch each well-specified plan task to the repo's implementer agent (pinned Sonnet), review its diff, and confirm the full quality gate before the next dispatch. Implement a task in the main loop, or upshift the dispatch model, only when it carries novel correctness-critical logic the plan does not fully specify.

After authoring a plan, still pre-bake the durable artifacts before executing. Commit the plan, point the project's status doc at it as the immediate next action, and refresh any relevant memory. This is insurance for a crashed or interrupted session, not a handoff. Anything load-bearing must live in the plan, spec, status doc, or memory, never only in the conversation. Do not run the `superpowers:writing-plans` "which execution method?" handoff question; same-session orchestrate-and-verify is the default.

A deliberate context clear is now the exception, reserved for an initiative whose brainstorm ran long and noisy. When clearing, give the exact prompt to paste in the fresh session, including which directory to launch in. This remains the pre-bake half of the autonomy-and-handoff practice.

## Writing voice

The `writing-voice` output style is always on (set in settings.json) and carries the
audience-invariant voice: plain voice, varied sentence length, the universal tells. The
`writing-voice` skill is the on-demand router: it maps each audience to its register and
states the shape rules and the em-dash matrix.

**Audience first.** Every piece of prose has a register. Before drafting, name the
audience and load its register through the `writing-voice` skill: site readers use the
site's own content guide, Go and web developer docs each have a dialect, end-user and
editor copy has its own register, and agent-facing text and commit messages have theirs.
Imitate the register's exemplars.

**Draft clean; Vale catches the residue.** The per-repo Vale config (the `glw907`
overlay on the Google or Microsoft baseline) is the deterministic net on docs prose and
code comments, and the `vale-hook` feeds its findings back as advisory context on save. A
clean Vale run is necessary, never sufficient, since it cannot judge voice. Draft clean
the first time from the register, and treat the hook feedback as a revision trigger for
prose you just wrote.

The highest-frequency tells, inline so they are unmissable without opening the register:
- One idea per sentence. Do not bridge two or three clauses into one.
- No "not X but Y" contrast frame. No reflexive three-item lists. No setup-colon payoff.
- No participial or connector openers ("Building on this", "Moreover", "Additionally").
- Em dashes are audience-conditional: discouraged in replies, commits, agent files, and
  editor copy, banned in code comments, allowed in developer and planning docs and (sparing)
  in site content.

Code comments also follow their stack's conventions (go-conventions for Go, file idiom
for TS/Svelte, PEP 257 for Python).
