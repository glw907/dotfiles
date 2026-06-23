# Register: TS/Svelte code comments

The reader is a coder or an AI agent already looking at the code. A comment exists to carry
what the code cannot: a why, a constraint, a piece of evidence. Prose style is the last
concern here; placement, length, and function come first. The empirical baseline is the
Svelte and SvelteKit source (high overall comment density, but true prose commentary runs
about 8-12 lines per 100 and concentrates where browser behavior, ordering, or state gets
weird, with straightforward plumbing left silent). Cairn's `src/lib` supplies the house
conventions for `.svelte` files.

## When a comment exists

- Comment why, almost never what. The paraphrase test from go-conventions applies: if the
  comment restates the next few lines, delete it.
- Comments cluster at the unobvious: a browser quirk, an ordering requirement, a magic
  number, code that looks wrong on purpose. Everywhere else, silence is the default.
- A comment justifying wrong-looking code sits immediately above it and carries evidence:
  the issue URL, the spec citation, the observed symptom. Links do the arguing so the
  prose doesn't have to.
- Suppressions (`@ts-expect-error`, `eslint-disable`) carry their reason inline, unless a
  comment directly above already explains the whole block.
- A deliberately empty block is marked (`// do nothing`) so emptiness reads as a decision.
- TODOs are bare `// TODO ...`, version-tagged when the debt is scheduled (`TODO 3.0`).

## Length scales with distance from the reader

Public API gets full JSDoc: capitalized sentences with periods, constraints stated, links
to MDN or the spec, second person where it helps ("Make sure you're not catching the
thrown error"). Internal helpers get a one-line summary, no period, params typed but not
described. Inline asides are lowercase fragments or plain sentences in first-person
plural, candid about hacks and uncertainty. Upstream occasionally drops an em dash in an
inline comment; cairn does not (Vale blocks it on `.ts` comments), so imitate the function,
not the punctuation.

## Exemplars

Public-API JSDoc (SvelteKit `error()`). Constraints, links, and a warning the reader
needs:

```js
/**
 * Throws an error with a HTTP status code and an optional message.
 * When called during request handling, this will cause SvelteKit to
 * return an error response without invoking `handleError`.
 * Make sure you're not catching the thrown error, which would prevent SvelteKit from handling it.
 * @param {number} status The HTTP status code. Must be in the range 400-599.
 * @throws {HttpError} This error instructs SvelteKit to initiate HTTP error handling.
 */
```

Internal helper, maximally terse (SvelteKit session-storage):

```js
/**
 * Read a value from `sessionStorage`
 * @param {string} key
 * @param {(value: string) => any} parse
 */
export function get(key, parse = JSON.parse) {
```

The browser-quirk why, with the symptom and the receipts (SvelteKit client runtime):

```js
// Firefox has a bug that sets the history state to `null` so we need to
// restore it after. See https://bugzilla.mozilla.org/show_bug.cgi?id=1199924
history.replaceState(history_state, '', url);
```

A spec citation carrying a magic number (SvelteKit redirect handling):

```js
// whatwg fetch spec https://fetch.spec.whatwg.org/#http-redirect-fetch says to error after 20 redirects
if (redirect_count < 20) {
```

An end-of-line why on a fallback (SvelteKit client runtime):

```js
setTimeout(fulfil, 100); // fallback for edge case where rAF doesn't fire because e.g. tab was backgrounded
```

A performance rationale for an odd-looking pattern (Svelte internals):

```js
// Store the references to globals in case someone tries to monkey patch these, causing the below
// to de-opt (this occurs often when using popular extensions).
export var is_array = Array.isArray;
```

Justifying code that looks like a bug (SvelteKit; a no-op assignment that forces a
refetch, with the bare suppression carried by the comment above):

```js
// fix link[rel=icon], because browsers will occasionally try to load relative
// URLs after a pushState/replaceState, resulting in a 404 — see
// https://github.com/sveltejs/kit/issues/3748#issuecomment-1125980897
link.href = link.href; // eslint-disable-line
```

Intentional emptiness, marked (SvelteKit; sessionStorage throws in sandboxed iframes):

```js
} catch {
	// do nothing
}
```

Cairn house style for a component: the `@component` block states behavior plus the
failure-mode rationale, and each Props member gets a one-line doc with a period:

```svelte
<!--
@component
A hidden CSRF double-submit field for an admin form. Pass `token` directly (the pre-auth
pages do), or omit it inside the authed shell, where AdminLayout provides the token
through context. A form that omits this field fails the guard's token check, which is the
intended fail-closed signal.
-->
  interface Props {
    /** The CSRF token. Falls back to the admin context when omitted. */
    token?: string;
  }
```

Cairn inline why, explaining a choice the code cannot show (NavTree):

```ts
// A flat, ordered working model is simpler to reorder than a recursive one: each row carries an
// explicit depth, and the nested tree is rebuilt from order plus depth only at submit time.
```

## Anti-patterns (both found in cairn; do not imitate)

The paraphrase, restating what the line visibly does:

```ts
if (lines.length > 1) lines.push(''); // blank line before this block
```

The filename header repeating what every editor already shows:

```ts
// src/lib/github/types.ts
// cairn-cms: the GitHub backend's plain data types and its one typed error.
```

## Off-voice contrast

The AI comment spray this file exists to prevent: narrating each step, capitalized labels,
no information the code lacks:

```ts
// Initialize the counter
let count = 0;
// Loop through the items
for (const item of items) {
  // Check if the item is valid
  if (isValid(item)) {
    // Increment the counter
    count++;
  }
}
```

## The TS tell catalogue (TS1 through TS15)

The numbered tells the `ts-conventions` skill cites. Each is an AI-shaped habit with its
mechanical fix; the worked examples below cover the tells the exemplars above do not already
show.

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
| TS15 | invented label-colon paragraphs in TSDoc | use the real tags, not a `Note:` block |

TS1, type restated from the signature. The annotation already says `string`:

```ts
// off-voice
/**
 * @param name {string} the user's name
 * @returns {string} the greeting
 */
// in-voice: state only the contract the type cannot
/** Greets the user. Falls back to "friend" when name is empty. */
```

TS9, the changelog comment. Git carries the task and the fix:

```ts
// off-voice
// added 2026-06 to fix the double-submit bug, see #1422
const token = freshToken();
// in-voice: the why, if it is not obvious; the issue link only if it argues the code
const token = freshToken(); // a reused token trips the guard's single-use check
```

TS13, the bare suppression. The reason rides inline:

```ts
// off-voice
// @ts-expect-error
widget.focus();
// in-voice
// @ts-expect-error the focus shim lands after hydration; types catch up next tick
widget.focus();
```

TS15, the invented label-colon paragraph. Use the tag the grammar provides:

```ts
// off-voice
/** Parses the slug. Note: throws on a trailing slash. */
// in-voice
/**
 * Parses the slug.
 * @throws {RangeError} when the slug carries a trailing slash.
 */
```
