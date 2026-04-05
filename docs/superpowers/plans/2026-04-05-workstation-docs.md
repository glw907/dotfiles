# Workstation Docs Overhaul -- Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace stale README and migration docs with a clean documentation system centered on a configuration reference README, supported by focused detail docs. Remove VSCodium entirely.

**Architecture:** Central README hub with inline coverage for simple topics and `docs/` detail docs for cross-cutting systems (email stack, secrets). Stale migration docs and unused packages (vscodium, browser-bookmarks) are deleted. `~/.claude/CLAUDE.md` is updated to match.

**Tech Stack:** Markdown, GNU Stow, bash

---

### Task 1: Remove VSCodium from the system

**Files:**
- Delete: `vscodium/` (entire directory)
- Delete: `applications/.local/share/applications/vscodium-writing.desktop`
- Modify: `sync-dotfiles.sh`
- Modify: `themes/NORD.md`

- [ ] **Step 1: Unstow vscodium**

Run: `cd ~/.dotfiles && stow -D vscodium 2>&1`
Expected: Symlinks removed (or warning if not currently stowed, which is fine)

- [ ] **Step 2: Remove VSCodium config from the system**

Run: `rm -rf ~/.config/VSCodium/User/settings.json`

This only removes the symlink target. If VSCodium is still installed, its defaults apply. The user can uninstall the package separately if desired.

- [ ] **Step 3: Delete the vscodium stow package**

Run: `cd ~/.dotfiles && rm -rf vscodium/`

- [ ] **Step 4: Delete the vscodium-writing.desktop launcher**

Run: `rm ~/.dotfiles/applications/.local/share/applications/vscodium-writing.desktop`

Keep `eudaimonia.desktop` (kitty launcher, still active).

- [ ] **Step 5: Remove VSCodium from sync-dotfiles.sh**

In `sync-dotfiles.sh`, change the stow package check loop from:

```bash
for package in bash bin claude vscodium; do
```

to:

```bash
for package in bash bin claude git; do
```

And remove the entire VSCodium extensions sync section (lines 42-56):

```bash
# 3. Sync VSCodium extensions
echo -e "\n${BOLD}🔌 Checking VSCodium extensions...${NC}"
if command -v codium &>/dev/null; then
    temp_ext=$(mktemp)
    codium --list-extensions > "$temp_ext"
    
    if ! diff -q "$temp_ext" "$DOTFILES/vscodium/extensions.txt" &>/dev/null; then
        echo -e "  ${YELLOW}→${NC} Extension list changed, updating..."
        mv "$temp_ext" "$DOTFILES/vscodium/extensions.txt"
        needs_commit=true
    else
        echo -e "  ${GREEN}✓${NC} Extensions in sync ($(wc -l < "$temp_ext") installed)"
        rm "$temp_ext"
    fi
else
    echo -e "  ${YELLOW}⚠${NC} VSCodium not found"
fi
```

- [ ] **Step 6: Remove VSCodium references from themes/NORD.md**

Remove the "Configure VSCodium Nord Theme" section (lines 76-88) and the VSCodium entries under "Recommended Extensions" (lines 127-128). These reference `codium` commands and the `arcticicestudio.nord-visual-studio-code` extension.

- [ ] **Step 7: Update blog function to not open VSCodium**

In `bash/.bash_blog_functions`, the `blog()` function (line 69) runs `codium . &`. Remove that line -- the function should just start the Hugo server.

- [ ] **Step 8: Commit**

