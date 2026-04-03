# aerc Fastmail Filter Tool

Create mail filter rules from within aerc and sync them to Fastmail via JSON import.

## Problem

When triaging mail in aerc, there's no way to quickly create a Fastmail filter rule for a message. You have to leave the terminal, open Fastmail settings, and manually create the rule. This tool captures filter intent inline and produces a Fastmail-compatible JSON file for import.

## Components

- `~/.local/bin/fastmail-filter` - Bash script called from aerc keybindings
- `~/.config/aerc/mailrules.json` - Fastmail-format rules file (the single source of truth)
- Keybindings in `~/.config/aerc/binds.conf`

## Keybindings

In the `[messages]` section of `binds.conf`:

- `ff` - filter by From address
- `fs` - filter by Subject

Both pipe the current message headers to `fastmail-filter`.

## Interaction Flow

1. User presses `ff` or `fs` from Inbox
2. aerc pipes message headers to `fastmail-filter from` or `fastmail-filter subject`
3. Script extracts the From address or Subject from headers
4. **Prompt 1**: Pre-filled with extracted value, user can edit
5. **Prompt 2**: Destination folder with tab-completion against filtered mailbox list (excludes Inbox, Sent, Drafts, Outbox, Trash, Spam, Archive). User can also type a new folder name.
6. Script appends the new rule to `~/.config/aerc/mailrules.json`
7. **Prompt 3**: "Apply now? [y/N]" - if yes, uses JMAP to find matching messages in Inbox and move them to the destination folder
8. Confirmation message displayed in aerc status bar

## Rule Format

New rules are appended to `mailrules.json` in Fastmail's native export format:

```json
{
  "name": "from:user@example.com -> Notifications",
  "search": "from:user@example.com",
  "fileIn": "Notifications",
  "skipInbox": true,
  "stop": true,
  "combinator": "all",
  "markRead": false,
  "markFlagged": false,
  "markSpam": false,
  "discard": false,
  "conditions": null,
  "redirectTo": null,
  "snoozeUntil": null,
  "showNotification": false,
  "previousFileInName": null,
  "created": "2026-04-03T14:30:00Z",
  "updated": "2026-04-03T14:30:00Z"
}
```

### Search format mapping

- From address: `"search": "from:user@example.com"`
- Subject contains: `"search": "subject:some text"`

### Rule naming

Auto-generated from the search and destination: `<search> -> <folder>`

Examples:
- `from:user@example.com -> Notifications`
- `subject:weekly digest -> Archive`
- `header:Fastmail-MaskedEmail -> Notifications`

## Immediate Apply

When the user opts to apply the filter immediately, the script:

1. Calls JMAP `Mailbox/get` to resolve the Inbox and destination mailbox IDs
2. Calls `Email/query` with the filter's search criteria scoped to the Inbox mailbox
3. Calls `Email/set` to update matching messages' `mailboxIds` (remove Inbox, add destination)
4. Reports the number of messages moved in the aerc status bar

If the destination folder doesn't exist yet, the script creates it via `Mailbox/set` before moving messages.

Requires `$FASTMAIL_API_TOKEN` to be set. If unavailable, the "Apply now?" prompt is skipped.

## Syncing to Fastmail

Manual import: Settings > Filters & Rules > Import, select `~/.config/aerc/mailrules.json`.

After import, re-export from Fastmail to refresh the local baseline (Fastmail may reorder or normalize fields). Save the export to `~/.config/aerc/mailrules.json`.

## Mailbox List for Tab Completion

The script queries the user's Fastmail mailboxes via JMAP `Mailbox/get` (using `$FASTMAIL_API_TOKEN`) and filters out system folders: Inbox, Sent, Drafts, Outbox, Trash, Spam, Archive. The filtered list is cached locally for tab-completion performance.

If the JMAP call fails (e.g. no token), the script falls back to a hardcoded list of common folders or lets the user type freely.

## Dotfiles Integration

- `fastmail-filter` script: `~/.dotfiles/bin/.local/bin/fastmail-filter`
- `binds.conf` changes: `~/.dotfiles/aerc/.config/aerc/binds.conf`
- `mailrules.json` is local state, not tracked in dotfiles

## Constraints

- Fastmail does not expose Sieve/filter management through its public JMAP API
- Rules are synced via manual JSON import/export in Fastmail's web UI
- The tool only creates "move to folder" rules (skipInbox + fileIn)
- Match criteria: from address (exact) or subject (contains)
