# nvim-mail Upgrade & aerc Quick Reference Redesign

**Date:** 2026-04-05
**Files touched:**
- `~/.config/nvim-mail/init.lua`
- `~/.dotfiles/docs/aerc-quickref.html`

---

## Goal

Level up the nvim-mail compose setup with better spellcheck ergonomics, undo
granularity, paragraph reflow, and khard contact insertion. Update the aerc
quick reference to reflect the improved setup, move the nvim-mail section
first, and add general-purpose vim editing references useful in a mail
authoring context.

---

## 1. init.lua Changes

### 1a. Undo breakpoints (insert mode)

Add `inoremap` mappings for `. , ! ? :` that inject `<C-g>u` before inserting
the character. This creates undo breakpoints at sentence boundaries so that `u`
in normal mode undoes by sentence rather than the entire insert session.

```lua
for _, ch in ipairs({ ".", ",", "!", "?", ":" }) do
  vim.keymap.set("i", ch, ch .. "<C-g>u", { desc = "Undo breakpoint" })
end
```

No visible behavior change while typing.

### 1b. Spellcheck bindings

| Binding | Action |
|---------|--------|
| `<leader>z` | `z=` - show spelling suggestions for word under cursor |
| `<leader>]` | `]s` - jump to next misspelled word |
| `<leader>[` | `[s` - jump to prev misspelled word |

`zg` (add to dictionary) and `zw` (mark bad) are built-in and don't need
remapping - document them in the quick reference. `<C-x><C-s>` for insert-mode
spell suggestion is also built-in; document only.

### 1c. Paragraph reflow

```lua
vim.keymap.set("n", "<leader>r", "gqip", { desc = "Reflow paragraph" })
```

Reflowing the paragraph under cursor to `textwidth=72`. Essential after editing
into quoted reply blocks.

### 1d. khard contact picker

`<leader>k` (normal and insert mode) - opens a `vim.ui.select` picker populated
by `khard email --parsable`. Output format is `email\tname\taddressbook`.
Selected entry is inserted as `Name <email>` at the cursor position. In insert
mode, exit insert briefly to insert then return to insert.

Implementation sketch:
```lua
local function khard_insert()
  local raw = vim.fn.systemlist("khard email --parsable 2>/dev/null")
  -- filter header line (khard --parsable starts with "Searching for...")
  local entries = {}
  for _, line in ipairs(raw) do
    local email, name = line:match("^([^\t]+)\t([^\t]+)")
    if email and name then
      entries[#entries + 1] = { label = name .. " <" .. email .. ">", text = name .. " <" .. email .. ">" }
    end
  end
  vim.ui.select(entries, {
    prompt = "Insert contact:",
    format_item = function(e) return e.label end,
  }, function(choice)
    if not choice then return end
    local pos = vim.api.nvim_win_get_cursor(0)
    local line = vim.api.nvim_buf_get_lines(0, pos[1]-1, pos[1], false)[1]
    local new_line = line:sub(1, pos[2]) .. choice.text .. line:sub(pos[2]+1)
    vim.api.nvim_buf_set_lines(0, pos[1]-1, pos[1], false, { new_line })
    vim.api.nvim_win_set_cursor(0, { pos[1], pos[2] + #choice.text })
  end)
end

vim.keymap.set("n", "<leader>k", khard_insert, { desc = "Insert khard contact" })
vim.keymap.set("i", "<leader>k", function()
  vim.cmd("stopinsert")
  vim.schedule(function()
    khard_insert(true)  -- pass flag to re-enter insert mode after insertion
  end)
end, { desc = "Insert khard contact" })
```

Notes:
- `khard email --parsable` output filters lines by `email\tname` pattern to
  skip any non-data lines.
- `khard_insert` accepts an optional boolean `reenter_insert`; when true, calls
  `vim.cmd("startinsert")` after the insertion callback completes, so the
  cursor returns to insert mode after picking a contact.

---

## 2. aerc-quickref.html Changes

### 2a. Section order

Move the nvim-mail section to the top (before Message Viewer, Compose, Message
List). Update subtitle from "keybinding cheat sheet" to "keybinding & compose
reference".

### 2b. nvim-mail section: 8 cards across 3 rows (3 + 3 + 2)

**Row 1**

| Card | Contents |
|------|----------|
| Exit & Send | `<leader>q` save + spellcheck prompt; `<leader>x` abort |
| Spellcheck Prompt | `s` jump to error; `y` send anyway; `n` stay |
| Spell Navigation | `]s`/`[s` or `<leader>]`/`<leader>[` next/prev; `<leader>z`/`z=` suggestions; `zg` add to dict; `zw` mark bad; `<C-x><C-s>` insert-mode suggestion |

**Row 2**

| Card | Contents |
|------|----------|
| Text & Formatting | `<leader>r`/`gqip` reflow paragraph; `gqq` reflow line; `(`/`)` sentence back/fwd; `{`/`}` paragraph back/fwd |
| khard & Tools | `<leader>k` insert contact; `Ctrl-o` address complete in aerc header (pre-editor); `<leader>s` toggle spell; `<leader>sig` insert signature; `g Ctrl-g` word/char count |
| Insert Mode | `<C-x><C-s>` spell suggestion; `<C-n>`/`<C-p>` word complete; `<C-w>` delete word back; `<C-u>` delete to line start |

**Row 3**

| Card | Contents |
|------|----------|
| Editing | `ciw`/`cis`/`cip` change word/sentence/paragraph; `J` join lines; `gUw`/`guw` upper/lowercase word; `~` toggle char case |
| Copy / Paste / Delete | `yy`/`yiw`/`yis`/`yip` yank line/word/sentence/paragraph; `p`/`P` paste after/before; `dd`/`diw`/`dis`/`dip` delete line/word/sentence/paragraph; `D` delete to EOL; `x` delete char |

### 2c. No changes to other sections

Message Viewer, Compose (review screen), and Message List cards are unchanged.

---

## Success Criteria

- Undo in nvim-mail is sentence-granular (undo after typing a sentence only
  removes that sentence, not the whole insert session)
- `<leader>k` opens a picker, selecting a contact inserts `Name <email>` at
  cursor in both normal and insert mode
- `<leader>r` reflowing a paragraph respects `textwidth=72`
- Spellcheck leader bindings navigate to errors and show suggestions
- Quick reference HTML renders correctly with nvim-mail section first and all
  8 cards visible
