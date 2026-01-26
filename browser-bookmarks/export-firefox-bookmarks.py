#!/usr/bin/env python3
"""
Export Firefox bookmarks to HTML format
Reads from places.sqlite and creates a standard bookmark HTML file
"""

import sqlite3
import html
from datetime import datetime
from pathlib import Path

# Input/output files
PLACES_DB = Path(__file__).parent / "firefox-places.sqlite"
OUTPUT_HTML = Path(__file__).parent / "firefox-bookmarks.html"

def export_bookmarks():
    """Export Firefox bookmarks from places.sqlite to HTML"""

    if not PLACES_DB.exists():
        print(f"Error: {PLACES_DB} not found")
        return

    # Connect to Firefox places database
    conn = sqlite3.connect(PLACES_DB)
    cursor = conn.cursor()

    # Query to get all bookmarks
    # Firefox stores bookmarks in moz_bookmarks with URLs in moz_places
    query = """
    SELECT
        b.title,
        p.url,
        b.dateAdded,
        b.parent
    FROM moz_bookmarks b
    LEFT JOIN moz_places p ON b.fk = p.id
    WHERE b.type = 1  -- type 1 = bookmark
    AND p.url IS NOT NULL
    ORDER BY b.dateAdded DESC
    """

    cursor.execute(query)
    bookmarks = cursor.fetchall()

    # Generate HTML
    html_content = """<!DOCTYPE NETSCAPE-Bookmark-file-1>
<!-- This is an automatically generated file.
     It will be read and overwritten.
     DO NOT EDIT! -->
<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=UTF-8">
<TITLE>Bookmarks</TITLE>
<H1>Bookmarks</H1>
<DL><p>
"""

    for title, url, date_added, parent in bookmarks:
        # Convert Firefox timestamp (microseconds) to seconds
        timestamp = date_added // 1000000 if date_added else 0

        # Escape HTML entities
        safe_title = html.escape(title or url)
        safe_url = html.escape(url)

        html_content += f'    <DT><A HREF="{safe_url}" ADD_DATE="{timestamp}">{safe_title}</A>\n'

    html_content += "</DL><p>\n"

    # Write to file
    OUTPUT_HTML.write_text(html_content, encoding='utf-8')

    conn.close()

    print(f"✓ Exported {len(bookmarks)} bookmarks to {OUTPUT_HTML}")
    print(f"  File size: {OUTPUT_HTML.stat().st_size / 1024:.1f} KB")

if __name__ == "__main__":
    export_bookmarks()
