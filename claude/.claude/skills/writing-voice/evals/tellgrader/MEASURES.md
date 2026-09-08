# The docs-register cadence measures

This is the canonical definition of the two cadence measures the docs-register profile
reports: `hinged_pair_share` and `short_sentence_share`. It exists so a second
implementation, or a reviewer reading a number, has one place to check against instead of
reverse-engineering the scanner's regexes.

`~/Projects/cairn-cms/scripts/checks/measure-prose.mjs` is a consumer, not a second
definition. Where it diverges from this document, this document is the reference, and
cairn's own pass conforms `measure-prose.mjs` to it or retires the script in favor of
`tellgrader`. Every known divergence is named in "Divergences from cairn's
measure-prose.mjs" below.

## The sentence splitter

`internal/tellscan/cadence.go`'s `splitSentences` is the splitter, unchanged for the
docs-register measures: markdown decoration (heading markers, bullet and numbered-list
markers, and `**`/`__` emphasis markers) is stripped first, each paragraph (text between
blank lines) is flattened to one line, and the flattened text is split on runs of `.`,
`!`, or `?` followed by whitespace or end of string. No sentence is dropped for being
short.

## The selector: prose

The measures grade `prose` only: paragraphs of running text, never a heading and never a
list item. The selector, `proseOnly`, blanks two kinds of line before the sentence
splitter runs, preserving each line's newline so line numbers still map to the input:

- A **heading line**, recognized by `headingRe`: a line starting with one to six `#`
  markers followed by whitespace. A heading is not a sentence, so its whole line is
  removed, not merely its `#` marker.
- A **list item**, recognized the same way the scanner's other checks recognize one, by
  `bulletRe` (a leading `-`, `*`, or `+` marker) or `numberedListRe` (a leading `1.`-style
  marker), together with every line that continues it. A **continuation line**, matched by
  `continuationRe`, is an indented, non-blank line (leading spaces or tabs followed by a
  non-space character) immediately following a marker line or another continuation line;
  the run ends at a blank line or a non-indented line. A wrapped bullet's second and later
  lines are removed along with its marker line, so neither contributes a sentence.

Because headings and list items are removed entirely, the denominator the two shares divide
by is the **prose-only sentence count**: the number of sentences `splitSentences` returns
after `proseOnly` runs, reported as the JSON `measures.sentences` field. This equals
`CadenceCV`'s own sentence count only on a document with no headings and no list items;
otherwise `CadenceCV` counts more sentences than the docs-register measures do, because it
runs over the whole document (headings and bullets included) while the measures run over
prose alone.

## The hinged-pair rule

A sentence counts as a hinged pair when it joins two clauses by any of:

- a comma followed by one of the coordinating conjunctions `and`, `but`, `or`, `so`, `yet`,
  `nor`, or `for`, subject to the serial-list exclusion below,
- a colon or a semicolon, anywhere in the sentence,
- a spaced dash (a hyphen, en dash, or em dash surrounded by spaces), or
- a chain of relative clauses: two or more occurrences, case-sensitive, of the exact words
  `which` or `who` (in either combination) in the same sentence. A single `which` or `who`
  is not a hinge; two or more are.

**The serial-list exclusion.** A comma-plus-coordinator match does not count as a hinge
when an earlier comma already appears in the same sentence. "The plan covered a, b, and c."
closes a serial list at its final item; the comma before `and` is the list's own separator,
not a hinge. "It ran, and the gate passed." has no earlier comma, so its `, and` joins two
independent clauses and counts. The exclusion applies to the whole coordinator set above,
not only `and`.

**This definition is unsettled.** It moved twice during the proposal that preceded this
scanner, and no number built on it gates anything: it carries no band, and a `fix` verdict
never rests on it alone. Treat a change to this rule as a change to a report-only figure,
not to a check.

## The short-sentence rule

