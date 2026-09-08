# CLAUDE.md displacement candidates

Task 6 of `2026-09-08-docs-standard-claude-infra.md`. This document produces the ranked
picks for the owner sitting that approves the docs-standard corpus (decision 7); it edits no
`CLAUDE.md` anywhere. Both files it measures already carry an outside file's full detail
elsewhere, which is why each candidate below is safe to shrink to a pointer rather than
delete outright.

## The budget arithmetic

`claude-context-budget` (`~/.dotfiles/bin/.local/bin/claude-context-budget`) sets
`CLAUDE_MD_BUDGET=6000` approximate tokens for any file named `CLAUDE.md`, computed as bytes
divided by four. The byte ceiling is therefore **24,000 bytes**.

| File | Current size | Headroom before the four lines |
| --- | --- | --- |
| `claude/.claude/CLAUDE.md` (stow source for `~/.claude/CLAUDE.md`) | 23,995 bytes | 5 bytes |
| `/var/home/glw907/Projects/cairn-cms/CLAUDE.md` | 24,136 bytes | already 136 bytes over |

## The four new lines and their byte cost

Each file gains the same four lines in its own voice: the standard's existence and where it
lives, the brief-first and one-section-per-read protocol, the owner-brief resolution rule for
any claim about the owner or cairn's stance, and the docs-register profile with the fact that
no measure it reports gates.

**`claude/.claude/CLAUDE.md` draft (630 bytes, measured with `wc -c`):**

```
- The cairn documentation standard governs every published docs page; see
  `~/Projects/cairn-cms/docs/superpowers/specs/2026-09-08-docs-standard-design.md`.
- Any page an outside reader opens leads with a one-paragraph brief and carries one section
  per read; do not make a reader assemble the page's point from its parts.
- A claim about the owner, or about cairn's own stance, resolves to a line in an owner brief,
  never to an inference from other prose.
- `tellgrader --profile docs-register` reports cadence measures for an opted-in repo; every
  number is report-only and gates nothing (see the scanner's `MEASURES.md`).
```

**`cairn-cms/CLAUDE.md` draft (623 bytes, measured with `wc -c`):**

```
- This repo follows the cairn documentation standard; see
  `docs/superpowers/specs/2026-09-08-docs-standard-design.md` for the full design.
- Any page an evaluator, editor, or extending developer reads leads with a brief and holds one
  section per read, never a page that makes the reader assemble the point from its parts.
- A claim about Geoff or about cairn's own stance resolves to a line in an owner brief, never
  to an inference the prose only implies.
- `tellgrader --profile docs-register` (opted in via `.tellgrader.json`) reports cadence
  measures on `docs/**`; every number is report-only and gates nothing.
```

## What each file must shed

- `claude/.claude/CLAUDE.md`: 5 bytes of headroom minus 630 new bytes leaves **625 bytes**
  that must leave the file for it to sit under budget with the four lines added.
- `cairn-cms/CLAUDE.md`: 136 bytes already over budget plus 623 new bytes means **759 bytes**
  must leave the file for it to sit under budget with the four lines added.

## Ranked candidates: `claude/.claude/CLAUDE.md`

Four candidates, ranked by cost-to-value (best cut first). Any one of the top two already
clears the 625-byte requirement on its own.

1. **The unattended-work guards paragraph, under "Multi-agent workflows: suggest, never
   launch unprompted" (455 bytes).** The paragraph beginning "Guards on long unattended work,
   both mandatory" restates the runaway-guard and battery-watchdog procedure that
   `~/.claude/docs/unattended-work-guards.md` already states in full, and the paragraph
   itself names that file as the one to read before arming either guard. Shrinking it to "See
   `~/.claude/docs/unattended-work-guards.md` before arming either guard" loses nothing a
   session cannot get from that doc in one read.
2. **The "Engine-level UI mechanics, every cairn site" section (2,142 bytes).** The mechanic
   vs. choice distinction, the consultation-first path, and the mid-pass filing fallback are
   the same protocol the `engine-consult` skill implements and that
   `cairn-cms/docs/superpowers/specs/2026-08-26-engine-consultation-design.md` and
   `cairn-cms/docs/internal/engine-rulings.md` state in full. A single-paragraph pointer to
   the skill and the rulings ledger preserves the trigger ("this repo has patched this
   before") without restating the whole procedure here.
3. **The "FULL ACCOUNT ACCESS" paragraph under "Cloudflare / Wrangler" (700 bytes).** The
   paragraph's own last sentence already defers exact scopes to
   `~/.claude/docs/cloudflare-estate-inventory.md`, which documents the token, its scopes,
   and the authorization model in full. What is lost by shrinking the paragraph to a pointer
   plus "make routine changes directly, never treat Cloudflare state as read-only" is the
   inline account ID and estate list, both already in the inventory doc.
4. **The "Installing a NEW long-lived secret" bullet under "Secrets" (921 bytes).** The
   bullet restates the exact flow that `secret-set.sh`'s own usage output and
   `~/.dotfiles/secrets/registry.md` already carry (the script enforces the steps this bullet
   describes). Shrinking it to "new secret: `secret-set.sh NAME --value|--file|--b64-file`,
   then record it in `~/.dotfiles/secrets/registry.md`, per the script's own help" keeps the
   entry point and drops the restated procedure.

## Ranked candidates: `cairn-cms/CLAUDE.md`

Four candidates, ranked by cost-to-value. The top candidate alone clears the 759-byte
requirement.

1. **The "Credentials (machine-local, intentionally not in git)" section (791 bytes).** Every
   value it names (`GITHUB_APP_ID`, `GITHUB_APP_INSTALLATION_ID`,
   `GITHUB_APP_PRIVATE_KEY_B64`, both D1 database ids) is already recorded in
   `~/.dotfiles/secrets/registry.md`, which carries a dedicated section for the GitHub App
   trio (line 327 at last read) and the per-site secret routing. Shrinking this section to
   "See `~/.dotfiles/secrets/registry.md` for the GitHub App and D1 auth-store identifiers"
   loses only the inline copy of values that live in the canonical registry.
2. **The "Admin interface design" section (723 bytes).** The section's own text says
   `docs/internal/admin-design-system.md` is "the agent-facing design system," then restates
   its contents (the token names, the type pairing, the component recipes, the `data-theme`
   rule) in the same breath. Shrinking to the one directive sentence, "read and follow
   `docs/internal/admin-design-system.md` before any `/admin` work," loses the inline preview
   but not the design system itself.
3. **The "Durable gotcha (Vite 8 ships TypeScript in dist `.svelte`)" section (643 bytes).**
   The section already closes with a link to the full post-mortem,
   `docs/internal/record/2026-06-21-e2e-dist-svelte-build-failure.md`. Trimming the middle
   explanation to "do not remove the transpile step or strip `lang=\"ts\"`; full mechanism in
   the linked post-mortem" keeps the one operative rule and drops the restated mechanism.
4. **The "Durable gotcha (a worktree showcase e2e proves MAIN's engine)" section (595
   bytes).** No other doc currently states this gotcha in full, so displacing it costs more
   than the first three: the content would need a new home, such as a "worktree gotchas" note
   under `docs/internal/`, before this section could shrink to a pointer. Ranked last because
   it is a net move, not a pure trim.

## What is not touched

No `CLAUDE.md` is modified by this task. `git -C ~/.dotfiles status --short
claude/.claude/CLAUDE.md` is empty, and no write happens in `~/Projects/cairn-cms`. The edits
themselves are the owner's pick at the sitting that approves the corpus (decision 7); task 8
of the plan records that debt.
