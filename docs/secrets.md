# Secrets Management

How workstation secrets are stored, synced, and accessed.

## Architecture

```
1Password (source of truth)
    |
    v
secrets/values.age (encrypted, safe to commit)
    |
    v  scripts/secrets/sync.sh
    |
    +---> ~/.local/secrets (local env vars, sourced by .bashrc)
    +---> Cloudflare Workers (per-worker secrets via wrangler)
```

- **1Password** holds all secret values and the age encryption key
- **values.age** is the encrypted bundle committed to this repo
- **sync.sh** decrypts via 1Password CLI and pushes to targets
- **~/.local/secrets** is chmod 600, gitignored, sourced by `.bashrc`
- Decryption happens in `/dev/shm` (tmpfs) -- nothing touches disk

## Sync Script

```bash
scripts/secrets/sync.sh               # Decrypt + push local + all workers
scripts/secrets/sync.sh --local       # Local secrets only
scripts/secrets/sync.sh --worker NAME # Single worker only
scripts/secrets/sync.sh --dry-run     # Show what would happen
scripts/secrets/sync.sh --verify      # Diff targets vs registry
```

Prerequisite: 1Password desktop app running + CLI authenticated (`eval $(op signin)`).

## What Goes Where

| Type | Location |
|------|----------|
| Sensitive tokens (API keys, passwords) | `~/.local/secrets` via sync.sh |
| Non-sensitive config (paths, emails, model names) | `.bashrc` as plain exports |
| Worker secrets | Pushed by sync.sh via `wrangler secret put` |
| Sudo password | 1Password only -- fetched live by `claude-askpass` |

## Sudo Helper

`claude-askpass` lets Claude Code run `sudo -A` without interactive prompts:

1. `claude-sudo-setup` fetches the sudo password from 1Password and caches it to `~/.cache/sudo-password.age`
2. `claude-askpass` decrypts and supplies it when `sudo -A` is invoked
3. The `.bashrc` wrapper clears the cache after each `claude` session

Prerequisite: 1Password desktop app unlocked, CLI integration enabled in Settings > Developer.

## Secret Registry

See [secrets/registry.md](../secrets/registry.md) for the full inventory: which secrets exist, what they grant, where they're routed, and how to rotate them.
