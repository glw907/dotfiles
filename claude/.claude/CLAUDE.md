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
- **Stow packages**: `bash`, `bin`, `claude`, `git`, `beautiful-aerc`, `kitty`, `applications`, `contacts`
- **Sync script**: `~/.dotfiles/sync-dotfiles.sh` -- checks stow status, git drift
- Adding new tracked script: copy to `~/.dotfiles/bin/.local/bin/`, then `cd ~/.dotfiles && stow -R bin`

## Git Conventions

- Imperative mood: "Add feature" not "Added feature"
- Co-authored footer: `Co-Authored-By: Claude <noreply@anthropic.com>`
- Commit specific files, not `git add -A`
- Never commit .env files or secrets; never force push to main/master

## Go Development

**MANDATORY: Read and follow `~/.claude/docs/go-conventions.md` before writing ANY Go code.** Every Go file, function, test, and error message must conform.

## Cloudflare / Wrangler

- `npx wrangler deploy` / `dev` / `secret put NAME` / `tail`
- `CLOUDFLARE_API_TOKEN` in `~/.bashrc` -- Wrangler picks it up automatically

## API-First Policy

Use API or CLI first for external services -- never suggest the web dashboard unless the API genuinely cannot do it. Check `.claude/instructions/api-access.md` in each project for the specific access inventory.

## Secrets

- **Never commit**: API tokens, passwords, keys, `.env` files with real values
- **Local dev**: `~/.bashrc` (non-sensitive) or `~/.local/secrets` (sensitive, sourced from 1Password)
- **CI/CD**: GitHub Actions secrets | **Runtime**: Cloudflare Workers secrets

## aerc (Email)

- **Client**: aerc terminal email client, launched via `mail` script in `~/.local/bin/`
- **Config**: `~/.dotfiles/beautiful-aerc/.config/aerc/` (stow package: `beautiful-aerc`)
- **Account**: Fastmail via IMAP/SMTP, with JMAP API for programmatic operations
- **Filters**: `beautiful-aerc` Go binary handles message rendering (headers, HTML, plain text)
- **Compose editor**: nvim-mail profile (`~/.config/nvim-mail/`) with custom `aercmail` syntax
- **Theme**: Nord-based, generated from `.config/aerc/themes/` via generator script
- **Full setup docs**: @~/.claude/docs/aerc-setup.md

### aerc-rules (Fastmail Filter Manager)

- **Project**: `~/Projects/aerc-rules/` -- Go CLI for managing Fastmail mail filters
- **Binary**: `~/.local/bin/aerc-rules`
- **Rules file**: `~/.config/aerc/mailrules.json` (or `$AERC_RULES_FILE`)
- **JMAP auth**: `$FASTMAIL_API_TOKEN` (in `~/.local/secrets`)
- **Keybindings**: `ff`/`fs`/`ft` (message list), `Ff`/`Fs`/`Ft` (viewer) -- filter by from/subject/to
- **Key commands**: `interactive` (full flow), `add`, `sweep`, `count`, `export`

## Neovim

- **Version**: 0.12.0-dev from `ppa:neovim-ppa/unstable`
- **nvim-journal**: `~/.config/nvim-journal/` -- jrnl-md editor with zen-mode + typewriter scrolling
- **nvim-mail**: `~/.dotfiles/nvim-mail/.config/nvim-mail/` -- aerc compose editor
- **Full setup docs**: @~/.claude/docs/neovim-setup.md

## Claude Code Agent Usage

Do not provide human-scale time estimates. Describe relative complexity: "quick", "straightforward", "multi-step". Focus on sequencing, dependencies, and testing steps.
