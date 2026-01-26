# Browser Bookmarks Backup

Backup of bookmarks from Ubuntu for easy restoration on Linux Mint.

## Contents

- **firefox-bookmarks.html** - Firefox bookmarks in standard HTML format (15 bookmarks)
- **firefox-places.sqlite** - Complete Firefox database (bookmarks, history, etc.)
- **chrome-bookmarks.json** - Google Chrome bookmarks in JSON format
- **export-firefox-bookmarks.py** - Script to regenerate HTML from places.sqlite

## Restore Bookmarks

### Firefox

**Option 1: Import HTML (Recommended)**

1. Open Firefox
2. Press `Ctrl+Shift+O` (Bookmarks Manager)
3. Click "Import and Backup" → "Import Bookmarks from HTML..."
4. Select `firefox-bookmarks.html`

**Option 2: Replace Database (Advanced)**

```bash
# Close Firefox first!
pkill firefox

# Backup existing places.sqlite
mv ~/.mozilla/firefox/*.default-release/places.sqlite{,.backup}

# Copy the backed up database
cp browser-bookmarks/firefox-places.sqlite ~/.mozilla/firefox/*.default-release/

# Restart Firefox
firefox &
```

### Google Chrome

**Import from JSON:**

1. Open Chrome
2. Press `Ctrl+Shift+O` (Bookmark Manager)
3. Click "⋮" (three dots) → "Import bookmarks"
4. Chrome doesn't directly import JSON, but you can use Firefox to import the HTML, then use Chrome to import from Firefox

**Or replace bookmarks file:**

```bash
# Close Chrome first!
pkill chrome

# Backup existing
cp ~/.config/google-chrome/Default/Bookmarks{,.backup}

# Copy backed up bookmarks
cp browser-bookmarks/chrome-bookmarks.json ~/.config/google-chrome/Default/Bookmarks

# Restart Chrome
google-chrome &
```

### Any Browser (Using HTML)

The `firefox-bookmarks.html` file is in standard Netscape Bookmark format, compatible with:
- Firefox
- Chrome/Chromium
- Brave
- Edge
- Most other browsers

Use the browser's "Import bookmarks from HTML" feature.

## Notes

- **firefox-places.sqlite** (5.0 MB) contains full browsing history, not just bookmarks
- **firefox-bookmarks.html** (1.8 KB) contains only bookmarks, easier to import
- **chrome-bookmarks.json** (7.9 KB) is Chrome's native format
- Always close browsers before replacing database files
- Bookmark count: 15 Firefox bookmarks exported

## Regenerate HTML Export

If you need to re-export from places.sqlite:

```bash
cd browser-bookmarks
python3 export-firefox-bookmarks.py
```

This will regenerate `firefox-bookmarks.html` from the places.sqlite database.
