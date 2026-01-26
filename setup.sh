#!/usr/bin/env bash
set -euo pipefail

# Dotfiles Setup Script
# Restores configuration files to a fresh Linux system

echo "🔧 Setting up dotfiles..."

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Helper function
print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Get the directory where this script is located
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Backup existing files
backup_if_exists() {
    local file=$1
    if [ -f "$file" ]; then
        local backup="${file}.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$file" "$backup"
        print_warning "Backed up existing $file to $backup"
    fi
}

echo ""
echo "📁 Installing shell configuration..."
backup_if_exists ~/.bashrc
backup_if_exists ~/.profile
cp "$DOTFILES_DIR/bash/.bashrc" ~/.bashrc
cp "$DOTFILES_DIR/bash/.profile" ~/.profile
print_status "Shell configuration installed"

echo ""
echo "📁 Installing git configuration..."
backup_if_exists ~/.gitconfig
cp "$DOTFILES_DIR/git/.gitconfig" ~/.gitconfig
print_status "Git configuration installed"

echo ""
echo "📁 Installing custom scripts..."
mkdir -p ~/.local/bin
cp "$DOTFILES_DIR/scripts/"* ~/.local/bin/
chmod +x ~/.local/bin/*
print_status "Custom scripts installed to ~/.local/bin"

echo ""
echo "📁 Installing Claude CLI configuration..."
mkdir -p ~/.claude
cp "$DOTFILES_DIR/claude/"* ~/.claude/
print_status "Claude CLI configuration installed"

echo ""
echo "📁 Installing VSCodium configuration..."
if command -v codium &> /dev/null; then
    mkdir -p ~/.config/VSCodium/User
    cp "$DOTFILES_DIR/vscodium/settings.json" ~/.config/VSCodium/User/
    print_status "VSCodium settings installed"

    echo "   Installing VSCodium extensions..."
    while IFS= read -r extension; do
        if [ -n "$extension" ]; then
            echo "   - Installing $extension..."
            codium --install-extension "$extension" 2>/dev/null || print_warning "Failed to install $extension"
        fi
    done < "$DOTFILES_DIR/vscodium/extensions.txt"
    print_status "VSCodium extensions installed"
else
    print_warning "VSCodium not found. Install it first, then run:"
    echo "           mkdir -p ~/.config/VSCodium/User"
    echo "           cp $DOTFILES_DIR/vscodium/settings.json ~/.config/VSCodium/User/"
    echo "           cat $DOTFILES_DIR/vscodium/extensions.txt | xargs -L 1 codium --install-extension"
fi

echo ""
echo "✅ Dotfiles setup complete!"
echo ""
echo "📝 Next steps:"
echo "   1. Reload your shell: source ~/.bashrc"
echo "   2. Install Claude CLI if needed: https://docs.claude.ai/docs/claude-code"
echo "   3. Install VSCodium if needed: https://vscodium.com/"
echo "   4. Review android/README.md for Android SDK setup"
echo "   5. Update git user info: git config --global user.name \"Your Name\""
echo "   6.                       git config --global user.email \"your@email.com\""
echo ""
