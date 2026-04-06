# nvim-mail Upgrade & aerc Quick Reference Redesign — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add undo breakpoints, spellcheck bindings, paragraph reflow, and khard contact insertion to nvim-mail; expand and reorder the aerc quick reference HTML.

**Architecture:** Four additive changes to `init.lua` (each self-contained at the bottom of the keybindings section), then a targeted HTML edit replacing the nvim-mail section and reordering sections. No new files, no plugins, no dependencies beyond khard (already installed).

**Tech Stack:** Lua (neovim config), HTML/CSS (static file, no build step), khard CLI

---

## File Map

| File | Change |
|------|--------|
| `~/.config/nvim-mail/init.lua` | Add undo breakpoints, spell bindings, reflow binding, khard picker function + mappings |
| `~/.dotfiles/docs/aerc-quickref.html` | Move nvim-mail section first, update subtitle, replace 3-card grid with 8-card grid |

---

### Task 1: Undo breakpoints

**Files:**
- Modify: `~/.config/nvim-mail/init.lua` (append after existing keybindings)

Adds sentence-granular undo. Without this, `u` in normal mode undoes the entire
insert session. With it, each punctuation character creates an undo break.

- [ ] **Step 1: Verify the problem exists**

Open nvim-mail on any file, enter insert mode, type two sentences (e.g.
`Hello there. This is a test.`), press `<Esc>`, then `u`. Observe that the
entire typed content is removed. This is the behaviour we are fixing.

- [ ] **Step 2: Add undo breakpoints to init.lua**

Append this block after the `vim.keymap.set("n", "<leader>x", ...)` line
(around line 315 in the current file):

```lua
-- Insert-mode undo breakpoints: pressing punctuation ends the current undo chunk.
-- Without these, `u` undoes the entire insert session (a paragraph or more).
for _, ch in ipairs({ ".", ",", "!", "?", ":" }) do
  vim.keymap.set("i", ch, ch .. "<C-g>u", { desc = "Undo breakpoint at " .. ch })
end
```

- [ ] **Step 3: Verify the fix**

Restart nvim-mail (`:qa` then reopen). Type two sentences, press `<Esc>`, then
`u`. Only the second sentence (after the last punctuation) should be removed.
Press `u` again to remove the first sentence. Each undo step now removes one
sentence.

- [ ] **Step 4: Commit**

```bash
git -C ~/.config/nvim-mail add init.lua 2>/dev/null || true
# nvim-mail config is not in a git repo - skip commit, move on
```

