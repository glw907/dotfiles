# Go Comment Voice Guide

Canonical reference for comment placement, density, voice, and error phrasing.
Applies to poplar and to every Go project on this workstation via `go-conventions`.

The threat model is contributor recruitment. Readers who recognize AI-generated Go
disengage. This guide names the tells, provides mechanical avoidance rules, and
picks a voice. Apply it at write-time; `/simplify` catches drift.

---

## §1. Decision Rubric

Apply this before writing any comment.

```
1. Is the symbol unexported?
   YES → Skip to step 2.  NO → Doc comment required (step 3).

2. Does the unexported symbol have unobvious behavior that the name
   doesn't convey?
   YES → Short doc comment, same shape as exported.  NO → No comment.

3. Is the public API contract fully implied by the name + signature?
   YES → One sentence. Period.  NO → One sentence + whatever the caller
   needs to know. No implementation detail.

4. Is there a concurrency hazard, surprising default, or known
   platform-specific behavior?
   YES → Add it.  NO → Stop.

5. Inside a function body: does this block differ from what the
   name/control-flow implies, or is the reason for the approach
   non-obvious?
   YES → One-line why-comment.  NO → No comment.

6. Error strings: lowercase, no trailing period, context-first.
   Never start with "failed to".
```

A comment that restates the code, describes what already follows from
the name, or explains an internal algorithm to a caller has failed this
rubric.

---

## §2. Placement × Circumstance Matrix

Per cell: comment or not, target length, what to include/exclude. All
examples cite source file:line from the research files.

### Package doc (`// Package foo …`)

Required sentence shape: `// Package [name] …` — first word "Package",
second the package name, third starts the description. This is mechanical.

| Circumstance | Length | Include | Exclude |
|---|---|---|---|
| Trivial / one-file utility | 1 sentence | What the package does | Nothing else |
| Protocol/format-specific | 1–3 paragraphs | RFC refs, import-side setup, security constraints | Algorithm detail |
| Tricky default or opt-in | +1 paragraph | The gotcha and how to avoid it | Rationale for the gotcha |
| Deprecation | `Deprecated:` paragraph | Replacement | Nothing else |

```go
// Package tsdb implements a time series storage for float64 sample data.
```
`2026-05-04-third-party-exemplars.md`, Prometheus TSDB, db.go:14–15

```go
// Package imapclient implements an IMAP client.
//
// # Charset decoding
//
// By default, only basic charset decoding is performed. For non-UTF-8 decoding
// of message subjects and e-mail address names, users can set Options.WordDecoder.
```
`2026-05-04-third-party-exemplars.md`, emersion/go-imap, imapclient/client.go:1–20

### Exported type (struct, interface, alias)

Always comment. Length proportional to non-obvious behavior.

| Circumstance | Length | Include | Exclude |
|---|---|---|---|
| Self-evident | 1 sentence | What instances represent | Field-level detail |
| Contract governs caller | 1–4 paragraphs | Caller obligations, zero-value, copy safety | Implementation |
| Concurrency hazard | +1 sentence | "Must not be copied after first use." | Reason |
| Interface with non-obvious methods | 1 sentence on type + 1 per method | Return invariants, contract violations | Internal state |

```go
// A Mutex is a mutual exclusion lock.
// The zero value for a Mutex is an unlocked mutex.
//
// A Mutex must not be copied after first use.
```
`2026-05-04-stdlib-exemplars.md`, sync/mutex.go:17–29

```go
// A Handler responds to an HTTP request.
//
// ServeHTTP should write reply headers and data to the ResponseWriter
// and then return. Returning signals that the request is finished; it
// is not valid to use the ResponseWriter or read from the Request.Body
// after or concurrently with the completion of the ServeHTTP call.
```
`2026-05-04-stdlib-exemplars.md`, net/http/server.go:64–91

### Exported function / method

Always comment. Length proportional to non-obvious behavior and contracts.

| Circumstance | Length | Include | Exclude |
|---|---|---|---|
| Name + signature fully describes | 1 sentence | Opens with function name | Implementation |
| Non-obvious return invariant | +1 sentence | "err == nil not err == EOF" | How it's achieved |
| Multiple behaviors / modes | 1 sentence + list | Each behavior | Priority mechanism |
| Concurrency safe / panics on misuse | +1 sentence | Claim / exact condition | Reason |
| Deprecation | `Deprecated:` paragraph | Replacement | Original motivation |

```go
// Copy copies from src to dst until either EOF is reached on src or an error
// occurs. It returns the total number of bytes written and the first error
// encountered while copying, if any.
//
// A successful Copy returns err == nil, not err == EOF.
// Because Copy is defined to read from src until EOF, it does not treat an
// EOF from Read as an error to be reported.
```
`2026-05-04-stdlib-exemplars.md`, io/io.go:375–385

```go
// Referer returns the referring URL, if sent in the request.
//
// Referer is misspelled as in the request itself, a mistake from the
// earliest days of HTTP. This value can also be fetched from the Header map
// as Header["Referer"]; the benefit of making it available as a method is
// that the compiler can diagnose programs that use the alternate (correct
// English) spelling req.Referrer() but cannot diagnose programs that use
// the Header map directly.
```
`2026-05-04-stdlib-exemplars.md`, net/http/request.go:473–479

### Exported const / var

| Circumstance | Length | Include |
|---|---|---|
| Self-documenting name | 1 sentence | What the value means |
| Sentinel / error var | 1 sentence | When it's returned |
| Tuning constant | 1 sentence + optional note | Basis for the value |

```go
// ErrLeadershipLost is returned when a leader fails to commit a log entry
// because it's been deposed in the process.
ErrLeadershipLost = errors.New("leadership lost while committing log")
```
`2026-05-04-third-party-exemplars.md`, HashiCorp raft, api.go:30–75

### Struct field (exported and unexported)

Self-documenting fields: no comment. Comment only when the type alone
doesn't describe valid values, nil semantics, or role-switching behavior.

```go
// Body is the request's body.
//
// For client requests, a nil body means the request has no body, such as
// a GET request. …
// For server requests, the Request Body is always non-nil but will return
// EOF immediately when no body is present.
//
// Body must allow Read to be called concurrently with Close.
Body io.ReadCloser
```
`2026-05-04-stdlib-exemplars.md`, net/http/request.go:173–186

