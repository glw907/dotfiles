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
