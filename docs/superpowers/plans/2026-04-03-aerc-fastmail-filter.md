# aerc Fastmail Filter Tool Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add keybindings to aerc that create Fastmail filter rules from the current message, save them locally, and optionally apply them immediately via JMAP.

**Architecture:** A bash script (`fastmail-filter`) handles three phases: (1) extract headers and present editable prompts via aerc commands, (2) append the rule to `~/.config/aerc/mailrules.json`, (3) optionally move matching Inbox messages via JMAP. The aerc keybindings use `:pipe -b` to extract headers to a temp file, then chain `:prompt` and `:menu` commands to collect user input.

**Tech Stack:** Bash, aerc commands (`:pipe`, `:prompt`, `:menu`), `jq` for JSON manipulation, `curl` for JMAP calls.

---

## File Structure

| File | Role |
|------|------|
| `~/.dotfiles/bin/.local/bin/fastmail-filter` | Main script - three subcommands: `extract`, `save`, `apply` |
| `~/.dotfiles/aerc/.config/aerc/binds.conf` | Add `ff` and `fs` keybindings |
| `~/.config/aerc/mailrules.json` | Fastmail-format rules file (local state, not in dotfiles) |

The script uses subcommands to bridge aerc's command model:
- `fastmail-filter extract from` / `extract subject` - reads piped message, writes header value to temp file
- `fastmail-filter save <criteria-type> <value> <folder>` - appends rule to mailrules.json
- `fastmail-filter apply <criteria-type> <value> <folder>` - moves matching Inbox messages via JMAP
- `fastmail-filter folders` - lists mailboxes for menu selection (via JMAP, excludes system folders)

---

### Task 1: Verify jq is available

**Files:** None

- [ ] **Step 1: Check jq is installed**

Run: `which jq && jq --version`

If missing, install:

```bash
sudo -A apt install -y jq
```

- [ ] **Step 2: Verify JMAP access works**

```bash
source ~/.local/secrets && curl -s -H "Authorization: Bearer $FASTMAIL_API_TOKEN" \
  https://api.fastmail.com/jmap/session | jq -r '.primaryAccounts["urn:ietf:params:jmap:mail"]'
```

Expected: `u74694077`

---

### Task 2: Create the `fastmail-filter` script - `extract` subcommand

**Files:**
- Create: `~/.dotfiles/bin/.local/bin/fastmail-filter`

- [ ] **Step 1: Create the script with extract subcommand**

```bash
#!/usr/bin/env bash
# fastmail-filter: Create Fastmail filter rules from aerc
# Subcommands: extract, save, apply, folders

set -euo pipefail

RULES_FILE="$HOME/.config/aerc/mailrules.json"
TMPDIR="${TMPDIR:-/tmp}"
EXTRACT_FILE="$TMPDIR/fastmail-filter-extract"

cmd_extract() {
    local type="$1"
    local headers
    headers=$(cat)

    local value
    case "$type" in
        from)
            # Extract email address from From header
            value=$(echo "$headers" | grep -i '^From:' | head -1 | sed 's/^[Ff]rom:[[:space:]]*//' | grep -oP '<\K[^>]+>' || echo "$headers" | grep -i '^From:' | head -1 | sed 's/^[Ff]rom:[[:space:]]*//' | tr -d '[:space:]')
            ;;
        subject)
            value=$(echo "$headers" | grep -i '^Subject:' | head -1 | sed 's/^[Ss]ubject:[[:space:]]*//')
            ;;
        *)
            echo "Unknown extract type: $type" >&2
            exit 1
            ;;
    esac

    echo "$value" > "$EXTRACT_FILE"
}

case "${1:-}" in
    extract) shift; cmd_extract "$@" ;;
    *) echo "Usage: fastmail-filter {extract|save|apply|folders} ..." >&2; exit 1 ;;
esac
```

- [ ] **Step 2: Make it executable**

```bash
chmod +x ~/.dotfiles/bin/.local/bin/fastmail-filter
```

- [ ] **Step 3: Stow and verify**

```bash
cd ~/.dotfiles && stow -R bin && which fastmail-filter
```

Expected: `/home/glw907/.local/bin/fastmail-filter`

- [ ] **Step 4: Test extract from with a sample message**

```bash
echo -e "From: Test User <test@example.com>\nSubject: Hello World\nDate: Thu, 03 Apr 2026" | fastmail-filter extract from
cat /tmp/fastmail-filter-extract
```

