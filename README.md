# Workstation Configuration

Personal workstation dotfiles — shell setup, custom scripts, Claude CLI tools, and VSCodium settings.

**Platform:** Linux Mint 22 (Cinnamon), Ubuntu 24.04 base
**Managed with:** [GNU Stow](https://www.gnu.org/software/stow/)

---

## Packages

| Package | Destination | Contents |
|---------|-------------|----------|
| `bash` | `~/` | `.bashrc`, `.profile`, `.bash_blog_functions` |
| `bin` | `~/.local/bin/` | `cld`, `claude-askpass`, `claude-sudo-clear`, `claude-sudo-setup`, `update-android-sdk`, `update-kitty`, `workstation-update`, `write` |
| `claude` | `~/.claude/` | CLI mode system prompt, context scripts, skills |
| `vscodium` | `~/.config/VSCodium/User/` | `settings.json`, extension list, markdown snippets |
| `git` | `~/` | `.gitconfig` — git identity and settings |
| `android` | *(docs only)* | SDK setup guide — SDK itself lives in `~/Android/` |
| `themes` | `~/.themes/` | Nord GTK theme installer |
| `wallpapers` | `~/Pictures/Wallpapers/` | Nord-themed desktop wallpapers |
| `applications` | `~/.local/share/applications/` | VSCodium writing profile launcher, Eudaimonia launcher |
| `browser-bookmarks` | *(backup only)* | Chrome/Firefox bookmark exports |

---

## Quick Setup (New Machine)

```bash
sudo apt update && sudo apt install -y stow git curl micro gh
git clone https://github.com/glw907/workstation.git ~/.dotfiles
cd ~/.dotfiles
stow bash bin claude vscodium git
source ~/.bashrc
```

→ See `CLAUDE.md` for the complete new machine setup guide (prerequisites, NVM, Android SDK, etc.)

---

## Using Stow (Day-to-Day)

```bash
cd ~/.dotfiles

# Install a package (create symlinks)
stow bash
stow bin
stow vscodium

# Install multiple packages at once
stow bash bin claude vscodium git

# Remove a package (remove symlinks)
stow -D bash

# Restow (useful after updates)
stow -R bash
```

---

## Key Tools

### CLI Mode (`cld`)

Launches Claude in system administration mode — for package management, dotfiles, system services, and workstation configuration. Tracked in the **bin** and **claude** Stow packages.

Variant modes (`cld-arch`, `cld-research`, `cld-write`, `cld-critic`) live in `~/Projects/modal-claude/` and are not tracked here.

### Blog Shortcuts

Defined in `.bash_blog_functions`, targeting the Hugo blog at `~/Projects/907-life`:

- `blog` — open blog in VSCodium and start Hugo dev server
- `newpost` — create a new post with date prefix
- `blogpush` — commit and push blog changes
- `blogdeploy` — deploy to Cloudflare

### sync-dotfiles.sh

Health check script for tracking configuration drift. Checks:
- Stow package symlink status
- Git config changes (auto-copies to dotfiles if changed)
- VSCodium extension changes
- Uncommitted changes in this repository

Run it before committing, or when you've made system configuration changes.

### update-android-sdk

Checks for and installs updates to all installed Android SDK components via `sdkmanager`.

### workstation-update

Updates tools installed outside apt that don't update automatically:
- **kitty** — official installer to `~/.local/kitty.app/`, not in apt repos
- **Android SDK** — via `sdkmanager --update`

```bash
workstation-update          # kitty + Android SDK
workstation-update --apt    # also runs apt upgrade/autoremove
```

Runs automatically every Monday at 9am via cron. Logs to `~/.local/share/workstation-update.log`.

---

## Maintenance

```bash
~/.dotfiles/sync-dotfiles.sh   # dotfiles health check
workstation-update --apt       # full system update (manual)
```

**Notes:**
- VSCodium `settings.json` is Stow-managed (symlinked) — changes are automatically tracked
- VSCodium extensions are manually synced via `vscodium/sync-extensions.sh`
- Git config is **not** stowed — manually synced via `sync-dotfiles.sh`
- kitty is installed via official installer (`~/.local/kitty.app/`), not apt — update via `workstation-update`