```bash
cd ~/.dotfiles
git add -A
git commit -m "$(cat <<'EOF'
Remove VSCodium package and all references

User has moved to Neovim. Removes stow package, .desktop launcher,
sync-dotfiles check, NORD.md references, and blog function codium call.

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

---

### Task 2: Delete stale files and packages

**Files:**
- Delete: `MIGRATION.md`
- Delete: `STOW-MIGRATION.md`
- Delete: `CLAUDE.md` (dotfiles root)
- Delete: `wallpapers/README.md`
- Delete: `browser-bookmarks/` (entire directory)
- Delete: `docs/superpowers/plans/2026-04-03-aerc-fastmail-filter.md`
- Delete: `docs/superpowers/specs/2026-04-03-aerc-fastmail-filter-design.md`

- [ ] **Step 1: Unstow browser-bookmarks if stowed**

Run: `cd ~/.dotfiles && stow -D browser-bookmarks 2>&1`

- [ ] **Step 2: Delete all stale files**

```bash
cd ~/.dotfiles
rm MIGRATION.md STOW-MIGRATION.md CLAUDE.md wallpapers/README.md
rm -rf browser-bookmarks/
rm docs/superpowers/plans/2026-04-03-aerc-fastmail-filter.md
rm docs/superpowers/specs/2026-04-03-aerc-fastmail-filter-design.md
```

Note: Keep `docs/superpowers/specs/2026-04-05-workstation-docs-design.md` (this project's spec) and `docs/superpowers/plans/2026-04-05-workstation-docs.md` (this plan) until the project is complete, then delete `docs/superpowers/` entirely in the final task.

- [ ] **Step 3: Commit**

```bash
cd ~/.dotfiles
git add -A
git commit -m "$(cat <<'EOF'
Delete stale migration docs, browser-bookmarks, and old specs

MIGRATION.md and STOW-MIGRATION.md are completed migrations.
CLAUDE.md setup guide is replaced by docs/new-machine.md.
browser-bookmarks is unused since the Ubuntu era.
aerc-rules specs belong to ~/Projects/aerc-rules/, not here.

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

---

### Task 3: Create `docs/secrets.md`

**Files:**
- Create: `docs/secrets.md`

- [ ] **Step 1: Write docs/secrets.md**

```markdown
# Secrets Management

How workstation secrets are stored, synced, and accessed.

## Architecture

```
1Password (source of truth)
    |
    v
secrets/values.age (encrypted, safe to commit)
    |
    v  scripts/secrets/sync.sh
    |
    +---> ~/.local/secrets (local env vars, sourced by .bashrc)
    +---> Cloudflare Workers (per-worker secrets via wrangler)
```

- **1Password** holds all secret values and the age encryption key
- **values.age** is the encrypted bundle committed to this repo
- **sync.sh** decrypts via 1Password CLI and pushes to targets
- **~/.local/secrets** is chmod 600, gitignored, sourced by `.bashrc`
- Decryption happens in `/dev/shm` (tmpfs) -- nothing touches disk

## Sync Script

```bash
scripts/secrets/sync.sh               # Decrypt + push local + all workers
scripts/secrets/sync.sh --local       # Local secrets only
scripts/secrets/sync.sh --worker NAME # Single worker only
scripts/secrets/sync.sh --dry-run     # Show what would happen
scripts/secrets/sync.sh --verify      # Diff targets vs registry
```

Prerequisite: 1Password desktop app running + CLI authenticated (`eval $(op signin)`).

## What Goes Where

| Type | Location |
|------|----------|
| Sensitive tokens (API keys, passwords) | `~/.local/secrets` via sync.sh |
| Non-sensitive config (paths, emails, model names) | `.bashrc` as plain exports |
| Worker secrets | Pushed by sync.sh via `wrangler secret put` |
| Sudo password | 1Password only -- fetched live by `claude-askpass` |

## Sudo Helper

`claude-askpass` lets Claude Code run `sudo -A` without interactive prompts:

1. `claude-sudo-setup` fetches the sudo password from 1Password and caches it to `~/.cache/sudo-password.age`
2. `claude-askpass` decrypts and supplies it when `sudo -A` is invoked
3. The `.bashrc` wrapper clears the cache after each `claude` session

Prerequisite: 1Password desktop app unlocked, CLI integration enabled in Settings > Developer.

## Secret Registry

See [secrets/registry.md](../secrets/registry.md) for the full inventory: which secrets exist, what they grant, where they're routed, and how to rotate them.
```

- [ ] **Step 2: Commit**

```bash
cd ~/.dotfiles
git add docs/secrets.md
git commit -m "$(cat <<'EOF'
Add secrets management documentation

Covers architecture (1Password -> age -> sync.sh -> targets),
sync script usage, secret placement rules, and sudo helper.

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

---

### Task 4: Create `docs/email.md`

**Files:**
- Create: `docs/email.md`

- [ ] **Step 1: Write docs/email.md**

```markdown
# Email Stack

How the mail system is wired together across multiple tools and repos.

## Components

