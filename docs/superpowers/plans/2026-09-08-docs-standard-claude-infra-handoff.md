# Hand-off: docs-standard Claude infrastructure to plan two

Plan one, `docs/superpowers/plans/2026-09-08-docs-standard-claude-infra.md`, is closed. This
document names the artifacts plan two's preflight verifies and the obligations plan two must
add to itself. It does not re-run acceptance criteria already proved per task.

## The six artifacts

### 1. The profile flag

`tellgrader --profile docs-register <file>` carries `profile` and a `measures` object;
`tellgrader --profile none <file>` carries neither. Binary at `~/.local/bin/tellgrader`.

```
$ tellgrader --profile docs-register docs/extend/seam.md
{
  ...
  "profile": "docs-register",
  "measures": {
    "unit": "fraction",
    "selector": "prose",
    "sentences": 2,
    "hinged_pair_share": 0.5,
    "short_sentence_share": 0.5
  }
}

$ tellgrader --profile none docs/extend/seam.md
{
  ...
}
```

The `--profile none` report carries neither `profile` nor `measures`, confirmed against a
fixture inside a tree that would otherwise opt in.

### 2. The discovery schema

`.tellgrader.json` at a repo's root, three keys: `profile`, `include`, and `exclude`, all
glob-valued. Resolution walks up from the scanned file's directory to the nearest such file,
stopping at `$HOME` or `/`; the nearest file wins outright, with no merging across levels.

The exact JSON plan two commits at `~/Projects/cairn-cms/.tellgrader.json`:

```json
{
  "profile": "docs-register",
  "include": ["docs/**"],
  "exclude": ["docs/internal/**", "docs/superpowers/**"]
}
```

### 3. The measure definition

`~/.claude/skills/writing-voice/evals/tellgrader/MEASURES.md` is the canonical definition of
the sentence split, the hinged pair with its serial-list exclusion, the short-sentence share,
the `prose` selector, and the fraction unit. `measure-prose.mjs` in cairn-cms is a consumer
that conforms to this definition or retires against it; the document's own "Divergences from
cairn's measure-prose.mjs" section names every gap.

### 4. The Vale hook change

`~/.local/bin/vale-hook` names the resolved config root and the relative path it linted on any
findings path:

```
$ grep -n "config root" bin/.local/bin/vale-hook
74:    directory, so the file is linted from its config root by its relative path. Vale
141:            f"(graded from config root {root}, as {rel_path}).\n"
149:        f"(graded from config root {root}, as {rel_path}). "
```

The pytest suite covers the four path-grading cases and the full suite passes:

```
$ uv run --with pytest --no-project python -m pytest tests/test_vale_hook.py -q
............                                                             [100%]
12 passed in 1.41s
```

### 5. The two skills

```
$ readlink -f ~/.claude/skills/cairn-figure/SKILL.md
/var/home/glw907/.dotfiles/claude/.claude/skills/cairn-figure/SKILL.md

$ grep -n "^## Author-facing prose" claude/.claude/skills/writing-voice/SKILL.md
60:## Author-facing prose
```

`cairn-figure` loads and states both figure tests, the mermaid-default and SVG-exception
routing, the commit-the-source rule, and the `figure-verifier` agent, disclosing that
`check:figures` and `check:visuals` are plan two's work and are not runnable today.

### 6. The figure-verifier agent

```
$ readlink -f ~/.claude/agents/figure-verifier.md
/var/home/glw907/.dotfiles/claude/.claude/agents/figure-verifier.md

$ grep -n "earns its place\|decoration\|should be a table\|should be a numbered\|missing figure" claude/.claude/agents/figure-verifier.md
71:- **earns its place**: passes both figure tests, follows the routing rule, and its
73:- **decoration**: fails the removal test; the surrounding prose already carries the point.
74:- **should be a table**: the figure encodes enumerable rows and columns a table states more
76:- **should be a numbered list**: the figure encodes a sequence or an enumerated set a list
78:- **missing figure**: a paragraph fails the missing-figure test; name the paragraph that wants
```

All five verdict values are present; the agent returns one verdict per figure with a
`file:line`, per task 4's acceptance criterion 6.

## The two obligations plan two must add to itself

1. **Create `~/Projects/cairn-cms/.tellgrader.json`** with the schema in artifact 2. No task in
   plan one or plan two creates it today, and it is the sole mechanism by which the
   docs-register profile ever fires without an explicit flag. Without it, the profile is dead
   on arrival in the repo it was built for.
2. **Add `figure-verifier` to plan two's chain D.** Plan two mentions the agent nowhere today,
   and its figure work is the first consumer.

## Still owed, carried, not verified

The four lines in each `CLAUDE.md`, pending the owner's pick from
`docs/superpowers/plans/2026-09-08-claude-md-displacement-candidates.md`, batched with the
corpus approval sitting (decision 7). Unit 3c closes at that sitting, not here.

One additional note for that sitting, not part of task 6's own scope: the "paragraphs outside
the bounds" cell in the review agents' measurement table (task 4) has no defined bounds until
plan two ships the Vale paragraph rule. A reviewer reading that cell before plan two lands
should treat it as an open column, not a silent zero.
