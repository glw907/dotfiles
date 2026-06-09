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

## Multi-agent workflows: suggest, never launch unprompted

The Workflow tool orchestrates fleets of subagents deterministically, and it runs only on my explicit opt-in. When a task would clearly benefit, suggest it rather than staying silent. Name what the workflow would do and the rough scale, and note that "use a workflow" is the opt-in phrase. Qualifying moments include the review gate of a large pass (an adversarial find-and-verify sweep catches more than a flat reviewer fan-out), a repo-wide audit or migration, a plan whose tasks are mostly independent, and deep multi-source research. The suggestion costs one sentence; skip it for small or already-verified work.

## Plan execution: same session by default

Plan and execute in one session. Fable 5's long context plus automatic summarization removed the old reason to hand off, so the brainstorming that produced a plan no longer crowds out the execution. Run the plan's tasks in the main loop, test-first, with the full quality gate after each task. Dispatch an implementer subagent only when tasks are independent enough to run in parallel, or when a high-blast-radius change wants worktree isolation.

After authoring a plan, still pre-bake the durable artifacts before executing. Commit the plan, point the project's status doc at it as the immediate next action, and refresh any relevant memory. This is insurance for a crashed or interrupted session, not a handoff. Anything load-bearing must live in the plan, spec, status doc, or memory, never only in the conversation. Do not run the `superpowers:writing-plans` "which execution method?" handoff question; main-loop execution is the default.

A deliberate context clear is now the exception, reserved for an initiative whose brainstorm ran long and noisy. When clearing, give the exact prompt to paste in the fresh session, including which directory to launch in. This remains the pre-bake half of the autonomy-and-handoff practice.

## Writing voice

The `writing-voice` output style is always on (set in settings.json) and carries the
full prose standard: plain voice, varied sentence length, no AI-writing tells.

**Audience first.** Every piece of prose has a register. Before drafting, name the
audience and open its register file under `~/.claude/docs/voice/` (routing table in
`prose-voice.md`): site readers use the site's own content guide, Go and web developer
docs each have a dialect, agent-facing text and commit messages have their own files.
Imitate the register's exemplars; the tell rules are the same in every register.

**Pre-flight, not cleanup.** Before composing any doc, plan, spec, ADR, or longer
commit body, read `~/.claude/docs/prose-voice.md` first. It holds the full banned-
construction list and the first-draft rule. The `prose-guard` hook
(`~/.local/bin/prose-guard`) rejects the whole file on a violation, so a dirty draft
costs a full rewrite. Drafting clean on the first pass is the cheap path.

The highest-frequency tells, inline so they are unmissable without opening the file:
- No em dashes in prose. End the sentence, or use a colon, a comma, or parentheses.
- One idea per sentence. Do not bridge two or three clauses into one.
- No "not X but Y" contrast frame. No reflexive three-item lists. No setup-colon payoff.
- No participial or connector openers ("Building on this", "Moreover", "Additionally").

Code comments also follow their stack's conventions (go-conventions for Go, file idiom
for TS/Svelte, PEP 257 for Python).
