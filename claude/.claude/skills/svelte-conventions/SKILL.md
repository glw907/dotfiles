---
name: svelte-conventions
description: >
  Mandatory rules for writing Svelte component comments on this workstation.
  Use before writing, reviewing, or modifying any `.svelte` `@component` block
  or script-block comment. Covers the write-time comment-or-not gate, the
  two-homes rule (`@component` carries purpose plus contract plus failure
  mode; props speak through their typed JSDoc), and the standard's principles
  and exemplars.
---

# Svelte Comment Conventions

A Svelte component has two comment surfaces, and each follows its own standard. The `<script>`
block is TypeScript and follows **TSDoc**, the same as `ts-conventions`. The component-level
documentation follows the **Svelte `@component` convention**
(https://svelte.dev/docs/svelte/basic-markup#Comments), the `<!-- @component ... -->` block the
language server surfaces on hover. The exemplar is **well-regarded Svelte and SvelteKit code**;
read how its components document themselves and match it. This skill is the Svelte arm of the
authoring charter (`~/.claude/docs/authoring-charter.md`).

## Principles

- **Comment the why, not the what.** The markup, the runes, and the typed props say what. A
  comment carries a reason, a constraint, or a failure mode they cannot.
- **Document the contract.** The `@component` block states the component's purpose, what a
  consumer must pass, and how it fails. A prop's JSDoc states the prop's constraint or fallback.
- **Do not paraphrase the code.** A comment narrating visible markup, a self-describing handler,
  or a standard rune should not exist.

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

## The `<script>` block

The `<script lang="ts">` block is TypeScript: its comments follow TSDoc and the `ts-conventions`
rules in full. Document the contract, never the type; comment the why; do not paraphrase the
code. The `Props` interface, its members' JSDoc, and any module-level helper all live under that
standard.

## Linting and the division of labor

- The `@component` block and the `<script>` comments are not the component's product copy.
  Visible markup text (headings, button labels, body copy) is a content surface and belongs to
  the site's own content tooling, not to this comment standard.
- ESLint with jsdoc and tsdoc owns the `<script>` block's structure where the repo wires the
  Svelte parser; until then the `<script>` block follows TSDoc as feedforward, checked by reading
  it against the exemplars. The `@component` convention has no deterministic linter: enforce one
  `@component` per file, in prose, by review.

## Output

When writing, run the §0 gate, then the two-homes rule, then write only what survives. When
reviewing, cite each finding at `file:line` with the principle it breaks and, where it helps, the
well-run-component comment it should resemble.
