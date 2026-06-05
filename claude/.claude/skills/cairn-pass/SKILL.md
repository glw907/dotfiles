---
name: cairn-pass
description: >
  Invoke at the start or end of a plan in the cairn-cms rebuild, the embedded
  magic-link, GitHub-committing CMS library for SvelteKit/Cloudflare sites
  (numbered plans 00 through 08 plus the later named plans). The canonical source is
  the functional spec at cairn-cms/docs/superpowers/specs/2026-05-28-cairn-rebuild-functional-spec.md;
  the plans live in cairn-cms/docs/superpowers/plans/. Trigger on "start/execute/implement
  plan <N or name>", "continue", or "next plan" when the work is cairn-cms; this is also
  the entry point for a fresh session resuming a plan after a context clear. For a site's
  OWN roadmap (ecnordic/907-life numbered passes) use site-pass.
---

# Cairn Pass (cairn-cms rebuild)

The cairn-cms library is being rebuilt test-first as a numbered plan series, 00
(foundation) through 08 (scaffolder). The canonical source of truth is the
functional spec, which supersedes the older `docs/PLAN.md` and `docs/ARCHITECTURE.md`.
Each plan is written just-in-time after the prior one lands, under
`cairn-cms/docs/superpowers/plans/`.

The rebuild (plans 00 through 08) has landed and merged to `main`; stable `0.6.0` shipped
and both sites run it. Later engine work (public delivery, the CairnExtension dispatch, the
scaffolder) runs on a feature worktree off `main`. The current state, the branch topology, and
the open decisions live in `cairn-cms/docs/STATUS.md`, which this skill reads at pass-start and
updates at pass-end. Honor `cairn-cms`'s own `CLAUDE.md` and skills.

> **Which skill?** This is for the cairn-cms library rebuild. If the user means a
> site's own numbered passes (ecnordic-ski / 907-life roadmap), use **`site-pass`**.

## Starting a plan

This is the entry point for a fresh session, including one resuming after a deliberate
context clear. STATUS.md's "immediate next action" line names the plan to execute and the
method; trust it and the plan file rather than re-deriving the design.

1. **Read `cairn-cms/docs/STATUS.md`** for the current state and open decisions, the
   **functional spec** (sections relevant to the plan) for the locked decisions and
   architecture, and **the plan file in full** for the task-by-task steps and exit criteria.
2. Confirm you are in a feature worktree off `main`, not the `main` checkout itself.
   STATUS.md lists the active worktrees.
3. Execute task-by-task with `superpowers:subagent-driven-development` (or
   `superpowers:executing-plans`). Dispatch the `cairn-implementer` agent per task
   (Sonnet by default; pass `model: opus` for judgment-heavy tasks). The suite is the
   acceptance contract: write or confirm the failing test first, then make it green.

> **Legacy discipline.** The frozen `legacy/` build only ever got smoke tests, not real
> use, so it is an accelerator and a behavioral reference, not a proven artifact to
> preserve. Port pure, framework-agnostic logic from it to move fast, but hold everything
> to the rebuild's current standards (Svelte 5 runes, DaisyUI v5, the a11y bar) and prove
> it with our own tests. Re-derive UI and framework-coupled code clean rather than copying
> legacy markup; copying v4/better-auth-era assumptions forward is what the Plan 05 review
> gate had to undo.

## Ending a plan: consolidation ritual

No plan is done until every step has run.

### 1. Simplify

Dispatch the code-simplifier agent over the code changed this plan. Use
`subagent_type` = **`code-simplifier:code-simplifier`** (the bare name errors).
Docs-only plans skip this.

### 2. Check and test

Run `npm run check` (svelte-check, 0 errors and 0 warnings) and `npm test` (the
unit, integration, and component projects; the integration layer runs in workerd
against a real miniflare D1, the component layer in a real browser). Green is the
bar, and that means `npm test` **exits 0**: a passing assertion count is not enough,
since an unhandled rejection can leave every test green while the process exits 1.
Fix every failure before continuing.

### 3. Review gate

Fan out the relevant review subagents in parallel and fold their findings in
before committing. Match the subagent to what the plan touched:
`svelte-reviewer`, `cloudflare-workers-reviewer`, `web-auth-security-reviewer`
(always for auth, session, cookie, token, or signing changes),
`daisyui-a11y-reviewer`. They complement `/code-review`, not replace it.

### 4. Live admin smoke

For any plan touching the `/admin` surface, run the live admin smoke against a
real Worker (`wrangler dev`). Under the rebuilt self-owned auth, mint a session
by inserting a D1 session row directly (no better-auth cookie, no email loop);
the final magic-link click in a browser stays a user step. Follow the smoke doc
in `cairn-cms/docs/` once Plan 01 rewrites it for the new auth. Record results as
evidence. Skip for plans that do not touch `/admin`.

### 5. Documentation

Documentation is a pass dimension, not a follow-up. Before the pass is done, update the docs for
whatever it changed.

- Update the relevant `docs/` arm: the reference page for any public-API change, and the guides,
  explanation, or tutorial as the change touches them. Update `CHANGELOG.md` and `docs/upgrading.md`
  for any breaking change, which is where the "Consumers must:" convention below applies.
