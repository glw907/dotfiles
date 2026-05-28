---
name: cairn-pass
description: >
  Invoke at the start or end of a pass on the cairn-cms initiative — the
  embedded magic-link, GitHub-committing CMS library for SvelteKit/Cloudflare
  sites (passes 0/A–F). The canonical tracker is `cairn-cms/docs/PLAN.md`
  (locked decisions, A–F roadmap, risk register, progress log). Trigger on
  "start pass A/B/…", "continue"/"next pass" when the work is cairn-cms.
  For a site's OWN roadmap (ecnordic/907-life numbered passes) use `site-pass`.
---

# Cairn Pass (cairn-cms initiative)

The cairn-cms library is built pass-by-pass (0, then A–F). Unlike a site's own
roadmap, this initiative is tracked in **`cairn-cms/docs/PLAN.md`**, not in any
site's `STATUS.md`. Passes A–F write code *inside a site repo* (mostly
`ecnordic-ski/` until the Pass F extraction), so you work in that repo and honor
its `CLAUDE.md`, rules, and tooling (e.g. the `svelte-check` skill). The
plan, decisions, and progress live in PLAN.md.

> **Which skill?** This is for the cairn-cms library. If the user means a
> site's own numbered passes (ecnordic-ski / 907-life roadmap), use
> **`site-pass`** instead.

## Starting a pass

1. **Read `cairn-cms/docs/PLAN.md` in full.** It covers locked decisions, architecture,
   the phased passes (0–F), the ranked risk register, and the Notes / progress
   log (where each pass's state lives).
2. Find the requested pass; note which site repo it executes in and what
   "Done" means for it.
3. Execute it. Honor the host site repo's `CLAUDE.md` and skills while working
   there. For multi-task plans, use `superpowers:subagent-driven-development`.

## Ending a pass: consolidation ritual

No pass is done until every step has run.

### 1. Simplify

Dispatch the code-simplifier agent over the code changed this pass. Use
`subagent_type` = **`code-simplifier:code-simplifier`** (plugin-namespaced; the
bare name errors). Docs-only passes skip this.

### 2. Type-check

Run the host site repo's `svelte-check` skill (or `npm run check`). Fix errors
before continuing. Also run the test suite if the pass touched tested code.

### 3. Live admin smoke

For any pass touching the `/admin` surface, run the live admin smoke against a real
Worker. The standard procedure is **`cairn-cms/docs/admin-smoke-test.md`**: start
`wrangler dev`, mint a session with the site's `scripts/mint-session.mjs` (it forges a
better-auth signed cookie, so no email loop is needed), and run the curl checklist on both
sites. Do not re-derive the cookie scheme; the doc and the script already encode it. The
final Firefox magic-link click stays a user step (the email token is hashed). Record the
results in the progress log. Skip for passes that do not touch `/admin`.

### 4. Update `cairn-cms/docs/PLAN.md`

Append/update the **Notes / progress log**: what was built, what was verified
(with evidence), decisions locked in, and any blockers. Update the risk register
if a risk was retired or newly hit. This is the cairn tracker. Do **not** write
cairn state into a site's `STATUS.md`.

### 5. Commit

Commit in the repo where the code landed (the host site repo for A–E; the
`cairn-cms` repo once code is extracted in Pass F), following that repo's git
conventions. Run the workstation `code-simplifier` first (done in step 1),
commit specific files, and push only when the user asks.

## When NOT to use

- A site's own numbered passes: use `site-pass`.
- Mid-pass debugging or single-file edits.
