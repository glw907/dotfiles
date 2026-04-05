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
