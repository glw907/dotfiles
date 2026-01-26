# Wallpapers

Nord-themed wallpapers for desktop backgrounds.

## Installation

Copy wallpapers to your Pictures directory:

```bash
mkdir -p ~/Pictures/Wallpapers
cp *.png ~/Pictures/Wallpapers/
```

Or run the main `setup.sh` script which handles this automatically.

## Included Wallpapers

- **nord-gradient.png** - Nord color gradient (recommended)
- **nord-minimal.png** - Minimal Nord design

## Setting Wallpaper

### Linux Mint (Cinnamon)
```bash
gsettings set org.cinnamon.desktop.background picture-uri "file://$HOME/Pictures/Wallpapers/nord-gradient.png"
```

### Ubuntu (GNOME)
```bash
gsettings set org.gnome.desktop.background picture-uri "file://$HOME/Pictures/Wallpapers/nord-gradient.png"
```

Or use the desktop environment's settings GUI:
- Right-click desktop → Change Desktop Background
- Navigate to `~/Pictures/Wallpapers/` and select the wallpaper

## Nord Theme

These wallpapers are part of the Nord theme setup. See `themes/NORD.md` for complete Nord theme installation instructions.