```go
mu      sync.Mutex // guards following
```
`2026-05-04-stdlib-exemplars.md`, net/http/server.go:643–659

### Unexported symbol (type, func, var)

Default: no comment. Comment only when the name + signature leaves
something unobvious.

```go
// copyBuffer is the actual implementation of Copy and CopyBuffer.
// if buf is nil, one is allocated.
func copyBuffer(dst Writer, src Reader, buf []byte) (written int64, err error) {
```
`2026-05-04-stdlib-exemplars.md`, io/io.go:396–397

```go
// chunkWriter writes to a response's conn buffer, and is the writer
// wrapped by the response.w buffered writer.
//
// chunkWriter also is responsible for finalizing the Header, including
// conditionally setting the Content-Type and setting a Content-Length
// in cases where the handler's final output is smaller than the buffer
// size. See the comment above (*response).Write for the entire write flow.
type chunkWriter struct {
```
`2026-05-04-stdlib-exemplars.md`, net/http/server.go:343–352

### Inline mid-function `//` comment

Default: no comment. Comment when:
- A branch takes a non-obvious path (why, not what)
- Protocol or spec deviation (rule + issue link)
- Historical context required to prevent a regression (paragraph)
- Lock invariant (`// c.mu must be held.`)

```go
// If the reader has a WriteTo method, use it to do the copy.
// Avoids an allocation and a copy.
if wt, ok := src.(WriterTo); ok {
```
`2026-05-04-stdlib-exemplars.md`, io/io.go:399–401

```go
// QUIRK: RFC 2045 section 6.4 specifies that multipart messages can't have
// a Content-Transfer-Encoding other than "7bit", "8bit" or "binary".
// However some messages in the wild are non-conformant …
// See https://github.com/emersion/go-message/issues/48
```
`2026-05-04-third-party-exemplars.md`, go-message, entity.go:34–39

### TODO / HACK / FIXME / BUG markers

- `// TODO(username): …` — open question or deferred work with owner.
  Bare `// TODO:` acceptable. Never without a real decision pending.
- `// HACK:` / `// XXX:` — known deviation. One sentence on why. Source
  must be citable.
- `// FIXME:` / `// BUG:` — known incorrect behavior. Include reproduction.
- Never `// for now` or `// temporary` without one of these markers.

### Test function name / table-case label

Test function names need no docstring. Table case `name:` is a noun phrase,
not a sentence: `"empty input"` not `"returns error when input is empty"`.
No per-case doc comment.

---

## §3. Density Expectations by File Type

Density is comments per 100 lines of non-blank, non-comment code.
Upper bounds for healthy code; the lower bound is zero for internal-only packages.

| File type | Upper bound | Notes |
|---|---|---|
| Protocol parser (IMAP, JMAP) | 12–18 | RFC deviations, invariants, why-comments |
| Public API surface | 8–14 | Godoc sentences; fewer inline |
| Data structure definitions | 4–8 | Field invariants, nil semantics |
| UI rendering (bubbletea View) | 2–6 | Layout math only |
| Internal helpers | 1–4 | Near zero is correct for obvious helpers |
| Test files | 0–3 | Name carries documentation |
| Config / schema | 4–10 | Field semantics, valid ranges |

**Reference calibration:**
- `net/http/server.go` (~3500 lines): ~14/100. Upper end of healthy density
  for protocol code with years of accumulated edge cases.
- `io/io.go` (~620 lines): ~8/100, almost entirely exported symbol docs.
  Zero inline restatements, zero TODOs. Target for a clean public interface.
- `sync/once.go` (~80 lines): ~15/100. Includes one load-bearing block that
  explains why the obvious CAS approach is wrong — without it the code
  invites a regression.
- `encoding/json/encode.go` (~1400 lines): ~6 inline comments/100 lines of
  function body. Internal complexity carries explanation; boilerplate does not.

Uniform density across functions of different complexity is itself a tell
(T3). Simple getters get one line; `io.Reader` gets a multi-paragraph contract.

---

## §4. Voice Palette

Five archetypes from the research: **Pike-aphoristic** (4–12 word commands,
no hedging); **Cheney-conversational** ("you"-addressed, problem then
solution, collegial); **stdlib-formal** (third-person declarative, no first-
person, rationale in one sentence); **Cox-measured** (engineering tradeoff
framing, longer paragraphs, context before principle); **Gerrand-welcoming**
(stdlib-formal but warmer, first-person plural for project voice, encouraging).

Third-party adds: **Charm-warm** (close to Gerrand), **HashiCorp-terse-formal**
(close to stdlib, no warmth), **Prometheus-engineering-blog** (RFC-like, for
infrastructure, not UI).

### Poplar's target: stdlib-formal with register shifts

Poplar's v0.9.0 contributors are experienced Go developers; Gerrand-warmth
signals "tutorial" and underestimates them. Charm's own libraries use
stdlib-formal for internal types and a light Gerrand-welcoming tone for
package docs — matching that is credible because poplar builds on bubbletea.
Pike-aphoristic is correct for error strings and proverbs, not API contracts.

**Register shifts:**
- **Package docs:** lean Gerrand-welcoming. One example per non-obvious
  import concern. First-person plural permitted: "For non-UTF-8 decoding,
  set Options.WordDecoder" — not "you can set."
- **Exported type and function docs:** stdlib-formal. Third-person, name-
  first, period-last. No "you", no "we", no hedging.
- **Internal helpers:** Pike-terse. One sentence. If the name says it, none.
- **Inline mid-function:** fragments acceptable (`// fast path`, `// guards
  following`). Full sentences for multi-line historical context.
- **Error strings:** Pike-aphoristic. Noun phrase, never a full predicate.

---

## §5. Phrasing Patterns

### Sentence shape

**Doc comments:** declarative, name-first. The first word of the comment
is the name of the symbol being documented.

```
// Foo does X.        ← correct
// The Foo function…  ← incorrect
// This does X.       ← incorrect
```

Exception: type comments may use "A" or "An" as article:

```
// A Request represents an HTTP request received by a server
// or to be sent by a client.
```
Source: `2026-05-04-stdlib-exemplars.md`, net/http/request.go:107–113

Boolean-returning functions use "reports whether":
```
// HasPrefix reports whether the string s begins with prefix.
```
Source: `2026-05-04-essays-and-proverbs.md`, go.dev/doc/comment

**Inline comments:** fragments acceptable. `// fast path`, `// src stopped
early; must have been EOF.` Period optional on fragments; required on full
sentences.

