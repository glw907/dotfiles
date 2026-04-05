# Global Claude Code Patterns — Workstation: thinkpad-x1

## MANDATORY: Work Autonomously Until Done

**Do not ask for review, confirmation, or approval until the task is fully complete.** Never say "ready for your review," "want me to commit?", "should I continue?", or similar. Keep working through all known issues until every quality gate passes and zero problems remain. The only reason to stop is a genuine blocker requiring information only the user can provide.

## Machine Environment

- **OS**: Linux Mint 22.3 "Zena" (Ubuntu 24.04 base), Cinnamon desktop
- **Shell**: bash | **Editor**: micro (quick edits), vscodium (scripts/code)
- **Key paths**: `~/Projects/` (all repos), `~/.dotfiles/` (config), `~/.local/bin/` (scripts)
- **Dev tools**: Python 3.12, Java 17 (OpenJDK), Node/nvm, Git 2.43, Go 1.26.1 (/usr/local/go)
- **Android SDK**: `~/Android/` — `ANDROID_HOME` set in .bashrc; `adb`/`fastboot` in platform-tools

## Sysadmin Preferences

- **Troubleshooting**: Search web after 1-2 failed attempts — include "Linux Mint 22" in queries
- **sudo**: Always `sudo -A`. The password is age-encrypted at `~/.cache/sudo-password.age` and decrypted automatically by `claude-askpass`. No setup needed - just use `sudo -A` directly. If the age file is missing or stale, run `claude-sudo-setup` (requires 1Password desktop app running - start it with `1password &` if needed, user must unlock it).
- **Packages**: apt for system/CLI tools and libraries; flatpak for GUI apps
  - Current flatpaks: Discord, Fastmail, noson, Apostrophe
- **Communication**: Direct answers; show command first, explain after; recommend one approach
- **Destructive ops**: Show dry-run or confirmation step first

## System Organization

- Home dir (`~/`) should have minimal loose files
- Scripts → `~/.local/bin/` | Configs → `~/.config/`
- After operations: remove temp files; suggest `sudo -A apt autoremove && sudo -A apt autoclean`
- When modifying configs: check if they belong in `~/.dotfiles/`
- Proactively suggest moving misplaced files to proper locations

## Dotfiles Management

- **Location**: `~/.dotfiles` (git: github.com/glw907/workstation), managed via GNU Stow
- **Stow packages**: `bash`, `bin`, `claude`, `vscodium`, `git`, `beautiful-aerc`, `kitty`, `applications`, `contacts`
- **Key symlinks**: `~/.bashrc` → dotfiles/bash | `~/.claude/` files → dotfiles/claude | `~/.gitconfig` → dotfiles/git
- **Sync script**: `~/.dotfiles/sync-dotfiles.sh` — checks stow status, git drift, VSCodium extensions
- After sysadmin config changes: run sync-dotfiles.sh and commit updates to dotfiles repo
- Adding new tracked script: copy to `~/.dotfiles/bin/.local/bin/`, then `cd ~/.dotfiles && stow -R bin`

## Hugo Sites

### Content Structure
- Posts use page bundles: `content/posts/YYYY-MM-DD-slug/index.md`
- Featured images: same directory as index.md (e.g., `featured.jpg`)
- Front matter: title, date, draft, tags, description

### Commands
```bash
hugo server -D              # Dev with drafts
hugo --gc --minify          # Production build
hugo new posts/YYYY-MM-DD-my-post/index.md
```

### Front Matter Template
```yaml
---
title: "Post Title"
date: YYYY-MM-DD
draft: false
tags: ["tag1", "tag2"]
description: "Brief description for SEO and previews"
---
```

## Git Conventions

### Commits
- Imperative mood: "Add feature" not "Added feature"
- Co-authored footer for Claude contributions:
  ```
  Co-Authored-By: Claude <noreply@anthropic.com>
  ```
- Use HEREDOC for multi-line messages

### Safety
- Commit specific files, not `git add -A`
- Never commit .env files or secrets
- Never force push to main/master

## Go Development

**MANDATORY: Read and follow `~/.claude/docs/go-conventions.md` before writing ANY Go code.** This is not optional. Every Go file, function, test, and error message must conform to these conventions. The guide exists specifically to prevent Claude's tendency to write Go that looks like Python or JavaScript.

Key non-negotiable rules:
- No unnecessary interfaces, goroutines, builder patterns, or functional options
- `cmd/` for CLI wiring only, `internal/` for business logic, no `pkg/`
- cobra with `SilenceUsage: true`, flags in a struct
- `fmt.Errorf("context: %w", err)` at every error boundary
- Table-driven tests, no assertion libraries
- `make check` (vet + test) must pass before any commit
- Atomic file writes for all mutations

## Cloudflare / Wrangler

```bash
npx wrangler deploy           # Deploy worker
npx wrangler dev              # Local dev server
npx wrangler secret put NAME  # Add encrypted secret
npx wrangler tail             # Stream logs
```

