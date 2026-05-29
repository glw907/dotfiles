# Prose voice: the concrete rules

Read this before writing a doc, plan, spec, or code comment. It is the human-readable companion to
the `prose-guard` PreToolUse hook (`~/.local/bin/prose-guard`), which enforces a subset of these at
write time, and to the always-on `writing-voice` output style. The hook blocks the whole file on a
trip, so a violation found after the fact means regenerating the entire artifact. Draft clean on the
first pass.

The bar is **human cadence**, not a passing sweep. A mechanical swap (an em dash for a colon, a
banned opener reworded) can pass the regex while still reading as machine-written. Rewrite the
sentence instead.

## Banned constructions

- **Em dashes.** None, in any docs-tier file or code comment. This includes em dashes inside code
  comments and UI strings within a generated artifact, because the hook scans the whole file. Use
  periods, commas, parentheses, or the word "including" instead. Recast the sentence so the aside
  becomes its own clause or sentence.
- **The short-clause colon list.** A brief clause, a colon, then a comma list. Fold the list into the
  sentence with a word like "including", or write the items as their own sentences.
- **Throat-clearing intensifiers and openers.** Cut these words and the phrases built on them:

  ```
  genuinely, honestly, genuine, honest
  "the honest answer is", "to be honest", "a genuine X"
  ```

- **Filler and hedging openers** that add no information (the "worth noting that", "importantly",
  "notably", "of course" family). State the point directly.
- **Anaphora as a crutch.** Repeating the same sentence opener across consecutive sentences or
  bullets. The hook treats this as advisory; vary the structure. Natural repetition over a long file
  is fine.

## How to apply

- Write in plain voice with varied sentence length.
- Reread a longer reply or file once before sending or writing it.
- The standard applies to my replies to the user too, not only to file edits. The output style turns
  on at session start, so within a session I self-police.
- Code comments additionally follow their stack's conventions: go-conventions for Go (see
  `go-comment-voice.md`), the file's own idiom for TS and Svelte, PEP 257 for Python.

## Where the rules are encoded

- `~/.local/bin/prose-guard`: the machine encoding (lexical, structural, statistics layers), source
  in `~/.dotfiles`. Tiers differ: the docs and comments tiers treat any em dash as a tell; the
  general content tier keeps some nuance. Key-value definition lists are exempt from the bold-header
  rule.
- `writing-voice` output style: the always-on prose standard for replies.
- This doc: the readable list to consult before writing.
