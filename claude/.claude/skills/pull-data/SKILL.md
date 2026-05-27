---
name: pull-data
description: >
  Use when the user says "/pull-data", "pull production data",
  "sync from remote", or wants to replace local data with production.
  Manual only — never run automatically at session start.
---

# Pull Data

Replace the local D1 database with a fresh copy of production data.
Automatically backs up local data first as a recovery point.

**Manual only.** Never run this automatically. The user invokes it
when they want a fresh production copy.

## Usage

`/pull-data`: backs up local data, then pulls remote data into the local DB.

## Steps

1. **Back up local database** (automatic safety net):

The pull script saves a local backup to
`db/backups/local-pre-pull-<timestamp>.sql` before clearing any data.

2. **Run the pull script**:

```bash
npm run pull
```

3. Report what was synced (the script prints row counts).

## Recovery

If local data was lost, restore from the most recent backup:

```bash
LOCAL_DB=$(find .wrangler/state/v3/d1/ -name "*.sqlite" | head -1)
sqlite3 "$LOCAL_DB" < db/backups/local-pre-pull-<timestamp>.sql
```

## Notes

- First-time setup: if there's no local DB, run `npm run setup` instead.
- The pull script lives at `scripts/pull-remote-data.sh`.
- Backups accumulate in `db/backups/`. Clean up old ones periodically.
