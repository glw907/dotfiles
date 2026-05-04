---
name: go-conventions
description: >
  Mandatory rules for writing Go code on this workstation. Use before
  writing, reviewing, or modifying any Go file. Covers anti-patterns
  (unnecessary interfaces, builder patterns, defensive nil checks),
  project structure (cmd/ + internal/), cobra CLI shape, error
  wrapping, atomic file writes, table-driven tests, Makefile gates,
  naming, and the human-voice / AI-tell catalogue. Every Go file,
  function, test, comment, and error message must conform.
---

# Go Conventions

Rules for writing Go utilities on this workstation.

## Persona

Write as an experienced Go developer would. Concretely:

- **Terse where the code is clear, deliberate where it isn't.** Sentence
  length varies. Identical-shape paragraphs across a file is a tell.
- **Opinionated.** "Inline this." "This wants a `sync.Once`." Not "you
  might consider…" or "perhaps we could…".
- **Idiom-naming.** Reach for stdlib vocabulary by name: goroutine, not
  thread; channel, not queue; sentinel error, not exception flag.
- **Anti-defensive.** Trust internal callers. Validate at boundaries.
  Bare `return err` over reflexive wrapping. No nil checks between two
  functions in the same package.
- **Stdlib over clever.** A struct literal beats a builder. `path.Join`
  beats hand-rolled concatenation. Single-impl interfaces are usually
  premature.
- **Pushback shape.** When reviewing, name the idiom or anti-pattern
  directly. "T10 — failed-to chorus" not "consider varying the error
  messages." Concrete fix, not vague suggestion.
- **No apologetic framing in code or comments.** Never "this may not
  handle every case" or "for now". State invariants; flag real gaps
  with `// TODO:` only when there's a concrete next step.

The full voice palette and rationale lives in
`~/.claude/docs/go-comment-voice.md` §4.

## Anti-Patterns: Go That Looks Like Python or JavaScript

Claude's default Go output drifts toward other languages. These are
the specific failure modes to reject:

- **Unnecessary interfaces.** Don't define an interface until a second
  consumer exists. A concrete type is fine.
- **Gratuitous goroutines.** CLI tools are sequential. No goroutines or
  channels unless there is measured concurrency to exploit.
- **Builder patterns / functional options.** Use a plain config struct.
  `NewFoo(cfg Config)` not `NewFoo(WithBar(...), WithBaz(...))`.
- **Deep nesting.** Return early. Guard clauses, not if/else chains.
  Never use `else` after a block that unconditionally exits (`return`,
  `panic`, `continue`).
- **Error types as classes.** A struct with `Error() string` is enough.
  No error hierarchies, no `errors.New` wrappers that add nothing.
- **Overuse of generics.** Concrete types unless the function genuinely
  operates on multiple types.
- **fmt.Sprintf for simple concatenation.** `path + "/" + name` is fine.
- **Defensive nil checks everywhere.** Trust internal code. Validate at
  boundaries (user input, external API responses).
- **Constants for strings used once.** Inline them.
- **Package-level init() functions.** Avoid. Pass dependencies explicitly.
- **`this`, `self`, or `me` as receiver names.** Use a short abbreviation
  of the type name: `func (e *Entry)`, not `func (self *Entry)`.
- **`Get` prefix on getters.** The exported first letter already signals
  accessor. Write `Name()` not `GetName()`.
- **`interface{}` instead of `any`.** Go 1.18+ — `any` is canonical.
- **`SCREAMING_SNAKE_CASE` constants.** Go uses `MixedCaps` for all
  identifiers including constants: `MaxEntries`, not `MAX_ENTRIES`.
- **Vague package names.** Never name a package `util`, `utils`,
  `common`, `helper`, `shared`, or `misc`. Name by what it provides:
  `atomicfile`, `timeparse`.
- **`context.Context` stored in a struct.** Pass it as the first
  function parameter. Storing it makes lifetime ambiguous and breaks
  cancellation propagation.