| Component | What it does | Location |
|-----------|-------------|----------|
| **aerc** | Terminal email client | System package (`apt install aerc`) |
| **beautiful-aerc** | Message rendering, themes, link picker | `~/Projects/beautiful-aerc/` (symlinked as stow package) |
| **aerc-rules** | Fastmail filter management via JMAP | `~/Projects/aerc-rules/` |
| **nvim-mail** | Compose editor (neovim profile) | `~/.config/nvim-mail/` (from beautiful-aerc) |
| **vdirsyncer** | CardDAV contact sync | `contacts` stow package |
| **khard** | Contact lookup for aerc address book | `contacts` stow package |

## Account

- **Provider**: Fastmail (907.life domain, business plan)
- **Protocols**: IMAP/SMTP for mail, JMAP API for aerc-rules, CardDAV for contacts
- **Account config**: `~/.config/aerc/accounts.conf` (not committed -- contains credentials)

## How the Pieces Connect

```
aerc (client)
  |
  +-- beautiful-aerc binary (message filters: headers, html, plain text)
  |     Config: ~/.config/aerc/aerc.conf [filters] section
  |     Theme:  ~/.config/aerc/generated/palette.sh
  |
  +-- nvim-mail (compose editor)
  |     Config: ~/.config/nvim-mail/init.lua
  |     Syntax: aercmail (custom filetype)
  |
  +-- aerc-rules (filter management, triggered by keybindings)
  |     Auth:   $FASTMAIL_API_TOKEN (in ~/.local/secrets)
  |     Rules:  ~/.config/aerc/mailrules.json
  |
  +-- khard (address book completion)
        Contacts: ~/.contacts/Default/ (synced by vdirsyncer)
        Auth:     fastmail-dav-password script (reads from 1Password)
```

## Config Files

| File | Source | Committed? |
|------|--------|-----------|
| `aerc.conf` | `beautiful-aerc` stow package | Yes |
| `binds.conf` | `beautiful-aerc` stow package | Yes |
| `accounts.conf` | Manual (credentials) | No |
| `mailrules.json` | Created by `aerc-rules add` | No |
| `generated/palette.sh` | Theme generator | Yes |

## Environment Variables

| Variable | Purpose | Source |
|----------|---------|--------|
| `FASTMAIL_API_TOKEN` | JMAP API auth for aerc-rules | `~/.local/secrets` |

## Filter Keybindings

Create Fastmail filters from within aerc by piping the current message:

| Context | Keys | Action |
|---------|------|--------|
| Message list | `ff` | Filter by sender (from) |
| Message list | `fs` | Filter by subject |
| Message list | `ft` | Filter by recipient (to) |
| Message viewer | `Ff` | Filter by sender (from) |
| Message viewer | `Fs` | Filter by subject |
| Message viewer | `Ft` | Filter by recipient (to) |

The interactive flow: extracts the header, prompts for search value, shows folder picker, creates the rule, offers to sweep matching inbox messages.

## Contact Sync

vdirsyncer syncs Fastmail contacts to `~/.contacts/` via CardDAV. A systemd timer runs the sync periodically.

- Config: `~/.config/vdirsyncer/config`
- Auth: `fastmail-dav-password` script (fetches app password from 1Password)
- Lookup: `khard` reads `~/.contacts/Default/` for aerc address completion

## Related Docs

- aerc keybinding cheat sheet: [docs/aerc-quickref.md](aerc-quickref.md)
- beautiful-aerc project: `~/Projects/beautiful-aerc/CLAUDE.md`
- aerc-rules project: `~/Projects/aerc-rules/CLAUDE.md`
```

- [ ] **Step 2: Commit**

```bash
cd ~/.dotfiles
git add docs/email.md
git commit -m "$(cat <<'EOF'
Add email stack documentation

Covers how aerc, beautiful-aerc, aerc-rules, nvim-mail, and
contacts (vdirsyncer/khard) are wired together.

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

---

### Task 5: Create `docs/aerc-quickref.md`

**Files:**
- Create: `docs/aerc-quickref.md`

This is a personal cheat sheet. Dense tables, minimal prose. Derived from the actual `binds.conf`.

- [ ] **Step 1: Write docs/aerc-quickref.md**