Expected: `test@example.com`

- [ ] **Step 5: Test extract subject**

```bash
echo -e "From: Test User <test@example.com>\nSubject: Hello World\nDate: Thu, 03 Apr 2026" | fastmail-filter extract subject
cat /tmp/fastmail-filter-extract
```

Expected: `Hello World`

- [ ] **Step 6: Test extract from with bare address (no angle brackets)**

```bash
echo -e "From: test@example.com\nSubject: Test" | fastmail-filter extract from
cat /tmp/fastmail-filter-extract
```

Expected: `test@example.com`

- [ ] **Step 7: Commit**

```bash
cd ~/.dotfiles
git add bin/.local/bin/fastmail-filter
git commit -m "Add fastmail-filter script with extract subcommand"
```

---

### Task 3: Add `folders` subcommand

**Files:**
- Modify: `~/.dotfiles/bin/.local/bin/fastmail-filter`

- [ ] **Step 1: Add folders subcommand to the script**

Add `cmd_folders` function before the `case` dispatch, and add `folders` to the dispatch:

```bash
EXCLUDED_FOLDERS="Inbox|Sent|Drafts|Outbox|Trash|Spam|Archive"

cmd_folders() {
    local account_id api_url
    account_id=$(curl -s -H "Authorization: Bearer $FASTMAIL_API_TOKEN" \
        https://api.fastmail.com/jmap/session | jq -r '.primaryAccounts["urn:ietf:params:jmap:mail"]')
    api_url="https://api.fastmail.com/jmap/api/"

    curl -s -X POST "$api_url" \
        -H "Authorization: Bearer $FASTMAIL_API_TOKEN" \
        -H "Content-Type: application/json" \
        -d "{
            \"using\": [\"urn:ietf:params:jmap:core\", \"urn:ietf:params:jmap:mail\"],
            \"methodCalls\": [[\"Mailbox/get\", {\"accountId\": \"$account_id\", \"properties\": [\"name\", \"role\"]}, \"0\"]]
        }" | jq -r '.methodResponses[0][1].list[] | select(.role == null or (.name | test("^('"$EXCLUDED_FOLDERS"')$") | not)) | .name' | sort
}
```

Update dispatch:

```bash
case "${1:-}" in
    extract) shift; cmd_extract "$@" ;;
    folders) cmd_folders ;;
    *) echo "Usage: fastmail-filter {extract|save|apply|folders} ..." >&2; exit 1 ;;
esac
```

- [ ] **Step 2: Test folders subcommand**

```bash
source ~/.local/secrets && fastmail-filter folders
```

Expected: sorted list of mailbox names excluding Inbox, Sent, Drafts, etc.

- [ ] **Step 3: Commit**

```bash
cd ~/.dotfiles
git add bin/.local/bin/fastmail-filter
git commit -m "Add folders subcommand to fastmail-filter"
```

---

### Task 4: Add `save` subcommand

**Files:**
- Modify: `~/.dotfiles/bin/.local/bin/fastmail-filter`

- [ ] **Step 1: Add save subcommand**

Add `cmd_save` function:

```bash
cmd_save() {
    local criteria_type="$1"
    local value="$2"
    local folder="$3"
    local now
    now=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    local search
    case "$criteria_type" in
        from) search="from:$value" ;;
        subject) search="subject:$value" ;;
    esac

    local name="$search -> $folder"

    local new_rule
    new_rule=$(jq -n \
        --arg name "$name" \
        --arg search "$search" \
        --arg fileIn "$folder" \
        --arg now "$now" \
        '{
            name: $name,
            search: $search,
            fileIn: $fileIn,
            skipInbox: true,
            stop: true,
            combinator: "all",
            markRead: false,
            markFlagged: false,
            markSpam: false,
            discard: false,
            conditions: null,
            redirectTo: null,
            snoozeUntil: null,
            showNotification: false,
            previousFileInName: null,
            created: $now,
            updated: $now
        }')

    # Append to rules file
    if [ -f "$RULES_FILE" ]; then
        jq --argjson rule "$new_rule" '. + [$rule]' "$RULES_FILE" > "$RULES_FILE.tmp" \
            && mv "$RULES_FILE.tmp" "$RULES_FILE"
    else
        echo "[$new_rule]" | jq '.' > "$RULES_FILE"
    fi

    echo "$name"
}
```

