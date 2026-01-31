# VSCodium Writing Profile

A dedicated VSCodium profile for distraction-free Markdown writing, designed to provide an iA Writer-like experience.

## Overview

The "Writing" profile is a completely separate VSCodium configuration that:
- Uses iA Writer Quattro font for readable typography
- Provides inline Markdown rendering (bold appears bold, italics rendered, etc.)
- Minimizes UI chrome for distraction-free writing
- Centers text with comfortable padding for optimal readability
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

## Profile Settings (Current Configuration)

The Writing profile uses these settings for optimal readability:

```json
{
  "editor.fontFamily": "'iA Writer Quattro', 'iA Writer Quattro S', sans-serif",
  "editor.fontSize": 18,
  "editor.lineHeight": 1.6,
  "editor.fontLigatures": false,
  
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
  
  "editor.wordWrap": "bounded",
  "editor.wordWrapColumn": 80,
  "editor.wrappingIndent": "same",
  
  "editor.padding.top": 40,
  "editor.padding.bottom": 40,
  
  "editor.cursorStyle": "line",
  "editor.cursorBlinking": "smooth",
  "editor.cursorWidth": 2,
  
  "workbench.activityBar.location": "hidden",
  "workbench.statusBar.visible": true,
  "workbench.editor.showTabs": "none",
  "workbench.sideBar.location": "right",
  "workbench.editor.centered": true,
  "workbench.editor.centeredLayoutAutoResize": false,
  "window.menuBarVisibility": "toggle",
  
  "zenMode.fullScreen": false,
  "zenMode.centerLayout": true,
  "zenMode.hideLineNumbers": true,
  "zenMode.hideTabs": true,
  "zenMode.hideStatusBar": false,
  "zenMode.silentNotifications": true,
  "zenMode.restore": true,
  
  "markdownInlineEditor.decorations.ghostFaintOpacity": 0.25,
  "markdownInlineEditor.emojis.enabled": true,
  
  "cSpell.language": "en"
}
```

## Installed Extensions

- **Markdown Inline Editor** (`CodeSmith.markdown-inline-editor-vscode`) - Inline rendering with 3-state syntax hiding
- **Code Spell Checker** (`streetsidesoftware.code-spell-checker`) - Prose spell checking
- **Markdown All in One** (includes word count, table of contents, etc.)

## Customization Tips

### Adjust padding
Change vertical breathing room:
```json
"editor.padding.top": 60,
"editor.padding.bottom": 60,
```

### Wider text column
For longer lines:
```json
"editor.wordWrapColumn": 90,
```

### Font size
Adjust for your display:
```json
"editor.fontSize": 16,  // or 20, 22, etc.
```

## Dependencies

### iA Writer Quattro Fonts
Location: `~/.local/share/fonts/ia-writer-quattro/`

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

## Profile Location

Profile settings are stored in:
- Settings: `~/.config/VSCodium/User/profiles/*/settings.json`
- Extensions: `~/.config/VSCodium/User/profiles/*/extensions/`
- Profile registry: `~/.config/VSCodium/User/globalStorage/storage.json`

Changes to profile settings are local to your machine (not tracked in dotfiles).
If you modify the Writing profile settings, update this document with the new JSON.

## See Also

- Full implementation plan: `~/Projects/vscodium-writing/IMPLEMENTATION_PLAN.md`
- Dotfiles sync script: `~/.dotfiles/sync-dotfiles.sh`