```markdown
# aerc Quick Reference

Personal keybinding and command cheat sheet. Based on `~/.config/aerc/binds.conf`.

---

## Message List

### Navigation

| Key | Action |
|-----|--------|
| `j` / `k` | Next / previous message |
| `g` / `G` | First / last message |
| `Ctrl-d` / `Ctrl-u` | Half-page down / up |
| `Ctrl-f` / `Ctrl-b` | Full page down / up |
| `J` / `K` | Next / previous folder |
| `H` / `L` | Collapse / expand folder |

### Actions

| Key | Action |
|-----|--------|
| `Enter` | Open message |
| `d` | Delete (with confirmation) |
| `D` | Delete (no confirmation) |
| `a` | Archive (flat) |
| `A` | Archive all marked |
| `c` | Change folder (`:cf`) |

### Compose

| Key | Action |
|-----|--------|
| `C` or `m` | New message |
| `rr` | Reply all |
| `rq` | Reply all, quote |
| `Rr` | Reply sender only |
| `Rq` | Reply sender, quote |

### Marking

| Key | Action |
|-----|--------|
| `v` | Toggle mark |
| `Space` | Mark and move to next |
| `V` | Toggle visual mark mode |

### Threads

| Key | Action |
|-----|--------|
| `T` | Toggle thread view |
| `Tab` | Toggle fold |
| `zc` / `zo` | Fold / unfold |
| `zM` / `zR` | Fold all / unfold all |

### Search

| Key | Action |
|-----|--------|
| `/` | Search |
| `\` | Filter |
| `n` / `N` | Next / previous result |
| `Esc` | Clear search |

### Splits

| Key | Action |
|-----|--------|
| `s` | Horizontal split |
| `S` | Vertical split |

### Filters (aerc-rules)

| Key | Action |
|-----|--------|
| `ff` | Create filter by sender |
| `fs` | Create filter by subject |
| `ft` | Create filter by recipient |

### Patches

| Key | Action |
|-----|--------|
| `pl` | List patches |
| `pa` | Apply patch |
| `pd` | Drop patch |
| `pb` | Rebase patches |
| `pt` | Patch terminal |
| `ps` | Switch patch |

---

## Message Viewer

### Navigation

| Key | Action |
|-----|--------|
| `J` / `K` | Next / previous message |
| `Ctrl-j` / `Ctrl-k` | Next / previous MIME part |
| `H` | Toggle headers |

### Actions

| Key | Action |
|-----|--------|
| `q` | Close viewer |
| `o` / `O` | Open attachment |
| `S` | Save attachment |
| `d` | Delete message |
| `D` | Close viewer and delete |
| `a` | Archive |
| `A` | Close viewer and archive |
| `f` | Forward |
| `b` | Save to beautiful-aerc corpus |

### Reply

| Key | Action |
|-----|--------|
| `rr` | Reply all |
| `rq` | Reply all, quote |
| `Rr` | Reply sender only |
| `Rq` | Reply sender, quote |

### Links

| Key | Action |
|-----|--------|
| `Tab` | Link picker (beautiful-aerc) |
| `Ctrl-l` | Open link (manual URL) |

### Filters (aerc-rules)

| Key | Action |
|-----|--------|
| `Ff` | Create filter by sender |
| `Fs` | Create filter by subject |
| `Ft` | Create filter by recipient |

---

## Compose

### Field Navigation

| Key | Action |
|-----|--------|
| `Ctrl-j` / `Tab` | Next field |
| `Ctrl-k` / `Shift-Tab` | Previous field |
| `Alt-n` / `Alt-p` | Switch account |
| `Ctrl-o` | Complete address |

### Review Screen

| Key | Action |
|-----|--------|
| `y` | Convert to multipart HTML and send |
| `n` | Abort |
| `v` | Preview |
| `p` | Postpone |
| `e` | Back to editor |
| `a` | Attach file |
| `d` | Detach file |
| `q` | Choose: discard or postpone |

---

## Global

| Key | Action |
|-----|--------|
| `Ctrl-p` / `Ctrl-n` | Previous / next tab |
| `Ctrl-t` | Open terminal |
| `?` | Help |
| `Ctrl-c` / `Ctrl-q` | Quit (with confirmation) |
| `$` or `!` | Open terminal with command |
| `\|` | Pipe message to command |
```

- [ ] **Step 2: Commit**

