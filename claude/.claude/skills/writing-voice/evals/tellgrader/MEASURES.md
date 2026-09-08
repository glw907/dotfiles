# The docs-register cadence measures

This is the canonical definition of the two cadence measures the docs-register profile
reports: `hinged_pair_share` and `short_sentence_share`. It exists so a second
implementation, or a reviewer reading a number, has one place to check against instead of
reverse-engineering the scanner's regexes.

`~/Projects/cairn-cms/scripts/checks/measure-prose.mjs` is a consumer, not a second
definition. Where it diverges from this document, this document is the reference, and
cairn's own pass conforms `measure-prose.mjs` to it or retires the script in favor of
`tellgrader`.

## The sentence splitter

`internal/tellscan/cadence.go`'s `splitSentences` is the splitter, unchanged for the
docs-register measures: markdown decoration (headings, bullet markers, bold and italic
markup) is stripped first, each paragraph (text between blank lines) is flattened to one
line, and the flattened text is split on runs of `.`, `!`, or `?` followed by whitespace or
end of string. No sentence is dropped for being short. The measures reuse this splitter
rather than writing a second one, so their denominator is the same one `CadenceCV` uses:
the two numbers stay comparable on the same document.

## The selector: prose

The measures grade `prose` only: paragraphs of running text, never list items. A line is
recognized as a list item the same way the scanner's other checks recognize one, by
`bulletRe` (a leading `-`, `*`, or `+` marker) or `numberedListRe` (a leading `1.`-style
marker). A list-item line is blanked, preserving its newline, before the sentence splitter
runs, so a bullet's text never contributes a sentence to either share.

## The hinged-pair rule

A sentence counts as a hinged pair when it joins two clauses by any of:

- a comma followed by a coordinating conjunction (`and`, `but`, `or`, `so`, `yet`, `nor`,
  `for`),
- a colon,
- a semicolon,
- a spaced dash (a hyphen or an em or en dash surrounded by spaces), or
- a chain of relative clauses: two or more relative pronouns (`which`, `who`) in the same
  sentence.

**The serial-list exclusion.** A comma-plus-coordinator match does not count as a hinge
when an earlier comma already appears in the same sentence. "The plan covered a, b, and c."
closes a serial list at its final item; the comma before `and` is the list's own separator,
not a hinge. "It ran, and the gate passed." has no earlier comma, so its `, and` joins two
independent clauses and counts.

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

`measure-prose.mjs` emits integer percentages today (`31`, not `0.31`). That is the
divergence a later pass closes, either by converting the script's output to fractions or by
retiring it in favor of `tellgrader --profile docs-register`.

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
differ from the report's top-level `sentences` field when the document contains list items.
