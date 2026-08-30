#!/usr/bin/env bash
# Surface shell-environment drift for Claude context: exports, aliases, and
# shell functions only. The machine inventory lives in CLAUDE.md; this exists
# to catch what changed since that file was last updated.

echo "## Shell Environment (drift check; canonical inventory is CLAUDE.md)"
echo ""

if [[ -f ~/.bash_aliases ]]; then
    echo "### Aliases (~/.bash_aliases)"
    echo '```bash'
    grep -E '^alias ' ~/.bash_aliases || echo "# none"
    echo '```'
    echo ""
fi

if [[ -f ~/.bashrc ]]; then
    echo "### Exports and functions (~/.bashrc)"
    echo '```bash'
    grep -E '^export |^[a-zA-Z_][a-zA-Z0-9_-]*\(\)' ~/.bashrc \
        | sed -E 's/^(export[[:space:]]+[A-Za-z_][A-Za-z0-9_]*)=.*/\1=<value redacted>/' \
        || echo "# none"
    echo '```'
    echo ""
fi

if [[ -f ~/.profile ]] && grep -q '^export' ~/.profile; then
    echo "### Exports (~/.profile)"
    echo '```bash'
    grep '^export' ~/.profile \
        | sed -E 's/^(export[[:space:]]+[A-Za-z_][A-Za-z0-9_]*)=.*/\1=<value redacted>/'
    echo '```'
    echo ""
fi
