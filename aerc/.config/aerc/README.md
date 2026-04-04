# Mail Environment

Terminal email setup built on aerc, neovim, and kitty with Nord theming.

## Quick Start

Launch from terminal or app menu:

    mail

This opens a dedicated kitty window running aerc.

## Architecture

    kitty (kitty-mail.conf)
     └── aerc (aerc.conf, accounts.conf)
          ├── format-headers (AWK - colorized header display)
          ├── aerc-wrap-plain (reflow + colorize plain text)
          └── nvim-mail (compose editor)
               └── pandoc (markdown to HTML on send)

## Components

### aerc - Email Client

- Config: `~/.config/aerc/`
- Account: Fastmail via JMAP with local caching
- Credentials: age-encrypted tokens (`fastmail-jmap-token.age`)
- Styleset: `nord-custom` (custom Nord palette for viewer and UI)
- Address completion: khard via CardDAV sync

### Viewer Pipeline

Plain text emails pass through `aerc-wrap-plain`:

1. Reflow hard-wrapped paragraphs to terminal width (`wrap -r`)
2. Colorize quotes, URLs, diffs, and signatures (`colorize`)

Headers pass through `format-headers` (AWK):

1. Reorder to From/To/Cc/Bcc/Date/Subject (all others dropped)
2. Colorize with Nord ANSI colors (blue keys, grey brackets)
3. Wrap long address lists at recipient boundaries
4. Draw a separator line matching terminal width

The built-in header-layout is collapsed via a nonexistent header trick
(`header-layout=X-Collapse`), so only the filter output is displayed.

HTML emails are converted to markdown via pandoc.

### nvim-mail - Compose Editor

- Config: `~/.config/nvim-mail/init.lua`
- Launcher: `~/.local/bin/nvim-mail` (sets `NVIM_APPNAME=nvim-mail`)
- Features: spell check, 72-char textwidth, format=flowed, signature snippet

Compose in markdown. On send, aerc runs pandoc to generate an HTML
alternative part automatically (`[multipart-converters]`).

### kitty-mail - Terminal

- Config: `~/.config/kitty/kitty-mail.conf`
- Font: iA Writer Mono S at 11.5pt
- Window: 140c x 48c, asymmetric padding
- Colors: Nord 16-color palette

### Desktop Launcher

- Desktop file: `~/.local/share/applications/aerc-mail.desktop`
- Script: `~/.local/bin/mail`

## Composing Email

aerc uses `edit-headers=true`, so To/From/Subject appear in the editor
buffer. Write the body in markdown. On send (review screen, press `y`),
aerc generates an HTML alternative part via pandoc.

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

## Keybindings (Message List)

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

## Keybindings (Message Viewer)

| Key | Action |
|---|---|
| `q` | Close message |
| `o/O` | Open attachment |
| `S` | Save attachment |
| `f` | Forward |
| `rr/rq` | Reply all / reply all with quote |
| `Rr/Rq` | Reply to sender / reply with quote |
| `H` | Toggle full headers |
| `D` | Delete |
| `A` | Archive |
| `Ctrl+j/k` | Next/previous MIME part |
| `J/K` | Next/previous message |

## Contacts

Address completion via khard, synced from Fastmail CardDAV:

- Contacts dir: `~/.contacts/`
- vdirsyncer config: `~/.config/vdirsyncer/config`
- khard config: `~/.config/khard/khard.conf`
- Sync: `vdirsyncer sync` (also runs via systemd timer)

## Filter Rules

Server-side Fastmail filter rules are tracked in `mailrules.json` and
managed via `fastmail-filter` (uses JMAP API).

## Credential Management

Fastmail tokens are age-encrypted and decrypted on demand:

- `fastmail-jmap-token.age` - JMAP session auth
- `fastmail-dav-token.age` - CardDAV sync auth
- Decryption scripts: `fastmail-password`, `fastmail-dav-password`

## Dotfiles

All config is tracked in `~/.dotfiles/` via GNU Stow:

| Stow Package | Files |
|---|---|
| `aerc` | `~/.config/aerc/*` |
| `kitty` | `~/.config/kitty/kitty-mail.conf` |
| `nvim-mail` | `~/.config/nvim-mail/init.lua` |
| `bin` | `~/.local/bin/mail`, `~/.local/bin/nvim-mail` |
| `applications` | `~/.local/share/applications/aerc-mail.desktop` |

To re-link after changes:

    cd ~/.dotfiles && stow -R aerc kitty nvim-mail bin applications
