# pings: dead-man's-switch monitoring Worker

A small Cloudflare Worker replaces healthchecks.io in the musicbox design: services ping
it after each timer run, it notices when an expected ping stops arriving, and an email
goes to Geoff. It lives on the existing estate (no new vendor), and any later service
onboards with one command. Repo: `~/Projects/pings`; worker `pings`; hostname
`pings.907.life`. Revised 2026-08-30 after adversarial review; prior-art research
(nothing maintained does push monitoring on Workers; Cloudflare has no native
cron-failure alerting, verified against the notifications catalog) settled build over
adopt, and the review drove the Durable Object architecture and the
silence-detection rules below.

Threat model, stated plainly: a ping URL is not a read-only credential — anyone holding
one can keep a dead check green forever. Ping URLs therefore carry the same sensitivity
as the monitored service's own secrets, and live only in the age store.

## Architecture: one Durable Object per check

Adopted from the `deadman` project's pattern (its code is a single-switch toy; the
pattern is right): each check is a Durable Object addressed by its slug, holding its own
state and a `storage.setAlarm(lastPing + period + grace)`. DO storage is strongly
consistent and alarms are at-least-once with retries, which deletes the whole class of
KV problems a cron-plus-KV design carries (read-modify-write races, 60-second staleness,
5-minute detection granularity, slug-scan lookups). A `*/5` cron remains for exactly two
jobs: probing pull checks and pinging the external watchdog.

- `GET|POST /ping/<slug>`: routes to the DO named by the slug. The DO records the ping,
  resets its alarm, and, if it was in alerted state, sends the recovery email inline
  before clearing the flag (single writer: only the DO touches its own state; recovery
  is immediate, not next-cron). Response 200, `Cache-Control: no-store`.
- `POST /ping/<slug>/fail`: records a failure and alerts on the transition only —
  a repeat failure while already alerted sends nothing (a systemd unit failing every
  15 minutes must not send 288 emails a weekend). POST-only so a link-scanning mail
  gateway can never trigger it.
- Anything else 404. No listing endpoint.
- Check metadata (name, kind, period, grace) lives in the DO plus a values-safe KV
  `check:<name>` record that carries NO slug, so definitions are printable. A
  `route:<name>` KV key does hold the slug (ratified deviation, 2026-08-30: required
  by remove-check and the digest), so inspecting route keys is an admin-only act; the
  ping URL otherwise exists only in the consuming service's secret store. The
  `alerted` flag means "the human was actually told": a cooldown-suppressed alert
  leaves it clear, and no recovery email ever references an alert never delivered.

## Alerting rules (where the review found the real defects)

- **A check that never arms alerts anyway.** Every check has an `armingWindow`
  (default: one period). If no first ping arrives within it, one "never pinged since
  creation" alert fires — a misspelled env var or unsynced secret must not read as
  health forever.
- **The alerted flag is written only after a successful send.** If `EMAIL.send()`
  throws, the flag stays clear and the next alarm retries; a transient email failure
  can never permanently swallow the one alert.
- **Cooldown and cap.** At most one alert email per check per hour (`lastAlertAt`), and
  a global daily send cap as a backstop; both protect the 907.life sending reputation
  and the Email Service quota.
- **Recovery emails** come from the ping path (see above), once per alert episode.
- **Weekly digest**: one "all clear" email listing every check and its last ping, so an
  absent monitor eventually becomes visible to a human even if everything else fails.
- `ALERT_EMAIL` (geoff-login@907.life) is registered as a **verified destination
  address**, which makes alert sends quota-exempt and free (verified against Email
  Service pricing docs). Per-check `alertEmail` override allows a future service to
  page someone else. Known operational quirk for the README: binding-sent mail shows as
  "dropped" in the Email Routing summary even when delivered; use Email Sending metrics
  when debugging. The alert path shares the Cloudflare failure domain; the watchdog
  below is the answer.

## Pull checks and the cron

Pull checks probe a URL with `AbortSignal.timeout(10s)`; two consecutive failures
alert. A probe asserts on body content, not just status — Navidrome's Subsonic endpoint
returns HTTP 200 with `status="failed"` when unauthenticated (verified), so
`expectBody: "status=\"ok\""` distinguishes "Navidrome works" from "something answered";
status-only probes are documented as tunnel-liveness only. Each check's handling wraps
in try/catch so one malformed record cannot kill a tick.

