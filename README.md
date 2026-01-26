# Dotfiles & Configuration

Ubuntu/Linux Mint configuration backup including shell setup, custom scripts, Claude CLI configuration, and VSCodium settings.

## Contents

- **bash/**: Shell configuration (.bashrc, .profile)
- **git/**: Git configuration (.gitconfig)
- **claude/**: Claude CLI mode configurations and settings
- **scripts/**: Custom utility scripts for ~/.local/bin
- **vscodium/**: VSCodium editor settings and extension list
- **android/**: Android SDK setup documentation

## Quick Setup on New System

```bash
# Clone this repository
cd ~
git clone https://github.com/glw907/dotfiles.git
cd dotfiles

# Run the setup script
./setup.sh

# Reload shell configuration
source ~/.bashrc
```

## Manual Setup

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
cp scripts/* ~/.local/bin/
chmod +x ~/.local/bin/*
```

### 4. Claude CLI Setup

```bash
# Install Claude CLI first (if not already installed)
# Visit: https://docs.claude.ai/docs/claude-code

# Copy Claude configuration
mkdir -p ~/.claude
cp claude/* ~/.claude/
```

### 5. VSCodium Setup

```bash
# Install VSCodium first
# Visit: https://vscodium.com/

# Copy settings
mkdir -p ~/.config/VSCodium/User
cp vscodium/settings.json ~/.config/VSCodium/User/

# Install extensions
cat vscodium/extensions.txt | xargs -L 1 codium --install-extension
```

### 6. Android SDK Setup

See `android/README.md` for detailed Android SDK installation instructions.

## Key Features

### Shell Aliases & Functions

- `cld` - Start Claude CLI mode with optional sudo caching
- `research` - Start Claude in research mode (Opus model)
- `blog` - Quick access to Hugo blog development
- `newpost` - Create new blog post with date prefix
- `blogpush` - Commit and push blog changes
- `blogdeploy` - Deploy blog to Cloudflare

### Claude Sudo Helper

The configuration includes a sudo helper that caches your password during Claude sessions:

- Start Claude with sudo caching: `cld -s`
- Password is automatically cleared when session ends
- Uses `SUDO_ASKPASS` for non-interactive prompts

### Custom Scripts

- **claude-askpass**: SUDO_ASKPASS helper for Claude sessions
- **claude-sudo-clear**: Clears cached sudo password
- **cld**: Enhanced Claude CLI launcher with sudo support
- **research**: Claude research mode launcher
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

## Notes

- The VSCodium settings.json is intentionally minimal (empty object)
- Extensions are listed in `vscodium/extensions.txt` for easy batch installation
- Claude configuration includes both CLI mode and research mode setups
- Sudo helper scripts require proper permissions (mode 700 or 600)

## License

Personal configuration files - use as you wish.
