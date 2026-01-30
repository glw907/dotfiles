# VSCodium Configuration

VSCodium settings and extensions managed with GNU Stow.

## Structure

- **`.config/VSCodium/User/settings.json`** - Symlinked via Stow (auto-tracked)
- **`extensions.txt`** - Extension list (manually synced)
- **`sync-extensions.sh`** - Helper script to update extensions.txt

## Usage

### Initial Setup

```bash
cd ~/.dotfiles
stow vscodium
```

This creates a symlink at `~/.config/VSCodium/User/settings.json` pointing to your dotfiles.

### Tracking Changes

**Settings**: Any changes you make in VSCodium are automatically tracked (symlinked).

**Extensions**: After installing/removing extensions, update the list:

```bash
~/.dotfiles/vscodium/sync-extensions.sh
```

Or manually:

```bash
codium --list-extensions > ~/.dotfiles/vscodium/extensions.txt
```

### Restoring on New System

```bash
# 1. Symlink settings
cd ~/.dotfiles
stow vscodium

# 2. Install extensions
cat ~/.dotfiles/vscodium/extensions.txt | xargs -L 1 codium --install-extension
```

## Current Extensions

See `extensions.txt` for the current extension list.

## Notes

- Settings are automatically synced via symlink
- Extension list must be manually updated when you add/remove extensions
- Run `sync-extensions.sh` before committing dotfiles changes
