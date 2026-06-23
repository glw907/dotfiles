---
name: ts-conventions
description: >
  Mandatory rules for writing TypeScript comments on this workstation.
  Use before writing, reviewing, or modifying any TypeScript doc comment
  or inline comment. Covers the write-time comment-or-not gate, the TSDoc
  doc-comment shape (document the contract, never the type), the copy-in
  ESLint jsdoc/tsdoc flat config, and the TS1 through TS15 AI-tell
  catalogue. The prose authority is the ts-svelte-comments register.
---

# TypeScript Comment Conventions

The reader is a coder or an agent already looking at the code. A comment carries what the
code cannot: a why, a constraint, a piece of evidence. The type annotation already states
the type, so a doc comment that restates it is noise. This skill is the TypeScript arm of the
authoring charter (`~/.claude/docs/authoring-charter.md`). The deeper prose authority, with
exemplars from the SvelteKit and cairn source, is the `ts-svelte-comments` register at
`~/.claude/docs/voice/ts-svelte-comments.md`; load it before writing or reviewing comments.

## Persona

You write comments the way the SvelteKit and Svelte maintainers do: terse, placed only where
behavior gets surprising, candid about hacks, with links doing the arguing. True prose
commentary runs about 8 to 12 lines per 100 and concentrates where browser behavior, ordering,
or state gets weird. Straightforward plumbing stays silent.

## §0: Comment-or-not (write-time gate)

Before writing any comment, run the three-question gate:

```
(a) Does the name plus the typed signature already say this?
(b) Is the why obvious from the next 5 lines or fewer?
(c) Would a reader otherwise miss a hidden constraint, invariant, side
    effect, or surprising consequence?
```

Skip on (a) or (b). Write only for (c). Mechanical test: if the comment paraphrases the next
few lines or restates a fact the type annotation already carries, delete it. The paraphrase
test is the primary filter against AI-shaped comments.

A doc comment on an exported symbol is the one presence default, and even then only when the
name plus signature leaves the contract unobvious. Internal helpers are opt-in: a one-line
private helper gets a `//` at most, and most get nothing.

## Decision rubric

```
1. Exported symbol whose contract is fully implied by name + signature?
   YES → no doc, or one sentence if a caller obligation hides in it.
   NO  → one sentence stating the constraint, unit, nil-semantic, or
         caller obligation the type cannot express. No type restatement.

2. Internal symbol with unobvious behavior the name does not convey?
   YES → short // line.   NO → no comment.

3. Inside a function: does this block differ from what the name and
   control flow imply?
   YES → one-line why-comment with evidence (issue URL, spec, symptom).
   NO  → no comment.

4. A suppression (@ts-expect-error, eslint-disable)?
   YES → carry the reason inline, unless the line above already argues it.
```

## TSDoc doc-comment shape

- TSDoc, not JSDoc. No `{type}` on any tag. The signature carries the types; the doc carries
  the why.
- Document the contract: the constraint, the unit, the nil-semantic, the caller obligation.
  Not the type, not the parameter list in English.
- Use the real tags for structured notes: `@remarks`, `@throws`, `@defaultValue`, `@param name -
  description`. Never invent `Note:` or `Important:` label-colon paragraphs.
- Public API gets full sentences with periods and links to MDN or the spec where they help.
  Internal helpers get a terse fragment, no period.
- Vary the opener across a file. Never lead every doc with "This function".
- One thought per comment. No em dash.

## Linting: the copy-in ESLint flat config

A consumer repo copies this `eslint.config.js` in (cairn is the first). It lints
`src/lib/**/*.ts` on the jsdoc typescript-error base plus tsdoc, with the rule tiers the
charter fixes. Adjust the `files` glob to the repo's source root.

```js
import jsdoc from 'eslint-plugin-jsdoc';
import tsdoc from 'eslint-plugin-tsdoc';
import tseslint from 'typescript-eslint';

export default [
  { files: ['src/lib/**/*.ts'], ...jsdoc.configs['flat/recommended-typescript-error'] },
  {
    files: ['src/lib/**/*.ts'],
    languageOptions: { parser: tseslint.parser },
    plugins: { jsdoc, tsdoc },
    rules: {
      // The contract, never the type. The signature already carries the types.
      'jsdoc/no-types': 'error',
      'jsdoc/check-tag-names': ['error', { typed: true }],
      'tsdoc/syntax': 'error',
      'jsdoc/check-param-names': 'error',
      // A doc on exports only, and at warn: check:reference owns the hard coverage gate.
      'jsdoc/require-jsdoc': ['warn', { publicOnly: true }],
      // The deterministic half of the paraphrase gate.
      'jsdoc/informative-docs': 'warn',
      // These manufacture the type-restatement the standard forbids.
      'jsdoc/require-param': 'off',
      'jsdoc/require-returns': 'off',
      'jsdoc/require-param-description': 'off',
      'jsdoc/require-returns-description': 'off',
      // require-throws-type wants JSDoc-style `@throws {Type}`, which TSDoc rejects as a
      // malformed inline tag. The charter mandates TSDoc, so @throws stays prose.
      'jsdoc/require-throws-type': 'off',
    },
  },
];
```