- **`[]T{}` for an empty slice.** Prefer `var t []T` (nil slice) when
  no elements are being added immediately. Use `[]T{}` only when the
  nil/empty distinction matters at a JSON or API boundary, and comment why.

## Project Structure

```
project-name/
  cmd/project-name/     # main package - CLI wiring only
    main.go             # build root cmd, run, print error, exit
    root.go             # cobra command definition + flags struct
    *.go                # one file per command/handler
  internal/             # all business logic
    subpackage/         # one package per concern
  e2e/                  # end-to-end tests (build + exec real binary)
    testdata/           # fixtures, golden files
  go.mod
  go.sum
  Makefile
  .golangci.yml
  CLAUDE.md
```

Rules:
- `cmd/` contains only CLI wiring. No business logic.
- `internal/` for all library code. No `pkg/` directory.
- One concern per file. Name files by what they do: `write.go`,
  `read.go`, `sweep.go`.
- Test files live alongside source: `foo_test.go` next to `foo.go`.

## CLI Framework

Use cobra with these conventions:

```go
func newRootCmd() *cobra.Command {
    var f flags

    cmd := &cobra.Command{
        Use:          "tool [args...]",
        Short:        "One-line description",
        RunE:         func(cmd *cobra.Command, args []string) error { return run(cmd, args, &f) },
        SilenceUsage: true,
    }
    // register flags on cmd.Flags()
    return cmd
}
```

- `SilenceUsage: true` - cobra does not print usage on error.
- Flags in a struct, not loose variables.
- `RunE` returns error. `main()` prints to stderr and exits 1.
- Hidden flags for aliases: `cmd.Flag("name").Hidden = true`.
- Subcommands only when the tool genuinely has distinct modes. Prefer
  a flat command with flags for simple tools.

## main.go

Always this shape:

```go
package main

import (
    "fmt"
    "os"
)

func main() {
    cmd := newRootCmd()
    if err := cmd.Execute(); err != nil {
        fmt.Fprintln(os.Stderr, err)
        os.Exit(1)
    }
}
```

main() is the only place that prints errors and calls os.Exit.

## Error Handling

```go
// Context-prefixed, lowercase, no trailing period
return fmt.Errorf("load config %s: %w", path, err)

// Sentinel checks
if errors.Is(err, os.ErrNotExist) { ... }

// Custom error type extraction
var pe *ParseError
if errors.As(err, &pe) { ... }
```

Rules:
- **Lowercase, no trailing period.** The error appears mid-sentence
  in caller logs.
- **Context-first.** Noun-verb form: `"load config"`, `"create
  directory"`. Never start with `"failed to"` (T10).
- **`%w` only when callers branch on the sentinel.** Use `%w` if
  any caller calls `errors.Is` / `errors.As` on the result.
  Otherwise `%v` or omit wrapping. Reflexive `%w` exposes the
  underlying error type as part of the package's API surface.
- **Adjacent error sites diverge in phrasing.** If two error
  returns in one function read identically, vary them — bare
  noun, context prefix, or operation-name inline (T11).
- **No function name in its own errors.** The call stack provides
  it (T12). State the condition, not the location.
- **Custom error types include location context** (File, Line) when
  the call stack alone isn't sufficient.
- Library functions return errors. Only `main()` prints them.
- Status messages (not errors) go to `os.Stderr`.

## File Writes

All file mutations use atomic write (temp + sync + rename):

```go
// internal/atomicfile/atomicfile.go
func WriteFile(path string, data []byte, perm os.FileMode) error
```

This prevents partial writes on crash. Write to a temp file in the
same directory, sync, then rename over the target.

Directory permissions: 0755. Plain files: 0644. Sensitive files: 0600.

## Testing

### Unit Tests

- Same package as source (not `_test` package).
- Table-driven with `[]struct{ name, input, expected }`.
- Sub-tests: `t.Run(tt.name, func(t *testing.T) { ... })`.
- No third-party assertion libraries. Use `t.Errorf` / `t.Fatalf`
  with `strings.Contains` and direct comparison.
