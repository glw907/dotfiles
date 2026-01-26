# Stow Migration Plan

## Current State
- Dotfiles repo exists at `~/dotfiles/` (Git managed)
- Currently using copy-based setup via `setup.sh`
- Active configs exist at `~/.claude/`, `~/.local/bin/`, etc.

## Plan
Following Opus recommendation to use GNU Stow for symlink management.

### Steps to Complete

1. **Install GNU Stow**
   ```bash
   sudo -A apt install -y stow
   ```

2. **Move repo to conventional location**
   ```bash
   mv ~/dotfiles ~/.dotfiles
   ```

3. **Restructure for Stow compatibility**

   Current structure:
   ```
   ~/dotfiles/
   ├── claude/cli-mode.md
   ├── scripts/myscript
   └── bash/.bashrc
   ```

   Stow structure (paths include the target dot-prefix):
   ```
   ~/.dotfiles/
   ├── claude/.claude/cli-mode.md      → symlinks to ~/.claude/cli-mode.md
   ├── bin/.local/bin/myscript         → symlinks to ~/.local/bin/myscript
   └── bash/.bashrc                    → symlinks to ~/.bashrc
   ```

4. **Create symlinks**
   ```bash
   cd ~/.dotfiles
   stow claude bin bash
   ```

5. **Update README.md** with Stow-based instructions

6. **Commit changes** to Git

## Benefits
- **Automatic symlink management**: No manual ln commands
- **Easy to add/remove configs**: Just `stow packagename` or `stow -D packagename`
- **Standard pattern**: Widely used in dotfiles community
- **Version controlled**: All changes tracked in Git

## Reference
- GNU Stow docs: https://www.gnu.org/software/stow/
- Pattern discussed with Claude Opus on 2026-01-26