### Length distribution

- Exported function doc: 1–5 sentences. Prefer shorter. Only expand if
  there's a non-trivial invariant, a surprising behavior, or a
  concurrency contract.
- Package doc: 1 paragraph required. Up to 4 paragraphs for complex
  packages. Headings (`# Section`) when a topic warrants it.
- Inline comment: 1 line preferred. Up to one paragraph for historical
  context that prevents a regression.

### Vocabulary register

- **Third-person throughout** for godoc. No "you", no "we", no "I".
- **First-person plural permitted only** in package-level docs when
  speaking for the project (Gerrand register).
- **Hedging words** ("maybe", "perhaps", "should probably", "might",
  "could") are forbidden in doc comments. They are factual statements,
  not suggestions.
- **"Note that"** is a flag that something important follows. Reserve it.
  Do not use as a sentence opener for routine observations.
- **"For now"** is forbidden. It implies a todo without stating one. Use
  a `// TODO:` instead.

### Punctuation

- Doc comments end with a period. Always.
- Fragment inline comments: period optional, consistent within a file.
- Em-dash (`—`) in prose comments: fine for parenthetical asides.
- Backticks for Go identifiers in doc comments: `[Name]` for cross-links;
  bare backtick `` `identifier` `` for inline literals in flowing prose.

### Source disagreement: sentence fragments in inline comments

Google distinguishes full-sentence comments (require capitalization and
terminal period) from fragments (neither required). CodeReviewComments
requires "full sentences" only for declaration comments. Neither addresses
`// fast path` style fragments.

**Poplar default:** inline fragments are lowercase, no trailing period.
Full-sentence inline comments follow standard English punctuation.

---

## §6. Error String Phrasing

### Hard rules (cross-source consensus)

1. **Lowercase.** Never capitalize the first word unless it's a proper
   noun, an acronym, or a package name used as prefix. The error will
   appear after context from the caller: `log.Printf("Reading %s: %v",
   filename, err)` must not produce a mid-sentence capital.

2. **No trailing period.** For the same reason.

3. **Context-first.** Errors that identify their package or operation are
   more useful far from the call site. `"image: unknown format"` not
   `"unknown format"`. `"http: named cookie not present"` not `"named
   cookie not present"`.
   Source: `2026-05-04-authoritative-docs.md`, Effective Go § Errors

4. **No "failed to".** Uber's rule, but well-supported by stdlib evidence.
   The error chain `"failed to x: failed to y: failed to create store: the
   error"` degrades into noise. Strip it: `"x: y: new store: the error"`.
   Stdlib models this: `"short write"`, `"invalid write result"`,
   `"unexpected EOF"` — none of them say "failed to."
   Source: `2026-05-04-authoritative-docs.md`, Uber § Error Wrapping

### Patterns from stdlib and emersion

```go
// io — bare noun phrases
errors.New("short write")
errors.New("short buffer")
errors.New("unexpected EOF")

// net/http — package-prefixed
errors.New("http: no such file")
errors.New("http: named cookie not present")
errors.New("http: Server closed")

// encoding/json — package:operation format
fmt.Errorf("json: unknown field %q", key)
fmt.Errorf("json: invalid number literal %q", numStr)

// emersion/go-imap — context-prefixed with colon
fmt.Errorf("in continue-req: %v", err)
fmt.Errorf("in %v: %v", token, err)
fmt.Errorf("imapclient: server sent PREAUTH on unencrypted connection")

// HashiCorp raft — plain noun clauses
errors.New("node is the leader")
errors.New("leadership lost while committing log")
errors.New("bootstrap only works on new clusters")
```

### `%w` vs `%v` vs bare `err`

- `%w` when the caller **might branch on the sentinel** via `errors.Is`
  or `errors.As`. Not otherwise.
- `%v` when wrapping for context but the caller has no reason to inspect
  the underlying type.
- Bare `err` when the caller already has the full context and re-wrapping
  would be noise.

### Adjacent error sites

Two adjacent returns in one function must not use identical phrasing unless
the failures are genuinely identical. emersion/go-imap models this:
```go
fmt.Errorf("in continue-req: %v", err)
fmt.Errorf("in response: cannot read tag: %v", c.dec.Err())
fmt.Errorf("in %v: %v", token, err)
fmt.Errorf("received unmatched continuation request")
```
`2026-05-04-third-party-exemplars.md`, go-imap, client.go:215–794

---

## §7. AI Tells — Catalogue and Avoidance

This section is self-contained. It is copied verbatim into `go-conventions`
and referenced by `/simplify`. Each entry: name, placement, AI-shaped
example, recognition cue, human counter-example (verbatim from research),
mechanical avoidance rule.

### Precedence rules

- **T1 outranks T2.** When an unexported symbol has a comment that
  restates its code, classify under T1. T2 is reserved for cases where
  the doc adds new information but is still unnecessary because the
  name suffices.
- **T11 covers within-function adjacent error sites; T10b covers cross-
  function chorus in one file.** Don't double-flag.

---

### T1: WHAT-comment restating the next line

**Placement:** inline mid-function.

**AI example:**
```go
// Iterate over all messages
for _, msg := range msgs {
```

**Cue:** the comment is a prose translation of the code that follows.
Remove the comment and nothing is lost.

**Human counter-example:**
```go
// If the reader has a WriteTo method, use it to do the copy.
// Avoids an allocation and a copy.
if wt, ok := src.(WriterTo); ok {
```
Source: `2026-05-04-stdlib-exemplars.md`, io/io.go:399–401

**Avoidance rule:** Before writing an inline comment, delete it and read
the next line. If the code already says what the comment said, delete it
permanently.

---

### T2: Godoc on every unexported symbol regardless of need

**Placement:** unexported type, func, var.

**AI example:**
```go
// parseHeader parses the message header.
func parseHeader(data []byte) (Header, error) {
```

**Cue:** the function name already says "parseHeader." The comment adds
zero information.

**Human counter-example:**
```go
// copyBuffer is the actual implementation of Copy and CopyBuffer.
// if buf is nil, one is allocated.
func copyBuffer(dst Writer, src Reader, buf []byte) (written int64, err error) {
```
Source: `2026-05-04-stdlib-exemplars.md`, io/io.go:396–397

This comment earns its place: the function name doesn't explain which
exported functions it serves or the nil buf behavior.

