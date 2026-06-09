# Pass <n>: <topic>

> **For agentic workers:** Implement this plan task-by-task in the main loop,
> verifying each task before the next. Dispatch `site-implementer` subagents
> only for parallel-independent tasks or a worktree-isolated change (they
> inherit the main-loop model; pass `model: sonnet` for a mechanical fan-out).
> Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** One sentence stating what this pass produces.

**Architecture:** What this pass delivers, including files created/modified
and key decisions locked in.

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
- [ ] Step 2: Run `npm run check` (expected: no errors)
- [ ] Step 3: Commit

---

## Pass-end checklist

- [ ] `code-simplifier` agent on changed code
- [ ] Quality gate: `npm run check` (0/0), `npm test` (exit 0), `npm run build`
- [ ] Review gate: fan out the reviewers matching what the pass touched
      (svelte-reviewer, daisyui-a11y-reviewer, cloudflare-workers-reviewer,
      web-auth-security-reviewer; content-review for site content)
- [ ] Update `docs/architecture.md`
- [ ] Update `docs/STATUS.md` (mark done, write next starter prompt)
- [ ] Archive plan: `git mv docs/superpowers/plans/<this>.md docs/superpowers/archive/plans/`
- [ ] Archive spec (if one exists): `git mv docs/superpowers/specs/<this>-design.md docs/superpowers/archive/specs/`
- [ ] Commit and push, then roll into the next pass in this session