A sentence counts as short when it has fewer than eight words, counted the same way
`cadenceCV` counts them: `strings.Fields` on the flattened sentence text.

## The unit: fractions, not percentages

Both shares are fractions in `[0, 1]`, and the report states this explicitly with a
`"unit": "fraction"` field. `hinged_pair_share: 0.0` on a document with no hinged pair is
reported, not omitted: `Measures` is a pointer field, present or absent as a unit, so a
legitimate zero share never reads as "not measured."

## Divergences from cairn's measure-prose.mjs

`measure-prose.mjs` (`/var/home/glw907/Projects/cairn-cms/scripts/checks/measure-prose.mjs`)
is a separate implementation, not generated from this one. Every place it diverges from the
definition above:

- **Unit.** `measure-prose.mjs` emits integer percentages (`hingePct: 31`, `shortPct: 12`),
  rounded from `100 * count / n`. `tellgrader` emits fractions in `[0, 1]`
  (`hinged_pair_share: 0.31`).
- **The splitter drops short sentences.** `measure-prose.mjs`'s `splitSentences` filters out
  any chunk under three words (`.filter((x) => x.split(/\s+/).length >= 3)`). `tellgrader`'s
  `splitSentences` drops no sentence for being short, so the two denominators differ on any
  document containing a sub-three-word fragment.
- **The coordinator set.** `measure-prose.mjs` splits the coordinator test across two
  patterns: `HINGE_SUB` unconditionally hinges a comma followed by `but`, `so`, `yet`,
  `which`, `where`, `while`, `because`, `since`, `although`, `though`, or `as` (no
  serial-list exclusion applies to these), while `HINGE_AND` hinges a comma followed by
  `and` or `or`, with the serial-list exclusion. It never matches `nor` or `for`.
  `tellgrader` hinges a single coordinator set, `and`, `but`, `or`, `so`, `yet`, `nor`, `for`,
  with the serial-list exclusion applying uniformly to all seven.
- **The colon/semicolon test.** `measure-prose.mjs` requires a colon or semicolon followed
  by whitespace and a non-space character (`[;:]\s+\S`), so a colon at the end of a sentence
  or followed directly by a non-whitespace character does not count. `tellgrader` hinges on
  any colon or semicolon anywhere in the sentence (`strings.ContainsAny(sentence, ":;")`).
- **The relative-clause rule.** `measure-prose.mjs` has no "two or more" chain rule: it
  hinges unconditionally on a single comma followed by `which` or `where` (via `HINGE_SUB`),
  or on `, which` / `, that` followed by two more words. `tellgrader` requires two or more
  occurrences of `which` or `who` (case-sensitive, not `where` or `that`) anywhere in the
  sentence, with no comma required and no single occurrence counted.
- **Selector differences that remain after the heading and list-continuation fix.**
  `measure-prose.mjs` also strips fenced code, tables, link targets, and inline code before
  building its blocks, none of which `tellgrader`'s `proseOnly` or `splitSentences` strip.
  `measure-prose.mjs`'s list-item recognition (`^\s*(?:[-*]|\d+\.)\s+`) does not match a `+`
  bullet, where `tellgrader`'s `bulletRe` does.

The serial-list exclusion itself is **not** a divergence: both implementations exclude a
comma-plus-coordinator match when an earlier comma already appears in the sentence.

## The `~/.claude` symlink caveat

`~/.claude` is a symlink into this dotfiles repo, so a file edited through it resolves home
first and never walks into `~/.dotfiles`; a `.tellgrader.json` committed here does not
govern files edited that way.

## The report shape

```json
"profile": "docs-register",
"measures": {
  "unit": "fraction",
  "selector": "prose",
  "sentences": 148,
  "hinged_pair_share": 0.31,
  "short_sentence_share": 0.12
}
```

`sentences` counts the prose-only sentences the two shares are computed over, which can
differ from the report's top-level `sentences` field when the document contains headings or
list items.