- `CLOUDFLARE_API_TOKEN` in `~/.bashrc` — Wrangler picks it up automatically

## API-First Policy

When tasks involve external services (Cloudflare, Google Workspace, GitHub, Stripe, etc.):

1. **Use API or CLI first** — never suggest the web dashboard unless the API genuinely cannot do it
2. **Extend automation** — if a plan step requires manual dashboard work that could be scripted, write the script
3. **Capability assumptions** — treat documented API credentials as real and available; don't hedge

Check `.claude/instructions/api-access.md` in each project for the specific access inventory.

## Secrets

- **Never commit**: API tokens, passwords, keys, `.env` files with real values
- **Local dev**: `~/.bashrc` (non-sensitive) or `~/.local/secrets` (sensitive, sourced from 1Password)
- **CI/CD**: GitHub Actions secrets
- **Runtime**: Cloudflare Workers secrets

## Testing TUI Applications

**Default approach for all TUI and config testing.** Full reference: `~/.claude/docs/tui-testing.md`. Use tmux to launch, interact with, and verify TUI applications without requiring human visual inspection. Always test config changes this way before reporting results.

### Basic Pattern

```bash
# Launch app in detached tmux session
tmux new-session -d -s test -x 100 -y 30 'app-command'
sleep 5  # wait for app to initialize

# Capture current screen
tmux capture-pane -t test -p

# Inspect specific regions
tmux capture-pane -t test -p | head -15   # top of screen
tmux capture-pane -t test -p | tail -5    # bottom of screen

# Clean up
tmux kill-session -t test
```

### Interactive Testing

Send keystrokes and verify results — essential for testing keybindings, editor behavior, and multi-step workflows:

```bash
# Send normal mode keys
tmux send-keys -t test 'G' && sleep 1

# Send special keys
tmux send-keys -t test Enter && sleep 0.5
tmux send-keys -t test Escape && sleep 0.3

# Send Ctrl combinations
tmux send-keys -t test C-y && sleep 0.5

# Type text in insert mode
tmux send-keys -t test 'iHello world' && sleep 0.5

# Chain: enter command mode and run a command
tmux send-keys -t test ':set number' Enter && sleep 0.5
```

### Verifying Neovim State

Query neovim internals via `:lua` or `:echo` commands and capture the output:

```bash
# Check a vim option
tmux send-keys -t test ':set scrolloff?' Enter && sleep 1
tmux capture-pane -t test -p | tail -3

# Check syntax group at a position (line, col)
tmux send-keys -t test ':echo synIDattr(synID(3,1,1),"name")' Enter
sleep 1 && tmux capture-pane -t test -p | tail -3

# Check highlight group colors
tmux send-keys -t test ':highlight GroupName' Enter
sleep 1 && tmux capture-pane -t test -p | tail -3

# Check lua values
tmux send-keys -t test ':lua print(vim.api.nvim_win_get_height(0))' Enter
sleep 1 && tmux capture-pane -t test -p | tail -3
```

### Testing aerc

aerc needs longer startup time. Navigate with keybindings, verify message list and viewer rendering:

```bash
tmux new-session -d -s test -x 140 -y 40 'aerc'
sleep 8  # aerc needs time to connect and sync

# Open first message
tmux send-keys -t test Enter && sleep 3
tmux capture-pane -t test -p | head -20

# Navigate to a folder
tmux send-keys -t test 'c' && sleep 0.5
tmux send-keys -t test 'Sent' Enter && sleep 2
```

### Important Patterns

- **Always kill previous session** before starting a new test: `tmux kill-session -t test 2>/dev/null`
- **Check if app survived** after testing crash-prone changes: `pgrep -a nvim`
- **Empty capture = blank screen or crash** — check `tmux list-sessions` and process list
- **Use line numbers** for precise neovim position verification: `:set number`
- **Press Enter/Escape** to dismiss prompts before sending next command
- **Undo test edits** before closing: `tmux send-keys -t test Escape && sleep 0.3 && tmux send-keys -t test 'u'`

## Neovim

Setup documentation: `~/.claude/docs/neovim-setup.md` — covers both profiles, design decisions, known issues, and failed approaches.

- **Version**: 0.12.0-dev from `ppa:neovim-ppa/unstable` (required for typewriter scrolling)
- **nvim-journal**: `~/.config/nvim-journal/` — jrnl-md editor with zen-mode + typewriter scrolling
- **nvim-mail**: `~/.dotfiles/nvim-mail/.config/nvim-mail/` — aerc compose editor with custom `aercmail` syntax

## Claude Code Agent Usage

### Time Estimates in Plans

**DO NOT provide human-scale time estimates** (e.g., "10-15 minutes"). Claude Code executes file edits in seconds.

- Describe relative complexity: "quick", "straightforward", "multi-step"
- Focus on sequencing, dependencies, and testing steps
- Omit duration estimates unless specifically requested
