# The authoring charter: audience first

This governs how Claude drafts on this workstation, across prose and code. It steers Claude's own
output and lints that output as a backstop. It is not a quality gate for human-written content, and
it is not a product feature. A project points at this file to adopt the system; the rule for adoption
is at the end.

## The principle

Every artifact has one audience, and the audience decides everything else: vocabulary, warmth,
person, sentence shape, what to explain versus assume, even punctuation. Name the audience before
drafting anything longer than a paragraph. A developer reading API docs is one reader. An editor
reading admin copy is another. A coder scanning a Go comment, a parent reading a 907-life essay:
each is a distinct reader, and each gets writing shaped for them.

No audience, no system. A project that has not declared its audience map gets nothing automatic. The
system fails closed rather than falling back to a generic register, because a generic default is the
audience-blind writing this exists to remove. Declaring the audience is the price of admission.

## Two jobs

The system does two things. It guides Claude to draft well for the reader (feedforward), and it
catches what slips (feedback). Guidance does the real work. A linter is the cheaper backstop, and a
clean lint run is necessary without ever being sufficient, since no linter judges voice.

## Three layers, one job each

Every audience gets the same three layers. Only the contents change with the reader.

1. A style guide. The reference standard for that reader, a public baseline where one fits (Google
   for developer docs, Microsoft for end-user copy, PEP 257 for Python docstrings) plus a house
   overlay carrying only what departs from the baseline.
2. Claude infra, the feedforward half. Whatever puts the audience in context before Claude writes:
   the always-on output style, a routing line in a project CLAUDE.md, a register file with a persona
   and exemplars, or a `<lang>-conventions` skill. Exemplars carry more than rules, because the model
   generalizes from a good example better than from a list.
3. Linting, the feedback half. The deterministic check on the saved artifact: Vale for prose and for
   the prose inside code comments, and the language's own linter for comment structure. It surfaces
   findings as facts, scopes them to what changed, and fails open.

The same three layers cover a Markdown doc, a Go comment, and a blog post. Each reader sets what
goes in the slots.

## The standing audiences

| Audience | Reader | Style-guide baseline | Feedforward | Feedback |
|---|---|---|---|---|
| Developer docs, internal planning docs | a developer, the author | Google developer style | `technical-doc-go` / `technical-doc-web` register | Vale (Google + glw907) |
| End-user, editor product copy | a non-technical editor | Microsoft writing style | the editor register | Vale (Microsoft + glw907) + Readability |
| Go comments | a Go coder | Effective Go, godoc | `go-conventions` skill, `go-comment-voice.md` | golangci-lint + Vale on `.go` |
| TypeScript comments | a TS coder | TSDoc | `ts-conventions` skill, `ts-svelte-comments` register | eslint jsdoc/tsdoc + Vale on `.ts` |
| Svelte comments | a coder reading a component | `@component` + TSDoc | `svelte-conventions` skill, `ts-svelte-comments` register | the check-svelte-comments extractor (Vale on @component + script comments) + Vale on .ts |
| Python comments | a Python coder | PEP 257, Google sections | `python-conventions` skill, `python-comments` register | ruff `D` rules + Vale on `.py` |
| Site content | the site's own reader | the site's `content-guide.md` | `content-draft` / `content-review` skills | Vale against the site guide |
| Agent-facing docs, commits, replies, email | an agent, the author | the workstation registers | `agent-facing` / `commit-and-pr` registers, the output style | Vale on the saved file |

A new kind of output is a new row, built the same way. The table is the design; the build state and
the per-arm detail live in the specs linked below.

## Adopt it in a project

A project opts in by pointing at this charter and declaring its own audience map.

1. Add a line to the project CLAUDE.md: authoring follows `~/.claude/docs/authoring-charter.md`.
2. Declare the audience map: which paths serve which audience. For example `docs/**` is developer
   docs, `src/**/*.ts` is TypeScript comments, `content/**` follows the site content guide.
3. Carry the configs the map needs: a `.vale.ini` that selects the baseline per glob, the vendored
   `glw907` Vale style, and any per-language linter config (eslint, ruff).
4. A project that serves a content audience carries its own `content-guide.md`. The charter supplies
   no generic one.

A project that declares nothing gets nothing automatic. That is the fail-closed rule working as
intended, not a gap to paper over.

## What this is not

The discipline here is the workstation's, not any product's. A product that happens to ship prose
tooling to its own users (cairn's editor spellcheck and tidy, for one) does that independently of
this charter. A repo that builds such a product is still an ordinary consumer of the charter for its
own developer docs and code comments, and the two never merge.

## Pointers

- Prose, including the docs and content registers and the Vale feedback hook, is designed in
  `~/.dotfiles/docs/superpowers/specs/2026-06-22-ai-drafting-prose-system-design.md`.
- Code comments across four languages and the three layers are designed in
  `~/.dotfiles/docs/superpowers/specs/2026-06-22-code-comment-standards-design.md`.
- Register routing for prose lives in `~/.claude/docs/prose-voice.md`, and the registers themselves
  in `~/.claude/docs/voice/`.
- Comment voice references are `~/.claude/docs/go-comment-voice.md` and
  `~/.claude/docs/voice/ts-svelte-comments.md`, with a Python companion to follow.
- The Vale foundation is built and the Go, TypeScript, and Svelte comment arms are live. The pinned
  binary, the split `glw907` overlay, the vendored Google and Microsoft baselines, the global
  config, and the fixture suite came first. poplar carries the Go arm; cairn is the first TypeScript
  adopter, with an in-tree `.vale.ini` linting `.ts` comment prose through a committed `glw907`
  copy, an `eslint.config.js` enforcing TSDoc structure on `src/lib`, and a `check:comments` CI gate.
  `scripts/glw907-vendor.sh` vendors and drift-checks each repo's overlay copy. Go and TypeScript
  each carry all three layers, the language linter for structure (golangci-lint, eslint
  jsdoc/tsdoc), Vale on the comments for the lexicon, and the `go-conventions` or `ts-conventions`
  skill plus the register for the semantic tells. cairn carries the Svelte arm through
  `scripts/check-svelte-comments.mjs`, the extractor that lints the `@component` block and the
  script-block comments through `glw907` and enforces the one-`@component` rule, with the
  `svelte-conventions` skill and the S catalogue for the semantic tells. Python and the prose arm
  are the next plans.
- `prose-guard` is being retired in full; Vale takes over the feedback layer.
