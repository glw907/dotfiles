# Pass <n> — <topic>

> **For agentic workers:** REQUIRED SUB-SKILL: Use
> superpowers:subagent-driven-development (recommended) or
> superpowers:executing-plans to implement this plan task-by-task.
> Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** One sentence stating what this pass produces.

**Architecture:** What this pass delivers — files created/modified,
key decisions locked in.

**Tech Stack:** SvelteKit, TypeScript, Tailwind CSS v4, DaisyUI v5,
mdsvex. Note any new deps.

---

## File Map

| File | Action | Purpose |
|---|---|---|
| `src/...` | Create/Modify | ... |

---

## Task N: <component>

**Files:**
- Create/Modify: `exact/path/to/file`

- [ ] Step 1: ...
- [ ] Step 2: Run `npm run check` — expected: no errors
- [ ] Step 3: Commit

---

## Pass-end checklist

- [ ] `code-simplifier` agent on changed code
- [ ] `/svelte-check` — no errors
- [ ] Update `docs/architecture.md`
- [ ] Update `docs/STATUS.md` (mark done, write next starter prompt)
- [ ] Archive plan: `git mv docs/superpowers/plans/<this>.md docs/superpowers/archive/plans/`
- [ ] Archive spec (if one exists): `git mv docs/superpowers/specs/<this>-design.md docs/superpowers/archive/specs/`
- [ ] Commit and push
