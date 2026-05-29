---
name: cairn-pass
description: >
  Invoke at the start or end of a plan in the cairn-cms rebuild, the embedded
  magic-link, GitHub-committing CMS library for SvelteKit/Cloudflare sites
  (numbered plans 00 through 08). The canonical source is the functional spec
  at cairn-cms/docs/superpowers/specs/2026-05-28-cairn-rebuild-functional-spec.md;
  the plans live in cairn-cms/docs/superpowers/plans/. Trigger on "start plan 0N",
  "continue", or "next plan" when the work is cairn-cms. For a site's OWN roadmap
  (ecnordic/907-life numbered passes) use site-pass.
---

# Cairn Pass (cairn-cms rebuild)

The cairn-cms library is being rebuilt test-first as a numbered plan series, 00
(foundation) through 08 (scaffolder). The canonical source of truth is the
functional spec, which supersedes the older `docs/PLAN.md` and `docs/ARCHITECTURE.md`.
Each plan is written just-in-time after the prior one lands, under
`cairn-cms/docs/superpowers/plans/`.

Fresh internals live in a git worktree off `cairn-cms` `main` (branch `rebuild`,
topology A). The live branch and both consumer sites stay untouched until cutover
(Plan 07). Work the worktree, honor `cairn-cms`'s own `CLAUDE.md` and skills.

> **Which skill?** This is for the cairn-cms library rebuild. If the user means a
> site's own numbered passes (ecnordic-ski / 907-life roadmap), use **`site-pass`**.

## Starting a plan

1. **Read the functional spec** (sections relevant to the plan) and **the plan file
   in full**. The spec holds the locked decisions, architecture, and the test plan;
   the plan file holds the task-by-task steps and the exit criteria.
2. Confirm you are in the `rebuild` worktree, not the live checkout.
3. Execute task-by-task with `superpowers:subagent-driven-development` (or
   `superpowers:executing-plans`). The suite is the acceptance contract: write or
   confirm the failing test first, then make it green.

## Ending a plan: consolidation ritual

No plan is done until every step has run.

### 1. Simplify

Dispatch the code-simplifier agent over the code changed this plan. Use
`subagent_type` = **`code-simplifier:code-simplifier`** (the bare name errors).
Docs-only plans skip this.

### 2. Check and test

Run `npm run check` (svelte-check) and `npm test` (the unit and integration
projects). The integration layer runs in workerd against a real miniflare D1.
Fix every failure before continuing; green is the bar.

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

### 5. Update tracking

Append progress to the active plan file and to the `cairn-rebuild-initiative`
memory: what was built, what was verified (with evidence), decisions locked in,
and any blockers. Do **not** write cairn state into a site's `STATUS.md`.

### 6. Commit

Commit in the `cairn-cms` worktree (branch `rebuild`), following the repo's git
conventions: simplify first (step 1), commit specific files, push only when the
user asks.

## When NOT to use

- A site's own numbered passes: use `site-pass`.
- Mid-plan debugging or single-file edits.
