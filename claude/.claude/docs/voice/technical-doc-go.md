# Register: Go developer documentation

The reader is a competent Go developer who knows the stdlib, terminals, and Unix idiom, and
has not read this codebase. The persona is a maintainer writing in the stdlib's own register:
terse, declarative, understated. Credibility comes from precision and from owning tradeoffs
plainly; enthusiasm reads as suspect.

Applies to READMEs, design docs, ADRs, and package documentation in the Go repos (poplar,
jrnl-md, displaywidth). Code comments have their own stricter rules in the go-conventions
skill and `go-comment-voice.md`; this register covers prose at the document level.

## Traits

- Subject-first declarative sentences that state behavior as settled fact. Rationale rides in
  a subordinate clause, not in a separate justification paragraph.
- Concreteness through identifiers, file paths, defaults, and named prior art instead of
  adjectives. "Search them with grep" sells harder than "powerful search".
- Tradeoffs and limitations owned in one breath: "Acceptable: the conflict still surfaces,
  just with worse latency."
- What the tool refuses to do is stated as confidently as what it does.
- Semicolons and colons carry the connective work. No hedging, no second-person hand-holding.
- Package docs open with the canonical "Package X is..." line.

## Exemplars

From the jrnl-md README, a philosophy section. Topic-sentence-first paragraphs and short
declarative closers:

```
The format is deliberately ordinary. Your journal files are readable without jrnl-md.
Sync them with git, rsync, or Syncthing. Search them with grep. The tool gets out of
the way.

Unix does the rest. jrnl-md does not include export, encryption, templates, or web
viewers. Those are solved problems. Use the tools that already exist.
```

From the jrnl-md README, reference prose for the `edit` subcommand. Exhaustive behavioral
specification as plain consecutive sentences, edge cases folded in without warning labels:

```
Open a day file in your editor. Defaults to today. `--on` selects a specific date. If the
day file doesn't exist, it is created with a day heading before the editor opens.
Re-opening today's file adds a new timestamp heading. If the previous timestamp heading
has no content (you opened and closed without writing), it is removed first. The cursor
is positioned at the end of the file, ready for a new paragraph.
```

From poplar's catkin package doc. The canonical opening line, an architecture rationale
compressed into a single but-clause, and a dependency contract stated as fact:

```
Package catkin is poplar's markdown-first bubbletea editor.

Catkin wraps bubbles/textarea as its buffer + cursor + edit-op primitive, but owns its
own renderer so live markdown styling and block-aware reflow can drive the display
directly from the raw source without parsing textarea's ANSI output.

This package depends only on bubbletea, bubbles, and lipgloss. It has no
poplar-specific imports and is extractable as github.com/glw907/catkin.
```

From a poplar ADR (0112). Design reasoning grounded in cited prior art, framed as named
forks with the tradeoff in one sentence:

```
A second fork was replay strategy: enqueue-order replay (FairEmail, Mailspring) vs.
type-ordered with automatic coalescing (Thunderbird). Coalescing buys IMAP/JMAP
round-trip efficiency at the cost of losing sequential intent and complicating error
attribution.
```

From a poplar ADR (0119), consequences stated as system behavior with a one-word verdict on
a known imperfection:

```
A backend that returns an unwrapped auth error degrades to "transient -> failed ->
backoff loop" until max-attempts promotes it to conflict. Acceptable: the conflict
still surfaces, just with worse latency.
```

From the displaywidth README. A feature motivated by one concrete canonical case, then a
performance contract in measurable terms:

```
The intended use is runtime terminal/font configuration that the Unicode standard cannot
capture. A common case is Nerd Font glyphs in the Supplementary Private Use Area:
Unicode classifies them as width 1, but terminals configured with a Nerd Font symbol_map
render them at width 2.

When no override range overlaps printable ASCII (the typical case), the fast path is
preserved bit-for-bit.
```

## Off-voice contrast

The same content in the register this file exists to prevent:

```
jrnl-md is a powerful yet lightweight journaling solution that seamlessly integrates
with your existing workflow. Whether you're a seasoned developer or just getting
started, its intuitive design empowers you to focus on what matters most: your
thoughts. And because it leverages plain markdown, your data is always yours.
```
