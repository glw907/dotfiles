---
name: site-pass
description: >
  Invoke at the start or end of a development pass on one of the SvelteKit
  site repos (ecxc-ski, 907-life, …). Covers pass-start (read STATUS,
  read plan, dispatch Sonnet implementers per task) and pass-end consolidation
  (code-simplifier, quality gate, reviewer fan-out, architecture + STATUS
  update, plan archival, commit + push, then roll into the next pass).
  Trigger on "continue development", "next pass", "finish pass", "ship pass",
  or explicit invocation, when the work is the site's own roadmap.
  For the cross-repo cairn-cms library initiative use `cairn-pass` instead; it
  tracks the cairn-cms repo's own `docs/STATUS.md`, not this repo's STATUS.md.
---

# Site Pass

Each site repo develops in numbered passes. A pass has a starter prompt in
this repo's `docs/STATUS.md`, a plan under `docs/superpowers/plans/`, and
(usually) a spec under `docs/superpowers/specs/`. This skill encodes the
ritual at both ends. It is site-agnostic; all paths are relative to the
repo you're working in.

Plan and execution share the session. The starter prompt and the committed
plan are crash insurance, not a handoff; do not run the
`superpowers:writing-plans` "which execution method?" question, and do not
recommend a context clear except after a long, noisy brainstorm (in that
case give the exact resume prompt and the launch directory).

> **Which skill?** This skill is for a *site's own* roadmap. If the user
> means the **cairn-cms** library initiative, stop and use **`cairn-pass`**.
> That work is tracked in the cairn-cms repo's own `docs/STATUS.md` and the
> functional spec, not this repo's STATUS.md.

## Starting a pass

1. Read `docs/STATUS.md` to get the current pass number and starter prompt.
2. Read the plan doc for the current pass. If none exists and the starter
   prompt lists open questions, brainstorm first (invoke
   `superpowers:brainstorming`), write a plan at
   `docs/superpowers/plans/YYYY-MM-DD-<topic>.md` (see `plan-template.md`),
   then pre-bake before executing: commit the plan and point STATUS.md's
   starter prompt at it. Then execute here, in this same session.
3. Execute the plan task-by-task by dispatching each well-specified task to
   `site-implementer` (pinned Sonnet for token economy): the implementer
   makes the failing check green and clears the repo gate; the main loop
   reviews the diff and verifies before the next dispatch.
4. Implement a task inline, or upshift the dispatch (`model: opus` /
   `model: fable`), only for novel correctness-critical logic the plan does
   not fully specify. When most of a plan's tasks are independent, suggest
   orchestrating them with the Workflow tool and let the user opt in.

## Ending a pass: the consolidation ritual

Every pass ends here. No pass is done until every step has run.

### 1. Simplify

Dispatch the code-simplifier agent over the code changed this pass. Use the
`Agent` tool's `subagent_type` = **`code-simplifier:code-simplifier`** (the
plugin-namespaced name; the bare `code-simplifier` is not a valid agent type
and will error). Docs-only passes skip this.

### 2. Quality gate

Run the repo's full gate: `npm run check` (svelte-check, 0 errors and 0
warnings), the test suite if the repo has one (`npm test` must **exit 0**,
not just show green assertions), and `npm run build`. Fix every failure
before continuing. Docs-only passes skip this.

### 3. Review gate

Fan out the relevant review subagents in parallel and fold their findings
in before committing. Match the subagent to what the pass touched:
`svelte-reviewer` (any `.svelte` or load/action change),
`daisyui-a11y-reviewer` (components, markup, styles, theme config),
`cloudflare-workers-reviewer` (Worker code, D1, wrangler config),
`web-auth-security-reviewer` (always for auth, session, cookie, or token
changes). For website content the `content-review` skill is the reviewer.
At the review gate of a large pass, suggest a Workflow find-and-verify
sweep instead of the flat fan-out and let the user opt in. Skip for small
or docs-only passes.

### 4. Update docs/architecture.md

Add any design decisions made this pass that belong in the long-term record.
Keep it factual: decisions, not narration.

Also keep the site's own docs current for whatever the pass changed (a README
note, a config comment, or an architecture entry). The cairn-cms library carries
the full docs-as-a-pass-dimension rule; for a site this is the light version.

### 5. Update docs/STATUS.md

- Mark the current pass `done` in the pass table.
- Write the next starter prompt (see format below).
- STATUS.md must stay ≤60 lines. Prune if it grows.

### 6. Archive plan + spec

```bash
git mv docs/superpowers/plans/<this-pass>.md docs/superpowers/archive/plans/
# if a spec exists:
git mv docs/superpowers/specs/<this-pass>-design.md docs/superpowers/archive/specs/
```

### 7. Commit and push

Stage the pass's files explicitly (never `git add -A`), then:

```bash
git add <files changed this pass>
git commit -m "Pass <n>: <summary>

Co-Authored-By: Claude <noreply@anthropic.com>"
git push
```

Also refresh the project memory if the initiative's state changed; a cold
session should recall where the roadmap stands from STATUS.md and memory
alone.

### 8. Roll into the next pass (same session by default)

The just-landed pass is fresh: its patterns and carried follow-ups are in
context, and re-deriving them cold is waste. With the ritual done the
durable artifacts are already pre-baked (STATUS.md names the next pass,
the tree is clean), so continue straight into "Starting a pass" above. If
the next starter prompt has open questions, run the brainstorm now while
context is warm. Stop only when the user wants to stop, the next pass's
direction is unsettled, or the session ran long and noisy (then recommend
a clear and give the exact resume prompt and launch directory).

## Execution discipline

- **One implementer per dispatch, verified.** When dispatching
  `site-implementer`, wait for each result and verify its commit (git log
  and status) before depending on it. On an API overload or 5xx, wait and
  retry once deliberately; never fire a second dispatch while one may still
  be in flight.
- **Suggest the Workflow tool at the right moments.** It runs only on the
  user's explicit opt-in ("use a workflow"), so name the moment when it
  would pay off: a plan whose tasks are mostly independent, the review gate
  of a large pass, or a site-wide audit or migration. One sentence naming
  the shape and rough scale is enough.

## Starter-prompt format

```markdown
### Next starter prompt (Pass <n>)

> **Goal.** One sentence describing what this pass accomplishes.
>
> **Scope.** What's in, what's out.
>
> **Settled (do not re-brainstorm):** Decisions already made.
>
> **Still open, brainstorm these:** Questions the pass must answer before
> coding. Omit section if none.
>
> **Approach.** "Invoke site-pass to start. Standard pass-end checklist applies."
```

## When NOT to use

- The cairn-cms library initiative: use `cairn-pass`.
- Mid-pass debugging or single-file edits.
- Purely doc changes (typo fix, content update): no ritual needed.
