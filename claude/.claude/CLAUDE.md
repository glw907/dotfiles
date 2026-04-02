# Global Claude Code Patterns — Workstation: thinkpad-x1

## MANDATORY: Work Autonomously Until Done

**Do not ask for review, confirmation, or approval until the task is fully complete.** Never say "ready for your review," "want me to commit?", "should I continue?", or similar. Keep working through all known issues until every quality gate passes and zero problems remain. The only reason to stop is a genuine blocker requiring information only the user can provide.

## Machine Environment

- **OS**: Linux Mint 22.3 "Zena" (Ubuntu 24.04 base), Cinnamon desktop
- **Shell**: bash | **Editor**: micro (quick edits), vscodium (scripts/code)
- **Key paths**: `~/Projects/` (all repos), `~/.dotfiles/` (config), `~/.local/bin/` (scripts)
- **Dev tools**: Python 3.12, Java 17 (OpenJDK), Node/nvm, Git 2.43
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
- **Stow packages**: `bash`, `bin`, `claude`, `vscodium`, `git`, `aerc`, `kitty`, `nvim-mail`, `applications`, `contacts`
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

## Claude Code Agent Usage

### Time Estimates in Plans

**DO NOT provide human-scale time estimates** (e.g., "10-15 minutes"). Claude Code executes file edits in seconds.

- Describe relative complexity: "quick", "straightforward", "multi-step"
- Focus on sequencing, dependencies, and testing steps
- Omit duration estimates unless specifically requested