```bash
cd ~/.dotfiles
git add docs/aerc-quickref.md
git commit -m "$(cat <<'EOF'
Add aerc quick reference cheat sheet

Complete keybinding reference for message list, viewer, compose,
filters, patches, and global shortcuts.

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

---

### Task 6: Create `docs/new-machine.md`

**Files:**
- Create: `docs/new-machine.md`

Salvaged and rewritten from the deleted dotfiles CLAUDE.md. Trimmed: no VSCodium, no Ubuntu/GNOME references.

- [ ] **Step 1: Write docs/new-machine.md**

```markdown
# New Machine Setup

Step-by-step bootstrap for a fresh Linux Mint 22 (Cinnamon) machine.

## 1. Prerequisites

```bash
sudo apt update && sudo apt install -y stow git curl micro gh aerc
gh auth login
```

## 2. Clone and Stow

```bash
git clone https://github.com/glw907/workstation.git ~/.dotfiles
cd ~/.dotfiles
stow bash bin claude git
source ~/.bashrc
```

**Core packages** (stow first): `bash bin claude git`

**Optional packages** (stow as needed): `kitty applications contacts themes wallpapers`

## 3. Node / NVM

Required for `npx`/wrangler and Claude CLI:

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/HEAD/install.sh | bash
source ~/.bashrc
nvm install --lts
```

## 4. Claude Code

```bash
npm install -g @anthropic-ai/claude-code
claude   # Opens browser for auth on first run
```

## 5. Secrets

Prerequisite: 1Password desktop app running + CLI integration enabled.

```bash
eval $(op signin)
~/.dotfiles/scripts/secrets/sync.sh --local
```

See [docs/secrets.md](secrets.md) for the full architecture.

## 6. Email Stack

```bash
stow beautiful-aerc contacts
```

Then create `~/.config/aerc/accounts.conf` manually (not committed -- contains credentials).

Contact sync: `vdirsyncer discover fastmail_contacts && vdirsyncer sync`

See [docs/email.md](email.md) for how the components connect.

## 7. Optional: kitty

Installed via official installer (not apt):

```bash
curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh
```

Launcher symlinks (`kitty`, `kitten`) are created at `~/.local/bin/`. Config is tracked in the `kitty` stow package. Update later via `workstation-update`.

## 8. Optional: Android SDK

Follow [android/README.md](../android/README.md). Summary:

```bash
mkdir -p ~/Android/cmdline-tools
# Download and extract command-line tools to ~/Android/cmdline-tools/latest/
sdkmanager --licenses && sdkmanager "platform-tools"
```

`ANDROID_HOME` and `PATH` entries are already in `.bashrc`.

## 9. Optional: Nord Theme

```bash
cd ~/.dotfiles/themes && ./setup-nord.sh
stow wallpapers
gsettings set org.cinnamon.desktop.background picture-uri \
  "file://$HOME/Pictures/Wallpapers/nord-gradient.png"
```

## 10. Flatpak Apps

Flatpak is pre-installed on Linux Mint:

```bash
flatpak install flathub com.discordapp.Discord
flatpak install flathub com.fastmail.Fastmail
flatpak install flathub org.gnome.Apostrophe
flatpak install flathub com.noson.Noson
```

## 11. Verify

```bash
~/.dotfiles/sync-dotfiles.sh    # Should report all packages in sync
which cld                        # ~/.local/bin/cld
ls -la ~/.claude/CLAUDE.md      # Symlink into ~/.dotfiles
claude                           # Starts Claude
```
```

- [ ] **Step 2: Commit**

```bash
cd ~/.dotfiles
git add docs/new-machine.md
git commit -m "$(cat <<'EOF'
Add new machine setup guide

Step-by-step bootstrap for Linux Mint 22. Replaces the old
dotfiles-root CLAUDE.md with a focused, current guide.

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

---

### Task 7: Rewrite README.md

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Write the new README.md**

```markdown
# Workstation Configuration

