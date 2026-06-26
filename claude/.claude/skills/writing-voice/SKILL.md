---
name: writing-voice
description: Use when drafting or revising any substantial prose (a doc, plan, spec, README, design note, commit message, PR body, or site content) to load the audience's external standard, its canonical exemplars, and the shape rules. The on-demand router for the workstation voice system.
---

# Writing voice: the on-demand router

Claude writes to a published external standard per audience, not a house voice. The always-on
`writing-voice` output style carries the audience-invariant core: vary sentence length, one idea per
sentence, avoid the AI-writing tells. This skill is the router. Name the audience, open the register
or conventions skill that holds its standard and exemplars, and follow the shape rules below. Load it
before drafting anything longer than a paragraph, and imitate the standard's canonical exemplars
rather than reaching for more rules. The model generalizes from a good example better than from a
rule list, so the exemplars are the stronger attractor. This router is the entry point to the
authoring charter (`~/.claude/docs/authoring-charter.md`).

## Pick the standard

| Artifact | Standard | Where the exemplars live |
|---|---|---|
| Developer docs, README, or design doc in a Go repo | Google Developer Documentation Style Guide | `~/.claude/docs/voice/technical-doc-go.md` |
| Developer docs, README, or design doc in a SvelteKit or web repo | Google Developer Documentation Style Guide | `~/.claude/docs/voice/technical-doc-web.md` |
| Changelog entry, GitHub release note, or upgrade-guide entry | Google Developer Documentation Style Guide (the developer reading the changelog is the same reader as the docs) | `~/.claude/docs/voice/technical-doc-web.md` (Go repo: `technical-doc-go.md`) |
| End-user and editor product copy, admin walkthroughs | Microsoft Writing Style Guide | `~/.claude/docs/voice/editor.md` |
| CLAUDE.md, skills, agent definitions, hook text | Anthropic Claude Code best practices | `~/.claude/docs/voice/agent-facing.md` |
| Commit messages and PR bodies | Conventional Commits and the git-commit canon | `~/.claude/docs/voice/commit-and-pr.md` |
| Go code comments | Go Doc Comments, Effective Go | the go-conventions skill |
| TypeScript code comments | TSDoc | the ts-conventions skill |
| Svelte code comments | TSDoc plus the Svelte `@component` convention | the svelte-conventions skill |
| Python comments and docstrings | PEP 257, PEP 8 | the python-conventions skill |
| Site content (pages, posts, form copy) | the site's own content guide | the site repo's `docs/content-guide.md`, via the content-draft skill |

Site content is the one personal voice, and it lives in the site repo, out of the workstation's
scope. Every other audience follows its external standard. The web dialect follows the repo's stack;
a project CLAUDE.md may override with an explicit register line.

## Document shape

Shape-level tells read as machine-written even when every sentence is clean.

- Paragraphs over bullets. A bullet list is for a true enumeration (options, steps, fields), not for
  prose that happens to carry three points. If the items read as sentences with a shared subject, write
  the paragraph.
- No scaffold headers. "Overview", "Introduction", "Conclusion", and "Summary" are filler in anything
  shorter than a book chapter. A header serves a reader who navigates by it.
- Do not open every bullet or paragraph with a bolded lead phrase. Sparingly it signposts; by reflex it
  is the machine list default.
- One register per artifact. Do not drift from runbook to essay mid-document.

## The em dash

The em dash is banned in code comments. The comment standards are silent on it, but a comment is a
keyboard, grep, and monospace medium with no place for a character you cannot type or search, so the
comment linter flags it, the one code-hygiene rule the standards do not carry. In developer docs the
em dash follows Google, which recommends it with no surrounding spaces. Editor copy follows Microsoft,
which is sparing. A terminal reply and a commit message go without, since neither has an em-dash key.
Site content follows the site's voice. Overuse is a tell in any register.

## Where the rules are encoded

- The registers under `~/.claude/docs/voice/` and the four conventions skills: each names its external
  standard, its linter, and its canonical exemplars. Lean on the exemplars harder than on any rule list.
- Vale, per repo `.vale.ini`, with the Google package on developer docs and the Microsoft package on
  editor copy: the deterministic net on docs prose. The `vale-hook` feeds its findings back as advisory
  context on save, and CI runs the same config. The native comment linters cover code comments (gofmt and
  go vet, ESLint jsdoc and tsdoc, ruff `D`).
- The `writing-voice` output style: the always-on audience-invariant core.
- This skill: the router and the shape rules.
