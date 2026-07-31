# Neovim Setup

This document tracks the neovim configuration on this workstation,
including design decisions, what worked, what didn't, and known issues.

## Overview

Neovim is used for journal editing (jrnl-md). The journal use case
has a dedicated NVIM_APPNAME profile to isolate config, data, and
plugins from any general-purpose neovim setup.

- **Neovim version**: 0.12.0-dev (upgraded from 0.9.5 via
  `ppa:neovim-ppa/unstable` — required for typewriter scrolling)
- **Config location**: `~/.config/nvim-journal/`
- **Launcher script**: `~/.local/bin/nvim-journal`
- **Called by**: jrnl-md (configured in `~/.config/jrnl-md/config.toml`
  as `editor = "nvim-journal"`)

## nvim-journal Profile

### Launcher Script (`~/.local/bin/nvim-journal`)

```bash
#!/usr/bin/env bash
# Neovim wrapper for jrnl-md journal editing.
NVIM_APPNAME=nvim-journal exec nvim -c "startinsert" "$@"
```

Uses `NVIM_APPNAME` so this profile has its own config, data, and plugin
directories completely separate from any default neovim setup. Starts in
insert mode since the primary use case is writing.

### Plugins

Managed via lazy.nvim. Only three plugins:

- **nord.nvim** — colorscheme
- **zen-mode.nvim** — distraction-free floating window (72 columns,
  full backdrop, auto-starts on VimEnter, `qa!` on close)

### Editor Settings

Configured for prose writing, not code:

- **Soft wrap**: `wrap=true`, `linebreak=true`, `textwidth=0`
- **breakat**: Set to `" \t"` (space and tab only). The default includes
  `!@*-+;:,./?` which breaks words at punctuation — e.g., "morning!"
  would split between `n` and `!`.
- **scrolloff**: Set to 0 (typewriter mode handles centering instead)
- **UI stripped down**: no line numbers, no signcolumn, no cursorline,
  no statusline, no mode indicator
- **Markdown lists**: `comments` set to support `- [ ]`, `- [x]`, `-`,
  `*`, `>` with `formatoptions+=ro` for auto-continuation

### @tag Syntax Highlighting

File: `~/.config/nvim-journal/after/syntax/markdown.vim`

```vim
syntax match JournalTag /@\w\+/
highlight JournalTag guifg=#88C0D0 gui=bold ctermfg=110 cterm=bold
```

Uses `after/syntax/` to extend the built-in markdown syntax rather than
replacing it. This approach survives zen-mode's floating window (unlike
`matchadd`, which is window-local and gets lost when zen-mode creates
its window).

**What didn't work for @tag highlighting:**
- `matchadd()` in a `BufRead` autocmd — window-local, doesn't carry
  into zen-mode's floating window
- `syntax match` in a `FileType` autocmd — fires before zen-mode
  creates its window
- `syntax match` in a `BufWinEnter` autocmd — also didn't fire in the
  zen-mode window

### Typewriter Scrolling

The cursor stays vertically centered on screen at all times, including
at the top and bottom of the file. This is the most complex part of the
setup and required upgrading neovim.

#### How It Works

Two mechanisms work together:

1. **Virtual line padding**: Extmarks with `virt_lines` are placed above
   line 1 and after the last line, each adding `floor(window_height/2)`
   blank virtual lines. This creates scrollable space beyond the buffer
   boundaries.

