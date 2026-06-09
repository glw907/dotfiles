# Workstation Configuration

Personal dotfiles and configuration reference -- Linux Mint 22 (Cinnamon), managed with [GNU Stow](https://www.gnu.org/software/stow/).

---

## Documentation

| Doc | Contents |
|-----|----------|
| [docs/email.md](docs/email.md) | How the mail stack is wired together (aerc, beautiful-aerc, aerc-rules, contacts) |
| [aerc-quickref.html](https://glw907.github.io/workstation/aerc-quickref.html) | aerc keybinding cheat sheet |
| [docs/secrets.md](docs/secrets.md) | Secrets architecture, sync script, sudo helper |
| [docs/new-machine.md](docs/new-machine.md) | Step-by-step bootstrap for a fresh machine |
| [secrets/registry.md](secrets/registry.md) | Secret inventory, routing table, rotation guide |
| [android/README.md](android/README.md) | Android SDK setup |
| [themes/NORD.md](themes/NORD.md) | Nord theme installation (GTK, icons, wallpaper) |

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
| `android` | *(docs only)* | SDK setup guide -- SDK itself lives in `~/Android/` |
| `themes` | `~/.themes/` | Nord GTK theme installer |
| `wallpapers` | `~/Pictures/Wallpapers/` | `nord-gradient.png`, `nord-minimal.png` |

### Day-to-day Stow usage

    cd ~/.dotfiles
    stow bash              # Install (create symlinks)
    stow -D bash           # Remove (delete symlinks)
    stow -R bash           # Restow (after file changes)
    stow bash bin claude git  # Multiple at once

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

Full wiring details: [docs/email.md](docs/email.md) | Keybinding cheat sheet: [aerc-quickref.html](https://glw907.github.io/workstation/aerc-quickref.html)

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

    scripts/secrets/sync.sh --local    # Push to ~/.local/secrets
    scripts/secrets/sync.sh --verify   # Check all targets match registry

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
