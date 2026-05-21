---
name: simplify
description: Review changed code for reuse, quality, and efficiency, then fix any issues found.
---

# Simplify: Code Review and Cleanup

Review all changed files for reuse, quality, and efficiency. Fix any issues found.

This is the generic, language-agnostic simplify used across projects. The
Go-aware version — which adds a human-voice agent and Go stdlib-idiom
scanning — lives in poplar's project skills (`.claude/skills/simplify`) and
takes precedence when working in that repo.

## Phase 1: Identify Changes

Run `git diff` (or `git diff HEAD` if there are staged changes) to see what
changed. If the diff doesn't include untracked files, run `git add -N` on them
first so they appear in the diff. If there are no git changes, review the most
recently modified files that the user mentioned or that you edited earlier in
this conversation.

## Phase 2: Launch Review Agents in Parallel

Use the Agent tool to launch three agents concurrently in a single message:
reuse, quality, efficiency. Pass each agent the full diff so it has the
complete context.

### Agent 1: Code Reuse Review

For each change:

1. **Search for existing utilities and helpers** that could replace newly
   written code. Look for similar patterns elsewhere in the codebase — common
   locations are utility directories, shared modules, and files adjacent to the
   changed ones.
2. **Flag any new function that duplicates existing functionality.** Suggest the
   existing function to use instead.
3. **Flag any inline logic that could use an existing utility** — hand-rolled
   string manipulation, manual path handling, custom environment checks, ad-hoc
   type guards, and similar patterns are common candidates.

### Agent 2: Code Quality Review

Review the same changes for hacky patterns:

1. **Redundant state**: state that duplicates existing state, cached values that
   could be derived, observers/effects that could be direct calls
2. **Parameter sprawl**: adding new parameters to a function instead of
   generalizing or restructuring existing ones
3. **Copy-paste with slight variation**: near-duplicate code blocks that should
   be unified with a shared abstraction
4. **Leaky abstractions**: exposing internal details that should be encapsulated,
   or breaking existing abstraction boundaries
5. **Stringly-typed code**: using raw strings where constants, enums, or branded
   types already exist in the codebase
6. **Unnecessary wrapper nesting**: wrapper elements/components that add no layout
   value — check if inner component props already provide the needed behavior
7. **Nested conditionals**: ternary chains, nested if/else, or nested switch 3+
   levels deep — flatten with early returns, guard clauses, a lookup table, or an
   if/else-if cascade
8. **Unnecessary comments**: comments explaining WHAT the code does (well-named
   identifiers already do that), narrating the change, or referencing the
   task/caller — delete; keep only non-obvious WHY (hidden constraints, subtle
   invariants, workarounds)

### Agent 3: Efficiency Review

Review the same changes for efficiency:

1. **Unnecessary work**: redundant computations, repeated file reads, duplicate
   network/API calls, N+1 patterns
2. **Missed concurrency**: independent operations run sequentially when they could
   run in parallel
3. **Hot-path bloat**: new blocking work added to startup or per-request/per-render
   hot paths
4. **Recurring no-op updates**: state/store updates inside polling loops, intervals,
   or event handlers that fire unconditionally — add a change-detection guard so
   downstream consumers aren't notified when nothing changed
5. **Unnecessary existence checks**: pre-checking file/resource existence before
   operating (TOCTOU anti-pattern) — operate directly and handle the error
6. **Memory**: unbounded data structures, missing cleanup, event listener leaks
7. **Overly broad operations**: reading entire files when only a portion is needed,
   loading all items when filtering for one

## Phase 3: Triage

Wait for all three agents to complete. Aggregate their findings before deciding
which to apply.

### Triage anti-pattern guard

**Before marking any finding as "skip," verify the rationale is not one of:**

- "Cross-module" / "cross-file" / "non-trivial refactor"
- "Schema change required"
- "Would require interface change"
- "Churn cost" / "out of scope"

**These are forbidden skip rationales when the project's `CLAUDE.md` (or analogous
file) establishes a refactor-friendly posture** — pre-beta, alpha, "code quality
outweighs stability," "refactor freely," or similar. In those projects the
rationales above describe exactly the work the project posture endorses.

**The only valid skip rationales are:**

1. **"Speculative future consumer"** — the finding adds a field, type, or hook for
   a consumer that doesn't yet exist and isn't immediately needed.
2. **"Upstream-blocked"** — the finding requires a change to a third-party
   dependency the project doesn't control or vendor.
3. **"Premature optimization without measurement"** — for efficiency findings only,
   where the hot path hasn't been profiled and the current shape is bounded.

If none of those three apply, the finding must be applied in this pass.

When you've decided what to apply, state the apply/skip split explicitly (one line
per skip with its rationale tagged) and then proceed to Phase 4.

## Phase 4: Fix Issues

Apply each finding directly. When done, briefly summarize what was fixed (or
confirm the code was already clean).
