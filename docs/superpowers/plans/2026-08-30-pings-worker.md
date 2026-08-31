# pings Worker Implementation Plan

> **For agentic workers:** execute per-task through the implementer → diff-reviewer chain
> (conductor conventions in the workstation CLAUDE.md). Revised 2026-08-30 after
> adversarial review (Durable Object architecture, silence-detection rules, task split).

**Goal:** Build and deploy the estate dead-man's-switch Worker at `pings.907.life`, wire
musicbox's checks into it, and retire healthchecks.io from the musicbox plan except as
its declined-watchdog role (decision in the spec).

**Architecture:** One Durable Object per check (alarm-driven, single-writer state);
`*/5` cron only for pull probes and the external watchdog ping; `send_email` binding
from `pings@907.life`; slug-free KV `check:<name>` records for printable metadata.

**Tech Stack:** Cloudflare Workers, Durable Objects (SQLite), KV, Email Sending binding,
wrangler, @cloudflare/vitest-pool-workers, TypeScript.

**Spec:** `~/.dotfiles/docs/superpowers/specs/2026-08-30-pings-worker-design.md`

**Token ceiling:** inside the musicbox pass's 2.1M envelope. **Checkpoint:** after P2b.

## Global Constraints

- No consumer-specific logic in Worker code; checks are data.
- Slugs and ping URLs never appear in the repo, commits, argv, or tool output; they
  flow through stdin pipes (`secret-set.sh NAME --stdin`), and `add-check` emits the
  URL and NOTHING ELSE on stdout (progress to stderr). The KV `check:<name>` record
  carries no slug and is safe to print.
- Alert emails: flag written only after successful send; transition-only alerts with a
  one-hour per-check cooldown and a global daily cap; `/fail` POST-only and deduped.
- Dependencies and `compatibility_date` pinned; wrangler.jsonc; `observability:
  { enabled: true }`; ts-conventions comments; Google register README (including the
  Email-Routing-shows-"dropped" debugging note).
- All Cloudflare mutations via wrangler or curl with `$CLOUDFLARE_API_TOKEN`.

---

### Task P1: Worker, Durable Object, logic, and tests

**Files:** create `~/Projects/pings/`: `wrangler.jsonc`, `src/index.ts`,
`src/check-do.ts`, `src/logic.ts`, `src/email.ts`, `test/logic.test.ts`,
`test/integration.test.ts`, `package.json`, `tsconfig.json`, `README.md`,
`docs/STATUS.md`, `docs/HISTORY.md`, `.gitignore`.

**Interfaces (produced):** DO class `CheckDO`, addressed by `idFromName(slug)`. DO
state: `{name, kind: "push"|"pull", periodMin, graceMin, armingMin, createdAt,
lastPing?, lastPingIp?, pingCount, failCount, alerted, lastAlertAt?, alertEmail?}`.
Routes: `GET|POST /ping/<slug>` (200, `Cache-Control: no-store`),
`POST /ping/<slug>/fail`, `POST /admin/checks` + `DELETE /admin/checks/<name>` guarded
by an `ADMIN_TOKEN` Worker secret (used only by the repo scripts). KV: `check:<name>`
(slug-free metadata), `pull:<name>` (url, expectBody). Env: `CHECKS` DO binding,
`PINGS_KV`, `EMAIL` send_email binding, `ALERT_EMAIL` and `WATCHDOG_URL` vars,
`ADMIN_TOKEN` secret, cron `*/5 * * * *`.

- [ ] TDD pure logic (`src/logic.ts`): transition function over DO state and events
      (ping, fail, alarm, probe-result) returning `{next state, emails to send}`.
      Vitest cases: arming-window expiry alerts once; overdue transition alerts once;
      repeat alarms while overdue stay silent; ping while alerted produces exactly one
      recovery; /fail dedupes while alerted; cooldown suppresses a second alert inside
      an hour; pull single blip silent, two consecutive failures alert.
- [ ] `src/check-do.ts`: alarm scheduling (`lastPing + period + grace`, arming alarm at
      `createdAt + armingMin` before first ping), single-writer state, email send via
      `env.EMAIL` with flag-after-success ordering, HTML-escaped interpolation of name
      and lastPingIp.
- [ ] `src/index.ts`: slug routing to DO; admin endpoints; scheduled handler = pull
      probes (`AbortSignal.timeout(10_000)`, body assertion, per-check try/catch) +
      global daily-cap key + watchdog ping (`WATCHDOG_URL`, skipped with a log line if
      unset).
- [ ] Integration tests (`cloudflare:test`: `createScheduledController`,
      `createExecutionContext`, Miniflare bindings, stubbed EMAIL): one email per
      transition; silence on repeat ticks; flag unwritten when send throws (next alarm
      retries); /fail deduped; never-armed check alerts after its window; pull probe
      rejects HTTP-200-with-failed-body; malformed pull record does not kill the tick.
