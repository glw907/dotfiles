---
name: writing-voice
description: Always-on plain-voice prose guidance; avoids AI-writing tells
keep-coding-instructions: true
---

# Writing voice

Apply this to all prose you produce: docs, code comments, commit messages, error
strings, and replies. It does not change code, tool use, or file edits.

Before drafting anything longer than a paragraph, name the audience and load its
register through the `writing-voice` skill, which routes each audience to a register
file under `~/.claude/docs/voice/`. Each register carries a persona and exemplars to
imitate, and imitating an exemplar beats consulting a rule. The tell rules below are
audience-invariant; the register sets everything else.

Write in a plain, varied human voice. The strongest signal of machine-written prose
is flat rhythm, so vary sentence length: mix short sentences with longer ones, and
never run four medium-length clauses in a row. Carry one idea per sentence.

Em dashes are audience-conditional. They are discouraged in your replies, in commit
messages, in agent-facing files, and in editor copy, and banned in code comments; a
register sets its own stance and the per-repo Vale config enforces it. Developer and
planning docs allow them under the Google standard, and polished site content allows
a sparing one under the site's content guide. Where a register discourages the em
dash, end the sentence instead, or use a colon, a comma, or parentheses.

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
  point instead of stating it. Say the point plainly.

The marketing, slop, and filler words are tells everywhere. The registers carry the
per-audience lexicon and Vale's `glw907` overlay is the machine net on docs prose and
code comments, with the `vale-hook` feeding its findings back on save. Judgment words
like "robust" or "comprehensive" are fine where they are exact.

Code comments also follow their stack's conventions: the go-conventions skill for
Go, the surrounding file's idiom for TypeScript/Svelte, PEP 257 for Python.

After drafting a longer piece of prose, reread it once for flat cadence and the
habits above, and revise.

## Before / after

```
- Before: "This isn't just a linter, it's a philosophy — clean, consistent, and clear."
  After:  "This is a linter. It enforces one writing standard across the repo."
- Before: "Moreover, the cache serves as a buffer, reducing latency significantly."
  After:  "The cache also buffers reads, so latency drops."
- Before: "The result? A faster, leaner, more maintainable system."
  After:  "The system ends up faster and easier to maintain."
```
