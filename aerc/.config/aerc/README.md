# Mail Environment

Terminal email setup built on aerc, neovim, and kitty with Nord theming.

## Quick Start

Launch from terminal or app menu:

    mail

This opens a dedicated kitty window running aerc.

## Architecture

    kitty (kitty-mail.conf)
     └── aerc (aerc.conf, accounts.conf)
          └── nvim-mail (compose editor)
               └── pandoc (markdown to HTML conversion)

## Components

### aerc - Email Client

- Config: `~/.config/aerc/`
- Account: geoff@907.life via Fastmail JMAP
- Credentials: age-encrypted tokens (`fastmail-jmap-token.age`, `fastmail-dav-token.age`)
- Styleset: Nord (built-in)
- Address completion: khard (`khard email --parsable`)

### nvim-mail - Compose Editor

- Config: `~/.config/nvim-mail/init.lua`
- Launcher: `~/.local/bin/nvim-mail` (sets `NVIM_APPNAME=nvim-mail`)
- Plugins: Nord colorscheme, treesitter markdown
- Features: spell check, 72-char textwidth, format=flowed, signature snippet

### kitty-mail - Terminal

- Config: `~/.config/kitty/kitty-mail.conf`
- Font: iA Writer Mono S at 11.5pt
- Window: 140c x 48c, asymmetric padding (15 30 15 30)
- Colors: Nord 16-color palette

### Desktop Launcher

- File: `~/.local/share/applications/aerc-mail.desktop`
- Script: `~/.local/bin/mail`
- Icon: internet-mail (Papirus-Dark)

## Composing Email

aerc uses `edit-headers=true`, so To/From/Subject appear in the editor buffer.

Write the body in markdown. On send (review screen, press `y`), aerc runs
pandoc to generate an HTML alternative part automatically.

### nvim-mail Keybindings

| Key | Action |
|---|---|
| `Space s` | Toggle spell check |
| `Space q` | Save and quit (return to aerc review) |
| `Space sig` | Insert email signature |

### aerc Compose Review

| Key | Action |
|---|---|
| `y` | Convert to HTML multipart and send |
| `e` | Re-edit the message |
| `a` | Attach a file |
| `v` | Preview the message |
| `n` | Abort (discard) |
| `p` | Postpone (save as draft) |

## Folder Organization

Inbox, Drafts, Sent, Archive, Notifications, Buccaneer 18, Remind, Spam, Trash

## aerc Keybindings (Message List)

| Key | Action |
|---|---|
| `j/k` | Next/previous message |
| `J/K` | Next/previous folder |
| `Enter` | View message |
| `C` or `m` | Compose new message |
| `rr` | Reply all |
| `rq` | Reply all with quote |
| `Rr` | Reply to sender |
| `Rq` | Reply to sender with quote |
| `d` | Delete (with confirmation) |
| `a` | Archive |
| `T` | Toggle threads |
| `/` | Search |
| `q` | Quit |

## aerc Keybindings (Viewing a Message)

| Key | Action |
|---|---|
| `q` | Close message |
| `o/O` | Open attachment |
| `S` | Save attachment |
| `f` | Forward |
| `rr` | Reply all |
| `rq` | Reply all with quote |
| `Rr` | Reply to sender |
| `Rq` | Reply to sender with quote |
| `H` | Toggle full headers |
| `D` | Delete |
| `A` | Archive |
| `Ctrl+j/k` | Next/previous MIME part |
| `J/K` | Next/previous message |

## Contacts

Address completion is provided by khard, synced from Fastmail via vdirsyncer/CardDAV.

- Contacts dir: `~/.contacts/`
- vdirsyncer config: `~/.config/vdirsyncer/config`
- khard config: `~/.config/khard/khard.conf`
- Sync: `vdirsyncer sync` (also runs via systemd timer)

## Dotfiles

All config is tracked in `~/.dotfiles/` via GNU Stow:

| Stow Package | Files |
|---|---|
| `aerc` | `~/.config/aerc/*` |
| `kitty` | `~/.config/kitty/kitty-mail.conf` |
| `nvim-mail` | `~/.config/nvim-mail/init.lua` |
| `bin` | `~/.local/bin/mail`, `~/.local/bin/nvim-mail` |
| `applications` | `~/.local/share/applications/aerc-mail.desktop` |
| `claude` | `~/.claude/instructions/aerc-mail.md` |

To re-link after changes:

    cd ~/.dotfiles && stow -R aerc kitty nvim-mail bin applications claude