Update dispatch:

```bash
case "${1:-}" in
    extract) shift; cmd_extract "$@" ;;
    folders) cmd_folders ;;
    save) shift; cmd_save "$@" ;;
    *) echo "Usage: fastmail-filter {extract|save|apply|folders} ..." >&2; exit 1 ;;
esac
```

- [ ] **Step 2: Test save subcommand**

```bash
# Back up current rules
cp ~/.config/aerc/mailrules.json ~/.config/aerc/mailrules.json.bak

fastmail-filter save from "test@example.com" "Notifications"
jq '.' ~/.config/aerc/mailrules.json | tail -20
```

Expected: new rule appended with `"name": "from:test@example.com -> Notifications"`

- [ ] **Step 3: Verify JSON is valid and rule count increased**

```bash
jq length ~/.config/aerc/mailrules.json
```

Expected: `3` (2 existing + 1 new)

- [ ] **Step 4: Restore backup**

```bash
mv ~/.config/aerc/mailrules.json.bak ~/.config/aerc/mailrules.json
```

- [ ] **Step 5: Commit**

```bash
cd ~/.dotfiles
git add bin/.local/bin/fastmail-filter
git commit -m "Add save subcommand to fastmail-filter"
```

---

### Task 5: Add `apply` subcommand

**Files:**
- Modify: `~/.dotfiles/bin/.local/bin/fastmail-filter`

- [ ] **Step 1: Add apply subcommand**

Add `cmd_apply` function:

```bash
cmd_apply() {
    local criteria_type="$1"
    local value="$2"
    local folder="$3"

    local account_id api_url
    account_id=$(curl -s -H "Authorization: Bearer $FASTMAIL_API_TOKEN" \
        https://api.fastmail.com/jmap/session | jq -r '.primaryAccounts["urn:ietf:params:jmap:mail"]')
    api_url="https://api.fastmail.com/jmap/api/"

    # Get Inbox and destination mailbox IDs
    local mailboxes
    mailboxes=$(curl -s -X POST "$api_url" \
        -H "Authorization: Bearer $FASTMAIL_API_TOKEN" \
        -H "Content-Type: application/json" \
        -d "{
            \"using\": [\"urn:ietf:params:jmap:core\", \"urn:ietf:params:jmap:mail\"],
            \"methodCalls\": [[\"Mailbox/get\", {\"accountId\": \"$account_id\", \"properties\": [\"name\", \"role\"]}, \"0\"]]
        }")

    local inbox_id
    inbox_id=$(echo "$mailboxes" | jq -r '.methodResponses[0][1].list[] | select(.role == "inbox") | .id')

    local dest_id
    dest_id=$(echo "$mailboxes" | jq -r --arg name "$folder" '.methodResponses[0][1].list[] | select(.name == $name) | .id')

    # Create folder if it doesn't exist
    if [ -z "$dest_id" ]; then
        local create_resp
        create_resp=$(curl -s -X POST "$api_url" \
            -H "Authorization: Bearer $FASTMAIL_API_TOKEN" \
            -H "Content-Type: application/json" \
            -d "{
                \"using\": [\"urn:ietf:params:jmap:core\", \"urn:ietf:params:jmap:mail\"],
                \"methodCalls\": [[\"Mailbox/set\", {\"accountId\": \"$account_id\", \"create\": {\"new\": {\"name\": \"$folder\"}}}, \"0\"]]
            }")
        dest_id=$(echo "$create_resp" | jq -r '.methodResponses[0][1].created.new.id')
    fi

    # Build search filter
    local filter
    case "$criteria_type" in
        from) filter="{\"inMailbox\": \"$inbox_id\", \"from\": \"$value\"}" ;;
        subject) filter="{\"inMailbox\": \"$inbox_id\", \"subject\": \"$value\"}" ;;
    esac

    # Query matching messages
    local query_resp
    query_resp=$(curl -s -X POST "$api_url" \
        -H "Authorization: Bearer $FASTMAIL_API_TOKEN" \
        -H "Content-Type: application/json" \
        -d "{
            \"using\": [\"urn:ietf:params:jmap:core\", \"urn:ietf:params:jmap:mail\"],
            \"methodCalls\": [[\"Email/query\", {\"accountId\": \"$account_id\", \"filter\": $filter}, \"0\"]]
        }")

    local email_ids
    email_ids=$(echo "$query_resp" | jq -r '.methodResponses[0][1].ids[]' 2>/dev/null)

    if [ -z "$email_ids" ]; then
        echo "0 messages moved"
        return 0
    fi

    # Build update object: for each email, remove Inbox and add destination
    local update_obj="{}"
    local count=0
    while IFS= read -r eid; do
        update_obj=$(echo "$update_obj" | jq \
            --arg eid "$eid" \
            --arg inbox "$inbox_id" \
            --arg dest "$dest_id" \
            '. + {($eid): {"mailboxIds/\($inbox)": null, "mailboxIds/\($dest)": true}}')
        count=$((count + 1))
    done <<< "$email_ids"

    # Move messages
    curl -s -X POST "$api_url" \
        -H "Authorization: Bearer $FASTMAIL_API_TOKEN" \
        -H "Content-Type: application/json" \
        -d "{
            \"using\": [\"urn:ietf:params:jmap:core\", \"urn:ietf:params:jmap:mail\"],
            \"methodCalls\": [[\"Email/set\", {\"accountId\": \"$account_id\", \"update\": $update_obj}, \"0\"]]
        }" > /dev/null

    echo "$count messages moved to $folder"
}
```