**Avoidance rule:** Comment an unexported symbol only if its name + signature
leaves something unobvious. Ask: "If I delete this comment, does a reader
lose information they need?" If no, delete it.

---

### T3: Uniform comment density across functions of different complexity

**Placement:** any.

**AI example:** Every function in a file, including trivial getters and
complex parsers, has a two-sentence doc comment of identical length.

**Cue:** scrolling the file, comments have the same visual weight
regardless of the function body below them.

**Human counter-example:** `io/io.go` — `LimitReader` gets one sentence;
`io.Reader` gets a multi-paragraph contract specifying edge cases. The
disparity is correct.

Source: `2026-05-04-stdlib-exemplars.md`, io/io.go:440–442, 55–86

**Avoidance rule:** After writing comments, scan them. If every function
has comments of the same length, something is wrong. Short obvious
functions get one sentence; complex functions get as much as the contract
requires.

---

### T4: Hedge phrases — "for now", "Note:", unlinked "TODO"

**Placement:** inline, doc comment.

**AI example:**
```go
// For now, we only support ASCII filenames.
// TODO: handle unicode
```

**Cue:** "for now" is never a valid technical description. The bare TODO
without an issue link or owner is a cleanup stub rather than a real
deferred decision.

**Human counter-example:**
```go
// TODO(bradfitz): let ServeHTTP handlers handle
// requests with non-standard expectations? Seems
// theoretical at best, and doesn't fit into the
// current ServeHTTP model anyway.
```
Source: `2026-05-04-stdlib-exemplars.md`, net/http/server.go:2182–2191

This TODO names an owner, frames the open question, and includes the
reason it's deferred.

**Avoidance rule:** Replace "for now" with either a TODO that names a
decision (`// TODO: switch to unicode paths once go-message supports it`)
or nothing. Bare `// TODO: improve this` is not acceptable.

---

### T5: Task-framing comments — "added for X flow", "used by Y"

**Placement:** inline, unexported symbol doc.

**AI example:**
```go
// added for the attachment picker flow
type pickerState struct {
```

**Cue:** the comment describes why the code was written (commit history),
not what it does or why it behaves as it does. It reads like a PR
description, not a code comment.

**Human counter-example:** No equivalent exists in the research because
experienced authors don't write these. The commit message is the place for
this information.

**Avoidance rule:** If the comment describes the task that motivated the
code, delete it. Commit messages carry that. Comments carry behavioral
facts.

---

### T6: First-person plural ("we") inside unexported docs

**Placement:** unexported symbol doc, inline.

**AI example:**
```go
// We use this to track which folders the user has opened.
var openedFolders map[string]bool
```

**Cue:** "we" implies a narrator explaining code to a reader. Docs are
specifications, not explanations.

**Human counter-example:**
```go
// Catching panics is incredibly useful for restoring the terminal to a
// usable state after a panic occurs. When this is set, Bubble Tea will
// recover from panics, print the stack trace, and disable raw mode.
withoutCatchPanics
```
Source: `2026-05-04-third-party-exemplars.md`, bubbletea, tea.go:101–105

Third-person declarative. No "we."

**Avoidance rule:** Search for "we" in comments. In exported docs, replace
with third-person. In unexported internals, delete if the sentence still
reads clearly without it.

---

### T7: Every doc comment begins "Foo does X"

**Placement:** exported function / method.

**AI example:**
```go
// QueryFolders retrieves folder list from the cache.
// LoadMessage loads a message from the backend.
// UpdateBadge updates the unread badge count.
```

**Cue:** every function doc in the file has the same subject-verb-object
structure and identical sentence length.

**Human counter-example:**
```go
// HasPrefix reports whether the string s begins with prefix.

// Referer returns the referring URL, if sent in the request.

// A successful Copy returns err == nil, not err == EOF.
// Because Copy is defined to read from src until EOF, it does
// not treat an EOF from Read as an error to be reported.
```
Source: `2026-05-04-stdlib-exemplars.md`, multiple files

The shapes vary: predicate ("reports whether"), return clause ("returns
… if"), invariant note. The length varies.

**Avoidance rule:** After writing a function's doc comment, look at the
three nearest function docs. If all four follow the same pattern, rewrite
at least two. Vary between: return-clause form, predicate form, invariant
form, or a two-sentence contract.

---

### T8: Multi-paragraph docstrings on self-describing functions

**Placement:** exported function.

**AI example:**
```go
// Add adds a new item to the list. It appends the item to the
// internal slice and updates the length counter. This method
// is safe for concurrent use by multiple goroutines.
//
// Note that the item is appended at the end of the list, not
// at the beginning. The index of the new item is len-1 after
// the call completes.
func (l *List) Add(item Item) {
```

**Cue:** the doc comment is longer than the function body would be for a
simple append. Every sentence restates something the name or code implies.

**Human counter-example:**
```go
// MarshalIndent is like Marshal but applies Indent to format the output.
// Each JSON element in the output will begin on a new line beginning with prefix
// followed by one or more copies of indent according to the indentation nesting.
func MarshalIndent(v any, prefix, indent string) ([]byte, error) {
```
Source: `2026-05-04-stdlib-exemplars.md`, encoding/json/encode.go:232–235

Two sentences for a function that wraps another. Not more.

**Avoidance rule:** Doc comment length is proportional to the number of
non-obvious behaviors. Count them; that's the number of sentences, minus
the name-first opener.

---

### T9: Per-case docstrings on every table-test case

**Placement:** test file.

**AI example:**
```go
{
    name: "TestClassifyDisposition returns attachment when disposition is attachment",
    input: …,
    want: …,
},
```

**Cue:** the `name` field restates the test function's name and the assertion.

**Human counter-example:** stdlib uses `"empty input"`, `"with header"`,
`"nil body"`. The test body is the documentation.

**Avoidance rule:** `name:` is a noun phrase. No "returns", "should", "when",
"given". Explanation goes as an inline comment in the case body.

**Extension — test function names.** The same anti-pattern appears at
the function level: `TestQueueOp_Atomicity_FlagAppliesOptimistic`
encodes a sentence-form assertion in the test name. Convert to a
noun-phrase suffix (`TestQueueOp_OptimisticFlagApply`) or split into
narrower tests so the name describes what's being tested, not the
expected behavior.

---

### T10: `fmt.Errorf("failed to X: %w", err)` chorus

**Placement:** error strings.

**AI example:**
```go
if err := db.Open(); err != nil {
    return fmt.Errorf("failed to open database: %w", err)
}
if err := db.Migrate(); err != nil {
    return fmt.Errorf("failed to run migrations: %w", err)
}
if err := db.Query(q); err != nil {
    return fmt.Errorf("failed to execute query: %w", err)
}
```

**Cue:** every error return reads identically. "Failed to X" accumulates:
`"failed to open: failed to connect: failed to dial: connection refused"`.

**Human counter-example:**
```go
errors.New("short write")           // bare noun
fmt.Errorf("json: unknown field %q", key)   // package-prefixed
fmt.Errorf("in continue-req: %v", err)      // context-prefixed
```
`2026-05-04-stdlib-exemplars.md` io; `2026-05-04-third-party-exemplars.md` emersion

**Avoidance rule:** Never start an error string with "failed to." Use a
bare noun clause (`"open db"`, `"read header"`) or a context prefix
(`"json: unknown field %q"`, `"in %v: %v"`).

---

### T10b: Cross-function error chorus in one file

**Placement:** error strings across multiple functions in one file.

**AI example:**
```go
func migrateV1(tx *sql.Tx) error {
    if err := …; err != nil { return fmt.Errorf("migrate v1: %w", err) }
}
func migrateV2(tx *sql.Tx) error {
    if err := …; err != nil { return fmt.Errorf("migrate v2: %w", err) }
}
func migrateV3(tx *sql.Tx) error {
    if err := …; err != nil { return fmt.Errorf("migrate v3: %w", err) }
}
```

**Cue:** N similarly-shaped functions in one file each return errors of
identical template, differing only in the version literal. T10 doesn't
catch this (no "failed to") and T11 doesn't catch this (not adjacent
within one function), but the file-level rhythm reads machine-shaped.

