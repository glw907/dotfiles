---
name: go-review
description: >
  Review Go code for compliance with the project's documented conventions
  in ~/.claude/docs/go-conventions.md. Use this skill after writing or
  modifying Go code, as a quality gate before committing, or when the user
  asks to check Go code quality. Trigger on: "review go code", "check
  conventions", "go review", "does this follow conventions", "check go
  style", or any request to verify Go code against project standards. Also
  use when finishing a Go implementation task and the plan includes a
  review/compliance step.
---

# Go Convention Review

Review Go code against the documented conventions in `~/.claude/docs/go-conventions.md`. This catches the specific anti-patterns and style violations that creep in when Claude writes Go - the conventions doc exists precisely to prevent Go that looks like Python or JavaScript.

## How to Review

### Step 1: Determine scope

**Diff mode (default):** Review only changed code. Run `git diff HEAD` (or `git diff <base>..HEAD` if on a feature branch) to get the changes. This is the right mode for "review what I just wrote" or post-implementation checks.

**Full mode:** Review entire files or packages. Use when asked to audit existing code, or when the user specifies files/packages explicitly.

### Step 2: Load the conventions

Read `~/.claude/docs/go-conventions.md` in full. This is the authoritative source. Do not rely on memory of what the conventions say - they may have been updated.

### Step 3: Check each convention

Work through the code systematically against every section of the conventions doc. The most commonly violated rules (in order of frequency) are:

**Anti-patterns (highest priority):**
- Unnecessary interfaces (no second consumer exists)
- Gratuitous goroutines in CLI tools
- Builder patterns / functional options instead of plain config structs
- Deep nesting instead of early returns
- Overuse of generics
- fmt.Sprintf for simple concatenation
- Defensive nil checks on internal code
- Constants for strings used once
- Package-level init() functions

**Project structure:**
- `cmd/` contains only CLI wiring, no business logic
- `internal/` for all library code, no `pkg/`
- One concern per file
- Test files alongside source

**CLI framework (cobra):**
- `SilenceUsage: true`
- Flags in a struct, not loose variables
- `RunE` returns error; only main() prints and exits

**Error handling:**
- `fmt.Errorf("context: %w", err)` at every boundary
- Messages lowercase, no trailing period
- Noun-verb form: "reading config", "creating directory"
- Library functions return errors, only main() prints them

**Testing:**
- Table-driven with `[]struct{ name, input, expected }`
- Sub-tests with `t.Run`
- No third-party assertion libraries
- Error paths tested explicitly

**File writes:**
- Atomic write pattern (temp + sync + rename)
- Directory permissions 0755, files 0644, sensitive 0600

**Output:**
- Data to stdout
- Status messages to stderr
- Errors returned, not printed (except main)

**Other:**
- Doc comments start with identifier name
- Short names in narrow scope, descriptive for exports
- Minimal dependencies (stdlib where possible)
- `make check` (vet + test) must pass before commit

### Step 4: Report findings

**If violations found**, report each one:

| File:Line | Convention | Issue |
|-----------|-----------|-------|
| `cmd/foo/bar.go:42` | Flags in struct | Loose `var` declarations instead of flag struct |
| `internal/x/y.go:15` | Error wrapping | Missing `%w` in fmt.Errorf |

After the table, note which are quick fixes vs. which need design changes.

**If no violations found:**

> Go conventions check: clean. All changed code follows `~/.claude/docs/go-conventions.md`.

### What NOT to flag

- Pre-existing violations in code you didn't change (in diff mode). Only flag these if the user explicitly asked for a full audit.
- Idiomatic Go patterns that aren't covered by the conventions doc. The doc is the standard, not general Go opinion.
- Style preferences not documented in the conventions (e.g., line length, import grouping beyond what goimports does).
