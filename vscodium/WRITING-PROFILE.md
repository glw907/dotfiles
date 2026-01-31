# VSCodium Writing Profile

A dedicated VSCodium profile for distraction-free Markdown writing, designed to provide an iA Writer-like experience.

## Overview

The "Writing" profile is a completely separate VSCodium configuration that:
- Uses iA Writer Quattro font for readable typography
- Provides inline Markdown rendering (bold appears bold, italics rendered, etc.)
- Minimizes UI chrome for distraction-free writing
- Enables word wrap at comfortable reading width
- Is **opt-in only** - never affects regular coding workflow

## Entry Points

### Shell Command
```bash
write [file]          # Open file in Writing mode
write                 # Open current directory in Writing mode
```

The `write` command is tracked in `~/.dotfiles/bin/.local/bin/write`

### Desktop Launcher
**VSCodium Writing** appears in the Cinnamon application menu under Office > Text Editors.

Desktop launcher is tracked in `~/.dotfiles/applications/.local/share/applications/vscodium-writing.desktop`

## Profile Setup

**IMPORTANT:** The Writing profile itself is NOT tracked in dotfiles (VSCodium profiles live in `~/.config/VSCodium/User/profiles/`). To recreate the profile on a new system or if it gets deleted:

### Manual Profile Creation

1. Open VSCodium
2. Press `Ctrl+Shift+P` → "Preferences: Create Profile"
3. Name it **"Writing"** (exact name matters for shell command)
4. Install the following extensions in the Writing profile:

```
CodeSmith.markdown-inline-editor-vscode
streetsidesoftware.code-spell-checker
ms-vscode.wordcount (optional)
```

5. Open Settings (JSON) in the Writing profile
6. Paste the settings below

### Profile Settings (JSON)

```json
{
  // Typography
  "editor.fontFamily": "'iA Writer Quattro', 'iA Writer Quattro S', sans-serif",
  "editor.fontSize": 18,
  "editor.lineHeight": 1.6,
  "editor.fontLigatures": false,

  // Distraction-free
  "editor.lineNumbers": "off",
  "editor.renderLineHighlight": "none",
  "editor.minimap.enabled": false,
  "editor.scrollbar.vertical": "hidden",
  "editor.scrollbar.horizontal": "hidden",
  "editor.overviewRulerBorder": false,
  "editor.hideCursorInOverviewRuler": true,
  "editor.glyphMargin": false,
  "editor.folding": false,
  "editor.renderIndentGuides": false,
  "breadcrumbs.enabled": false,

  // Word wrap for prose
  "editor.wordWrap": "wordWrapColumn",
  "editor.wordWrapColumn": 80,
  "editor.wrappingIndent": "same",

  // Cursor
  "editor.cursorStyle": "line",
  "editor.cursorBlinking": "smooth",
  "editor.cursorWidth": 2,

  // Clean UI
  "workbench.activityBar.location": "hidden",
  "workbench.statusBar.visible": true,
  "workbench.editor.showTabs": "none",
  "workbench.sideBar.location": "right",
  "window.menuBarVisibility": "toggle",

  // Zen mode defaults
  "zenMode.fullScreen": false,
  "zenMode.centerLayout": true,
  "zenMode.hideLineNumbers": true,
  "zenMode.hideTabs": true,
  "zenMode.hideStatusBar": false,
  "zenMode.silentNotifications": true,

  // Markdown Inline Editor settings
  "markdownInlineEditor.decorations.ghostFaintOpacity": 0.25,
  "markdownInlineEditor.emojis.enabled": true,

  // Spell checker
  "cSpell.language": "en",

  // Start in Zen mode
  "zenMode.restore": true
}
```

## Dependencies

### iA Writer Quattro Fonts
The profile requires iA Writer Quattro fonts to be installed at `~/.local/share/fonts/ia-writer-quattro/`.

To install fonts:
```bash
mkdir -p ~/.local/share/fonts/ia-writer-quattro
# Download from https://github.com/iaolo/iA-Fonts
# Copy Static/*.ttf and Variable/*.ttf to ~/.local/share/fonts/ia-writer-quattro/
fc-cache -fv ~/.local/share/fonts/ia-writer-quattro/
```

### Pandoc (for export)
Document export functionality requires Pandoc and XeLaTeX:

```bash
sudo apt install pandoc texlive-xetex
```

Export examples:
```bash
pandoc input.md -o output.docx
pandoc input.md -o output.pdf --pdf-engine=xelatex
pandoc input.md -o output.rtf
```

## Philosophy

**Writing mode is explicitly opt-in.**

- Regular `codium` command uses Default profile (coding mode)
- Markdown files in coding projects (README.md, docs/) stay in coding mode
- Only files opened via `write` command or desktop launcher use Writing profile
- The two workflows are completely isolated

## Notes

- Profile settings are stored in `~/.config/VSCodium/User/profiles/Writing/`
- Changes to profile settings are local to your machine (not tracked in dotfiles)
- If you modify the Writing profile settings, update this document with the new JSON
- Extensions installed in Writing profile don't affect Default profile

## See Also

- Full implementation plan: `~/Projects/vscodium-writing/IMPLEMENTATION_PLAN.md`
- Dotfiles sync script: `~/.dotfiles/sync-dotfiles.sh`