**Human counter-example:** stdlib migration-style code uses real prose
keyed to the operation:
```go
fmt.Errorf("create folders table: %w", err)
fmt.Errorf("seed default folders: %w", err)
fmt.Errorf("backfill exists_total: %w", err)
```

**Avoidance rule:** in a file where N similarly-shaped functions all
return errors of identical template, vary at least every other one.
Use the operation's verb (`"create"`, `"seed"`, `"backfill"`) instead
of a numeric index.

---

### T11: Adjacent error sites reading identically

**Placement:** error strings, function body.

**AI example:**
```go
body, err := io.ReadAll(r.Body)
if err != nil {
    return fmt.Errorf("failed to read body: %w", err)
}
header, err := parseHeader(body)
if err != nil {
    return fmt.Errorf("failed to parse header: %w", err)
}
```

**Cue:** identical verb, identical template — interchangeable error messages.

**Human counter-example:**
```go
fmt.Errorf("in continue-req: %v", err)
fmt.Errorf("in response: cannot read tag: %v", c.dec.Err())
fmt.Errorf("received unmatched continuation request")
```
`2026-05-04-third-party-exemplars.md`, go-imap, client.go:215–794

**Avoidance rule:** Scan error returns after writing a function. If two
read identically, diverge them: one bare noun, one context prefix, one
formatted with the operation name inline.

---

### T12: Redundant context — error includes the function name

**Placement:** error strings.

**AI example:**
```go
func (a *Account) QueryFolder(id string) (*Folder, error) {
    …
    return nil, fmt.Errorf("QueryFolder: folder %q not found", id)
}
```

**Cue:** `QueryFolder` appears in the error string, but the caller already
knows it called `QueryFolder`. The function name is noise in the chain.

**Human counter-example:**
```go
errors.New("node is not the leader")
errors.New("snapshot restored while committing log")
```
Source: `2026-05-04-third-party-exemplars.md`, HashiCorp raft, api.go

No function names. State is described, not the call stack.

**Avoidance rule:** Never embed the function name in an error string
returned from that same function. The call stack provides it; the error
provides the condition.

---

### T13: Bare `%w` wrapping where no caller branches on the sentinel

**Placement:** error handling.

**AI example:**
```go
return fmt.Errorf("get message: %w", err)
```
…where no caller ever calls `errors.Is` or `errors.As` on the result.

**Cue:** `%w` exposes the error type as part of the package's API contract.
Using it reflexively where no sentinel check exists is excess API surface.

**Human counter-example:** io package uses `%w` only on errors that callers
branch on (`io.EOF`, `io.ErrUnexpectedEOF`). Internal failures use `%v`
or bare strings.

**Avoidance rule:** Use `%w` only if a caller in the codebase calls
`errors.Is`/`errors.As` on this error. Otherwise use `%v` or omit wrapping.

---

### T14: `GetX` getter prefix

**Placement:** exported method name.

**AI example:**
```go
func (a *Account) GetName() string { return a.name }
func (r *Request) GetContext() context.Context { return r.ctx }
```

**Cue:** "Get" prefix is non-idiomatic Go. All five authoritative sources
agree: Effective Go, CodeReviewComments, Google Guide, Uber, and practical
Go convention.

**Human counter-example:**
```go
func (r *Request) Context() context.Context
func (r *Request) UserAgent() string
func (r *Request) Referer() string
```
Source: `2026-05-04-stdlib-exemplars.md`, net/http/request.go

**Avoidance rule:** Never prefix a getter with "Get" or "get." The noun
alone is the method name.

---

### T15: Package-doubled types

**Placement:** type name.

**AI example:**
```go
package mail

type MailMessage struct { … }
type MailFolder struct { … }
```

**Cue:** callers see `mail.MailMessage`. The package name is repeated.

**Human counter-example:**
```go
// bufio.Reader not bufio.BufReader
// ring.New not ring.NewRing
```
Source: `2026-05-04-authoritative-docs.md`, Effective Go § Names — Package names

**Avoidance rule:** Check every exported type name: does it start with
the package name or a synonym? If yes, drop the prefix.

---

### T16: `Manager` / `Helper` / `Util` / `Service` suffixes

**Placement:** type name.

**AI example:**
```go
type CacheManager struct { … }
type RequestHelper struct { … }
type UIService struct { … }
```

**Cue:** the suffix describes a role, not a thing. These names have no
information content beyond "this does stuff."

**Human counter-example:** net/http uses `Handler`, `Transport`, `Client`,
`Server` — role-nouns that are meaningful because there's a concrete
contract. `Manager` is not a contract.

