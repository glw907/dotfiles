---
name: svelte-conventions
description: >
  Mandatory rules for writing Svelte component comments on this workstation.
  Use before writing, reviewing, or modifying any `.svelte` `@component` block
  or script-block comment. Covers the write-time comment-or-not gate, the
  two-homes rule (`@component` carries purpose plus contract plus failure
  mode; props speak through their typed JSDoc), and the S1 through S10
  AI-tell catalogue. The prose authority is the ts-svelte-comments register.
---

# Svelte Comment Conventions

The reader is a coder or an agent already looking at the component. This skill is the Svelte arm
of the authoring charter (`~/.claude/docs/authoring-charter.md`). The deeper prose authority, with
exemplars from the SvelteKit and cairn source, is the `ts-svelte-comments` register at
`~/.claude/docs/voice/ts-svelte-comments.md`; load it before writing or reviewing comments. The
TypeScript tells (TS1 through TS15, the `ts-conventions` skill) apply to the `<script>` block; the
S-tells below specialize them for Svelte.

## §0: Comment-or-not (write-time gate)

```
(a) Does the markup, the rune, or the typed prop already say this?
(b) Is the why obvious from the next 5 lines or fewer?
(c) Would a reader otherwise miss a hidden constraint, an ordering
    requirement, a browser quirk, or a failure mode?
```

Skip on (a) or (b). Write only for (c). Markup nesting, handler names, and `bind:` are visible, so
they get no narration. A rune declares its own dependency; comment only a non-obvious why.

## The two-homes rule

A component has two comment homes, and they do not overlap. This is the load-bearing rule.

- The `@component` HTML comment carries the component's purpose, its contract, and its failure
  mode, in prose. The Svelte language server surfaces it on hover at the import site. Exactly one
  per file: the LSP reads only the last, so a second `@component` is a silent footgun.
- Prop docs live on the typed `Props` interface members as JSDoc, never in `@component`. The type
  states the prop's type; the JSDoc adds only the constraint, the fallback, or the why. Duplicating
  props into `@component` creates two sources of truth that drift.

State behavior and the failure mode in `@component`, never a template walkthrough.

## §catalogue: the S1 through S10 AI-tell catalogue

Each tell: id, name, the mechanical avoidance rule. Full prose is in the `ts-svelte-comments`
register. The S-tells specialize the Go and TS tells they extend; when both apply, cite the most
specific (S2 over a TS paraphrase tell for a reactive line, S5 over it for a rune, S4 for a
template banner). Cite as `S<n> at file:line`.

| id | name | rule |
|---|---|---|
| S1 | `@component` restating every typed prop | `@component` is purpose plus contract plus failure mode; props speak through their JSDoc |
| S2 | narrating a reactive declaration | the rune declares the dependency; comment only a non-obvious why |
| S3 | over-commenting markup structure | markup nesting is visible; a template comment earns its place only for a why |
| S4 | redundant template section banners | delete a `<!-- header -->` banner unless it carries a constraint |
| S5 | commenting standard rune idioms | never explain what a rune does; comment only an unusual use |
| S6 | file-header boilerplate | the editor shows the filename; fold real content into `@component` |
| S7 | prop JSDoc restating the type | the type says the type; the doc adds the why or nothing |
| S8 | narrating handlers and bindings | the handler name and `bind:` are self-describing |
| S9 | `untrack`/snapshot under- or over-commented | one line of why is correct here; not zero, not a paragraph |
| S10 | uniform `@component` shape across the set | vary opener and length with each component's surface |

## Tooling and the division of labor

- `scripts/check-svelte-comments.mjs` (cairn) is the deterministic net: it extracts the `@component`
  block and the `<script>`-block comments and runs Vale `glw907` over them, catching the em dash and
  the banned lexicon, and it enforces the structural rule (at most one `@component`, with prose). It
  never scans the component's markup text, which is `check:prose`'s product-copy surface.
- This skill and the register own the semantic S-tells the extractor cannot see: the paraphrase, the
  prop restated into `@component`, the rune narrated, the uniform shape across the set.

## Output

When reviewing, cite each finding as `S<n> at file:line` with the avoidance rule. When writing, run
the §0 gate, then the two-homes rule, then write only what survives.