- Test error paths explicitly. They are first-class tests.

### End-to-End Tests

- Package `e2e` in an `e2e/` directory.
- `TestMain` builds the binary once into a temp dir.
- All tests exec the real compiled binary.
- `testEnv` struct carries dir, config path, etc. No globals.
- `t.TempDir()` for all test directories.
- Helper functions: `run`, `runErr`, `runWithStdin`.

### Golden Tests (when applicable)

- Golden files in `e2e/testdata/golden/`.
- `--update-golden` flag to regenerate from an oracle.
- Normalization functions to handle acceptable differences.

## Build System

Makefile with these targets:

```makefile
BINARY := tool-name

build:   go build -o $(BINARY) ./cmd/tool-name
test:    go test ./...
vet:     go vet ./...
lint:    @command -v golangci-lint >/dev/null 2>&1 && golangci-lint run ./... || echo "golangci-lint not installed, skipping"
install: go install ./cmd/tool-name
check:   vet test
clean:   rm -f $(BINARY)
```

- `make check` is the gate before committing: vet + test.
- Lint is advisory (skips if not installed). Vet is mandatory.
- No code generation, no build tags, no CGO.

## Linting

`.golangci.yml`:

```yaml
linters:
  enable:
    - errcheck
    - govet
    - ineffassign
    - staticcheck
    - unused
    - gosimple

linters-settings:
  errcheck:
    check-type-assertions: true

issues:
  exclude-use-default: false
```

No `nolint` pragmas. Fix the code instead.

## Dependencies

- Minimal. Stdlib where possible.
- cobra for CLI, nothing else assumed.
- No frameworks, no DI containers, no ORM.
- Direct dependencies explicitly required in go.mod.
- Indirect dependencies annotated with `// indirect`.

## Naming

- Short names in narrow scope: `f`, `cfg`, `err`, `ok`.
- Descriptive names for exports: `NewClient`, `WriteFile`.
- `NewX()` constructor pattern.
- Unexported types use short names: `day`, `flags`, `rule`.
- Boolean fields: positive sense (`Encrypt`, not `NoEncrypt`).
  Use `*bool` for optional overrides.

## Comments and Voice

The full guide is `~/.claude/docs/go-comment-voice.md` — load it
before writing or reviewing comments. Below is the operative
summary + the §7 AI-tell catalogue with mechanical avoidance rules.

### Decision rubric

Apply before writing any comment:

```
1. Unexported symbol?
   YES → Step 2.   NO → Doc comment required (Step 3).

2. Does the unexported symbol have unobvious behavior the name
   doesn't convey?
   YES → Short doc.   NO → No comment.

3. Is the public API contract fully implied by name + signature?
   YES → One sentence. Period.
   NO  → One sentence + what the caller needs to know. No
         implementation detail.

4. Concurrency hazard, surprising default, platform-specific
   behavior?
   YES → Add it.   NO → Stop.

5. Inside a function: does this block differ from what the name /
   control flow implies?
   YES → One-line why-comment.   NO → No comment.

6. Error strings: lowercase, no trailing period, context-first.
   Never start with "failed to".
```

A comment that restates the code, describes what the name already
conveys, or explains an internal algorithm to a caller has failed
this rubric.

### Doc comment shape

- **Doc comments end with a period.** Always.
- **Name-first.** First word is the identifier name. Type docs may
  use "A" / "An" as article.
- **Boolean returns:** "reports whether" — `// HasPrefix reports
  whether s begins with prefix.`
- **Length proportional to non-obvious behavior.** 1 sentence is
  the floor; expand only when there is a contract, hazard, or
  surprising default to communicate. Never expand to fill space.
- **No first person.** Third-person declarative for godoc. "We"
  permitted only at package-doc level (project voice). No "you".
- **No hedging.** "maybe", "perhaps", "should probably", "might",
  "could" — forbidden in doc comments.

### Unexported godoc default

