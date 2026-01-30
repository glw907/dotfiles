# Dotfiles & Configuration

Ubuntu/Linux Mint configuration backup including shell setup, custom scripts, Claude CLI configuration, and VSCodium settings.

Managed with [GNU Stow](https://www.gnu.org/software/stow/) for automatic symlink management.

## Contents

- **bash/**: Shell configuration (.bashrc, .profile)
- **bin/**: System utility scripts (update-android-sdk)
- **git/**: Git configuration (.gitconfig)
- **vscodium/**: VSCodium editor settings and extension list
- **android/**: Android SDK setup documentation
- **themes/**: Nord theme setup and installation scripts
- **wallpapers/**: Nord-themed desktop wallpapers
- **sync-dotfiles.sh**: Health check script for tracking drift

## Quick Setup on New System

```bash
# Install GNU Stow
sudo apt install -y stow

# Clone this repository
git clone https://github.com/glw907/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# Install desired packages (creates symlinks)
stow bash bin vscodium

# Reload shell configuration
source ~/.bashrc
```

## Using Stow

Stow creates symlinks from `~/.dotfiles/` to your home directory automatically:

```bash
cd ~/.dotfiles

# Install a package (create symlinks)
stow bash              # Links .bashrc and .profile
stow bin               # Links scripts to ~/.local/bin/
stow vscodium          # Links VSCodium settings.json

# Install multiple packages at once
stow bash bin vscodium

# Remove a package (remove symlinks)
stow -D bash

# Restow (useful after updates)
stow -R bash
```

## Manual Setup (Alternative)

If you prefer not to use Stow, you can manually copy files:

### 1. Shell Configuration

```bash
cp bash/.bashrc ~/.bashrc
cp bash/.profile ~/.profile
source ~/.bashrc
```

### 2. Git Configuration

```bash
cp git/.gitconfig ~/.gitconfig
```

### 3. Custom Scripts

```bash
mkdir -p ~/.local/bin
cp bin/.local/bin/* ~/.local/bin/
chmod +x ~/.local/bin/*
```

### 4. VSCodium Setup

```bash
# Install VSCodium first
# Visit: https://vscodium.com/

# Copy settings
mkdir -p ~/.config/VSCodium/User
cp vscodium/settings.json ~/.config/VSCodium/User/

# Install extensions
cat vscodium/extensions.txt | xargs -L 1 codium --install-extension
```

### 5. Android SDK Setup

See `android/README.md` for detailed Android SDK installation instructions.

### 6. Nord Theme Setup

Install Nord theme across system (GTK, icons, terminal, VSCodium):

```bash
# Automated installation
cd ~/.dotfiles/themes
./setup-nord.sh

# Or see themes/NORD.md for manual installation steps
```

This will install:
- Nordic GTK theme
- Papirus icon theme (Nord-compatible)
- Nord GNOME Terminal colors
- Nord wallpapers
- VSCodium Nord theme extension

## Key Features

### Shell Aliases & Functions

- `blog` - Quick access to Hugo blog development (`cd ~/Projects/907-life && codium . && hugo server -D`)
- `newpost` - Create new blog post with date prefix
- `blogpush` - Commit and push blog changes
- `blogdeploy` - Deploy blog to Cloudflare

### Modal Claude Integration

Modal Claude scripts are maintained in a separate repository (`~/Projects/modal-claude/`) and symlinked to `~/.local/bin/`:

**Mode Launchers:**
- `cld` - CLI mode (execution and system changes)
- `cld-arch` - Architecture mode (design and scaffolding)
- `cld-research` - Research mode (external research)
- `cld-write` - Write mode (documentation and prose)
- `cld-critic` - Critic mode (media recommendations)

**Helper Scripts:**
- `claude-askpass` - SUDO_ASKPASS helper for Claude sessions
- `claude-sudo-clear` - Clears cached sudo password

See: [github.com/glw907/modal-claude](https://github.com/glw907/modal-claude)

### System Utility Scripts

Scripts tracked in this repository:
- **update-android-sdk**: Android SDK component updater

## System Information

This configuration was created on:
- OS: Ubuntu 24.04 LTS
- Shell: bash
- Editor: VSCodium

Compatible with Ubuntu, Linux Mint, and other Debian-based distributions.

## Blog Configuration

The .bashrc includes shortcuts for managing the 907.life Hugo blog:
- Blog directory: `~/Projects/907-life`
- Hugo server with drafts: `blog`
- Create posts: `newpost YYYY-MM-DD-title`
- Deploy: `npx wrangler deploy`

## Script Distribution Strategy

Configuration and scripts are distributed across two repositories:

**This repository (`~/.dotfiles/`)** - System configuration
- Shell config (bash)
- Editor settings (vscodium)
- Git configuration
- System utilities (`update-android-sdk`)

**Modal Claude (`~/Projects/modal-claude/`)** - Application code
- Mode launchers (`cld`, `cld-arch`, `cld-research`, `cld-write`, `cld-critic`)
- Claude-specific helpers (`claude-askpass`, `claude-sudo-clear`)

This separation keeps system configuration portable while maintaining Modal Claude as versioned application code.

## Maintenance

Run the sync script to check for drift and update tracked files:
```bash
~/.dotfiles/sync-dotfiles.sh
```

This checks:
- Stow package symlink status
- Git config changes (auto-copies if changed)
- VSCodium extension changes
- Uncommitted changes in the repository

CLI mode automatically runs this when making configuration changes.

## Notes

- VSCodium settings.json is Stow-managed (symlinked)
- Extensions are listed in `vscodium/extensions.txt` (manual sync via script)
- Git config is NOT stowed - manually synced via `sync-dotfiles.sh`
- Modal Claude scripts are separate - see modal-claude repository

## License

Personal configuration files - use as you wish.
