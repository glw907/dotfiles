---
name: site-pass
description: >
  Invoke at the start or end of a development pass on one of the SvelteKit
  site repos (ecnordic-ski, 907-life, …). Covers pass-start (read STATUS,
  read plan, execute) and pass-end consolidation (code-simplifier,
  svelte-check, architecture + STATUS update, plan archival, commit + push).
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

> **Which skill?** This skill is for a *site's own* roadmap. If the user
> means the **cairn-cms** library initiative, stop and use **`cairn-pass`**.
> That work is tracked in the cairn-cms repo's own `docs/STATUS.md` and the
> functional spec, not this repo's STATUS.md.

## Starting a pass

1. Read `docs/STATUS.md` to get the current pass number and starter prompt.
2. Read the plan doc for the current pass. If none exists and the starter
   prompt lists open questions, brainstorm first (invoke
   `superpowers:brainstorming`) and write a plan at
   `docs/superpowers/plans/YYYY-MM-DD-<topic>.md` (see `plan-template.md`).
3. Execute the plan using `superpowers:subagent-driven-development`.

## Ending a pass: the consolidation ritual

Every pass ends here. No pass is done until every step has run.

### 1. Simplify

Dispatch the code-simplifier agent over the code changed this pass. Use the
`Agent` tool's `subagent_type` = **`code-simplifier:code-simplifier`** (the
plugin-namespaced name; the bare `code-simplifier` is not a valid agent type
and will error). Docs-only passes skip this.

### 2. /svelte-check

Run the `svelte-check` skill. Fix any type errors before continuing.
Docs-only passes skip this.

### 3. Update docs/architecture.md

Add any design decisions made this pass that belong in the long-term record.
Keep it factual: decisions, not narration.

### 4. Update docs/STATUS.md

- Mark the current pass `done` in the pass table.
- Write the next starter prompt (see format below).
- STATUS.md must stay ≤60 lines. Prune if it grows.

### 5. Archive plan + spec

```bash
git mv docs/superpowers/plans/<this-pass>.md docs/superpowers/archive/plans/
# if a spec exists:
git mv docs/superpowers/specs/<this-pass>-design.md docs/superpowers/archive/specs/
```

### 6. Commit and push

```bash
git add -A
git commit -m "Pass <n>: <summary>

Co-Authored-By: Claude <noreply@anthropic.com>"
git push
```

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
