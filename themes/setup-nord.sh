#!/usr/bin/env bash
set -euo pipefail

# Nord Theme Installer for Linux Mint / Ubuntu
# Installs Nordic GTK theme, Nordic icons, Nord terminal theme, and sets wallpaper

echo "=========================================="
echo "Nord Theme Installer"
echo "=========================================="
echo ""

# Detect desktop environment
if [ "$XDG_CURRENT_DESKTOP" = "X-Cinnamon" ]; then
    DE="cinnamon"
    echo "Detected: Linux Mint (Cinnamon)"
elif [ "$XDG_CURRENT_DESKTOP" = "GNOME" ] || [ "$XDG_CURRENT_DESKTOP" = "ubuntu:GNOME" ]; then
    DE="gnome"
    echo "Detected: GNOME"
else
    echo "Unknown desktop environment: $XDG_CURRENT_DESKTOP"
    echo "This script supports Cinnamon and GNOME. Proceeding with generic setup..."
    DE="unknown"
fi

echo ""
echo "This will install:"
echo "  - Nordic GTK theme"
echo "  - Nordic icon theme"
echo "  - Nord GNOME Terminal theme"
echo "  - Nord wallpaper"
echo ""
read -p "Continue? [y/N] " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 0
fi

echo ""
echo "Installing themes..."
echo ""

# 1. Install Nordic GTK Theme
echo "[1/5] Installing Nordic GTK theme..."
if [ ! -d /usr/share/themes/Nordic ]; then
    cd /tmp
    if [ -d Nordic ]; then
        rm -rf Nordic
    fi
    git clone https://github.com/EliverLara/Nordic.git
    sudo mv Nordic /usr/share/themes/
    echo "✓ Nordic GTK theme installed"
else
    echo "✓ Nordic GTK theme already installed"
fi

# 2. Install Papirus Icon Theme
echo "[2/5] Installing Papirus icon theme..."
if ! dpkg -l | grep -q papirus-icon-theme; then
    sudo apt install -y papirus-icon-theme
    echo "✓ Papirus icon theme installed"
else
    echo "✓ Papirus icon theme already installed"
fi

# 3. Install Nord GNOME Terminal theme
echo "[3/5] Installing Nord GNOME Terminal theme..."
cd /tmp
if [ -d nord-gnome-terminal ]; then
    rm -rf nord-gnome-terminal
fi
git clone https://github.com/arcticicestudio/nord-gnome-terminal.git
cd nord-gnome-terminal/src
# Run non-interactively (selects default profile)
bash nord.sh
echo "✓ Nord terminal theme installed"

# 4. Set up wallpapers directory and copy wallpapers
echo "[4/5] Setting up wallpapers..."
mkdir -p ~/Pictures/Wallpapers
# Wallpapers should already exist, but note if they don't
if [ -f ~/Pictures/Wallpapers/nord-gradient.png ]; then
    echo "✓ Nord wallpapers found"
else
    echo "⚠ Nord wallpapers not found in ~/Pictures/Wallpapers/"
    echo "  Please copy nord-gradient.png and nord-minimal.png manually"
fi

# 5. Apply themes
echo "[5/5] Applying themes..."

if [ "$DE" = "cinnamon" ]; then
    # Cinnamon settings
    gsettings set org.cinnamon.desktop.interface gtk-theme "Nordic"
    gsettings set org.cinnamon.theme name "Nordic"
    gsettings set org.cinnamon.desktop.interface icon-theme "Papirus-Dark"

    if [ -f ~/Pictures/Wallpapers/nord-gradient.png ]; then
        gsettings set org.cinnamon.desktop.background picture-uri "file://$HOME/Pictures/Wallpapers/nord-gradient.png"
    fi

    echo "✓ Cinnamon themes applied"
elif [ "$DE" = "gnome" ]; then
    # GNOME settings
    gsettings set org.gnome.desktop.interface gtk-theme "Nordic"
    gsettings set org.gnome.desktop.interface icon-theme "Papirus-Dark"

    if [ -f ~/Pictures/Wallpapers/nord-gradient.png ]; then
        gsettings set org.gnome.desktop.background picture-uri "file://$HOME/Pictures/Wallpapers/nord-gradient.png"
    fi

    echo "✓ GNOME themes applied"
else
    echo "⚠ Unknown DE - skipping theme application"
    echo "  Manually set GTK theme to 'Nordic' and icon theme to 'Papirus-Dark'"
fi

echo ""
echo "=========================================="
echo "✓ Nord theme installation complete!"
echo "=========================================="
echo ""
echo "Additional steps:"
echo "  - VSCodium: Install 'Nord' extension (arcticicestudio.nord-visual-studio-code)"
echo "  - Terminal: Select 'Nord' profile in terminal preferences"
echo "  - You may need to log out and back in for all changes to take effect"
echo ""
