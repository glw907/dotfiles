---
name: go-conventions
description: >
  Mandatory rules for writing Go code on this workstation. Use before
  writing, reviewing, or modifying any Go file. Covers anti-patterns
  (unnecessary interfaces, builder patterns, defensive nil checks),
  project structure (cmd/ + internal/), cobra CLI shape, error
  wrapping, atomic file writes, table-driven tests, Makefile gates,
  naming, modern-stdlib idiom defaults (slices/maps/iter/slog/
  OnceValue), and the comment standard (Go Doc Comments, Effective Go).
  Every Go file, function, test, comment, and error message must conform.
---

# Go Conventions

Rules for writing Go utilities on this workstation. Code follows
**Effective Go**; comments follow **Go Doc Comments**
(https://go.dev/doc/comment). The linters are **gofmt** and **go vet**,
both wired into `make check`. The canonical exemplar is **the Go standard
library**: read the doc comments next to the code you are writing and
match their density, shape, and voice. This skill is the Go arm of the
authoring charter (`~/.claude/docs/authoring-charter.md`).

## Principles

Three principles carry every comment decision; the rest of this file
applies them to Go specifics.

- **Comment the why, not the what.** The code already states what it
  does. A comment earns its place when it carries a reason, a
  constraint, or a piece of evidence the code cannot.
- **Document the contract.** A doc comment states what a caller must
  know: the invariant, the unit, the nil-semantic, the concurrency
  hazard. Not the implementation.
- **Do not paraphrase the code.** If removing the comment leaves a
  competent Go reader no worse off, the comment should not exist. This
  is the single most effective filter against machine-shaped comments.

When the shape of a comment is in doubt, open the nearest standard-library
file and copy how its maintainers handled the same case.

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
- **Overuse of generics.** Concrete types unless the function operates
  on multiple types.
- **fmt.Sprintf for simple concatenation.** `path + "/" + name` is fine.
- **Defensive nil checks everywhere.** Trust internal code. Validate at
  boundaries (user input, external API responses).
- **Constants for strings used once.** Inline them.
- **Package-level init() functions.** Avoid. Pass dependencies explicitly.
- **`this`, `self`, or `me` as receiver names.** Use a short abbreviation
  of the type name: `func (e *Entry)`, not `func (self *Entry)`.
- **`Get` prefix on getters.** The exported first letter already signals
  accessor. Write `Name()` not `GetName()`.
- **`interface{}` instead of `any`.** Go 1.18+; `any` is canonical.
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

## Modern Stdlib Idioms

The Go we have is 1.21–1.26. Reach for the modern stdlib form by
default; the pre-1.21 spelling signals that the code predates the
toolchain. Each rule below names the preferred form and the one-line
reason.

### Sorting

`slices.SortFunc` / `slices.SortStableFunc` with `cmp.Compare` or
`cmp.Or`, not `sort.Slice` / `sort.SliceStable`. `slices.Sort(s)`
for `[]string` / `[]int`, not `sort.Strings` / `sort.Ints`. The
comparator returns `-1/0/+1`, so multi-key sorts collapse to one
`cmp.Or(...)` line.

```go
// pre-1.21
sort.SliceStable(xs, func(i, j int) bool {
    if xs[i].Rank != xs[j].Rank { return xs[i].Rank < xs[j].Rank }
    return xs[i].Name < xs[j].Name
})

// 1.21+
slices.SortStableFunc(xs, func(a, b X) int {
    return cmp.Or(cmp.Compare(a.Rank, b.Rank), cmp.Compare(a.Name, b.Name))
})
```

### One-shot init

`sync.OnceValue[T]` / `sync.OnceFunc`, not `sync.Once` paired
with a package-level result var. The `Once` + var + wrapper trio
exists only because pre-1.21 had no return-value form.

```go
// pre-1.21
var (
    cfgOnce sync.Once
    cfg     *Config
)
func Cfg() *Config { cfgOnce.Do(func() { cfg = load() }); return cfg }

// 1.21+
var Cfg = sync.OnceValue(func() *Config { return load() })
```

### Iterators

`iter.Seq[T]` / `iter.Seq2[K,V]` for push iterators with ≥ 2
call sites. Hand-rolled `Next()/Stop()` pairs and `ForEach(func)`
callbacks are pre-1.23. Single-caller helpers can stay as plain
functions. The win is when consumers want real `break` and
loop-local state.

### Logging

`log/slog` for internal-package log calls. `fmt.Fprintln(os.Stderr,
...)` is acceptable only in `cmd/` for user-facing startup errors
that aren't log-shaped. Inside `internal/`, structured log records
beat printf strings; the receiver can filter, route, or drop them.

### Loops

`for range N` when the index is never read inside the body. The
classic three-clause `for i := 0; i < N; i++` survives only when
the body uses `i`.

```go
for range rows { ... }              // 1.22+
for i := 0; i < rows; i++ { ... }   // only if i is read
```

### Maps

`maps.Keys` / `maps.Values` (`iter.Seq` in 1.23) with
`slices.Sorted` for deterministic order, not collect-then-sort
loops. `maps.Clone` over hand-rolled copy loops.

```go
keys := slices.Sorted(maps.Keys(m))
```

### Builtins

`min` / `max` / `clear` are language builtins (1.21). Conditional
helpers (`if a < b { return a }; return b`) get inlined to the
builtin. Generic `MinInt` / `MaxInt` helpers go away.

### Comparators

`cmp.Or(a, b, c)` for nil/zero coalescing across a fixed list of
candidates, not stacked `if a != "" { return a }` chains. The
absence is a voice-lens flag, not a grep gate: a manual coalescing
chain that `cmp.Or` would collapse is what `/simplify` Agent 3
looks for.

### Errors

`errors.Join(errs...)` for multi-error accumulation that all
callers see. First-error-wins still wins when call order matters
or when one error semantically supersedes the rest.

### Loop scoping (1.22)

Every `for` loop variable is per-iteration. Delete leftover
`x := x` shadow lines (workarounds for the pre-1.22
shared-variable footgun).

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
- Subcommands only when the tool has distinct modes that don't flatten
  to flags. Prefer a flat command with flags for simple tools.

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
  directory"`. Never start with `"failed to"`.
- **`%w` only when callers branch on the sentinel.** Use `%w` if
  any caller calls `errors.Is` / `errors.As` on the result.
  Otherwise `%v` or omit wrapping. Reflexive `%w` exposes the
  underlying error type as part of the package's API surface.
- **Adjacent error sites diverge in phrasing.** If two error
  returns in one function read identically, vary them: bare
  noun, context prefix, or operation-name inline.
- **No function name in its own errors.** The call stack provides
  it. State the condition, not the location.
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

### Assertion Discipline (no useless tests)

For every test, ask: "what would have to be wrong about the code
under test for this test to fail?" If the answer is "nothing
realistic," the test is theatre. Specific anti-patterns to reject
on sight:

- **Silent-success fakes.** A fake/mock whose mutation methods
  (`Send`, `Append`, `Copy`, `CreateDraft`, …) always `return nil`
  makes every error-path test in the suite trivially pass. Rule:
  any fake method that models a fallible production call gets a
  per-method `*Err error` field; the fake consults it on call;
  error-path table rows set it. Same shape as ADR-0230's Pass 40.1
  fix template: extend `MockBackend`, `fakeClient`, `fakeCache`,
  not the call sites.
- **Self-derived expectations.** Computing `want` from the system
  under test (`wantCol := m.popover.width()`) tests that a function
  equals itself. Hard-code the expected value, or derive it from
  inputs the test owns.
- **Trivially-true style assertions.** `style.Render("x") != ""`
  passes for the zero-value `lipgloss.Style{}`, asserting nothing
  about styling. Assert the resolved attribute instead:
  `style.GetForeground() == expected`, `style.GetBold()`, etc.
  (See `elm-conventions` for the bubbletea-specific tells.)
- **Cmd-shape assertions that don't invoke.** `if cmd != nil`
  proves the function returned *something*, not that the right
  thing happened. Invoke the cmd, type-switch on the resulting
  `tea.Msg`, assert the message's payload.
- **Skipped placeholder tests.** A `t.Skip("implement later")`
  at the top of a test function body is green CI signal with
  zero coverage. Either write the assertion or delete the
  function. Conditional skips (env-gated integration tests,
  GOOS-specific tests, missing-fixture guards) are fine.
- **Goldens are last-resort.** Snapshot tests catch *that*
  output changed, not *what* should have changed. Mutation
  testing fights them. Use goldens only for high-fidelity render
  surfaces where the value is the literal bytes; for everything
  else, assert on parsed structure.

The strong signal for assertion meaningfulness is mutation
testing. Poplar runs `make check-deep` (gremlins) at pass-end;
surviving mutants are tests that can't tell correct code from
broken code. Treat surviving mutants as bug reports against the
test suite, not the source.

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
lint:    golangci-lint run ./...
install: go install ./cmd/tool-name
check:   vet lint test
clean:   rm -f $(BINARY)
```

`make check` is the gate before committing, and every step in it
gates. A check either gates or does not exist. Never guard a step
with `command -v tool || echo "skipping"`: that turns a missing or
misconfigured tool into a green build, and the gate then decays
silently for months. If a tool is required, let its absence fail
loudly. If reproducible tool versions matter, pin them in a
separate `tools/go.mod` and invoke them with `go run -C tools`,
which keeps the product module's dependency graph clean.

No code generation, no build tags, no CGO.

## Linting

`.golangci.yml`:

```yaml
version: "2"

linters:
  default: none
  enable:
    - errcheck
    - govet
    - ineffassign
    - staticcheck
    - unused
    - modernize
    - misspell
    - unparam
  settings:
    errcheck:
      check-type-assertions: true

formatters:
  enable:
    - gofmt
    - goimports
```

The `version: "2"` key is required. A v1-schema file fails against a
v2 binary with "unsupported version of the configuration", which is
easy to mistake for a missing linter when a Makefile swallows the
error.

`default: none` plus an explicit enable list is the legible form,
and it is also load-bearing: v2's `default: none` drops errcheck,
unused, and ineffassign unless you name them. `staticcheck` in v2
subsumes the old `gosimple` and `stylecheck`. `modernize` (built in
since v2.6.0) reports stale stdlib idioms, so a separate grep pass
for them is redundant. Verify a config with
`golangci-lint config verify` before committing it.

No `nolint` pragmas. Fix the code instead. Where a project must
allow them, enable `nolintlint` and require both a rule id and a
reason, so every suppression is legible to a reviewer.

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

## Comments

Comments follow **Go Doc Comments** (https://go.dev/doc/comment).
The exemplar is the standard library: when a comment's shape is in
doubt, read the doc comments next to the same kind of code in the
stdlib and match them. `go vet` flags malformed doc comments; `gofmt`
canonicalizes their layout. The subsections below apply the standard's
principles to the cases that come up most.

### Comment-or-not (write-time gate)

Before reaching for the placement rubric below, run this three-question
gate:

```
(a) Does the function/type name already say this?
(b) Is the why obvious from the next ≤5 lines?
(c) Would a reader otherwise miss a hidden constraint, invariant,
    or surprising consequence?
```

Skip rule: if (a) or (b), don't write the comment. Write rule:
only when (c). **Mechanical test: if the comment paraphrases the
next ≤5 lines, delete it.** The paraphrase test is the primary
check, and the single most effective filter against a machine-shaped
in-function comment.

Doc comments on unexported symbols are opt-in, not opt-out: comment
only when name and signature leave something a competent Go reader
would not immediately know. Silence is the default, the same as the
standard library's own unexported code.

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
- **Boolean returns:** use "reports whether": `// HasPrefix reports
  whether s begins with prefix.`
- **Length proportional to non-obvious behavior.** 1 sentence is
  the floor; expand only when there is a contract, hazard, or
  surprising default to communicate. Never expand to fill space.
- **No first person.** Third-person declarative for godoc. "We"
  permitted only at package-doc level (project voice). No "you".
- **No hedging.** "maybe", "perhaps", "should probably", "might",
  "could" are forbidden in doc comments.

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

### Comment review

Review comments against Go Doc Comments and the standard library, not a
fixed checklist. Read the doc comments next to the same kind of code in
the stdlib and ask whether yours match their density, shape, and candor.
The recurring failure mode is the paraphrase comment that restates the
code; run the write-time gate's mechanical test on every in-function
comment before saving. `/simplify` runs a quality lens over the diff and
flags comments that paraphrase the code or restate a type.

## Output

- Data goes to stdout.
- Status messages and counts go to stderr.
- Errors returned, not printed (except in main).

## Module Naming

Use `github.com/<owner>/<project-name>` as the module path, matching
the repository it lives in. The Go version in go.mod should match what
is installed on the system (currently 1.26.1).
