#!/usr/bin/env bash
set -euo pipefail

# Dotfiles Sync & Health Check Script
# Checks for drift and updates tracked configurations

DOTFILES="$HOME/.dotfiles"
BOLD='\033[1m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BOLD}🔄 Dotfiles Sync & Health Check${NC}\n"

# Track if anything needs attention
needs_commit=false

# 1. Check Stow-managed packages
echo -e "${BOLD}📦 Checking Stow packages...${NC}"
stow_packages=()
mapfile -t stow_packages < <(grep -vE '^[[:space:]]*(#|$)' "$DOTFILES/bluefin/stow-packages.txt")
for package in "${stow_packages[@]}"; do
    if [ -d "$DOTFILES/$package" ]; then
        echo -e "  ${GREEN}✓${NC} $package (Stow-managed)"
    fi
done

# 2. Check Git config
echo -e "\n${BOLD}📦 Checking Git config...${NC}"
if [ -L "$HOME/.gitconfig" ]; then
    echo -e "  ${GREEN}✓${NC} .gitconfig (symlinked)"
else
    echo -e "  ${YELLOW}⚠${NC} .gitconfig (not symlinked - managed manually)"
    if ! diff -q "$HOME/.gitconfig" "$DOTFILES/git/.gitconfig" &>/dev/null; then
        echo -e "  ${YELLOW}→${NC} Changes detected, updating dotfiles..."
        cp "$HOME/.gitconfig" "$DOTFILES/git/.gitconfig"
        needs_commit=true
    fi
fi

# 3. Check for uncommitted changes
echo -e "\n${BOLD}📝 Checking Git status...${NC}"
cd "$DOTFILES"
if [[ -n $(git status --porcelain) ]]; then
    echo -e "  ${YELLOW}→${NC} Uncommitted changes detected:\n"
    git status --short | sed 's/^/    /'
    needs_commit=true
else
    echo -e "  ${GREEN}✓${NC} No uncommitted changes"
fi

# Summary
echo -e "\n${BOLD}Summary:${NC}"
if [ "$needs_commit" = true ]; then
    echo -e "  ${YELLOW}⚠${NC} Changes detected - review and commit:"
    echo -e "    cd ~/.dotfiles && git status"
    echo -e "    git add -A && git commit -m \"Update dotfiles\""
    exit 1
else
    echo -e "  ${GREEN}✓${NC} All dotfiles in sync!"
    exit 0
fi