Note: `~/.config/nvim-mail/` is not tracked by git (it's a generated profile).
Only `~/.dotfiles/` is tracked. Changes to `init.lua` take effect immediately
on next nvim-mail launch - no commit needed here.

---

### Task 2: Spellcheck navigation bindings

**Files:**
- Modify: `~/.config/nvim-mail/init.lua` (append after Task 1 block)

Adds leader-key aliases for the built-in `]s`, `[s`, and `z=` spell commands.
The built-ins already work; these are muscle-memory shortcuts for when you're
new to the setup.

- [ ] **Step 1: Verify built-ins work**

Open nvim-mail on a file with a deliberate typo (e.g. `teh`). Press `]s` in
normal mode - cursor should jump to the misspelled word. Press `z=` - a
suggestion list should appear. Confirm these work before adding aliases.

- [ ] **Step 2: Add spell bindings to init.lua**

Append after the undo breakpoints block:

```lua
-- Spellcheck navigation (leader aliases for built-ins)
vim.keymap.set("n", "<leader>]", "]s", { desc = "Next misspelled word" })
vim.keymap.set("n", "<leader>[", "[s", { desc = "Prev misspelled word" })
vim.keymap.set("n", "<leader>z", "z=",  { desc = "Spelling suggestions" })
```

- [ ] **Step 3: Verify**

Restart nvim-mail. With a misspelled word in the buffer, press `<Space>]` -
cursor should jump to next error. Press `<Space>z` - suggestion list appears.
Press `<Space>[` - jumps to previous error.

---

### Task 3: Paragraph reflow binding

**Files:**
- Modify: `~/.config/nvim-mail/init.lua` (append after Task 2 block)

`gqip` reflowing the paragraph under the cursor to `textwidth=72`. Essential
when editing into quoted reply text where line lengths become uneven.

- [ ] **Step 1: Verify the built-in works**

Open nvim-mail with a paragraph of text where some lines exceed 72 chars.
In normal mode, type `gqip`. The paragraph should reflow to 72-char lines.
Confirm this works before adding the binding.

- [ ] **Step 2: Add reflow binding to init.lua**

```lua
-- Paragraph reflow to textwidth=72
vim.keymap.set("n", "<leader>r", "gqip", { desc = "Reflow paragraph" })
```

- [ ] **Step 3: Verify**

Restart nvim-mail. Place cursor inside an over-long paragraph, press `<Space>r`.
Paragraph should hard-wrap at 72 characters.

---

### Task 4: khard contact picker

**Files:**
- Modify: `~/.config/nvim-mail/init.lua` (append after Task 3 block)

`<leader>k` opens a `vim.ui.select` picker populated from `khard email
--parsable`. The selected contact is inserted as `Name <email>` (or just
`email` if the contact has no display name) at the cursor position. Works in
both normal and insert mode; insert mode returns to insert after selection.

- [ ] **Step 1: Check khard output format**

```bash
khard email --parsable 2>/dev/null | head -5
```

Expected output (first line is a header, subsequent lines are tab-separated):
```
searching for 'ALL' ...
email@example.com	Contact Name	addressbook, pref
bare@example.com	 	addressbook, pref
```

The header line has no tabs so the Lua pattern match will skip it naturally.
Some contacts have whitespace-only names - the implementation handles this.

- [ ] **Step 2: Add khard picker function and mappings to init.lua**

```lua
-- khard contact picker: <leader>k inserts a contact address at the cursor.
-- Works in normal and insert mode. In insert mode, returns to insert after selection.
local function khard_insert(reenter_insert)
  local raw = vim.fn.systemlist("khard email --parsable 2>/dev/null")
  local entries = {}
  for _, line in ipairs(raw) do
    local email, name = line:match("^([^\t]+)\t([^\t]*)")
    if email then
      name = name and name:match("^%s*(.-)%s*$") or ""
      local label = name ~= "" and (name .. " <" .. email .. ">") or email
      entries[#entries + 1] = { label = label, text = label }
    end
  end
  if #entries == 0 then
    vim.notify("No khard contacts found", vim.log.levels.WARN)
    if reenter_insert then vim.cmd("startinsert") end
    return
  end
  vim.ui.select(entries, {
    prompt = "Insert contact: ",
    format_item = function(e) return e.label end,
  }, function(choice)
    if not choice then
      if reenter_insert then vim.cmd("startinsert") end
      return
    end
    local pos = vim.api.nvim_win_get_cursor(0)
    local buf_line = vim.api.nvim_buf_get_lines(0, pos[1] - 1, pos[1], false)[1]
    local new_line = buf_line:sub(1, pos[2]) .. choice.text .. buf_line:sub(pos[2] + 1)
    vim.api.nvim_buf_set_lines(0, pos[1] - 1, pos[1], false, { new_line })
    vim.api.nvim_win_set_cursor(0, { pos[1], pos[2] + #choice.text })
    if reenter_insert then vim.cmd("startinsert") end
  end)
end

vim.keymap.set("n", "<leader>k", function() khard_insert(false) end,
  { desc = "Insert khard contact" })
vim.keymap.set("i", "<leader>k", function()
  vim.cmd("stopinsert")
  vim.schedule(function() khard_insert(true) end)
end, { desc = "Insert khard contact (insert mode)" })
```

- [ ] **Step 3: Verify in normal mode**

Restart nvim-mail on a compose buffer. In normal mode on a `To:` header line,
press `<Space>k`. A picker should appear listing all khard contacts. Select one
- the `Name <email>` string should be inserted at the cursor position.

- [ ] **Step 4: Verify in insert mode**

Place cursor in insert mode on an address header line. Press `<Space>k`. Picker
should appear. Select a contact. Text should be inserted and cursor should
return to insert mode after the inserted text.

- [ ] **Step 5: Verify empty-name contacts**

Find a contact with no display name in the picker (shows as just `email`).
Select it. Only the bare email address should be inserted (no angle brackets,
no name).

---

### Task 5: Update aerc quick reference

**Files:**
- Modify: `~/.dotfiles/docs/aerc-quickref.html`

Two changes: (a) update the subtitle, (b) move the nvim-mail `<section>` block
to be first after `<header>`, and (c) replace the existing 3-card nvim-mail
grid with an 8-card grid.

- [ ] **Step 1: Update the subtitle**

Find this line (around line 178):
```html
      <span class="subtitle">keybinding cheat sheet</span>
```
Replace with:
```html
      <span class="subtitle">keybinding &amp; compose reference</span>
```

- [ ] **Step 2: Move nvim-mail section to top**

The current section order in the HTML body is:
1. Message Viewer (`<section class="s-view">`) — lines ~188–229
2. Compose (`<section class="s-compose">`) — lines ~232–269
3. nvim-mail (`<section class="s-nvim">`) — lines ~272–299
4. Message List (`<section class="s-list">`) — lines ~302–372

Cut the entire `<section class="s-nvim">...</section>` block and paste it
immediately after `<header>...</header>`, before the `<!-- MESSAGE VIEWER -->`
comment.

- [ ] **Step 3: Replace the nvim-mail grid with 8 cards**

Find the existing grid div inside `<section class="s-nvim">`:
```html
    <div class="grid">

      <div class="card"><h3>Exit &amp; Send</h3>
        ...
      </div>

      <div class="card"><h3>Spellcheck Prompt</h3>
        ...
      </div>

      <div class="card"><h3>Tools</h3>
        ...
      </div>

    </div>
```

Replace the entire `<div class="grid">...</div>` with:

```html
    <div class="grid">

      <div class="card"><h3>Exit &amp; Send</h3>
        <dl>
          <div class="row"><dt><kbd>Space</kbd><kbd>q</kbd></dt><dd>Save &amp; exit → review screen (spellcheck first)</dd></div>
          <div class="row"><dt><kbd>Space</kbd><kbd>x</kbd></dt><dd>Abort compose (no prompt)</dd></div>
        </dl>
      </div>

      <div class="card"><h3>Spellcheck Prompt</h3>
        <dl>
          <div class="row"><dt><kbd>s</kbd></dt><dd>Jump to first misspelling</dd></div>
          <div class="row"><dt><kbd>y</kbd></dt><dd>Send anyway</dd></div>
          <div class="row"><dt><kbd>n</kbd></dt><dd>Stay in editor</dd></div>
        </dl>
      </div>

      <div class="card"><h3>Spell Navigation</h3>
        <dl>
          <div class="row"><dt><kbd>]s</kbd> <span class="sep">/</span> <kbd>Space</kbd><kbd>]</kbd></dt><dd>Next misspelled word</dd></div>
          <div class="row"><dt><kbd>[s</kbd> <span class="sep">/</span> <kbd>Space</kbd><kbd>[</kbd></dt><dd>Prev misspelled word</dd></div>
          <div class="row"><dt><kbd>z=</kbd> <span class="sep">/</span> <kbd>Space</kbd><kbd>z</kbd></dt><dd>Spelling suggestions</dd></div>
          <div class="row"><dt><kbd>zg</kbd></dt><dd>Add word to dictionary</dd></div>
          <div class="row"><dt><kbd>zw</kbd></dt><dd>Mark word as misspelled</dd></div>
          <div class="row"><dt><kbd>Ctrl-x</kbd><kbd>Ctrl-s</kbd></dt><dd>Spell suggestion (insert mode)</dd></div>
        </dl>
      </div>

      <div class="card"><h3>Text &amp; Formatting</h3>
        <dl>
          <div class="row"><dt><kbd>Space</kbd><kbd>r</kbd> <span class="sep">/</span> <kbd>gqip</kbd></dt><dd>Reflow paragraph to 72 cols</dd></div>
          <div class="row"><dt><kbd>gqq</kbd></dt><dd>Reflow current line</dd></div>
          <div class="row"><dt><kbd>(</kbd> <span class="sep">/</span> <kbd>)</kbd></dt><dd>Sentence backward / forward</dd></div>
          <div class="row"><dt><kbd>{</kbd> <span class="sep">/</span> <kbd>}</kbd></dt><dd>Paragraph backward / forward</dd></div>
        </dl>
      </div>

      <div class="card"><h3>khard &amp; Tools</h3>
        <dl>
          <div class="row"><dt><kbd>Space</kbd><kbd>k</kbd></dt><dd>Insert contact (khard picker)</dd></div>
          <div class="row"><dt><kbd>Ctrl-o</kbd></dt><dd>Address complete in aerc header (pre-editor)</dd></div>
          <div class="row"><dt><kbd>Space</kbd><kbd>s</kbd></dt><dd>Toggle spell check</dd></div>
          <div class="row"><dt><kbd>Space</kbd><kbd>sig</kbd></dt><dd>Insert signature</dd></div>
          <div class="row"><dt><kbd>g</kbd><kbd>Ctrl-g</kbd></dt><dd>Word / char count</dd></div>
        </dl>
      </div>

      <div class="card"><h3>Insert Mode</h3>
        <dl>
          <div class="row"><dt><kbd>Ctrl-x</kbd><kbd>Ctrl-s</kbd></dt><dd>Spell suggestion</dd></div>
          <div class="row"><dt><kbd>Ctrl-n</kbd> <span class="sep">/</span> <kbd>Ctrl-p</kbd></dt><dd>Word complete next / prev</dd></div>
          <div class="row"><dt><kbd>Ctrl-w</kbd></dt><dd>Delete word backward</dd></div>
          <div class="row"><dt><kbd>Ctrl-u</kbd></dt><dd>Delete to line start</dd></div>
        </dl>
      </div>

      <div class="card"><h3>Editing</h3>
        <dl>
          <div class="row"><dt><kbd>ciw</kbd> <span class="sep">/</span> <kbd>cis</kbd> <span class="sep">/</span> <kbd>cip</kbd></dt><dd>Change word / sentence / paragraph</dd></div>
          <div class="row"><dt><kbd>J</kbd></dt><dd>Join lines</dd></div>
          <div class="row"><dt><kbd>gUw</kbd> <span class="sep">/</span> <kbd>guw</kbd></dt><dd>Uppercase / lowercase word</dd></div>
          <div class="row"><dt><kbd>~</kbd></dt><dd>Toggle character case</dd></div>
        </dl>
      </div>

      <div class="card"><h3>Copy / Paste / Delete</h3>
        <dl>
          <div class="row"><dt><kbd>yy</kbd> <span class="sep">/</span> <kbd>yiw</kbd> <span class="sep">/</span> <kbd>yis</kbd> <span class="sep">/</span> <kbd>yip</kbd></dt><dd>Yank line / word / sentence / paragraph</dd></div>
          <div class="row"><dt><kbd>p</kbd> <span class="sep">/</span> <kbd>P</kbd></dt><dd>Paste after / before</dd></div>
          <div class="row"><dt><kbd>dd</kbd> <span class="sep">/</span> <kbd>diw</kbd> <span class="sep">/</span> <kbd>dis</kbd> <span class="sep">/</span> <kbd>dip</kbd></dt><dd>Delete line / word / sentence / paragraph</dd></div>
          <div class="row"><dt><kbd>D</kbd></dt><dd>Delete to end of line</dd></div>
          <div class="row"><dt><kbd>x</kbd></dt><dd>Delete character</dd></div>
        </dl>
      </div>

    </div>
```

- [ ] **Step 4: Verify in browser**

Open `~/.dotfiles/docs/aerc-quickref.html` in a browser. Check:
- nvim-mail section appears first (before Message Viewer)
- Subtitle reads "keybinding & compose reference"
- 8 cards render across 3 rows (3 + 3 + 2)
- No layout breakage on the other sections

- [ ] **Step 5: Commit**

```bash
cd ~/.dotfiles
git add docs/aerc-quickref.html
git commit -m "$(cat <<'EOF'
Expand nvim-mail section in aerc quick reference

Move nvim-mail to top, update subtitle, expand from 3 to 8 cards
covering spell navigation, khard, text formatting, and general vim
editing operations useful in a mail composing context.

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

After committing the HTML, also commit the init.lua changes via the dotfiles
sync if init.lua is stow-tracked; otherwise just verify nvim-mail launches
cleanly with `nvim-mail /dev/null`.

---

## Self-Review Checklist

- [x] All 4 spec requirements covered: undo breakpoints (Task 1), spell
  bindings (Task 2), reflow (Task 3), khard picker (Task 4)
- [x] Quick reference covers all 8 cards from spec (Task 5)
- [x] khard output format verified before writing code (khard outputs
  `email\tname\taddressbook`, header line filtered by tab-pattern match)
- [x] Empty-name contacts handled (name trimmed, falls back to bare email)
- [x] Insert mode khard returns to insert mode after selection
- [x] No TBDs or placeholders
- [x] Function name `khard_insert` consistent across all references