Personal dotfiles and configuration reference -- Linux Mint 22 (Cinnamon), managed with [GNU Stow](https://www.gnu.org/software/stow/).

---

## Stow Packages

| Package | Destination | Contents |
|---------|-------------|----------|
| `bash` | `~/` | `.bashrc`, `.profile`, `.bash_blog_functions` |
| `bin` | `~/.local/bin/` | `cld`, `claude-askpass`, `claude-sudo-setup`, `fastmail-password`, `journal`, `workstation-update`, others |
| `claude` | `~/.claude/` | `CLAUDE.md`, `settings.json`, docs, skills, gather scripts |
| `git` | `~/` | `.gitconfig` |
| `beautiful-aerc` | `~/.config/aerc/`, `~/.config/nvim-mail/`, `~/.local/bin/` | aerc config, theme, filters, compose editor (symlink to `~/Projects/beautiful-aerc`) |
| `contacts` | `~/.config/vdirsyncer/`, `~/.config/khard/`, systemd units | CardDAV contact sync with Fastmail |
| `kitty` | `~/.config/kitty/` | Terminal config (Monaspace Neon, Nord colors, powerline tabs) |
| `applications` | `~/.local/share/applications/` | Eudaimonia desktop launcher |
| `android` | *(docs only)* | SDK setup guide -- SDK itself lives in `~/Android/` |
| `themes` | `~/.themes/` | Nord GTK theme installer |
| `wallpapers` | `~/Pictures/Wallpapers/` | `nord-gradient.png`, `nord-minimal.png` |

### Day-to-day Stow usage

```bash
cd ~/.dotfiles
stow bash              # Install (create symlinks)
stow -D bash           # Remove (delete symlinks)
stow -R bash           # Restow (after file changes)
stow bash bin claude git  # Multiple at once
```

---

## Shell

`.bashrc` sets up PATH, sources secrets, and loads blog functions:

- **PATH**: `~/.local/bin`, Go, Android SDK, NVM
- **Secrets**: `~/.local/secrets` sourced if present (see [docs/secrets.md](docs/secrets.md))
- **Blog functions**: `.bash_blog_functions` -- `blog`, `newpost`, `blogpush`, `blogdeploy`, `blogbuild`, `bloglist`

---

## Email

Terminal email via aerc + Fastmail, with custom rendering and filter management.

| Component | Purpose |
|-----------|---------|
| **aerc** | Mail client (IMAP/SMTP) |
| **beautiful-aerc** | Message rendering, Nord theme, link picker |
| **aerc-rules** | Fastmail filter creation via JMAP |
| **nvim-mail** | Compose editor (neovim profile) |
| **vdirsyncer + khard** | Contact sync and address completion |

**Filter keybindings**: `ff`/`fs`/`ft` (message list) or `Ff`/`Fs`/`Ft` (viewer) to create filters by from/subject/to.

Full wiring details: [docs/email.md](docs/email.md) | Keybinding cheat sheet: [docs/aerc-quickref.md](docs/aerc-quickref.md)

---

## Editors

- **Neovim** (primary) -- two profiles:
  - `nvim-journal` (`~/.config/nvim-journal/`) -- jrnl-md editor with zen-mode + typewriter scrolling
  - `nvim-mail` (`~/.config/nvim-mail/`) -- aerc compose editor with `aercmail` syntax
- **micro** -- quick terminal edits

---

## Terminal

**kitty** installed via [official installer](https://sw.kovidgoyal.net/kitty/installer.sh) to `~/.local/kitty.app/`. Not in apt.

- Font: Monaspace Neon 11pt, JetBrainsMono Nerd Font for symbols
- Colors: Nord palette
- Config: `kitty` stow package

**Eudaimonia** -- daily practice session launcher (`.desktop` file in `applications` package, runs a kitty session from `~/Projects/eudaimonia/`)

---

## Claude Code

The `claude` stow package provides:

| File | Purpose |
|------|---------|
| `CLAUDE.md` | Global instructions for all projects |
| `settings.json` | Claude Code configuration |
| `docs/go-conventions.md` | Go coding standards (mandatory for all Go work) |
| `instructions/aerc-mail.md` | aerc environment context |
| `instructions/fastmail-api.md` | Fastmail JMAP API context |
| `gather-dotfiles.sh` | Collects dotfiles state for context |
| `gather-scripts.sh` | Collects script inventory for context |
| `skills/` | Custom skills: `go-review`, `ship`, `log-issue`, `log-project`, `pull-data`, `start-server` |

---

## Dev Tools

- **Go** 1.26.1 -- `/usr/local/go`, conventions in `~/.claude/docs/go-conventions.md`
- **Node/NVM** -- `~/.nvm/`, LTS version, used for wrangler and Claude CLI
- **Android SDK** -- `~/Android/`, details in [android/README.md](android/README.md)
- **Cloudflare/Wrangler** -- `npx wrangler deploy/dev/secret put/tail`, token in `~/.local/secrets`

---

## Secrets

1Password is the source of truth. Secrets are age-encrypted in this repo and synced to local env vars and Cloudflare Workers.

```bash
scripts/secrets/sync.sh --local    # Push to ~/.local/secrets
scripts/secrets/sync.sh --verify   # Check all targets match registry
```

Full details: [docs/secrets.md](docs/secrets.md) | Secret inventory: [secrets/registry.md](secrets/registry.md)

---

## System Maintenance

| Command | Purpose |
|---------|---------|
| `sync-dotfiles.sh` | Check stow status, git config drift, uncommitted changes |
| `workstation-update` | Update kitty + Android SDK (runs Monday 9am via cron) |
| `workstation-update --apt` | Also runs apt upgrade/autoremove |

---

## Desktop

- **Theme**: Nord -- GTK via `themes/setup-nord.sh`, details in [themes/NORD.md](themes/NORD.md)
- **Wallpapers**: `nord-gradient.png`, `nord-minimal.png` in `~/Pictures/Wallpapers/` (stow package)

---

## New Machine Setup

See [docs/new-machine.md](docs/new-machine.md) for the complete bootstrap guide.
```

- [ ] **Step 2: Commit**

```bash
cd ~/.dotfiles
git add README.md
git commit -m "$(cat <<'EOF'
Rewrite README as central configuration reference

Covers all stow packages, shell, email, editors, terminal, Claude Code,
dev tools, secrets, maintenance, and desktop. Points to detail docs
for complex topics.

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

---

### Task 8: Update `~/.claude/CLAUDE.md`

**Files:**
- Modify: `~/.claude/CLAUDE.md` (symlinked from `~/.dotfiles/claude/.claude/CLAUDE.md`)

- [ ] **Step 1: Update CLAUDE.md**

Changes to make:
1. Remove `vscodium` from the Editor line in Machine Environment (currently says "micro (quick edits), vscodium (scripts/code)")
2. Update the Dotfiles Management stow packages list to remove `vscodium` and `browser-bookmarks`
3. Verify the aerc section is accurate (it was added earlier today and should be correct)
4. No other changes needed -- the file was already trimmed to 89 lines earlier this session

The Machine Environment editor line should become:

```
- **Shell**: bash | **Editor**: neovim (primary), micro (quick edits)
```

The Dotfiles Management stow packages line should become:

```
- **Stow packages**: `bash`, `bin`, `claude`, `git`, `beautiful-aerc`, `kitty`, `applications`, `contacts`
```

- [ ] **Step 2: Commit**

```bash
cd ~/.dotfiles
git add claude/.claude/CLAUDE.md
git commit -m "$(cat <<'EOF'
Update CLAUDE.md: remove VSCodium, update editor and stow list

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

---

### Task 9: Final cleanup

**Files:**
- Delete: `docs/superpowers/` (entire directory, including this plan and spec)

- [ ] **Step 1: Delete the superpowers docs directory**

```bash
cd ~/.dotfiles
rm -rf docs/superpowers/
```

If `docs/` is now empty except for the new docs, that's fine -- the new docs are there.

- [ ] **Step 2: Verify docs/ contents**

Run: `ls ~/.dotfiles/docs/`
Expected: `aerc-quickref.md  email.md  new-machine.md  secrets.md`

- [ ] **Step 3: Run sync-dotfiles.sh to verify health**

Run: `~/.dotfiles/sync-dotfiles.sh`
Expected: All packages in sync, no uncommitted changes (after committing)

- [ ] **Step 4: Commit**

```bash
cd ~/.dotfiles
git add -A
git commit -m "$(cat <<'EOF'
Remove superpowers planning artifacts

Spec and plan served their purpose. All docs are now in place.

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

- [ ] **Step 5: Verify final state**

Run: `cd ~/.dotfiles && find . -name '*.md' -not -path './.git/*' | sort`

Expected:

```
./android/README.md
./docs/aerc-quickref.md
./docs/email.md
./docs/new-machine.md
./docs/secrets.md
./README.md
./secrets/registry.md
./themes/NORD.md
```
