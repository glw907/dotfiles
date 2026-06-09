# Prose voice: the concrete rules

Read this before writing a doc, plan, spec, or code comment. It is the human-readable companion to
the `prose-guard` PreToolUse hook (`~/.local/bin/prose-guard`), which enforces a subset of these at
write time, and to the always-on `writing-voice` output style. The hook denies the write on a trip;
the cost is rewording the offending sentence and retrying, so draft clean and the tax stays near
zero.

The bar is **human cadence**, not a passing sweep. A mechanical swap (an em dash for a colon, a
banned opener reworded) can pass the regex while still reading as machine-written. Rewrite the
sentence instead.

## Pick the register first

Most tell rules hold in every register; the exceptions are keyed to authorship plausibility, the
em-dash rule below being the clearest case. Who reads it sets everything else about a draft:
vocabulary, warmth, person, what to explain versus assume. Before drafting anything longer than a
paragraph, name the audience and open its register file; each one carries a persona, the register's
traits, and exemplars to imitate.

A tell is usually a register misapplied, not bad writing in isolation. A model falls back on the
registers its training rewarded hardest (polished professional copy, the essayist's staged turn)
wherever nothing stronger sits in context, and copy-editor prose is right for a brochure and wrong
for a code comment, an open-source README, or a coaching article for high-school kids. The register
file's job is to be the stronger attractor. The corollary is that tell lists are per-model
observations, re-derived from each model's actual drafts and pruned when entries stop firing, never
inherited as standing battles from the last model.

| Artifact | Register file |
|---|---|
| Site content (pages, posts, form copy) | the site repo's `docs/content-guide.md`, via the content-draft skill |
| Developer docs, README, design doc in a Go repo | `~/.claude/docs/voice/technical-doc-go.md` |
| Developer docs, README, design doc in a SvelteKit/web repo | `~/.claude/docs/voice/technical-doc-web.md` |
| CLAUDE.md, skills, agent definitions, hook text | `~/.claude/docs/voice/agent-facing.md` |
| Commit messages and PR bodies | `~/.claude/docs/voice/commit-and-pr.md` |
| Code comments | go-conventions for Go; `~/.claude/docs/voice/ts-svelte-comments.md` for TS/Svelte; PEP 257 for Python |

The dialect follows the repo's stack; a project CLAUDE.md may override with an explicit register
line. Exemplars beat rules: when a sentence feels off, reread the register's exemplars and imitate,
rather than consulting more rules.

## Document shape

Shape-level tells read as AI even when every sentence is clean.

- Paragraphs over bullets. A bullet list is for true enumerations (options, steps, fields), not
  for prose that happens to have three points. If the items read as sentences with a shared
  subject, write the paragraph.
- No scaffold headers. "Overview", "Introduction", "Conclusion", and "Summary" sections are
  filler in anything shorter than a book chapter. Headers exist for a reader who navigates by
  them; a doc a person reads top to bottom usually needs few or none.
- Do not open every bullet or paragraph with a bolded lead phrase. Used sparingly it is signpost;
  used by reflex it is the AI list default, and the guard blocks the worst form.
- One register per artifact. Do not drift from runbook to essay mid-document.

## Banned constructions

- **Em dashes.** None in any docs-tier file or code comment, and none in replies, commit messages,
  or email. The rule is authorship plausibility, not aesthetics: the character has no key, so a
  programmer never types one, and in a technical artifact it reads as machine authorship. This
  includes em dashes inside code comments and UI strings within a generated artifact, because the
  hook scans the whole file. Use periods, commas, parentheses, or the word "including" instead.
  Polished editorial copy is the exception: a magazine-register sentence carries one legitimately,
  so site content (the general tier) allows sparing use under the site's own content guide,
  including a blog post when the audience fits. Overuse is still a tell there; the general tier
  flags sprays and tacked-on fragments.
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

## What blocks versus what advises

The hook blocks a write on the lexical and structural tells. The softer tells surface only in the
`prose-guard` sweep and the post-hook feedback, so they guide a rewrite without stopping the file.
Active voice is the standard, which is why passive phrasing advises rather than blocks. Keep passive
only where it truly fits.

Advisory findings are dosage signals, not prohibitions. Most of the flagged constructions are
legitimate in a single well-placed instance; the tell is reaching for the same move by reflex. Read
a cluster of advisory hits as "this draft leans on a crutch" and vary the writing, rather than
mechanically purging every hit. Promotion of any advisory tell to the blocking tier is Geoff's call,
never a default.

| Layer | Examples | Enforcement |
|---|---|---|
| Lexical, structural | em dash in docs and comments, banned phrases and openers, marketing words (`empower`, `streamline`, `supercharge`, `effortless`, `plethora`, `myriad`), `to be honest`, `in the realm of`, the antithesis, setup-colon, and bold-header patterns | Blocks the write |
| Soft line-level | passive phrasing (`allows you to`, `enables you to`), passive with a named agent, soft words (`leverage`, `unlock`, `elevate`, `foster`, `boost`), throat-clearing openers (`importantly`, `notably`, `of course`), adjective tricolon, decorative emoji, the spaced-hyphen dodge | Advisory, sweep only |
| Statistics | low burstiness, anaphora | Advisory, sweep only |

## How to apply

- Write in plain voice with varied sentence length.
- Reread a longer reply or file once before sending or writing it.
- The standard applies to my replies to the user too, not only to file edits. The output style turns
  on at session start, so within a session I self-police.
- Code comments additionally follow their stack's conventions: go-conventions for Go (see
  `go-comment-voice.md`), the file's own idiom for TS and Svelte, PEP 257 for Python.

## Where the rules are encoded

- `~/.local/bin/prose-guard`: the machine encoding (lexical, structural, advisory, and statistics
  layers), source in `~/.dotfiles`. Tiers differ: the docs and comments tiers treat any em dash as a
  tell; the general content tier keeps some nuance. Key-value definition lists are exempt from the
  bold-header rule. The advisory layer surfaces in the sweep and in the PostToolUse `--post-hook`
  feedback, and never blocks a write. Ban lists are a per-model patch layer; the `FABLE_PHRASES`
  section holds Fable-era candidates pending calibration.
- `~/.claude/docs/voice/`: the register files (persona + traits + exemplars per audience).
  Registers are model-stable, so lean on them harder than on the ban lists.
- `writing-voice` output style: the always-on prose standard for replies.
- This doc: the readable list, the register routing table, and the shape rules.
