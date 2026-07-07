# Cloudflare estate + authorization model (glw907 account)

Workstation-wide reference, loaded by any project. Account `120c269ad6d3dfbe6d63a0bb53758ca0`.
**Values-free by rule** (this file is worth reading in any repo, some public): it records what
EXISTS and HOW to reach it, never a secret's value. Regenerate the live lists with the commands
at the foot; treat the snapshot below as orientation, verify before acting.

## Authorization: how each thing is reached non-interactively

- **Cloudflare API / Wrangler**: `CLOUDFLARE_API_TOKEN` in `~/.bashrc` (wrangler picks it up;
  `curl -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN"` for the REST API). Full account access
  per the workstation CLAUDE.md: zones, DNS, Workers, Access, D1, R2. The Cloudflare MCP plugin's
  token is READ-ONLY for Access/Workers-domain writes; use `curl` with the bashrc token for those
  writes.
- **Worker secrets are WRITE-ONLY**: `wrangler secret list` returns NAMES, never values; a value
  set with `wrangler secret put` cannot be read back. To learn a secret's value you need its
  origin store, not the worker.
- **Access-protected sites (ASC dev/staging)**: the service token in `~/.local/secrets`
  (`ASC_ACCESS_CLIENT_ID` / `ASC_ACCESS_CLIENT_SECRET`), sent as `CF-Access-Client-Id` /
  `CF-Access-Client-Secret` headers. Full recipe: the cairn `asc-cloudflare-access` memory.
- **The encrypted registry** `~/.dotfiles/secrets/values.age` and `~/.local/secrets`: the
  workstation's own secrets (GitHub App key, the ASC Access service token, etc.). Stripe API keys
  are NOT here — marked "ASC-managed separately"; they live only as worker secrets + the Stripe
  dashboard.
- **1Password** (interactive, `op` CLI): the fallback for a value in no scripted store — a
  dashboard LOGIN, a rarely-needed credential. **Each `op` call can prompt a desktop approval, so
  batch them: one `op item get --format json` and parse locally, never a loop of calls.** See the
  global CLAUDE.md Secrets rule.

## What's installed (snapshot 2026-07-07; verify live before acting)

**D1 databases:** asc-club (the phase-2 club domain — members/assets/classes/events/email),
asc-ops + asc-ops-staging (the legacy ops stack, READ-ONLY during absorption, retiring),
asc-staging (the retired sveltekit shell), cairn-asc-auth (the ASC site's magic-link auth),
cairn-907-auth, cairn-ecxc-auth (+ the old cairn-ecnordic-auth pending delete), cairn-pub-auth,
cairn-pub-app, daily-tracker.

**R2 buckets:** asc-site-media (the ASC site's media library), asc-event-images (+ -staging, the
legacy ops event photos), 907-life-media, ecxc-media, cairn-pub-media.

**Workers:** asc-site (the NEW cairn ASC site, served at dev.aksailingclub.org; the apex is the
legacy site until cutover), aksailingclub-org (build worker), asc-ops (+ -dev, -staging; the
retiring dashboard), asc-handbook, asc-uptime, 907-life, ecxc, cairn-pub, eudaimonia.

**Access apps:** ASC CMS Admin (dev.aksailingclub.org/admin), ASC Staging, ASC Handbook (+ its
CMS), Ops Dashboard (ops + staging), the Ops Schema API (public, consumed cross-origin by the
handbook — do not lock it).

**asc-site worker secrets (names):** GITHUB_APP_ID, GITHUB_APP_INSTALLATION_ID,
GITHUB_APP_PRIVATE_KEY_B64. **Not yet set:** STRIPE_SECRET_KEY, STRIPE_WEBHOOK_SECRET,
TURNSTILE_SECRET_KEY, CONTACT_EMAIL (the phase-2 payment + form path adds these).

## Regenerate the live inventory

```bash
AID=120c269ad6d3dfbe6d63a0bb53758ca0; T="Authorization: Bearer $CLOUDFLARE_API_TOKEN"
curl -s -H "$T" "https://api.cloudflare.com/client/v4/accounts/$AID/d1/database"          # D1
curl -s -H "$T" "https://api.cloudflare.com/client/v4/accounts/$AID/r2/buckets"           # R2
curl -s -H "$T" "https://api.cloudflare.com/client/v4/accounts/$AID/workers/scripts"      # Workers
curl -s -H "$T" "https://api.cloudflare.com/client/v4/accounts/$AID/access/apps"          # Access
cd <a repo bound to the worker> && npx wrangler secret list                               # secret NAMES
```