**What monitors the monitor.** Cloudflare has no alert for a cron that stops firing, no
Workers alerting at all, and community reports of silent multi-day cron stalls; a deploy
from a config missing `triggers.crons` silently removes them. An external cross-vendor
watchdog (one free healthchecks.io check pinged each tick) was proposed and **declined**
(Geoff, 2026-08-30: no extra account). The accepted answer is the weekly all-clear
digest: if the digest stops arriving, the monitor itself is down, and Geoff notices at
human timescale rather than machine timescale. That residual risk — up to a week of
monitor silence — is owned, not accidental. The code keeps a `WATCHDOG_URL` var that,
when set, is pinged each successful tick and skipped with a log line when unset, so
reversing the decision later is one secret, zero code changes. Provisioning asserts
post-deploy that the cron schedule is registered via the API, and DO alarms (the push
path) are independent of the cron entirely, so a dead cron silences only pull probes and
the digest, never overdue-push detection.

## Forensics

DO state keeps `lastPingIp` and `pingCount` (escaped before any HTML interpolation), so
an alert can answer "when did pings stop and where were they coming from." No further
history retention.

## Implementation and testing

TypeScript Worker, no framework; `wrangler.jsonc` with pinned `compatibility_date`,
`observability: { enabled: true }`, the DO binding + migration, the `send_email`
binding, and the custom domain as `routes: [{ pattern: "pings.907.life",
custom_domain: true }]` (no wrangler subcommand exists for this; provisioning checks for
a conflicting pre-existing DNS record first). Transition logic lives in pure functions
under vitest, and — because the review showed every real defect lives in the shell, not
the logic — integration tests drive the DO and the scheduled handler directly
(`createScheduledController`, Miniflare-backed bindings, stubbed `EMAIL`): one email per
transition, silence on repeat ticks, flag unwritten when send throws, `/fail` deduped,
never-armed alert after its window, pull-probe body assertion.

## Provisioning and reuse

The Worker is service-agnostic; onboarding any future service is one command:

- `provision.sh` (idempotent): deploy, verify cron registered, verify custom domain,
  register the verified destination address (the confirmation click is Geoff's), create
  the watchdog ping wiring.
- `add-check NAME --period MIN --grace MIN [--arming MIN] [--email ADDR]` or
  `add-check NAME --pull URL --expect-body SUBSTR`: generates a 32-hex slug (128 bits;
  entropy is not the risk, disclosure is), initializes the DO, writes the slug-free
  `check:<name>` KV record, and emits the ping URL on stdout — **the URL and nothing
  else on stdout**, progress on stderr, so it pipes cleanly into
  `secret-set.sh NAME --stdin`. Secrets never pass as argv. `remove-check` reverses it.
- Check names carry the consumer prefix (`musicbox-backup`).

For musicbox: `MUSICBOX_HC_BACKUP_URL`, `MUSICBOX_HC_IMPORT_URL`,
`MUSICBOX_HC_DISK_URL` in the age store (names unchanged from the musicbox env
template), documented in `registry.md`. The `musicbox-navidrome` pull check is created
in musicbox Task 6 when its endpoint exists — created enabled, no disabled-state
mechanism (cut by review). Musicbox side decisions the review forced: `music-import`
pings success when it exits early on flock contention (the system is healthy; the
residual risk that a wedged 90-minute import stays green is accepted and revisited with
real data after a month), and `ping_hc` gains `--retry 3 --max-time 10` and an
empty-URL guard so a lost ping is a network event, not a silent config bug. Check
periods: backup 1560+60 grace (27 h: exactly one missed daily run alerts), import and
disk 60+15 (tolerates three missed 15-minute runs).

## Exit path

If this Worker is ever abandoned, the consumers read whole URLs from env: point the
same env vars at healthchecks.io URLs and restart the timers. No code changes anywhere.

## Out of scope

Relaying musicbox's msmtp review notifications (noted as a future consolidation),
status pages, non-email alert channels, multi-tenant auth, ping history beyond the
forensic fields.
