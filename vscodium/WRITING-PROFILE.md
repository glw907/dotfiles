# VSCodium Writing Profile

A distraction-free Markdown writing environment inspired by iA Writer.

## Overview

The "Writing" profile provides:
- iA Writer Mono font at 20px for optimal readability
- Nord theme for muted, comfortable colors matching your system
- Centered layout with 80-character line width
- Zen Mode for complete focus
- Bold headers for visual hierarchy
- Clean, minimal UI with no distractions

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

## Quick Start

1. **Launch Writing mode:**
   ```bash
   write myfile.md
   ```

2. **Enter Zen Mode:** Press `Ctrl+K` then `Z`

3. **Exit Zen Mode:** Press `Escape` twice

4. **Toggle menu bar:** Press `Alt` (if needed)

## Profile Settings (Final Configuration)

```json
{
  "workbench.colorTheme": "Nord",
  
  "editor.fontFamily": "'iA Writer Mono S', 'iA Writer Mono V', monospace",
  "editor.fontSize": 20,
  "editor.lineHeight": 1.7,
  "editor.fontLigatures": false,
  "editor.fontWeight": "400",
  
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
  "editor.guides.indentation": false,
  "editor.guides.bracketPairs": false,
  "editor.guides.bracketPairsHorizontal": false,
  "editor.guides.highlightActiveIndentation": false,
  "editor.guides.highlightActiveBracketPair": false,
  "editor.rulers": [],
  "editor.renderWhitespace": "none",
  "breadcrumbs.enabled": false,
  
  "editor.wordWrap": "wordWrapColumn",
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
  "workbench.editor.tabCloseButton": "off",
  "workbench.editor.tabSizing": "shrink",
  "workbench.sideBar.location": "right",
  "workbench.startupEditor": "none",
  "window.menuBarVisibility": "toggle",
  "window.title": "",
  "window.titleBarStyle": "custom",
  
  "workbench.editor.centeredLayoutFixedWidth": true,
  
  "workbench.colorCustomizations": {
    "editorGroup.border": "#00000000",
    "editorPane.background": "#2e3440",
    "sideBar.border": "#00000000",
    "panel.border": "#00000000",
    "tab.border": "#00000000",
    "tab.activeBorder": "#00000000",
    "tab.activeBorderTop": "#00000000",
    "tab.unfocusedActiveBorder": "#00000000",
    "tab.unfocusedActiveBorderTop": "#00000000",
    "editorGroupHeader.tabsBackground": "#00000000",
    "editorGroupHeader.tabsBorder": "#00000000",
    "editorGroupHeader.border": "#00000000"
  },
  
  "editor.tokenColorCustomizations": {
    "textMateRules": [
      {
        "scope": "markup.heading",
        "settings": {
          "fontStyle": "bold"
        }
      }
    ]
  },
  
  "security.workspace.trust.enabled": false,
  "security.workspace.trust.untrustedFiles": "open",
  
  "zenMode.fullScreen": false,
  "zenMode.centerLayout": true,
  "zenMode.hideLineNumbers": true,
  "zenMode.hideTabs": true,
  "zenMode.hideStatusBar": false,
  "zenMode.silentNotifications": true,
  "zenMode.restore": true,
  
  "cSpell.language": "en",
  
  "[markdown]": {
    "editor.guides.indentation": false,
    "editor.guides.bracketPairs": false,
    "editor.rulers": [],
    "editor.renderIndentGuides": false,
    "editor.renderWhitespace": "none"
  }
}
```

## Installed Extensions

- **Nord Theme** (`arcticicestudio.nord-visual-studio-code`) - Muted Arctic color palette
- **Code Spell Checker** (`streetsidesoftware.code-spell-checker`) - Prose spell checking
- **Markdown All in One** - Markdown editing enhancements

## Dependencies

### iA Writer Fonts
Location: `~/.local/share/fonts/ia-writer-mono/`

Includes both Static and Variable font variants. Installed from [iA Fonts GitHub](https://github.com/iaolo/iA-Fonts).

### Pandoc (for export)
Document export functionality:

```bash
sudo apt install pandoc texlive-xetex
```

Export examples:
```bash
pandoc input.md -o output.docx
pandoc input.md -o output.pdf --pdf-engine=xelatex
pandoc input.md -o output.rtf
```

## Features

### Zen Mode (Recommended)
- **Enter:** `Ctrl+K` then `Z`
- **Exit:** `Escape` twice
- Provides centered layout with generous margins
- Hides all UI distractions
- Status bar remains visible for word count

### Typography
- **Font:** iA Writer Mono at 20px
- **Line height:** 1.7 for comfortable reading
- **Line width:** 80 characters (optimal for prose)
- **Headers:** Bold with Nord theme colors

### UI Minimalism
- No line numbers
- No scrollbars (scroll with trackpad/mouse wheel)
- No minimap
- No file tree (unless manually opened)
- No tabs
- Clean margins

## Philosophy

**Writing mode is explicitly opt-in.**

- Regular `codium` command uses Default profile (coding mode)
- Markdown files in coding projects (README.md, docs/) stay in coding mode
- Only files opened via `write` command or desktop launcher use Writing profile
- The two workflows are completely isolated

## Customization

### Font Size
Adjust in settings.json:
```json
"editor.fontSize": 22,  // Larger
"editor.fontSize": 18,  // Smaller
```

### Line Width
Adjust column width:
```json
"editor.wordWrapColumn": 90,  // Wider
"editor.wordWrapColumn": 70,  // Narrower
```

### Padding
Adjust vertical breathing room:
```json
"editor.padding.top": 60,
"editor.padding.bottom": 60,
```

## Profile Location

Profile settings are stored in:
- Settings: `~/.config/VSCodium/User/profiles/*/settings.json`
- Extensions: `~/.config/VSCodium/User/profiles/*/extensions/`
- Profile registry: `~/.config/VSCodium/User/globalStorage/storage.json`

Changes to profile settings are local to your machine (not tracked in dotfiles).

## See Also

- Original implementation plan: `~/Projects/vscodium-writing/IMPLEMENTATION_PLAN.md`
- Dotfiles sync script: `~/.dotfiles/sync-dotfiles.sh`
