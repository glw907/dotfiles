# Mail Environment

## Overview

Terminal mail setup: kitty (dedicated window) -> aerc (email client) -> nvim-mail (compose editor).
All Nord-themed. Single account: geoff@907.life via Fastmail JMAP.

## File Locations

| Component | Config | Scripts |
|---|---|---|
| aerc | `~/.config/aerc/` | `fastmail-password`, `fastmail-dav-password` |
| nvim-mail | `~/.config/nvim-mail/init.lua` | `~/.local/bin/nvim-mail` |
| kitty-mail | `~/.config/kitty/kitty-mail.conf` | `~/.local/bin/mail` |
| Desktop | `~/.local/share/applications/aerc-mail.desktop` | |
| Contacts | `~/.contacts/` (vdirsyncer) | khard for address completion |

## How It Connects

1. `mail` script (or desktop launcher) runs kitty with kitty-mail.conf
2. kitty launches aerc directly; kitty closes when aerc exits
3. aerc uses nvim-mail as its compose editor (`edit-headers=true`)
4. Compose bodies are written in markdown
5. aerc's multipart converter runs pandoc to generate HTML on send

## Credentials

- JMAP token: `~/.config/aerc/fastmail-jmap-token.age` (age-encrypted)
- DAV token: `~/.config/aerc/fastmail-dav-token.age` (age-encrypted)
- Age key: `$AGE_KEY_FILE` (default `~/.config/age/asc-key.txt`)

## Dotfiles

All managed via GNU Stow in `~/.dotfiles/`. Packages: aerc, kitty, nvim-mail, bin, applications, claude.

## Full Documentation

See `~/.config/aerc/README.md` for complete reference.