Comment an unexported symbol when the name + signature leaves
something a competent Go reader wouldn't immediately know.
Otherwise no comment. Silence is the default.

### Error strings

1. **Lowercase.** Never capitalize the first word unless it's a
   proper noun, an acronym, or a package name as prefix.
2. **No trailing period.**
3. **Context-first.** `"image: unknown format"`, not
   `"unknown format"`.
4. **Never start with "failed to".** Use a bare noun clause
   (`"open db"`, `"read header"`) or context prefix (`"json:
   unknown field %q"`).
5. **`%w` only when callers branch on the sentinel.** Otherwise
   `%v`. `%w` makes the underlying error type part of the
   package's API surface.

### §7 — AI-tell catalogue

Each tell: name, where it appears, the mechanical avoidance rule.
Full examples (AI-shaped + human counter-example) live in
`~/.claude/docs/go-comment-voice.md` §7.

**Precedence:** when a finding triggers multiple tells, pick the
strongest. T1 outranks T2 (restatement is the violation regardless
of export status). T11 covers within-function adjacent errors;
T10b covers cross-function chorus in one file. Don't double-flag.

**Comment tells:**

- **T1 — WHAT-comment restating the next line.** Comments above
  obvious code. *Avoid:* if removing the comment leaves a reader
  no worse off, the comment shouldn't exist.
- **T2 — Godoc on every unexported symbol.** *Avoid:* unexported
  gets a comment only when name + signature leaves unobvious
  behavior unexplained.
- **T3 — Uniform comment density across functions of different
  complexity.** *Avoid:* density follows complexity. A 3-line
  helper and a 30-line state machine should not have similarly
  shaped doc comments.
- **T4 — Hedge phrases ("for now", "Note:", unlinked TODO).**
  *Avoid:* never `// for now`. `// Note:` only when something
  truly important follows. `// TODO:` requires a concrete next
  step or issue link.
- **T5 — Task-framing comments ("added for X flow", "used by Y",
  "fixes #N").** *Avoid:* code is not a changelog. Never reference
  callers, the current task, or prior bugs in comments.
- **T6 — First-person plural ("we") inside unexported docs.**
  *Avoid:* third-person declarative. `// we use this to track …`
  → delete or rewrite.
- **T7 — Every doc comment begins "Foo does X".** *Avoid:* after
  writing a function doc, look at the three nearest. If all four
  follow the same subject-verb-object shape, rewrite at least
  two. Vary between return-clause, predicate, invariant, contract.
- **T8 — Multi-paragraph docstrings on self-describing
  functions.** *Avoid:* doc length proportional to non-obvious
  behaviors. Count them; that's the sentence count minus the
  name-first opener.
- **T9 — Per-case docstrings on every table-test case (extends to
  test function names).** *Avoid:* `name:` is a noun phrase. No
  "returns", "should", "when", "given". Test function names follow
  the same rule: `TestQueueOp_OptimisticFlagApply`, not
  `TestQueueOp_FlagAppliesOptimistic`. The body is the documentation.

**Error-phrasing tells:**

- **T10 — `fmt.Errorf("failed to X: %w", err)` chorus.** *Avoid:*
  never start an error string with "failed to". Use a bare noun
  clause or context prefix.
- **T10b — Cross-function error chorus in one file.** *Avoid:* if
  N functions in one file all return errors of identical template
  (e.g., `"migrate vN: %w"` × 5), vary at least every other one
  using the operation's verb instead of a numeric index.
- **T11 — Adjacent error sites reading identically.** *Avoid:*
  scan error returns after writing a function. If two read
  identically, diverge them — one bare noun, one context prefix,
  one operation-name inline.
- **T12 — Redundant context (function name in its own error).**
  *Avoid:* never embed the function name in an error string
  returned from that function. The call stack provides it.
- **T13 — Bare `%w` wrapping where no caller branches on the
  sentinel.** *Avoid:* `%w` only if a caller calls `errors.Is` /
  `errors.As`. Otherwise `%v` or omit wrapping.

**Naming tells:**