- [ ] Gate: `tsc --noEmit`, `vitest run` green, `wrangler deploy --dry-run` clean.

### Task P2a: Provisioning and check-management scripts

**Files:** create `scripts/provision.sh`, `scripts/add-check`, `scripts/remove-check`
(bash, shellcheck-clean, idempotent; a `scripts/check.sh` gate mirroring the musicbox
convention runs shellcheck + the P1 gate).

- [ ] `provision.sh`: fail if `pings.907.life` has a pre-existing DNS record (custom
      domains refuse CNAME conflicts); generate and set `ADMIN_TOKEN` (openssl rand,
      piped to `wrangler secret put` AND `secret-set.sh PINGS_ADMIN_TOKEN --stdin`);
      set `ALERT_EMAIL`; `wrangler deploy` (routes carry the custom domain); assert
      post-deploy via API that the cron schedule is registered and the custom domain
      active; create the Email Routing verified destination address for
      geoff-login@907.life via API if absent (the confirmation click is Geoff's, listed
      in P2c); leave `WATCHDOG_URL` unset (external watchdog declined 2026-08-30,
      decision in the spec; the weekly digest is the monitor-of-the-monitor).
- [ ] `add-check NAME --period MIN --grace MIN [--arming MIN] [--email ADDR]` and
      `add-check NAME --pull URL --expect-body SUBSTR`: slug via `openssl rand -hex
      16`; POST /admin/checks; write `check:<name>` KV metadata (no slug); emit the
      ping URL alone on stdout. Refuse existing names without `--force`.
      `remove-check NAME` deletes DO state, KV record.
- [ ] Gate: `bash scripts/check.sh` green; `add-check --help` and argument validation
      covered by a small bats file (stdout purity asserted: exactly one line).

### Task P2b: Deploy and register musicbox checks

- [ ] Run `provision.sh` for real; verify with independent curl: `/ping/garbage` 404s,
      admin endpoint rejects a missing token, cron schedule visible via API.
- [ ] Register `musicbox-backup` (period 1560, grace 60), `musicbox-import` (60, 15),
      `musicbox-disk` (60, 15), each URL piped into the age store under the existing
      `MUSICBOX_HC_*_URL` names; registry.md entries (rotate = remove-check +
      add-check); commit registry.md in ~/.dotfiles. (`musicbox-navidrome` waits for
      musicbox Task 6, created enabled when its endpoint exists.)
- [ ] Ping one stored URL through a sourced env var (never echoed) and confirm via
      `wrangler tail` or a state probe that the DO recorded it.
- [ ] Update pings STATUS/HISTORY, commit.

### Task P2c: Live drill (Geoff-run checklist, written by the implementer)

A one-page checklist in `docs/drill.md`, executed by Geoff (the email-arrival
confirmation is a human observation and stays out of implementer hands): create
`scratch-test` with period 15 / grace 0; wait out cron propagation (up to 15 min);
observe the never-armed alert OR ping once and wait past the threshold for the overdue
alert; ping again and observe the immediate recovery email; click the destination-
address verification link if P2b left it pending; `remove-check scratch-test`. Success
criteria listed per step with expected email subjects.

### Task P3: Musicbox integration and ledgers (runs after the infra workflow releases the repo)

- [ ] Musicbox plan amendments: Task 0 drops the healthchecks.io API item; Task 6's
      check-creation step becomes "add-check musicbox-navidrome --pull
      https://music.907.life/rest/ping --expect-body 'status=\"ok\"' and verify all
      four checks green".
- [ ] Musicbox script hardening from the review: `ping_hc` gains `--retry 3 --max-time
      10 -fsS` and an empty-URL guard; `music-import` pings success on the
      flock-contention early exit (decision recorded in the spec); bats cases updated;
      gate green.
- [ ] Verify env template names match P2b's stored names; update musicbox STATUS,
      dotfiles STATUS/HISTORY, music-library-setup memory. Commit everything.

## Self-review notes

Every review blocker maps to a task: B1 arming alarm (P1 logic+DO+test), B2 single
writer with inline recovery (P1 DO), B3 drill rewrite (P2c) plus deterministic
integration tests (P1), B4 /fail dedupe+cooldown+cap+POST-only+verified destination
(P1+P2a provisioning), B5 watchdog ping + post-deploy cron assertion + weekly digest
(P1 scheduled handler emits the digest — covered in logic tests as a transition-free
send — and P2a). S6-S16 and C17-C24 all land in the sections above; the two spec/plan
contradictions (recovery writer, disabled flag) are resolved by the spec rewrite. The
watchdog account decision is recorded in the spec and its wiring is optional-pending in
P2a so the build does not block on it.
