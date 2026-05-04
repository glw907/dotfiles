---
name: simplify
description: Review changed code for reuse, quality, efficiency, and human voice (Go only), then fix any issues found.
---

# Simplify: Code Review and Cleanup

Review all changed files for reuse, quality, efficiency, and — when the diff includes Go files — human voice. Fix any issues found.

## Phase 1: Identify Changes

Run `git diff` (or `git diff HEAD` if there are staged changes) to see what changed. If the diff doesn't include untracked files, run `git add -N` on them first so they appear in the diff. If there are no git changes, review the most recently modified files that the user mentioned or that you edited earlier in this conversation.

Note whether the diff includes any Go files. If yes, dispatch four agents (reuse, quality, efficiency, voice). If no Go files, dispatch three (skip voice).

## Phase 2: Launch Review Agents in Parallel

Use the Agent tool to launch all agents concurrently in a single message. Pass each agent the full diff so it has the complete context.

### Agent 1: Code Reuse Review

For each change:

1. **Search for existing utilities and helpers** that could replace newly written code. Look for similar patterns elsewhere in the codebase — common locations are utility directories, shared modules, and files adjacent to the changed ones.
2. **Flag any new function that duplicates existing functionality.** Suggest the existing function to use instead.
3. **Flag any inline logic that could use an existing utility** — hand-rolled string manipulation, manual path handling, custom environment checks, ad-hoc type guards, and similar patterns are common candidates.

### Agent 2: Code Quality Review

Review the same changes for hacky patterns:

1. **Redundant state**: state that duplicates existing state, cached values that could be derived, observers/effects that could be direct calls
2. **Parameter sprawl**: adding new parameters to a function instead of generalizing or restructuring existing ones
3. **Copy-paste with slight variation**: near-duplicate code blocks that should be unified with a shared abstraction
4. **Leaky abstractions**: exposing internal details that should be encapsulated, or breaking existing abstraction boundaries
5. **Stringly-typed code**: using raw strings where constants, enums (string unions), or branded types already exist in the codebase
6. **Unnecessary JSX nesting**: wrapper Boxes/elements that add no layout value — check if inner component props (flexShrink, alignItems, etc.) already provide the needed behavior
7. **Nested conditionals**: ternary chains (`a ? x : b ? y : ...`), nested if/else, or nested switch 3+ levels deep — flatten with early returns, guard clauses, a lookup table, or an if/else-if cascade
8. **Unnecessary comments**: comments explaining WHAT the code does (well-named identifiers already do that), narrating the change, or referencing the task/caller — delete; keep only non-obvious WHY (hidden constraints, subtle invariants, workarounds)

### Agent 3: Efficiency Review

Review the same changes for efficiency:

1. **Unnecessary work**: redundant computations, repeated file reads, duplicate network/API calls, N+1 patterns
2. **Missed concurrency**: independent operations run sequentially when they could run in parallel
3. **Hot-path bloat**: new blocking work added to startup or per-request/per-render hot paths
4. **Recurring no-op updates**: state/store updates inside polling loops, intervals, or event handlers that fire unconditionally — add a change-detection guard so downstream consumers aren't notified when nothing changed. Also: if a wrapper function takes an updater/reducer callback, verify it honors same-reference returns (or whatever the "no change" signal is) — otherwise callers' early-return no-ops are silently defeated
5. **Unnecessary existence checks**: pre-checking file/resource existence before operating (TOCTOU anti-pattern) — operate directly and handle the error
6. **Memory**: unbounded data structures, missing cleanup, event listener leaks
7. **Overly broad operations**: reading entire files when only a portion is needed, loading all items when filtering for one

### Agent 4: Voice Review (Go diffs only)

Skip this agent if the diff has no Go files.

The agent must first read `~/.claude/docs/go-comment-voice.md` to load the full T1–T32 catalogue (§7) and the decision rubric (§1). Then scan the Go portion of the diff for tells. Each finding cites the tell number, quotes the offending lines, and quotes the avoidance rule. Bias toward precision over recall — false positives on voice waste apply-phase time.

Tells to scan for, by category:

1. **Comment tells (T1–T9):** WHAT-comments restating obvious code; godoc on unexported symbols where the name suffices; uniform comment density across functions of different complexity; hedge phrases (`// for now`, `// Note:` opener, unlinked TODO); task-framing comments ("added for X flow", "used by Y", "fixes #N"); first-person plural in unexported docs; every doc beginning "Foo does X"; multi-paragraph docstrings on self-describing functions; per-case docstrings in table tests.

2. **Error-phrasing tells (T10–T13):** `fmt.Errorf("failed to X: %w", err)` template; adjacent error sites reading identically; function name embedded in its own error string; bare `%w` wrapping where no caller branches on the sentinel.

3. **Naming tells (T14–T18):** `GetX` getter prefix; package-doubled types (`mail.MailMessage`); `Manager` / `Helper` / `Util` / `Service` suffixes on single-field types; over-descriptive locals in tight scopes; exported names that read like docstrings.

4. **Structural tells (T19–T23):** reflexive `doc.go` / `errors.go` / `types.go` skeleton; single-impl interfaces with no test fake or DI seam; `New<X>` constructors that only set fields a struct literal would set; defensive nil checks between same-package functions; length checks before indexing on internal callers.

5. **Test tells (T24–T26):** identical assertion phrasing copy-pasted across files; tautological cases; subtests for trivial scalar functions.

6. **Voice tells (T27–T32):** apologetic or hedging documentation; over-explanation of standard Go idioms; uniform sentence length across a file; identical paragraph rhythm; uniform verbosity (identical doc shape and length); `Builder` patterns where a struct literal would suffice.

Output format per finding:

```
T<n> at path/to/file.go:LINE
  <quoted offending line(s)>
  Avoidance: <one-line rule from the catalogue>
```

## Phase 3: Triage

Wait for all three agents to complete. Aggregate their findings before deciding which to apply.

### Triage anti-pattern guard

**Before marking any finding as "skip," verify the rationale is not one of:**

- "Cross-package" / "cross-3-files" / "non-trivial refactor"
- "Schema change required"
- "Would require interface change" / "would require backend change"
- "Churn cost" / "out of scope"

**These are forbidden skip rationales when the project's `CLAUDE.md` (or analogous file) establishes a refactor-friendly posture** — pre-beta, alpha, "code quality outweighs stability," "refactor freely," "breaking changes first-class," or similar. In those projects the rationales above describe *exactly* the work the project posture endorses, so they cannot be used to defer.

**The only valid skip rationales are:**

1. **"Speculative future consumer"** — the finding adds a field, type, or hook for a consumer that doesn't yet exist and isn't immediately needed. Read the code: if no current call site benefits, skip is fair.
2. **"Upstream-blocked"** — the finding requires a change to a third-party dependency that the project doesn't control or vendor.
3. **"Premature optimization without measurement"** — for efficiency findings only, where the hot path hasn't been profiled and the current shape is bounded.

If none of those three apply, the finding must be applied in this pass.

When you've decided what to apply, state the apply/skip split explicitly (one line per skip with its rationale tagged) and then proceed to Phase 4.

## Phase 4: Fix Issues

Apply each finding directly. When done, briefly summarize what was fixed (or confirm the code was already clean).
