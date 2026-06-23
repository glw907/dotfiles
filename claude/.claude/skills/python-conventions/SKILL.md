---
name: python-conventions
description: >
  Mandatory rules for writing Python docstrings and comments on this
  workstation. Use before writing, reviewing, or modifying any Python
  docstring or inline comment. Covers the write-time comment-or-not gate,
  the PEP 257 docstring shape (state intent, never the type the hint
  carries), the copy-in ruff D config, and the T-P1 through T-P13 AI-tell
  catalogue. The prose authority is the python-comments register.
---

# Python Comment Conventions

The reader is a Python coder or an agent already looking at the code. A comment carries what the
code cannot: a why, a constraint, a piece of evidence. The type hint already states the type, so a
docstring that restates it is noise. This skill is the Python arm of the authoring charter
(`~/.claude/docs/authoring-charter.md`). The deeper prose authority, with exemplars, is the
`python-comments` register at `~/.claude/docs/voice/python-comments.md`; load it before writing or
reviewing comments.

## Persona

You write Python the way the standard library and a well-run CLI do: a terse one-line docstring or
none, a `#` comment only where the why is non-obvious, type hints carrying the types. The
workstation's Python is small scripts in `~/.local/bin`, not a documented library, so a one-line
docstring is the common case and a missing one is fine. An `Args:` or `Returns:` block is reserved
for a contract the signature and the hints leave unobvious. Imperative mood, period-terminated.

## §0: Comment-or-not (write-time gate)

```
(a) Does the name plus the typed signature already say this?
(b) Is the why obvious from the next 5 lines or fewer?
(c) Would a reader otherwise miss a hidden constraint, an invariant, a
    side effect, or a surprising consequence?
```

Skip on (a) or (b). Write only for (c). A `with` block, a comprehension, and a standard idiom get
no narration; a Python reader knows them. The paraphrase test is the primary filter: if the
docstring is the signature in English, or the `#` comment restates the next line, delete it.

## Decision rubric

```
1. Public function, class, or method whose contract is fully implied by
   name + signature + hints?
   YES -> a one-line docstring if it sharpens intent, or none. No Args:/Returns:.
   NO  -> a one-line summary plus an Args:/Returns: entry only for the part
          the signature cannot express (a unit, a bound, a None-semantic).

2. Internal helper (leading underscore) with unobvious behavior?
   YES -> a one-line docstring or a short # comment.   NO -> nothing.

3. Inside a function: does this block differ from what the name and
   control flow imply?
   YES -> one-line # why-comment with evidence (issue URL, spec, symptom).
   NO  -> no comment.

4. A real gap or deferral?
   YES -> a concrete # TODO(glw907): ...   NO -> no apology, no hedge.
```

ruff does not force a docstring to exist; the `D100` through `D107` presence family is ignored
precisely so this gate, not the linter, owns presence. That mirrors Go's opt-in-on-unexported rule.

## Docstring shape

- PEP 257: a one-line docstring is one physical line, opening with a capital and ending with a
  period, in imperative mood ("Return the sum", not "Returns the sum"). ruff's `D401` enforces the
  mood and `D415` the period.
- State intent, never the type. The signature and the hints carry the types; the docstring carries
  the constraint, the unit, the None-semantic, or the caller obligation they cannot express.
- Google-style sections (`Args:`, `Returns:`, `Raises:`) are used sparingly, only when a parameter
  or return value carries a contract beyond its type. Document an `Args:` entry for the why, not the
  type. Document a `Raises:` entry only for an exception a caller must handle, never a speculative
  one.
- A module docstring is one sentence of intent when it earns its place, not a banner and not
  metadata git already tracks.
- Vary the opener across neighbors. Never lead every docstring with "Foo does X". One thought per
  comment. No em dash.

## Linting: the copy-in ruff config

The dotfiles repo carries this at `ruff.toml` in its root. A consumer repo copies it in and adjusts
`per-file-ignores` to its own test layout.

```toml
[lint]
select = ["D"]
ignore = ["D100", "D101", "D102", "D103", "D104", "D105", "D106", "D107"]
extend-select = ["D401"]

[lint.pydocstyle]
convention = "google"

[lint.per-file-ignores]
"tests/**" = ["D"]
```

`select = ["D"]` turns on the pydocstyle rules; `convention = "google"` disables the
convention-incompatible ones for you (and suppresses the `D203`/`D211` and `D212`/`D213`
incompatibility warnings). The `ignore` list drops the whole missing-docstring presence family,
because ruff has no warn tier and presence is this skill's gate, not a hard block. `extend-select`
restores `D401`, which the google convention drops. `per-file-ignores` exempts tests. ruff lints an
extensionless script too when you pass its path, so the bin scripts are covered; Vale's `py` scope
reaches `.py` files only.

## §catalogue: the T-P1 through T-P13 AI-tell catalogue

Each tell: id, name, the mechanical avoidance rule. The full prose, with an AI-shaped example and a
human counter-example, is in the `python-comments` register. When a finding triggers more than one
tell, cite the strongest: T-P1 (signature restatement) outranks T-P6 (type in the docstring); T-P4
(paraphrase) outranks a structural tell on the same line. Cite as `T-P<n> at file:line`.

| id | name | rule |
|---|---|---|
| T-P1 | docstring restating the signature | if it is the signature in English, delete it |
| T-P2 | reflexive docstring on a trivial helper | a private helper gets a docstring only for unobvious behavior |
| T-P3 | `Args:`/`Returns:` duplicating type hints | document a constraint, not a type the hint declares |
| T-P4 | `# This function` / restating the next line | the paraphrase test; comment the surprise |
| T-P5 | module or class docstring banner | one prose sentence; no banner art, no metadata git tracks |
| T-P6 | type info in the docstring | annotate the signature; the docstring states intent |
| T-P7 | hedging or apologetic docstring | state the invariant; a real gap is a concrete `# TODO(glw907):` |
| T-P8 | uniform docstring rhythm | length follows complexity |
| T-P9 | uniform "Foo does X" shape | imperative mood, varied sentence shape across neighbors |
| T-P10 | speculative `Raises:` entries | document only an exception a caller must handle |
| T-P11 | over-explaining Python idioms | never explain `with` or a comprehension to a Python reader |
| T-P12 | task-framing or changelog comments | git carries the task and the fix |
| T-P13 | restated-annotation `#` comment | the annotation is the type statement; delete the comment |

## Tooling and the division of labor

- ruff (`D` rules) owns docstring correctness: imperative mood, the period, the one-line form,
  argument-description completeness when an `Args:` block exists. It cannot see prose quality, and it
  does not force presence.
- Vale on `.py` comments owns the deterministic lexical net: the em dash, the marketing and slop
  words, the banned phrases, inside `#` comments and `"""` docstrings. It is the home of the retired
  `prose-guard` comment tier. It reaches `.py` files only; an extensionless script gets the ruff
  layer alone.
- This skill and the register own the semantic tells neither tool can see: the paraphrase, the
  reflexive docstring, the type narrated in prose, the uniform rhythm. When a finding is a plain
  lexical or correctness hit, expect ruff or Vale to have caught it; spend the judgment here.

## Output

When reviewing, cite each finding as `T-P<n> at file:line` with the one-line avoidance rule. When
writing, run the §0 gate first, then the rubric, then write only what survives.