**Avoidance rule:** If the type name ends in Manager, Helper, Util, or
Service, replace it with what it actually manages, helps, or serves. If
there's no good noun, consider whether the type should exist at all.

---

### T17: Over-descriptive locals in tight scopes

**Placement:** local variable names.

**AI example:**
```go
for _, messageInfo := range messageInfoList {
    currentMessageUID := messageInfo.UID
```

**Cue:** `messageInfo` instead of `m`, `currentMessageUID` instead of `uid`,
inside a 5-line loop.

**Human counter-example:** `for _, msg := range msgs { … }` — stdlib everywhere.
`2026-05-04-stdlib-exemplars.md`, various

**Avoidance rule:** Name length proportional to scope, inversely proportional
to use frequency (Cox's principle). Loop variable used 3 times in 10 lines:
one or two letters.

---

### T18: Exported names that read like docstrings

**Placement:** exported function name.

**AI example:**
```go
func GetAllActiveAccountsFromDatabase() []*Account
func LoadAndParseConfigurationFromFile(path string) (*Config, error)
```

**Cue:** the function name is a sentence that restates what the signature
already conveys.

**Human counter-example:**
```go
func (s *Scheme) KnownTypes(gv schema.GroupVersion) map[string]reflect.Type
```
`2026-05-04-third-party-exemplars.md`, Kubernetes scheme.go

**Avoidance rule:** Read the name with its package qualifier.
`account.GetAllActiveAccountsFromDatabase` → `account.All`. Strip everything
the package context or signature already supplies.

---

### T19: Reflexive `doc.go` / `errors.go` / `types.go` skeleton

**Placement:** package structure.

**AI example:** Every package contains `doc.go`, `errors.go`, `types.go`,
and `helpers.go` regardless of the package's size or content.

**Cue:** the file structure is uniform. A 200-line package has the same
file layout as a 2000-line package.

**Human counter-example:** `io` package — `io.go`, `io_test.go`, `multi.go`,
`pipe.go`. No doc.go. No errors.go. No types.go. Files split by function,
not by role.

**Avoidance rule:** Split files when one file got unwieldy. Do not create
a file because a category needs a home.

---

### T20: Single-impl interfaces with no test fake, no DI seam

**Placement:** interface declaration.

**AI example:**
```go
type MessageRepository interface {
    Load(id UID) (*Message, error)
    Save(m *Message) error
}
type sqlMessageRepository struct { … }
// only implementation; no test double exists
```

**Cue:** the interface has one concrete implementation and no test double
uses it.

**Human counter-example:** `mail.Backend` in poplar — multiple
implementations (JMAP, IMAP) plus the interface exists specifically for
the DI seam between `internal/ui/` and the backends.

**Avoidance rule:** An interface requires at least two implementations or
a documented rationale (test double, explicit DI seam named in the code
or ADR). Otherwise, delete the interface and use the concrete type.

---

### T21: `New<X>` constructors that only set fields

**Placement:** constructor function.

**AI example:**
```go
func NewConfig(host string, port int) *Config {
    return &Config{Host: host, Port: port}
}
```

**Cue:** the constructor does nothing a struct literal wouldn't do at the
call site. Its only effect is hiding field names.

**Human counter-example:** `http.NewRequest` runs validation, parses the
URL, sets defaults. `sync.NewCond` records the locker. Constructors that
have work to do.

**Avoidance rule:** If a `New<X>` function's body is only field
assignments with no validation, transformation, or default-setting,
replace it with a struct literal at the call site.

---

### T22: Defensive nil checks between same-package functions

**Placement:** function body.

**AI example:**
```go
func (a *Account) process(m *Message) {
    if m == nil { return }
    …
}
// called only from Account.handleUpdate, which never passes nil
```

**Cue:** the check defends against a caller that doesn't exist in the
codebase. Internal callers are known at write time.

**Human counter-example:** `io.copyBuffer` does not nil-check `dst`/`src` —
validated by exported entry points.

**Avoidance rule:** Nil-check at exported API boundaries. Not between
functions in the same package.

**Boundary-vs.-internal test (calibration refinement):** if the zero
value of a field can occur through the package's own API surface
(constructor accepts nil, factory returns nil on a path, optional
field), the check is a real boundary and stays. If only constructed-
and-handed-off code reaches the check (constructor rejects nil, no
public method ever sets it to nil), it's T22 — the field has an
internal invariant the package itself maintains.

---

### T23: Length checks before indexing on internal callers

**Placement:** function body.

**AI example:**
```go
func (l *MessageList) selectedUID() UID {
    if len(l.msgs) == 0 { return 0 }
    if l.cursor >= len(l.msgs) { return 0 }
    return l.msgs[l.cursor].UID
}
```
…when `Update` already maintains the cursor in-bounds invariant.

**Cue:** checks that defend against conditions the caller has already guaranteed.

**Avoidance rule:** If the invariant is maintained elsewhere, don't check
it again in the helper. Add a comment to where the invariant is maintained
instead.

---

### T24: Identical assertion phrasing copy-pasted across test files

**Placement:** test files.

**AI example:** `t.Errorf("got %v, want %v", got, want)` in every test file,
word for word.

**Cue:** uniform assertion message across files of different functionality.

**Human counter-example:** stdlib varies: `t.Errorf("expected %v")`,
`t.Fatalf("got %v, expected %v")`, `t.Errorf("%s: UID mismatch")`.

**Avoidance rule:** Assertion messages are not templates. Write them for the
specific case: what was expected and what to look for in a debug session.

---

### T25: Tautological test cases

**Placement:** test file, table-driven test.

**AI example:**
```go
{name: "passthrough", input: "foo", want: "foo"},
// func identity(s string) string { return s }
```

**Cue:** the test asserts the only thing the function does.

**Avoidance rule:** One case for a trivially obvious function is correct.
A table with multiple entries all asserting the same trivial behavior is not.

---

### T26: Subtests for trivial scalar functions

**Placement:** test file.

**AI example:**
```go
func TestAdd(t *testing.T) {
    t.Run("adds two positive numbers", func(t *testing.T) { … })
    t.Run("adds zero to a number", func(t *testing.T) { … })
}
// func Add(a, b int) int { return a + b }
```

**Cue:** subtests for a three-line function with no error paths or edge cases.

**Avoidance rule:** Subtests add value when they have setup/teardown or
conditions that genuinely differ in non-trivial ways. Scalar functions
get table-driven tests in the parent.

---

### T27: Apologetic or hedging documentation

**Placement:** doc comment.

**AI example:**
```go
// Sort sorts the list. Note that this implementation may not handle
// all edge cases perfectly and could be improved in the future.
```

**Cue:** "may not handle", "could be improved" — undermines confidence in
code that presumably works.

**Human counter-example:**
```go
// Note that while correct uses of TryLock do exist, they are rare,
// and use of TryLock is often a sign of a deeper problem in a particular
// use of mutexes.
```
`2026-05-04-stdlib-exemplars.md`, sync/mutex.go:49–53 — precise, no apology.

**Avoidance rule:** State real limitations precisely. Delete speculative ones
("could be improved"). Known bugs get `// BUG:`.

---

### T28: Over-explanation of standard Go idioms

**Placement:** inline, doc comment.

**AI example:**
```go
// Use a goroutine to avoid blocking the main thread.
go func() { … }()

// Close the channel when done to signal completion.
close(done)
```

**Cue:** comments explain Go mechanics to Go developers.

**Human counter-example:** sync/once.go explains why the obvious CAS
approach is wrong — not what CAS is:
```go
// Here is an incorrect implementation of Do:
//  if o.done.CompareAndSwap(false, true) { f() }
//
// Do guarantees that when it returns, f has finished.
// This implementation would not implement that guarantee…
```
`2026-05-04-stdlib-exemplars.md`, sync/once.go:55–68

**Avoidance rule:** Never explain Go mechanics (goroutines, channels, defer,
range). Comment only on why *this* specific use is structured the way it is.

---

### T29: Uniform sentence length across a file

**Placement:** any.

**Cue:** every doc comment in a file is 10–15 words. No short ones, no
long ones. The visual rhythm is metronomic.

**Human counter-example:**
```go
// Wait blocks until the WaitGroup task counter is zero.  ← short
// A WaitGroup is a counting semaphore typically used to wait
// for a group of goroutines or tasks to finish. ← medium
// Add adds delta, which may be negative, to the WaitGroup task counter.
// If the counter becomes zero, all goroutines blocked on Wait are released.
// If the counter goes negative, Add panics.
// … ← long
```
Source: `2026-05-04-stdlib-exemplars.md`, sync/waitgroup.go

**Avoidance rule:** After writing all comments in a file, verify that
short functions have short docs and complex functions have long ones.
If the distribution is uniform, it's wrong.

---

### T30: Identical rhythm — every paragraph the same shape

**Placement:** doc comment.

**Cue:** every type comment starts with "A Foo is a…", every function
comment starts with "Foo does X.", every field comment is one sentence.
The regularity is mechanical.

**Human counter-example:** net/http mixes:
- `// A Handler responds to an HTTP request.` (article-first)
- `// Context returns the request's context.` (function-name first)
- `// The Flusher interface is implemented by ResponseWriters…` (article-first, interface)
- `// Referer returns the referring URL, if sent in the request.` (function-name + conditional)

Source: `2026-05-04-stdlib-exemplars.md`, net/http

**Avoidance rule:** Vary the opener: sometimes article, sometimes
name-first, sometimes predicate-form. The rule is that doc comments begin
with a subject that includes the symbol name — the shape of the sentence
around that subject should vary.

---

### T31: Uniform verbosity — identical doc shape and length across a file

**Placement:** any.

See T3 (uniform density) and T29 (uniform length). This tell is their
combination: when density, length, and shape are all uniform, the file
is AI-authored regardless of content. The fix is the same: match comment
length and density to actual complexity.

---

### T32: `Builder` patterns where a struct literal would suffice

**Placement:** API design.

**AI example:**
```go
cfg := NewConfigBuilder().
    WithHost("localhost").
    WithPort(5432).
    WithTimeout(30 * time.Second).
    Build()
```

**Cue:** the builder wraps a struct with no invariants that require ordered
construction. A struct literal is clearer and shorter.

**Human counter-example:**
```go
tr := &http.Transport{
    MaxIdleConns:       10,
    IdleConnTimeout:    30 * time.Second,
    DisableCompression: true,
}
```
Source: `2026-05-04-stdlib-exemplars.md`, net/http/doc.go

**Avoidance rule:** A builder is appropriate when construction has ordering
constraints or when a subset of optional fields must be set after
validation. If `Build()` just returns a struct literal, delete the builder
and use the struct literal at the call site.

---

## §8. Anti-Patterns by Placement

**Unexported helpers:** godoc on every function regardless of whether the
name leaves anything unsaid. `slugify`, `clamp`, `min` need no comment.
`io.copyBuffer` earns one sentence because the name doesn't tell you which
exported functions delegate to it, or the nil-buf behavior.

**Struct fields:** `Name string`, `Port int`, `Enabled bool` — no comment.
`Body io.ReadCloser` in `http.Request` earns a comment because nil/non-nil
semantics differ between client and server roles.

**Table-test cases:** `name: "should return error when input is nil and
the context is cancelled"` is a doc comment masquerading as a case name.
Use a noun phrase: `"nil input, cancelled context"`.

**Error strings:** a function where every error return reads `fmt.Errorf("failed
to X: %w", err)` looks machine-generated. See T10 and T11.

**Inline mid-function:** `// Check if the list is empty` before
`if len(list) == 0`. The code is clearer than the comment. Delete it.

**Package docs:**
```go
// Package mailjmap provides functionality for the JMAP email backend.
```
This adds nothing beyond the import path. The emersion package says:
```go
// Package imapclient implements an IMAP client.
//
// # Charset decoding
//
// By default, only basic charset decoding is performed. …
```
`2026-05-04-third-party-exemplars.md`, emersion/go-imap, imapclient/client.go:1–20

---

## §9. Positive-Example Pool

Verbatim excerpts the guide holds up as exemplary. Each seeds ADR-0141's
example pool. Citations are to the research files; readers can verify there.

**1. Non-obvious return invariant:**
```go
// A successful Copy returns err == nil, not err == EOF.
// Because Copy is defined to read from src until EOF, it does not treat an
// EOF from Read as an error to be reported.
```
`2026-05-04-stdlib-exemplars.md`, io/io.go:375–385

**2. Historical context preventing a regression:**
```go
// We were past the end of the previous request's body already … so this is
// a pipelined HTTP request. Prior to Go 1.11 we used to send on the
// CloseNotify channel and cancel the context here …
// New Go 1.11 behavior: don't fire CloseNotify or cancel contexts on
// pipelined requests. Shouldn't affect people, but fixes cases like Issue 23921.
```
`2026-05-04-stdlib-exemplars.md`, net/http/server.go:712–737

**3. Zero-value and copy-safety:**
```go
// A Mutex is a mutual exclusion lock.
// The zero value for a Mutex is an unlocked mutex.
//
// A Mutex must not be copied after first use.
```
`2026-05-04-stdlib-exemplars.md`, sync/mutex.go:17–29

**4. Interface post-return contract:**
```go
// A Handler responds to an HTTP request.
//
// ServeHTTP should write reply headers and data to the ResponseWriter and then
// return. Returning signals that the request is finished; it is not valid to
// use the ResponseWriter or read from the Request.Body after or concurrently
// with the completion of the ServeHTTP call.
```
`2026-05-04-stdlib-exemplars.md`, net/http/server.go:64–91

**5. Why the obvious implementation is wrong:**
```go
// Note: Here is an incorrect implementation of Do:
//
//  if o.done.CompareAndSwap(false, true) {
//      f()
//  }
//
// Do guarantees that when it returns, f has finished.
// This implementation would not implement that guarantee: given two
// simultaneous calls, the winner of the cas would call f, and the second
// would return immediately, without waiting for the first's call to complete.
```
`2026-05-04-stdlib-exemplars.md`, sync/once.go:55–68

**6. Fast-path, two sentences:**
```go
// If the reader has a WriteTo method, use it to do the copy.
// Avoids an allocation and a copy.
if wt, ok := src.(WriterTo); ok {
```
`2026-05-04-stdlib-exemplars.md`, io/io.go:399–401

**7. Spec deviation with reference:**
```go
// QUIRK: RFC 2045 section 6.4 specifies that multipart messages can't have
// a Content-Transfer-Encoding other than "7bit", "8bit" or "binary".
// However some messages in the wild are non-conformant …
// See https://github.com/emersion/go-message/issues/48
```
`2026-05-04-third-party-exemplars.md`, go-message, entity.go:34–39

**8. Error variable — comment and string don't repeat each other:**
```go
// ErrLeadershipLost is returned when a leader fails to commit a log entry
// because it's been deposed in the process.
ErrLeadershipLost = errors.New("leadership lost while committing log")
```
`2026-05-04-third-party-exemplars.md`, HashiCorp raft, api.go:30–75

**9. Layout-for-performance — invisible without the comment:**
```go
// done indicates whether the action has been performed.
// It is first in the struct because it is used in the hot path.
// The hot path is inlined at every call site.
// Placing done first allows more compact instructions on some architectures
// (amd64/386), and fewer instructions (to calculate offset) on other architectures.
done atomic.Bool
```
`2026-05-04-stdlib-exemplars.md`, sync/once.go:22–27

**10. Setup-critical package doc:**
```go
// Package imapclient implements an IMAP client.
//
// # Charset decoding
//
// By default, only basic charset decoding is performed. For non-UTF-8 decoding
// of message subjects and e-mail address names, users can set Options.WordDecoder.
```
`2026-05-04-third-party-exemplars.md`, emersion/go-imap, imapclient/client.go:1–20

---

## §10. How This Binds Going Forward

### Propagation plan

**`go-conventions` skill** — append a "Human voice & AI tells" section
that reproduces §5–§7 of this guide inline. The full §7 catalogue with
mechanical avoidance rules per tell. This skill loads before every Go file
edit, so the catalogue is in-context at write-time. No paraphrase —
paraphrasing decays into "use judgment" within two revisions.

**`/simplify` voice lens** — add a fourth parallel reviewer agent that
scans the diff against the §7 catalogue by tell number. Each finding cites
the tell (e.g., "T10: failed-to chorus — three adjacent error returns use
identical phrasing") and quotes the avoidance rule. Catches drift that
slipped past write-time.

**`CLAUDE.md` `Human voice` section** (poplar) — the short-form rules
remain there; add a pointer to this guide and to §7. Path-scoped rules
don't replicate the full catalogue, only point to it.

**ADR-0141** — already exists as the binding policy decision. Ensure it
references this guide and the updated go-conventions skill as the
enforcement mechanism.

**Cross-project reuse** — the `go-conventions` update benefits every Go
project on this workstation. The §7 catalogue is generic (no poplar-
specific examples in the skill copy; those stay in this guide and ADR-0141).

### The unexported-godoc default (source disagreement resolved)

Three sources differ:
- **CodeReviewComments:** "non-trivial unexported type or function
  declarations" should have doc comments.
- **Google:** "unexported type or function declarations with unobvious
  behavior or meaning" — a harder bar.
- **go.dev/doc/comment (Russ Cox):** unexported declarations are exempt
  from the doc comment rule entirely.

**Poplar default:** Google's "unobvious" is the operative standard.
Comment an unexported symbol when the name + signature leaves something
that a competent Go reader wouldn't immediately know. Obvious helpers —
where the name is the documentation — get no comment. The rationale:
comments that restate obvious names accumulate into noise and train
readers to skip them, which defeats the purpose of the comments that
matter.

---

## Synthesis decisions

**Voice choice:** stdlib-formal as the base register, with register shifts
for package docs (lean Gerrand-welcoming) and error strings (Pike-
aphoristic). This matches the Charm libraries poplar builds on, signals
credibility to experienced contributors, and avoids the tutorial register
that underestimates readers.

**Unexported-godoc default:** Google's "unobvious" bar, not CodeReview's
"non-trivial." Silence is the default for unexported symbols; a comment is
a decision that requires justification.

**"failed to" in errors:** Uber's rule adopted. The stdlib evidence confirms
it — `io.EOF`, `"short write"`, `"unexpected EOF"` — none of them hedge
with "failed to." The pattern accumulates as the stack unwinds and degrades
readability. Dropped.

**`%w` vs `%v`:** `%w` only when a caller branches on the error sentinel.
Otherwise `%v`. The distinction matters because `%w` makes the underlying
error type part of the package's public API surface.

**Inline fragment punctuation:** fragments are lowercase without a trailing
period; full-sentence inline comments follow standard English punctuation.
This matches stdlib practice and the Google guide's fragment distinction,
but is stated as a concrete rule rather than a taste call.