2. **Manual centering**: A `CursorMoved`/`CursorMovedI` autocmd checks
   `winline()` (the cursor's screen row) against the window midpoint
   and adjusts `topline` via `winsaveview`/`winrestview` to center it.

The padding is created on `BufWinEnter` and `VimResized`. The bottom
extmark is repositioned to the actual last line on every cursor/text
event (since inserting lines causes the extmark to drift from the end).
Centering runs on every cursor movement via `vim.schedule` to avoid
recursion.

Extmarks are updated in place using stored IDs rather than
clear+recreate, which avoids a visual flash when the padding is
momentarily removed.

A reentrancy guard (`tw_centering`) prevents recursive
`CursorMoved` events from `winrestview` causing infinite loops.

#### Why This Requires Neovim 0.10+

Neovim PR #28044 (merged March 2024) made virtual lines at buffer
boundaries scrollable. On 0.9.x, the extmarks render but neovim refuses
to scroll into them — the cursor pins to the top/bottom of the real
buffer content. On 0.10+, the virtual lines create real scrollable
space.

#### What Didn't Work (and Why)

**`scrolloff=999`** — The oldest trick for centering. Works mid-file but
neovim clamps scrolling at buffer boundaries. Line 1 stays at the top
of the screen, last line stays at the bottom. This is a known neovim
limitation (issue #25392).

**scrollEOF.nvim** — Extends scrolloff past EOF. Has a `floating=true`
option but didn't actually work inside zen-mode's floating window.

**typewriter.nvim** — Dedicated typewriter plugin with zen-mode
integration. Broken as of December 2025 (issue #50): depends on
`nvim-treesitter.ts_utils` which was removed from treesitter's main
branch. Even if fixed, it uses `zz` which has the same boundary
limitation as scrolloff.

**stay-centered.nvim** — Simpler alternative that runs `zz` on every
`CursorMoved`. Same `zz` limitation — can't center past buffer
boundaries.

**`virt_lines` extmarks on neovim 0.9.5** — The extmarks rendered but
neovim wouldn't scroll into them. Confirmed by manually checking
`topline` — neovim clamped it to 1 when the file fit in the window.

**`topline` manipulation via `winsaveview`/`winrestview` (without
extmarks)** — Neovim clamps `topline` so the last buffer line is always
visible. Without virtual padding to extend the buffer, there's nothing
to scroll into.

**`Ctrl-E`/`Ctrl-Y` scroll commands in `center_cursor()`** — The
original centering implementation used
`vim.fn.execute("normal! N\x05")` and `\x19` for scrolling. This
worked in normal mode but **crashed neovim during insert mode typing**.
In insert mode, `Ctrl-E` inserts the character from the line below and
`Ctrl-Y` inserts from the line above. So when a word wrapped
(triggering `CursorMovedI`), the function would insert garbage
characters into the buffer, which triggered `TextChangedI`, which
re-ran padding, which triggered more cursor events — a recursive loop
that corrupted buffer state and crashed neovim. Fixed by switching to
`winsaveview`/`winrestview` for centering.

**Clear+recreate extmarks on text change** — The original
`update_typewriter_padding` cleared all extmarks in the namespace and
recreated them on every `TextChangedI` event. This caused a blank
screen when pressing Enter: the bottom padding extmark stayed on its
original line (now second-to-last) after a new line was inserted, and
without padding after the actual last line, `winrestview` scrolled
the viewport past all content. Fixed by: (1) using extmark IDs to
update in place instead of clear+recreate, and (2) repositioning the
bottom extmark to the actual last line on every cursor/text event.

**`zz` with virtual padding** — Even with extmark padding on neovim
0.12, `zz` does not scroll into virtual lines. It only considers real
buffer lines for centering. This is why `winsaveview`/`winrestview`
with direct `topline` manipulation is necessary.

#### Known Issues / Areas to Watch

- The centering autocmd fires on every cursor movement. If there are
  performance issues on very large files, this may need debouncing.
- The interaction between `linebreak`/soft wrap and `winline()` hasn't
  been thoroughly tested with very long wrapped lines. `winline()`
  counts screen lines, which should be correct, but edge cases may
  exist.
- Not tested with multiple buffers or splits — only used in zen-mode's
  single floating window context.

## Neovim Upgrade Notes

Upgraded from 0.9.5 (Ubuntu 24.04 apt default) to 0.12.0-dev:

```
sudo add-apt-repository ppa:neovim-ppa/unstable
sudo apt update && sudo apt install neovim
```

This was required for the typewriter scrolling feature. The `unstable`
PPA tracks neovim nightly builds. If stability becomes a concern,
`ppa:neovim-ppa/stable` provides the latest stable release (0.10.x+),
which also has the required PR #28044 fix.

## Plugin Opportunity

The typewriter scrolling implementation (extmark padding +
winsaveview centering) is a novel combination that doesn't exist as a
standalone plugin. Existing plugins either use `zz` (which can't center
at buffer boundaries) or only handle one end (go-up.nvim does top
padding only). This could be extracted into a reusable plugin.

### Hardening Needed for General Use

The current implementation works well in a single-buffer, single-window
zen-mode context. To be robust across arbitrary neovim configurations,
these areas need attention:

- **Multiple windows/splits**: Extmark IDs are stored as global
  variables. With splits, each window showing the same buffer shares
  the padding extmarks but would need independent centering (each
  window has its own `topline` and `winline()`).
- **Buffer switching**: `tw_top_id`/`tw_bot_id` are single variables,
  not per-buffer. Opening a second buffer loses track of the first
  buffer's extmarks. Needs a table keyed by buffer number.
- **Filetype filtering**: Most users would want typewriter mode for
  prose only, not every buffer. Help pages, terminals, file pickers,
  completion popups, etc. should be excluded. Needs a configurable
  filetype allowlist/blocklist or a manual enable/disable model.
- **Toggle commands**: Needs `:TWEnable`, `:TWDisable`, `:TWToggle`
  commands and a per-buffer enabled flag so users can control when it's
  active.
- **Interaction with other plugins**: Telescope, nvim-cmp completion
  popups, and other floating windows trigger `CursorMoved` events. The
  centering handler would fire in those contexts and potentially
  interfere. Needs a guard that checks the window type or skips
  non-target windows.
- **Performance on large files**: The `CursorMoved` handler runs on
  every movement. Could skip the `winrestview` call if `winline()`
  hasn't changed since the last invocation (cache the previous value).
- **Extmark cleanup**: When typewriter mode is disabled or a buffer is
  unloaded, the virtual padding extmarks should be removed to avoid
  ghost padding in other contexts.
