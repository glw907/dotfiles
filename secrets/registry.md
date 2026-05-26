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

## How to Add / Update a Secret

**Use `scripts/secrets/secret-set.sh` — do not leave loose key files on disk.** It edits
`values.age` (the source of truth), verifies the re-encrypted blob, and regenerates
`~/.local/secrets`. Then document the secret below and, for Workers, add it to the routing
table in `sync.sh`.

```bash
secret-set.sh NAME --value 'literal'    # single-line value (token, id)
secret-set.sh NAME --file PATH          # raw file contents (must be single-line)
secret-set.sh NAME --b64-file PATH      # base64-encode a file → one line (PEMs / multi-line)
secret-set.sh --sync                    # just regenerate ~/.local/secrets
secret-set.sh --dry-run NAME --value …  # preview, write nothing
```

`values.age` is **line-parsed** (`KEY=value`, one per line), so multi-line material (e.g. an
RSA PEM) **must** be stored base64-encoded via `--b64-file`; decode at the consumer
(`atob()` in a Worker, `base64 -d` in shell). Re-encryption targets the single recipient
`age197mcd2m3z90t49n9t5v3ujjntw7krfkw5y9sjfc545v28qvezugshg7jgk`.

**Authenticate once per session.** This box uses 1Password **desktop-app integration** —
there is no reusable CLI session token (`op signin --raw` returns nothing). So `secret-set.sh`
fetches the age key from 1Password on first use, caches it in tmpfs
(`/dev/shm/.age-key-$UID`, chmod 600), and reuses it for the rest of the session — only the
first call prompts. The cache is wiped on reboot, when the `claude` shell function exits, or
via `scripts/secrets/secret-session-clear.sh`. (`sync.sh` still fetches+shreds its own key
per run; for multi-step manual work, prefer `secret-set.sh` to avoid repeat prompts.)

To rotate: regenerate the source credential, then `secret-set.sh NAME …` overwrites it.

---

## Master Routing Table

(Worker names: 907-life's worker is `907-life`; ecnordic.ski's worker is `ecnordic`.)

| Secret              | Local (~/.local/secrets) | 907-life Worker | ecnordic Worker |
|---------------------|--------------------------|-----------------|-----------------|
| CLOUDFLARE_API_TOKEN | ✓                       | ✓               | —               |
| CF_ZT_TOKEN         | ✓                        | —               | —               |
| CF_ACCESS_CLIENT_SECRET | ✓                   | —               | —               |
| ANTHROPIC_API_KEY   | ✓                        | —               | —               |
| CMS_BOT_PAT         | ✓                        | —               | —               |
| RESEND_API_KEY      | ✓                        | ✓               | —               |
| FASTMAIL_API_TOKEN  | ✓                        | —               | —               |
| GITHUB_APP_ID       | ✓                        | ✓               | ✓               |
| GITHUB_APP_INSTALLATION_ID | ✓                 | ✓               | ✓               |
| GITHUB_APP_PRIVATE_KEY_B64 | ✓                 | ✓               | ✓               |

> `GITHUB_APP_*` are the cairn-cms committing identity (GitHub App, App ID 3847496,
> Installation `135372268` — single install on glw907, both repos selected). **Both the `ecnordic`
> and `907-life` workers are wired into `sync.sh` and pushed (ecnordic go-live 2026-05-25, 907-life
> go-live 2026-05-26);** `sync.sh --worker 907-life` re-pushes the shared App secrets reproducibly.
>
> **Per-site, NOT in this registry:** each cairn site's `MAGIC_LINK_SECRET` + `SESSION_SECRET`
> are worker-only (set directly via `wrangler secret put`, freshly generated per site so sessions
> don't cross sites — the locked "no cross-site SSO" decision). Rotatable: regenerate + re-put to
> invalidate all active links/sessions. `sync.sh --verify` will list them as "extra" on both the
> ecnordic and 907-life workers — expected (same as CONTACT_EMAIL / TURNSTILE_SECRET_KEY).

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

### GITHUB_APP_ID / GITHUB_APP_INSTALLATION_ID / GITHUB_APP_PRIVATE_KEY_B64
- **Grants**: cairn-cms GitHub App — `Contents: Read & write` on glw907/ecnordic-ski and
  glw907/907-life. Used to mint short-lived installation tokens that commit markdown to
  `main` (committer = `cairn-cms[bot]`, author = the editor).
- **App ID**: 3847496 (GitHub App "cairn-cms", owner glw907)
- **Key encoding**: `GITHUB_APP_PRIVATE_KEY_B64` is the RSA PEM base64-encoded single-line
  (the registry is line-parsed; multi-line PEM would break it). Decode with `atob()` in the
  Worker before handing to `@octokit/auth-app`.
- **Used by**: cairn-cms admin Worker (ecnordic + 907-life) — wired in Pass A.
- **Rotate at**: https://github.com/settings/apps → cairn-cms → Private keys (generate new,
  base64 it, update values.age, re-run sync.sh). Revoke old key in the same screen.

---

## 907-life Worker — Existing Secrets Audit

Secrets currently set on the worker (via `wrangler secret list --name 907-life`):
- CONTACT_EMAIL — not managed by this registry (worker-only config)
- RESEND_API_KEY — managed here
- TURNSTILE_SECRET_KEY — not managed by this registry (worker-only config)
- GITHUB_APP_ID / GITHUB_APP_INSTALLATION_ID / GITHUB_APP_PRIVATE_KEY_B64 — managed here (cairn admin, go-live 2026-05-26)
- MAGIC_LINK_SECRET / SESSION_SECRET — worker-only (per-site cairn HMAC keys, set directly via `wrangler secret put`)

Secrets this registry will set:
- CLOUDFLARE_API_TOKEN — added by sync.sh
- RESEND_API_KEY — updated by sync.sh
- GITHUB_APP_ID / GITHUB_APP_INSTALLATION_ID / GITHUB_APP_PRIVATE_KEY_B64 — pushed by sync.sh

> The `--verify` mode will report CONTACT_EMAIL, TURNSTILE_SECRET_KEY, MAGIC_LINK_SECRET, and
> SESSION_SECRET as "extra" (present on worker but not in registry). This is expected — they're
> managed elsewhere (worker-only config / per-site HMAC keys).

---

## age Key Details

- **Algorithm**: X25519 (age native)
- **Public key**: age197mcd2m3z90t49n9t5v3ujjntw7krfkw5y9sjfc545v28qvezugshg7jgk
- **Private key storage**: 1Password > Private vault > "Workstation age encryption key"
- **No persistent key file on disk** — private key is fetched from 1Password at decrypt time