Update dispatch:

```bash
case "${1:-}" in
    extract) shift; cmd_extract "$@" ;;
    folders) cmd_folders ;;
    save) shift; cmd_save "$@" ;;
    apply) shift; cmd_apply "$@" ;;
    *) echo "Usage: fastmail-filter {extract|save|apply|folders} ..." >&2; exit 1 ;;
esac
```

- [ ] **Step 2: Test apply with a dry query (don't actually move)**

Test the query portion only to verify it finds messages. Pick a known sender in your Inbox:

```bash
source ~/.local/secrets
ACCOUNT_ID="u74694077"
INBOX_ID=$(curl -s -X POST https://api.fastmail.com/jmap/api/ \
    -H "Authorization: Bearer $FASTMAIL_API_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{
        \"using\": [\"urn:ietf:params:jmap:core\", \"urn:ietf:params:jmap:mail\"],
        \"methodCalls\": [[\"Mailbox/get\", {\"accountId\": \"$ACCOUNT_ID\", \"properties\": [\"name\", \"role\"]}, \"0\"]]
    }" | jq -r '.methodResponses[0][1].list[] | select(.role == "inbox") | .id')

echo "Inbox ID: $INBOX_ID"

# Query for any from address you know is in Inbox - just to verify the query works
curl -s -X POST https://api.fastmail.com/jmap/api/ \
    -H "Authorization: Bearer $FASTMAIL_API_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{
        \"using\": [\"urn:ietf:params:jmap:core\", \"urn:ietf:params:jmap:mail\"],
        \"methodCalls\": [[\"Email/query\", {\"accountId\": \"$ACCOUNT_ID\", \"filter\": {\"inMailbox\": \"$INBOX_ID\", \"from\": \"noreply@example.com\"}, \"limit\": 5}, \"0\"]]
    }" | jq '.methodResponses[0][1]'
```

Expected: a response with `ids` array (may be empty if no match, but no errors)

- [ ] **Step 3: Commit**

```bash
cd ~/.dotfiles
git add bin/.local/bin/fastmail-filter
git commit -m "Add apply subcommand to fastmail-filter"
```

---

### Task 6: Add aerc keybindings

**Files:**
- Modify: `~/.dotfiles/aerc/.config/aerc/binds.conf`

The keybinding design chains aerc commands:
1. `:pipe -b` extracts headers to temp file
2. `:prompt` asks user to edit the extracted value
3. `:menu` lets user pick destination folder
4. `:prompt` asks "Apply now?"

aerc allows chaining commands with `:exec` and the binds.conf can specify multi-command sequences. However, the chaining needs to happen through the script itself writing aerc commands to a FIFO or by using `:exec` with callbacks.

The practical approach: use `:term` instead of `:pipe -b` so the script runs interactively inside an aerc terminal tab. The script handles all prompts itself using `read` with pre-filled defaults (via readline).

- [ ] **Step 1: Rethink interaction model**

aerc's `:prompt` cannot be chained from a piped script. Instead, the keybinding opens a `:term` pane where the script runs interactively:

- `ff` = `:pipe -b fastmail-filter extract from<Enter>:term fastmail-filter interactive from<Enter>`
- `fs` = `:pipe -b fastmail-filter extract subject<Enter>:term fastmail-filter interactive subject<Enter>`

The `interactive` subcommand reads the extracted value from the temp file, presents editable prompts using `read -e -i`, and calls `save` and `apply` internally.

- [ ] **Step 2: Add `interactive` subcommand to the script**

Add `cmd_interactive` function:

```bash
cmd_interactive() {
    local criteria_type="$1"

    # Read extracted value from temp file
    if [ ! -f "$EXTRACT_FILE" ]; then
        echo "Error: No extracted value found. Use extract first."
        read -rp "Press Enter to close..."
        exit 1
    fi
    local default_value
    default_value=$(cat "$EXTRACT_FILE")

    # Prompt 1: Edit match value
    echo "Filter by $criteria_type"
    read -r -e -i "$default_value" -p "Match: " value
    if [ -z "$value" ]; then
        echo "Cancelled."
        sleep 1
        exit 0
    fi

    # Prompt 2: Choose destination folder
    echo ""
    echo "Available folders:"
    local folders
    if folders=$(cmd_folders 2>/dev/null); then
        echo "$folders" | nl -ba
        echo ""
        read -r -e -p "Folder (name or number, or type new): " folder_input
    else
        echo "(Could not fetch folders - type folder name manually)"
        echo ""
        read -r -e -p "Folder: " folder_input
    fi

    if [ -z "$folder_input" ]; then
        echo "Cancelled."
        sleep 1
        exit 0
    fi

    # If user entered a number, resolve to folder name
    local folder
    if [[ "$folder_input" =~ ^[0-9]+$ ]] && [ -n "${folders:-}" ]; then
        folder=$(echo "$folders" | sed -n "${folder_input}p")
        if [ -z "$folder" ]; then
            folder="$folder_input"
        fi
    else
        folder="$folder_input"
    fi

    # Save the rule
    local rule_name
    rule_name=$(cmd_save "$criteria_type" "$value" "$folder")
    echo ""
    echo "Saved: $rule_name"

    # Prompt 3: Apply now?
    if [ -n "${FASTMAIL_API_TOKEN:-}" ]; then
        echo ""
        read -r -p "Apply now? [y/N] " apply
        if [[ "$apply" =~ ^[Yy]$ ]]; then
            local result
            result=$(cmd_apply "$criteria_type" "$value" "$folder")
            echo "$result"
        fi
    fi

    echo ""
    echo "Done. Import ~/.config/aerc/mailrules.json into Fastmail to sync."
    sleep 2
}
```

Update dispatch:

```bash
case "${1:-}" in
    extract) shift; cmd_extract "$@" ;;
    folders) cmd_folders ;;
    save) shift; cmd_save "$@" ;;
    apply) shift; cmd_apply "$@" ;;
    interactive) shift; cmd_interactive "$@" ;;
    *) echo "Usage: fastmail-filter {extract|save|apply|folders|interactive} ..." >&2; exit 1 ;;
esac
```

- [ ] **Step 3: Add keybindings to binds.conf**

Add after the existing `s = :split<Enter>` line in the `[messages]` section:

```
ff = :pipe -b fastmail-filter extract from<Enter>:term fastmail-filter interactive from<Enter>
fs = :pipe -b fastmail-filter extract subject<Enter>:term fastmail-filter interactive subject<Enter>
```

- [ ] **Step 4: Stow both changes**

```bash
cd ~/.dotfiles && stow -R bin && stow -R aerc
```

- [ ] **Step 5: Commit**

```bash
cd ~/.dotfiles
git add bin/.local/bin/fastmail-filter aerc/.config/aerc/binds.conf
git commit -m "Add interactive subcommand and aerc keybindings for fastmail-filter"
```

---

### Task 7: Integration test in aerc

**Files:** None (testing only)

- [ ] **Step 1: Back up mailrules.json**

```bash
cp ~/.config/aerc/mailrules.json ~/.config/aerc/mailrules.json.bak
```

- [ ] **Step 2: Launch aerc in tmux and test ff keybinding**

```bash
tmux kill-session -t test 2>/dev/null
tmux new-session -d -s test -x 140 -y 40 'mail'
sleep 8
```

Navigate to Inbox, select a message, press `ff`:

```bash
# Select first message and press ff
tmux send-keys -t test 'g' && sleep 1
tmux send-keys -t test 'ff' && sleep 3
tmux capture-pane -t test -p
```

Expected: a terminal tab opens showing "Filter by from" with the sender's address pre-filled.

- [ ] **Step 3: Complete the interactive flow**

```bash
# Accept the default value
tmux send-keys -t test Enter && sleep 3
tmux capture-pane -t test -p
```

Expected: folder list displayed with numbered options.

```bash
# Type a folder name and press Enter
tmux send-keys -t test 'Notifications' Enter && sleep 2
tmux capture-pane -t test -p
```

Expected: "Saved: from:... -> Notifications" and "Apply now? [y/N]" prompt.

```bash
# Decline apply
tmux send-keys -t test 'n' Enter && sleep 3
```

- [ ] **Step 4: Verify the rule was saved**

```bash
jq '.' ~/.config/aerc/mailrules.json | tail -20
jq length ~/.config/aerc/mailrules.json
```

Expected: 3 rules (2 original + 1 new), new rule has correct naming pattern.

- [ ] **Step 5: Clean up**

```bash
tmux kill-session -t test 2>/dev/null
mv ~/.config/aerc/mailrules.json.bak ~/.config/aerc/mailrules.json
```

- [ ] **Step 6: Commit any fixes needed**

If any issues were found and fixed during testing:

```bash
cd ~/.dotfiles
git add bin/.local/bin/fastmail-filter aerc/.config/aerc/binds.conf
git commit -m "Fix issues found during integration testing of fastmail-filter"
```

---

### Task 8: Update documentation

**Files:**
- Modify: `~/.claude/docs/aerc-setup.md`
- Modify: `~/Documents/aerc-quick-reference.md`

- [ ] **Step 1: Add filter tool section to aerc-setup.md**

Add a new section after the existing configuration sections:

```markdown
## Fastmail Filter Tool

Keybinding-driven tool for creating Fastmail mail filter rules from
within aerc. Rules are saved locally and synced via manual JSON import.

### Components

- **Script**: `~/.local/bin/fastmail-filter` (bash, subcommands: extract, save, apply, folders, interactive)
- **Rules file**: `~/.config/aerc/mailrules.json` (Fastmail export format, not tracked in dotfiles)
- **Keybindings**: `ff` (filter by From), `fs` (filter by Subject) in `[messages]` section

### Workflow

1. Press `ff` or `fs` from the Inbox message list
2. Edit the pre-filled match value (From address or Subject)
3. Select destination folder from numbered list or type a new name
4. Rule is appended to `~/.config/aerc/mailrules.json`
5. Optionally apply immediately (moves matching Inbox messages via JMAP)

### Syncing to Fastmail

Import `~/.config/aerc/mailrules.json` at Fastmail Settings > Filters
& Rules > Import. After import, re-export to refresh the local baseline.

### Rule naming

Auto-generated: `<search> -> <folder>` (e.g. `from:user@example.com -> Notifications`)

### Dependencies

- `jq` for JSON manipulation
- `$FASTMAIL_API_TOKEN` for folder listing and immediate apply
```

- [ ] **Step 2: Add filter keybindings to aerc-quick-reference.md**

Add a new "Filter" subsection in the "Message List > Actions" area, after the existing actions table:

```markdown
### Filter (create Fastmail rule)

| Key | Action |
|-----|--------|
| `ff` | Filter by From address |
| `fs` | Filter by Subject |
```

- [ ] **Step 3: Regenerate the quick reference PDF**

```bash
aerc-quickref-pdf
```

- [ ] **Step 4: Commit documentation updates**

```bash
cd ~/.dotfiles
git add -f docs/  # aerc-setup.md is in claude dotfiles
```

```bash
git add ~/Documents/aerc-quick-reference.md ~/Documents/aerc-quick-reference.pdf
```

Determine the correct paths (aerc-setup.md is a symlink from dotfiles, quick-reference is standalone):

```bash
cd ~/.dotfiles
git add claude/.claude/docs/aerc-setup.md
git commit -m "Document fastmail-filter tool in aerc setup and quick reference"
```

For the quick reference (not in dotfiles):

```bash
cd ~/Documents
# If this is tracked in a repo, commit there. Otherwise just note the update.
```
