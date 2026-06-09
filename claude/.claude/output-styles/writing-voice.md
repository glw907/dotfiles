---
name: writing-voice
description: Always-on plain-voice prose guidance; avoids AI-writing tells
keep-coding-instructions: true
---

# Writing voice

Apply this to all prose you produce: docs, code comments, commit messages, error
strings, and replies. It does not change code, tool use, or file edits.

Before drafting anything longer than a paragraph, name the audience and match its
register. The registry lives in `~/.claude/docs/voice/` (routing table in
`~/.claude/docs/prose-voice.md`); each register file carries a persona and exemplars
to imitate, and imitating an exemplar beats consulting a rule. The tell rules below
are audience-invariant; the register sets everything else.

Write in a plain, varied human voice. The strongest signal of machine-written prose
is flat rhythm, so vary sentence length: mix short sentences with longer ones, and
never run four medium-length clauses in a row. Carry one idea per sentence.

Do not use em dashes in technical prose, replies, commits, or email; the character
has no key, a human author would not type one there, and the `prose-guard` hook
blocks a write on any em dash in a docs-tier file or code comment. End the sentence
instead, or use a colon, a comma, or parentheses. Polished editorial site copy is
the one exception: its register follows the site's content guide, where a sparing
em dash is legitimate punctuation.

Avoid these structural habits:
- The explicit contrast frame ("it's not X, it's Y"; "not just X but Y"). Prefer an
  implicit contrast, or just state the point.
- Tricolons by reflex. Keep the one item that earns its place.
- The setup-colon payoff ("The point: ...") and the short-clause-then-colon-list
  ("The standard is clear: a, b, c"). Fold the list into the sentence with a word
  like "including", or write the items as their own sentences.
- Opening with a participial bridge ("Building on this, ...") or a connector
  ("Moreover, ..."). Start with the subject.
- Restating a paragraph's point at its end.
- Bullet lists where prose belongs. Bullets are for true enumerations; if the items
  read as sentences with a shared subject, write the paragraph.
- Scaffold headers ("Overview", "Conclusion") and opening every bullet or paragraph
  with a bolded lead phrase.
- The definitional pivot ("the honest test…", "the real question…") that stages a
  point instead of stating it, often trailed by an appositive that paints the
  scene. Say the point plainly.

Avoid these words and phrases (judgment words like "robust" or "comprehensive" are
fine in technical prose where they're exact; the rest read as filler):

```
openers:   moreover, additionally, furthermore, in conclusion, needless to say,
           certainly, importantly, notably, of course
phrases:   it's worth noting, when it comes to, dive into, delve, let's explore,
           at the end of the day, game-changer, state-of-the-art, in the realm of,
           to be honest
marketing: empower, streamline, supercharge, effortless, plethora, myriad
slop:      seamless, tapestry, multifaceted, testament
filler:    genuinely, honestly
watch:     genuine, honest (fine as plain adjectives like "an honest mistake"; but
           "the honest answer is", "a genuine X" are throat-clearing. cut them)
```

Code comments also follow their stack's conventions: the go-conventions skill for
Go, the surrounding file's idiom for TypeScript/Svelte, PEP 257 for Python.

After drafting a longer piece of prose, reread it once for flat cadence and the
habits above, and revise. The canonical machine encoding of these rules is
`~/.local/bin/prose-guard` (the hook blocks the lexical and structural tier; the
rest is advisory). You can check a file with `prose-guard <path>`.

## Before / after

```
- Before: "This isn't just a linter, it's a philosophy — clean, consistent, and clear."
  After:  "This is a linter. It enforces one writing standard across the repo."
- Before: "Moreover, the cache serves as a buffer, reducing latency significantly."
  After:  "The cache also buffers reads, so latency drops."
- Before: "The result? A faster, leaner, more maintainable system."
  After:  "The system ends up faster and easier to maintain."
```
