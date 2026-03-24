# Workstation Secrets Registry

Plaintext inventory — no secret values here. All values live in `secrets/values.age` (encrypted).

---

## How to Decrypt

1. **Authenticate 1Password CLI** (required once per session):
   ```bash
   eval $(op signin)
   ```

2. **Decrypt interactively** (for inspection):
   ```bash
   age --decrypt \
     -i <(op item get "Workstation age encryption key" --fields notesPlain --reveal \
          | sed 's/^"//;s/"$//') \
     ~/.dotfiles/secrets/values.age
   ```

3. **Run sync** (decrypt + push to local + workers):
   ```bash
   ~/.dotfiles/scripts/secrets/sync.sh
   ```

---

## Sync Script Modes

```
sync.sh               # Decrypt + push local + all workers
sync.sh --local       # Local only (no worker push)
sync.sh --worker NAME # Single worker only
sync.sh --dry-run     # Show what would happen, no changes
sync.sh --verify      # Diff targets vs registry, exits non-zero on mismatch
```

Local secrets land in `~/.local/secrets` (chmod 600, gitignored), sourced by `.bashrc`.

---

## Master Routing Table

| Secret              | Local (~/.local/secrets) | 907-life Worker |
|---------------------|--------------------------|-----------------|
| CLOUDFLARE_API_TOKEN | ✓                       | ✓               |
| CF_ZT_TOKEN         | ✓                        | —               |
| CF_ACCESS_CLIENT_SECRET | ✓                   | —               |
| ANTHROPIC_API_KEY   | ✓                        | —               |
| CMS_BOT_PAT         | ✓                        | —               |
| RESEND_API_KEY      | ✓                        | ✓               |
| FASTMAIL_API_TOKEN  | ✓                        | —               |

**1Password only** (not in values.age):
- `WORKSTATION_SUDO` — sudo password, stored as `op://Private/Workstation sudo/password`

**Out of scope** (ASC project manages separately):
- STRIPE_SECRET_KEY, STRIPE_WEBHOOK_SECRET
- DISCORD_WEBHOOK_* (four webhooks)

**Orphaned** (removed from .bashrc, DNS migrated to Cloudflare):
- CLOUDNS_AUTH_ID, CLOUDNS_AUTH_PASSWORD

**Non-secrets** (remain as plain exports in .bashrc):
- CLAUDE_CODE_SUBAGENT_MODEL, WORKSPACE_ADMIN_EMAIL, ANDROID_HOME, AGE_KEY_FILE
- NVM_DIR, GOOGLE_APPLICATION_CREDENTIALS (path only), SUDO_ASKPASS

---

## Per-Secret Scope

### CLOUDFLARE_API_TOKEN
- **Grants**: Full Cloudflare API access (DNS, Workers, Pages, Access, R2)
- **Used by**: wrangler, DNS automation scripts, all project deployments
- **Rotate at**: https://dash.cloudflare.com/profile/api-tokens

### CF_ZT_TOKEN
- **Grants**: Cloudflare Zero Trust API (Access apps, policies, identity providers)
- **Used by**: ASC ops dashboard configuration scripts
- **Rotate at**: https://dash.cloudflare.com/profile/api-tokens

### CF_ACCESS_CLIENT_SECRET
- **Grants**: Service token auth for Cloudflare Access protected apps
- **Client ID**: 355524dff8edea34539419e97c66a085.access
- **Used by**: Testing ops dashboard endpoints from CLI
- **Rotate at**: Cloudflare Access > Service Tokens dashboard

### ANTHROPIC_API_KEY
- **Grants**: Claude API access (claude-3-*, claude-sonnet-*, etc.)
- **Used by**: Claude CLI, any scripts using the Anthropic SDK
- **Rotate at**: https://console.anthropic.com/settings/keys

### CMS_BOT_PAT
- **Grants**: GitHub repository write access for CMS automation
- **Used by**: Content publish workflows, automated PR creation
- **Rotate at**: https://github.com/settings/tokens

### RESEND_API_KEY
- **Grants**: Resend transactional email API
- **Used by**: 907-life contact form worker, local email testing
- **Rotate at**: https://resend.com/api-keys

### FASTMAIL_API_TOKEN
- **Grants**: Full Fastmail JMAP access (mail, contacts, calendars, files, settings)
- **Domain**: 907.life (business plan)
- **Used by**: aerc (via `op read`), Claude Code JMAP scripting (via env var)
- **Rotate at**: Fastmail > Settings > Privacy & Security > App Passwords

---

## 907-life Worker — Existing Secrets Audit

Secrets currently set on the worker (via `wrangler secret list --name 907-life`):
- CONTACT_EMAIL — not managed by this registry (worker-only config)
- RESEND_API_KEY — managed here
- TURNSTILE_SECRET_KEY — not managed by this registry (worker-only config)

Secrets this registry will set:
- CLOUDFLARE_API_TOKEN — added by sync.sh
- RESEND_API_KEY — updated by sync.sh

> The `--verify` mode will report CONTACT_EMAIL and TURNSTILE_SECRET_KEY as "extra"
> (present on worker but not in registry). This is expected — they're managed elsewhere.

---

## age Key Details

- **Algorithm**: X25519 (age native)
- **Public key**: age197mcd2m3z90t49n9t5v3ujjntw7krfkw5y9sjfc545v28qvezugshg7jgk
- **Private key storage**: 1Password > Private vault > "Workstation age encryption key"
- **No persistent key file on disk** — private key is fetched from 1Password at decrypt time
