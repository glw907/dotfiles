# aerc Quick Reference

Personal keybinding and command cheat sheet. Based on `~/.config/aerc/binds.conf`.

---

## Message List

<table>
<tr><td>

**Navigation**

| Key | Action |
|-----|--------|
| `j` / `k` | Next / prev message |
| `g` / `G` | First / last message |
| `Ctrl-d` / `Ctrl-u` | Half-page down / up |
| `Ctrl-f` / `Ctrl-b` | Full page down / up |
| `J` / `K` | Next / prev folder |
| `H` / `L` | Collapse / expand folder |

**Search**

| Key | Action |
|-----|--------|
| `/` | Search |
| `\` | Filter |
| `n` / `N` | Next / prev result |
| `Esc` | Clear |

</td><td>

**Actions**

| Key | Action |
|-----|--------|
| `Enter` | Open message |
| `d` | Delete (confirm) |
| `D` | Delete (immediate) |
| `a` | Archive (flat) |
| `A` | Archive all marked |
| `c` | Change folder |

**Compose**

| Key | Action |
|-----|--------|
| `C` / `m` | New message |
| `rr` | Reply all |
| `rq` | Reply all, quote |
| `Rr` | Reply sender |
| `Rq` | Reply sender, quote |

</td><td>

**Marking**

| Key | Action |
|-----|--------|
| `v` | Toggle mark |
| `Space` | Mark + next |
| `V` | Visual mark mode |

**Threads**

| Key | Action |
|-----|--------|
| `T` | Toggle threads |
| `Tab` | Toggle fold |
| `zc` / `zo` | Fold / unfold |
| `zM` / `zR` | Fold all / unfold all |

**Splits**

| Key | Action |
|-----|--------|
| `s` / `S` | Horizontal / vertical |

</td></tr>
</table>

<table>
<tr><td>

**Filters (aerc-rules)**

| Key | Action |
|-----|--------|
| `ff` | Filter by sender |
| `fs` | Filter by subject |
| `ft` | Filter by recipient |

</td><td>

**Patches**

| Key | Action |
|-----|--------|
| `pl` | List |
| `pa` | Apply |
| `pd` | Drop |
| `pb` | Rebase |
| `pt` | Terminal |
| `ps` | Switch |

</td><td>&nbsp;</td></tr>
</table>

---

## Message Viewer

<table>
<tr><td>

**Navigation**

| Key | Action |
|-----|--------|
| `J` / `K` | Next / prev message |
| `Ctrl-j` / `Ctrl-k` | Next / prev MIME part |
| `H` | Toggle headers |

**Links**

| Key | Action |
|-----|--------|
| `Tab` | Link picker |
| `Ctrl-l` | Open link (manual URL) |

</td><td>

**Actions**

| Key | Action |
|-----|--------|
| `q` | Close viewer |
| `o` / `O` | Open attachment |
| `S` | Save attachment |
| `d` | Delete message |
| `D` | Close + delete |
| `a` | Archive |
| `A` | Close + archive |
| `f` | Forward |
| `b` | Save to corpus |

</td><td>

**Reply**

| Key | Action |
|-----|--------|
| `rr` | Reply all |
| `rq` | Reply all, quote |
| `Rr` | Reply sender |
| `Rq` | Reply sender, quote |

**Filters (aerc-rules)**

| Key | Action |
|-----|--------|
| `Ff` | Filter by sender |
| `Fs` | Filter by subject |
| `Ft` | Filter by recipient |

</td></tr>
</table>

---

## Compose

<table>
<tr><td>

**Field Navigation**

| Key | Action |
|-----|--------|
| `Ctrl-j` / `Tab` | Next field |
| `Ctrl-k` / `Shift-Tab` | Prev field |
| `Alt-n` / `Alt-p` | Switch account |
| `Ctrl-o` | Complete address |

</td><td>

**Review Screen**

| Key | Action |
|-----|--------|
| `y` | HTML multipart + send |
| `n` | Abort |
| `v` | Preview |
| `p` | Postpone |
| `e` | Back to editor |
| `a` / `d` | Attach / detach file |
| `q` | Discard or postpone |

</td><td>

**Global**

| Key | Action |
|-----|--------|
| `Ctrl-p` / `Ctrl-n` | Prev / next tab |
| `Ctrl-t` | Open terminal |
| `?` | Help |
| `Ctrl-c` / `Ctrl-q` | Quit (confirm) |
| `$` / `!` | Terminal with cmd |
| `\|` | Pipe to command |

</td></tr>
</table>
