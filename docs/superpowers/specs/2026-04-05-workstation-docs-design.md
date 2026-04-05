# Workstation Docs Overhaul -- Design Spec

**Date:** 2026-04-05
**Repo:** `~/.dotfiles` (github.com/glw907/workstation)
**Audience:** Geoff + Claude Code sessions

---

## Goal

Replace the stale README and accumulated migration docs with a clean documentation system: a central README as a configuration reference hub, supported by focused docs for complex topics. Remove VSCodium entirely (no longer used). Clean up all stale artifacts.

---

## Deletions

### Files to remove

| File | Reason |
|------|--------|
| `MIGRATION.md` | Completed Ubuntu-to-Mint migration |
| `STOW-MIGRATION.md` | Completed copy-to-Stow migration |
| `CLAUDE.md` (dotfiles root) | Stale setup guide, replaced by README + `docs/new-machine.md` |
| `docs/superpowers/plans/` | aerc-rules brainstorming artifacts, project lives at `~/Projects/aerc-rules/` |
| `docs/superpowers/specs/` | Same (remove after this spec is committed and the plan is written) |
| `wallpapers/README.md` | Trivial, one line in the README covers it |

### Packages to remove

| Package | Action |
|---------|--------|
| `vscodium/` | Run `stow -D vscodium`, then delete the entire directory. User has moved to Neovim. |
| `applications/.local/share/applications/vscodium-writing.desktop` | Delete the .desktop file. Keep `eudaimonia.desktop` (kitty launcher). |
| `browser-bookmarks/` | Run `stow -D browser-bookmarks` if stowed, then delete. Stale Firefox/Brave/Chromium exports from Ubuntu era. |

### References to update

- Remove `vscodium` and `browser-bookmarks` from stow package lists everywhere (README, any scripts)
- Remove VSCodium from `~/.claude/CLAUDE.md` if referenced
- Remove VSCodium from `sync-dotfiles.sh` if it checks for it

---

## New docs

### `docs/email.md` -- Mail Stack

How the email system is wired together. Cross-cutting doc spanning multiple tools and repos.

**Sections:**
- Overview: aerc as the client, Fastmail as the provider
- Components: aerc, beautiful-aerc (rendering/themes), aerc-rules (filter management), nvim-mail (compose editor), contacts (vdirsyncer + khard)
- Account configuration: IMAP/SMTP for aerc, JMAP API for aerc-rules, CardDAV for contacts
- How the pieces connect: which config files, which env vars, which binaries
- Keybindings quick summary (detailed version in aerc-quickref.md)
- Pointer to each component's own docs (beautiful-aerc CLAUDE.md, aerc-rules CLAUDE.md)

### `docs/aerc-quickref.md` -- aerc Quick Reference

Personal cheat sheet. Rich GitHub markdown. Optimized for scanning.

**Sections:**
- Navigation: message list, folders, threads
- Reading: viewer controls, link picker, headers toggle
- Composing: reply, forward, compose, review screen
- Managing: archive, delete, mark, move
- Filter creation: `ff`/`fs`/`ft` bindings, the interactive flow
- Patch management: `pl`/`pa`/`pd`/`pb`/`pt`/`ps` bindings
- Tabs and splits

Use tables and grouped keybinding sections. No prose where a table suffices.

### `docs/secrets.md` -- Secrets Management

How secrets are stored, synced, and accessed.

**Sections:**
- Architecture: 1Password as source of truth, age-encrypted cache, `~/.local/secrets` as runtime
- Sync script: `scripts/secrets/sync.sh --local`
- Registry: what secrets exist and what they're for (pointer to `secrets/registry.md`)
- Sudo helper: claude-askpass + claude-sudo-setup flow
- Rules: what goes in .bashrc (non-sensitive) vs ~/.local/secrets (sensitive)

### `docs/new-machine.md` -- New Machine Setup

Salvaged and rewritten from the deleted dotfiles CLAUDE.md. Step-by-step bootstrap guide.

**Sections:**
- Prerequisites (apt packages, gh auth)
- Clone and stow core packages
- Install Claude CLI + NVM
- Secrets sync
- Optional: kitty, Android SDK, Nord theme, wallpapers, contacts
- Flatpak apps
- Verify setup

---

## README.md -- Central Reference

Concise configuration reference. Each section is a summary. Complex topics point to their detail doc.

### Structure

```
# Workstation Configuration

## Stow Packages
  Table: package | destination | contents (updated, no vscodium/browser-bookmarks)

## Shell
  bash, PATH setup, blog functions, .profile

## Email
  Summary of the stack, key bindings at a glance
  -> docs/email.md, docs/aerc-quickref.md

## Editors
  Neovim profiles (nvim-journal, nvim-mail), micro for quick edits

## Terminal
  kitty config, Eudaimonia session launcher

## Claude Code
  Settings, skills, docs, gather scripts -- what the claude stow package provides

## Dev Tools
  Go, Node/nvm, Android SDK (-> android/README.md), Cloudflare/wrangler

## Secrets
  Summary of the system
  -> docs/secrets.md

## System Maintenance
  sync-dotfiles.sh, workstation-update, cron schedule

## Desktop
  Nord theme (-> themes/NORD.md), wallpapers, .desktop launchers

## New Machine Setup
  -> docs/new-machine.md
```

---

## `~/.claude/CLAUDE.md` Refactoring

After the workstation docs are in place, update the global CLAUDE.md:

- Remove any VSCodium references
- Remove `browser-bookmarks` from stow package list
- Add `@~/.dotfiles/docs/email.md` import for email context (or keep the current concise summary and just ensure it's accurate)
- Verify the stow packages list matches reality
- Keep it under 100 lines -- the workstation docs carry the detail now

---

## Principles

- **README is the hub**: scannable, concise, pointers to detail docs
- **Short topics inline**: kitty, wallpapers, git, bash -- no separate doc needed
- **Cross-cutting topics get docs**: email stack, secrets -- span multiple packages
- **Package docs stay with packages**: android/README.md, themes/NORD.md
- **No duplication**: each fact lives in one place
- **Audience**: Geoff scanning for a quick answer, Claude orienting in the repo
- **All docs written by Opus**