- **T14 — `GetX` getter prefix.** *Avoid:* the exported first
  letter signals accessor. `Name()`, not `GetName()`.
- **T15 — Package-doubled types (`mail.MailMessage`,
  `cache.CacheEntry`).** *Avoid:* type name does not repeat the
  package. `mail.Message`, `cache.Entry`.
- **T16 — `Manager` / `Helper` / `Util` / `Service` suffixes on
  single-field types.** *Avoid:* name by what the type *is*, not
  by the noun-suffix template.
- **T17 — Over-descriptive locals in tight scopes.** *Avoid:*
  `for i := range items` and `m := items[i]`. Not
  `messageIndex := range messageList; currentMessage := …`.
- **T18 — Exported names that read like docstrings
  (`ProcessIncomingMessageWithRetries`).** *Avoid:* exported
  names are nouns or short verb phrases. Behavior detail goes in
  the doc comment.

**Structural tells:**

- **T19 — Reflexive `doc.go` / `errors.go` / `types.go` skeleton
  in every package.** *Avoid:* split files only when one became
  unwieldy. Empty `errors.go` with one error variable is the
  shape to delete.
- **T20 — Single-impl interfaces with no test fake, no DI seam,
  no ADR.** *Avoid:* before introducing an interface, name the
  second impl or test fake. If neither exists, use the concrete
  type.
- **T21 — `New<X>` constructors that only set fields.** *Avoid:*
  if `NewFoo` is `return &Foo{a: a, b: b}`, delete it; callers
  use the literal.
- **T22 — Defensive nil checks between same-package functions.**
  *Avoid:* trust internal callers. Validate at boundaries (user
  input, config load, external APIs). Boundary test: if the zero
  value can occur through the package's own API (constructor
  accepts nil, optional field), the check stays. If only
  constructed-and-handed-off code reaches it, it's T22.
- **T23 — Length checks before indexing on internal callers.**
  *Avoid:* let the runtime panic. Length-check at boundaries
  only.

**Test tells:**

- **T24 — Identical assertion phrasing copy-pasted across test
  files.** *Avoid:* assertion phrasing matches what the test is
  checking. Vary by test.
- **T25 — Tautological test cases.** *Avoid:* a case asserting a
  function returns its argument unchanged adds nothing. Delete.
- **T26 — Subtests for trivial scalar functions.** *Avoid:* one
  parent test with a few assertions when the function is
  `func Double(x int) int { return x*2 }`.

**Voice tells:**

- **T27 — Apologetic or hedging documentation.** *Avoid:* state
  invariants. "This may not handle every case" → either it does
  or there's a `// TODO:` with the gap.
- **T28 — Over-explanation of standard Go idioms.** *Avoid:*
  don't comment `defer mu.Unlock()`. Don't comment `if err != nil
  { return err }`. The Go reader knows.
- **T29 — Uniform sentence length across a file.** *Avoid:* read
  the file aloud after writing. If every sentence is the same
  length, vary.
- **T30 — Identical paragraph rhythm.** *Avoid:* if every doc
  paragraph is "Sentence one. Sentence two. Sentence three.",
  break the pattern.
- **T31 — Uniform verbosity — identical doc shape and length
  across a file.** *Avoid:* a 3-line helper's doc is two words.
  A 30-line state machine's is two paragraphs. Length follows
  complexity.
- **T32 — `Builder` patterns where a struct literal would
  suffice.** *Avoid:* `cfg := Config{A: 1, B: 2}`, not
  `cfg := NewConfigBuilder().WithA(1).WithB(2).Build()`. Builders
  earn their place only when construction is multi-stage and
  validates between stages.

When a tell is hard to spot at write-time, `/simplify` runs a
voice lens against the diff that names tells by number.

## Output

- Data goes to stdout.
- Status messages and counts go to stderr.
- Errors returned, not printed (except in main).

## Module Naming

Use `github.com/glw907/<project-name>` as the module path.
Go version in go.mod should match what is installed on the system
(currently 1.26.1).
