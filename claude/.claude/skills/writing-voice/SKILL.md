---
name: writing-voice
description: Use when drafting or revising any substantial prose (a doc, plan, spec, README, design note, commit message, PR body, or site content) to load the audience's register, its exemplars, and the shape rules. The on-demand router for the workstation voice system.
---

# Writing voice: the on-demand router

The always-on `writing-voice` output style carries the audience-invariant voice: vary sentence
length, one idea per sentence, the universal tells, and the em-dash stance for replies. This skill is
the router. Name the audience, open the register that holds its persona and exemplars, and follow the
shape rules below. Load the register before drafting anything longer than a paragraph, and imitate its
exemplars rather than reaching for more rules. A tell is usually a register misapplied, so the
register is the stronger attractor.

## Pick the register

| Artifact | Register |
|---|---|
| Developer docs, README, or design doc in a Go repo | `~/.claude/docs/voice/technical-doc-go.md` |
| Developer docs, README, or design doc in a SvelteKit or web repo | `~/.claude/docs/voice/technical-doc-web.md` |
| End-user and editor product copy, admin walkthroughs | `~/.claude/docs/voice/editor.md` |
| CLAUDE.md, skills, agent definitions, hook text | `~/.claude/docs/voice/agent-facing.md` |
| Commit messages and PR bodies | `~/.claude/docs/voice/commit-and-pr.md` |
| Go code comments | the go-conventions skill |
| TypeScript and Svelte code comments | `~/.claude/docs/voice/ts-svelte-comments.md`, plus the ts-conventions and svelte-conventions skills |
| Python comments and docstrings | `~/.claude/docs/voice/python-comments.md`, plus the python-conventions skill |
| Site content (pages, posts, form copy) | the site repo's `docs/content-guide.md`, via the content-draft skill |

The dialect follows the repo's stack; a project CLAUDE.md may override with an explicit register line.

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

## The em-dash policy by audience

The em dash is the worked example of an audience-conditional rule. It is not banned outright, and
overuse is the real failure, flagged everywhere as a density signal.

| Audience | Em dash |
|---|---|
| Developer and planning docs (specs, plans, STATUS, post-mortems) | allowed; planning docs are throwaway, and long-term docs follow the Google standard |
| Polished or literary site content | allowed, sparing, per the site content-guide |
| End-user and editor product copy | discouraged |
| Agent-facing docs and commit messages | discouraged |
| Code comments | banned, enforced by the per-repo comment arm |
| Replies to Geoff | discouraged, a terminal reply has no em-dash key |

## Where the rules are encoded

- The registers under `~/.claude/docs/voice/`: persona, traits, and exemplars per audience. Registers
  are model-stable, so lean on them harder than on any rule list.
- Vale, per repo `.vale.ini` (the `glw907` overlay on the Google or Microsoft baseline): the
  deterministic lexical and structural net on docs prose and code comments. The `vale-hook` feeds its
  findings back as advisory context on save, and CI runs the same config.
- The `writing-voice` output style: the always-on audience-invariant voice.
- This skill: the router, the shape rules, and the em-dash matrix.