The base preset enforces the canonical expanded doc-block shape (`jsdoc/multiline-blocks`,
`jsdoc/tag-lines`), the form the SvelteKit source uses. A repo whose comments predate the
standard runs `eslint src/lib --fix` once to reformat to it, then hand-fixes the residue Vale
and `--fix` cannot: scoped package names go in backticks (`` `@codemirror/view` ``, not a bare
`@codemirror/view` that TSDoc reads as a tag), brace and angle spans in prose go in backticks,
and a `@param` gets its hyphen. cairn's adoption did exactly this.

The parser is `typescript-eslint`'s with no `project` setting: the jsdoc and tsdoc rules read
the comment AST, not the type graph, so type-aware linting is not needed and the run stays
fast.

## §catalogue: the TS1 through TS15 AI-tell catalogue

Each tell: id, name, the mechanical avoidance rule. The full prose, with an AI-shaped example
and a human counter-example, is in the `ts-svelte-comments` register. When a finding triggers
more than one tell, cite the strongest. TS1 (type restatement) outranks TS2 (type narration);
TS7 (paraphrase) outranks a structural tell on the same line.

| id | name | rule |
|---|---|---|
| TS1 | `@param {type}` restating the signature | never write a `{type}` in a tag; if the line only names the type, delete it |
| TS2 | type-narration in prose | state the constraint, not the type the annotation already shows |
| TS3 | "This function" opener | start with the behavior; vary the opener across a file |
| TS4 | every export documented reflexively | a self-evident export gets no doc, even when public |
| TS5 | `/** */` on a trivial internal | internals are opt-in; a one-line private helper gets a `//` at most |
| TS6 | uniform density across files | density follows complexity, not a fixed shape |
| TS7 | comment restating the next line | the paraphrase test; delete it |
| TS8 | section-boundary narration | comment where understanding fails, not where structure changes |
| TS9 | changelog or task-framing | no `// added for X`, `// fixes #N`; the commit carries it |
| TS10 | file-header banner repeating the path | a header earns its place only for a cross-cutting invariant |
| TS11 | over-documenting typed props | a prop doc adds a constraint or fallback, never the type |
| TS12 | `@component` narrating markup | state behavior and the failure mode, not a template walkthrough |
| TS13 | suppression without an inline reason | every `@ts-expect-error` carries its why, unless the line above argues it |
| TS14 | em dash and multi-clause comment rhythm | no em dash; one thought per comment |
| TS15 | invented label-colon paragraphs in TSDoc | use `@remarks`, `@throws`, `@defaultValue`, not `Note:` blocks |

Calibration for a coverage-gated repo. Where a repo enforces export-doc coverage, the presence tells
TS4 and TS5 apply to internal symbols only. cairn's `check:reference` and its `jsdoc/require-jsdoc`
(publicOnly) want every exported symbol to keep a doc, so a minimal one-line doc on an export is the
house default there, not a tell. Flag a reflexive doc on an internal helper; leave the export's
one-liner. The cairn comment-lens trial confirmed this: the lens over-flagged `EntryIdentity`,
`createSession`, and `findEditor` until the rule was scoped to internals.

## Tooling and the division of labor

Three layers, three jobs:

- ESLint (jsdoc + tsdoc) owns structure: the `{type}` ban, TSDoc syntax, `@param` drift, the
  coverage warning. It cannot see prose quality.
- Vale on `.ts` comments owns the deterministic lexical net: the em dash, the marketing and
  slop words, the banned phrases.
- This skill and the register own the semantic tells Vale and ESLint cannot see: the paraphrase,
  the doc on a self-evident export, the uniform comment rhythm. When a finding is a plain
  lexical or structural hit, expect ESLint or Vale to have caught it; spend the judgment here.

## Output

When reviewing, cite each finding as `TS<n> at file:line` with the one-line avoidance rule.
When writing, run the §0 gate first, then the rubric, then write only what survives.
