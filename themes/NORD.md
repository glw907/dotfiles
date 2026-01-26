# Nord Theme Setup

Nord is the preferred color scheme across all applications and desktop environments.

**Nord Theme**: https://www.nordtheme.com/

## Color Palette

Nord uses a carefully designed color palette based on arctic, north-bluish colors:

- **Polar Night** (dark): `#2E3440`, `#3B4252`, `#434C5E`, `#4C566A`
- **Snow Storm** (light): `#D8DEE9`, `#E5E9F0`, `#ECEFF4`
- **Frost** (blue/cyan): `#8FBCBB`, `#88C0D0`, `#81A1C1`, `#5E81AC`
- **Aurora** (accent): `#BF616A`, `#D08770`, `#EBCB8B`, `#A3BE8C`, `#B48EAD`

## Linux Mint (Cinnamon) Setup

### 1. Install Nord GTK Theme

```bash
# Clone Nord GTK theme
cd /tmp
git clone https://github.com/EliverLara/Nordic.git
sudo mv Nordic /usr/share/themes/

# Apply theme
gsettings set org.cinnamon.desktop.interface gtk-theme "Nordic"
gsettings set org.cinnamon.theme name "Nordic"
```

### 2. Install Nord Icon Theme

```bash
# Install Papirus icon theme (has Nord variants)
sudo apt install papirus-icon-theme

# Or install Nordic icon theme
cd /tmp
git clone https://github.com/EliverLara/Nordic-Folders.git
cd Nordic-Folders
./install.sh

# Apply icon theme
gsettings set org.cinnamon.desktop.interface icon-theme "Nordic"
```

### 3. Set Nord Wallpaper

Wallpaper files are included in this repository (should be copied to `~/Pictures/Wallpapers/`):

```bash
# Set wallpaper
gsettings set org.cinnamon.desktop.background picture-uri "file:///home/$USER/Pictures/Wallpapers/nord-gradient.png"
```

### 4. Install Nord Terminal Theme

For GNOME Terminal / Mint Terminal:

```bash
# Install Nord GNOME Terminal theme
cd /tmp
git clone https://github.com/arcticicestudio/nord-gnome-terminal.git
cd nord-gnome-terminal/src
./nord.sh
```

For other terminals, see: https://www.nordtheme.com/ports

### 5. Configure VSCodium Nord Theme

Install Nord theme extension:

```bash
codium --install-extension arcticicestudio.nord-visual-studio-code
```

Then in VSCodium settings:
- `Ctrl+Shift+P` → "Preferences: Color Theme"
- Select "Nord"

Or set in `settings.json`:
```json
{
  "workbench.colorTheme": "Nord"
}
```

## Quick Setup Script

Run the included setup script for automatic Nord installation:

```bash
cd ~/dotfiles/themes
./setup-nord.sh
```

## Ubuntu GNOME Setup

If using Ubuntu with GNOME instead of Mint Cinnamon:

```bash
# GTK Theme
gsettings set org.gnome.desktop.interface gtk-theme "Nordic"

# Icon Theme
gsettings set org.gnome.desktop.interface icon-theme "Nordic"

# Wallpaper
gsettings set org.gnome.desktop.background picture-uri "file:///home/$USER/Pictures/Wallpapers/nord-gradient.png"
```

## Application-Specific Nord Themes

### Firefox
Install Nord theme from Firefox Add-ons:
- https://addons.mozilla.org/en-US/firefox/addon/nord-theme/

### Chrome/Brave
Install Nord theme from Chrome Web Store:
- https://chrome.google.com/webstore/detail/nord/abehfkkfjlplnjadfcjiflnejblfmmpj

### Recommended Extensions

For a complete Nord experience:

**VSCodium:**
- `arcticicestudio.nord-visual-studio-code` - Nord theme

**Terminal:**
- Configure Nord color scheme (see terminal-specific instructions above)

**File Manager (Nemo):**
- Automatically themed when Nordic GTK theme is applied

## Wallpapers

This repository includes Nord-themed wallpapers:
- `nord-gradient.png` - Gradient version (recommended)
- `nord-minimal.png` - Minimal version

Location: `~/Pictures/Wallpapers/`

## Notes

- The Nordic GTK theme is actively maintained and works well with Cinnamon
- Some applications may require a logout/login to fully apply the theme
- For custom applications not supporting theming, check https://www.nordtheme.com/ports for available ports
- The Nord color palette is consistent across all applications for a unified look

## Troubleshooting

**Theme doesn't apply:**
- Try logging out and back in
- Check if theme is in `/usr/share/themes/` or `~/.themes/`

**Icons don't change:**
- Some apps use hardcoded icons
- Papirus/Nordic icon themes cover most common applications

**Terminal colors look wrong:**
- Make sure you selected the Nord profile after installation
- Some terminals require manual color configuration

## Resources

- Nord Theme Official: https://www.nordtheme.com/
- Nordic GTK Theme: https://github.com/EliverLara/Nordic
- Nord Ports: https://www.nordtheme.com/ports
