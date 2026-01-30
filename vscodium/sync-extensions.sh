#!/usr/bin/env bash
set -euo pipefail

# VSCodium Extension Sync Script
# Updates extensions.txt with currently installed extensions

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
EXTENSIONS_FILE="$SCRIPT_DIR/extensions.txt"

echo "📦 Syncing VSCodium extensions..."

if ! command -v codium &> /dev/null; then
    echo "❌ VSCodium not found"
    exit 1
fi

# Get current extensions and save to file
codium --list-extensions > "$EXTENSIONS_FILE"

echo "✅ Synced $(wc -l < "$EXTENSIONS_FILE") extensions to $EXTENSIONS_FILE"
echo ""
echo "Extensions:"
cat "$EXTENSIONS_FILE"