- A public-API change is not done until its reference page matches. Enforce it by running
  `npm run check:reference` (the export-coverage gate fails on an undocumented export) and
  `npm run check:package`. Both must pass.
- Append any design friction the writing surfaced to `docs/internal/docs-friction-log.md`, one entry
  per finding with its perspective (developer or editor) and a short note. Triage candidates into
  `ROADMAP.md` (Now or Next) and the STATUS carry-forwards. This repo keeps no separate backlog file.

A docs-only pass skips the engine check and test (step 2) but still does this step. See the
`docs-is-a-pass-dimension` memory.

### 6. Update tracking

Append the post-mortem to the active plan file (what was built, what was verified
with evidence, decisions locked in, blockers). Then update `cairn-cms/docs/STATUS.md`,
the canonical rolling status, with where the work is now, what is next, the open
decisions, and the carried follow-ups. STATUS.md lives on `main`, so update it there as
part of the merge. Durable cross-cutting gotchas stay as focused `cairn-*` memories, and
locked architecture decisions stay in the functional spec. Do **not** write cairn state
into a consumer site's `STATUS.md`; that is the site's own.

**Changelog convention (enforced).** If the pass made any breaking change to the public
surface, its `CHANGELOG.md` entry must carry a `Consumers must:` line per breaking change,
stating the concrete consumer action (the rename, the moved import, the new required
argument). A non-breaking change needs no such line. This convention exists so a site
crossing several `0.x` versions reads the actions off the changelog instead of
rediscovering each rename. The `0.x` renames also accumulate in `docs/upgrading.md`, one
line each; add the pass's renames there too.

### 7. Commit

Commit in the cairn-cms feature worktree, following the repo's git conventions.
Simplify first (step 1), commit specific files, and push or merge only when the user
asks.

### 8. Draft the next plan (while context is warm)

Preferred, not skippable lightly. The just-landed pass is fresh now: its patterns,
carried follow-ups, and lessons are in context, and re-deriving them cold next
session is waste. So before stopping, draft the next plan. Run
`superpowers:brainstorming` first to settle the open design decisions with the user
(the spec locks most of it; surface only what it leaves open), then
`superpowers:writing-plans` to author the numbered plan file. Keep the
design-and-approval gate: never auto-write a plan without the user's calls on the
open decisions. The plan stays revisable next session. Skip only when the next pass's
direction is unsettled or the user wants to stop here.

### 9. Hand off for a fresh-session execution

Geoff executes a plan in a fresh session, so the writing session's last job is to make
resuming frictionless. Do this after the plan is written; do **not** run the
`superpowers:writing-plans` "which execution method?" question (subagent-driven is the
default and gets baked into the resume instructions).

- **Pre-bake the handoff while context is warm.** Commit the plan (push if the user wants
  it pushed). Update STATUS.md so its **immediate next action** line names the new plan, its
  path, and the method (`subagent-driven-development` + `cairn-implementer` per task, on a
  worktree off `main`). Refresh the relevant `cairn-*` memory so a cold session recalls the
  initiative. Leave the tree clean. Anything load-bearing must live in the plan, the spec,
  STATUS.md, or memory, never only in the conversation.
- **Then recommend clearing context** and give the exact resume prompt to paste in the fresh
  session, including the launch directory (inside `cairn-cms`, so its hooks and memory load).
  Example: "Execute the component grammar plan (`docs/superpowers/plans/<file>.md`),
  subagent-driven."

See the `clear-context-before-implementing-plans` memory. Skip the clear only for a trivial
one- or two-task plan, where a fresh session's re-read cost outweighs the benefit.

## Execution discipline (lessons from Plan 07)

- **One implementer per task.** Dispatch a single `cairn-implementer` per task in
  subagent-driven-development, wait for its result, and verify its commit (git log and status)
  before dispatching the next. On an API overload or 5xx, wait and retry once deliberately; never
  fire a second dispatch while one may still be in flight, because a cleared overload fires every
  queued retry at once. See the `plan-execution-dispatch-discipline` memory.
- **Verify a plan's locked build assumptions.** When a plan locks a packaging, build, or
  module-resolution mechanism (for example `publishConfig.exports`, an export condition, or a
  source-to-`dist` swap), confirm it against the real toolchain at the first task that touches it
  rather than trusting the lock. Plan 07's locked `publishConfig.exports` swap did not work on
  npm 11.
- **prose-guard is tiered.** The blocking hook checks only em dashes, banned phrases and openers,
  and structural patterns on the text being written. Anaphora and burstiness are advisory
  sweep-only and scan the whole file, so do not gate commits or spend effort on them, especially
  when they sit in a doc's pre-existing body. See the `prose-guard-tiers` memory.
- **Consider the Workflow tool.** For a numbered plan with many tasks, orchestrating the
  task-then-verify loop through `Workflow` (sequential implementers with built-in verification)
  cuts the per-task coordination round-trips.

## When NOT to use

- A site's own numbered passes: use `site-pass`.
- Mid-plan debugging or single-file edits.
