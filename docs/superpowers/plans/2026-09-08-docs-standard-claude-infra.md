# cairn documentation standard, plan one of three: the Claude infrastructure pass

**Goal:** land the workstation half of the cairn documentation standard, so that plan two
(the cairn toolset) and plan three (the docs rewrite) build against a scanner, a set of
voice files, review agents, and skills that already carry the standard.

**Spec:** `~/Projects/cairn-cms/docs/superpowers/specs/2026-09-08-docs-standard-design.md`,
sections "Claude setup", "Where each piece lives", "Unit 3c: the workstation setup", and
"Owner decisions". Its parent proposal is
`~/Projects/cairn-cms/docs/internal/record/2026-09-08-polish-inputs/docs-standard-proposal.md`,
section "The Claude setup". All seven owner decisions are accepted as written; decision 7
puts the new cadence measures in tellgrader behind a docs-register profile that is off
outside docs paths.

**Repo:** `~/.dotfiles` (github.com/glw907/workstation). One task also touches
`~/Projects/cairn-cms/CLAUDE.md`, and that crossing is called out where it happens.

**Budget:** ceiling 1.2M tokens. Checkpoint interval four tasks (after task 4, and at close).

**Execution mode:** main-loop dispatch per task with the Agent tool, one
implementer-review-gate chain per task. The dotfiles repo has no repo-specific implementer
agent, so the implementer is `general-purpose` at `model: sonnet`, and the reviewer is
`diff-reviewer` (pinned `claude-opus-5` in its frontmatter). The gate is
`bash ~/.dotfiles/scripts/check.sh`. Task 1 additionally runs the tellgrader module's own
`make check`, and wires that command into `check.sh` so every later task's gate covers it.
Below eight dispatched tasks and with real file contention on `scripts/check.sh`,
`docs/STATUS.md`, and `README.md`, this pass runs sequentially in the main loop rather than
through `pass-execute.js`.

**The plan itself is not prose-graded and carries no receipt.**

## What this pass found before it was written

Three corrections to the spec's assumptions, each load-bearing for a task below.

**The tell scanner is not in poplar, and poplar's `make check` is not its gate.** Unit 3c's
last acceptance criterion says "The tellgrader change clears poplar's own `make check`".
That is wrong. `tellgrader` on PATH is `/var/home/glw907/.local/bin/tellgrader`, built from
`~/.dotfiles/claude/.claude/skills/writing-voice/evals/tellgrader/`, which reaches
`~/.claude` through the `claude` stow package. It is a Go module in its own right, module
path `github.com/glw907/workstation/tellgrader`, Go 1.27, one dependency (`spf13/cobra`).
Its gate is its own `Makefile`: `make check` runs `go vet ./...`, `golangci-lint run ./...`,
and `go test ./...`. Its packages are `internal/tellscan` (the scanner and its
`scan_test.go`) and `internal/posthook` (the PostToolUse adapter and its `posthook_test.go`).
The compiled binary is gitignored; the source is tracked in the dotfiles repo. **The real
gate is `make -C ~/.dotfiles/claude/.claude/skills/writing-voice/evals/tellgrader check`,
and `scripts/check.sh` does not run it today.** Task 1 wires it in.

**Both `CLAUDE.md` files are at or over the budget hook's ceiling already.**
`claude-context-budget` sets `CLAUDE_MD_BUDGET=6000` approximate tokens, measured as bytes
divided by four. `~/.dotfiles/claude/.claude/CLAUDE.md` is 23,995 bytes, about 5,998 tokens,
one line under. `~/Projects/cairn-cms/CLAUDE.md` is 24,136 bytes, about 6,034 tokens, which
is already over. So the spec's "four lines replace four others" understates the cairn file:
it must shed the four new lines' cost plus about 136 bytes of existing overage. Task 6
carries this and is blocked on the owner.

**The `.claude` tree is a stow package, with live unstowed state beside it.** `CLAUDE.md`,
`agents/`, `docs/`, `instructions/`, `output-styles/`, `settings.json`, `skills/`, and
`workflows/` under `~/.claude` are all symlinks into `~/.dotfiles/claude/.claude/`. Every
task edits the stow source, never the symlink. A task that creates a new file or directory
needs `stow -R claude` afterwards; an edit to an existing file does not.

## Global constraints (every task)

- Edit stow sources under `~/.dotfiles/claude/.claude/`, never the `~/.claude/` symlinks.
- The dotfiles working tree was clean at plan authoring. A task starts only when none of its
  own **Files** appears in `git -C ~/.dotfiles status --short`. Never `git add` a path
  outside the task's own list. The one-executor-per-worktree rule applies: verify no other
  live executor holds this repo before the first dispatch.
- Prose register: `CLAUDE.md`, skills, and agent definitions follow
  `~/.claude/docs/voice/agent-facing.md`; the repo docs follow the Google developer-doc
  register. No em dashes in anything this pass writes.
- Go written this pass invokes the `go-conventions` skill first, as the workstation rule
  requires. Comments follow Go Doc Comments; no em dashes.
- Every task ends with `bash ~/.dotfiles/scripts/check.sh` green, then stages exactly its own
  paths with `git add` and does not commit. The conductor commits each accepted task by path.
- Every commit message ends with:

  ```
  Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>
  Claude-Session: https://claude.ai/code/session_01EVUo5W1SXuvMxsqDx8xdtH
  ```

---

### Task 0: Pre-bake and coordination gate (conductor, no dispatch)

**Dependencies:** none. **Deliverables:** 2.

- Run `git -C ~/.dotfiles status --short` and confirm it is empty, or that no listed path
  appears in any task's **Files**. Run `pgrep -f /var/home/glw907/.dotfiles` and confirm no
  other executor holds the repo.
- Commit this plan file, so STATUS and the later tasks can point at a committed path.

**Acceptance criteria:** `git -C ~/.dotfiles log -1 --name-only` names
`docs/superpowers/plans/2026-09-08-docs-standard-claude-infra.md` and nothing else.

---

### Task 1: The tellgrader docs-register profile, the two measures, and the gate wiring

**Dependencies:** task 0. **Deliverables:** 4 (the profile and its opt-in resolution; the two
measures; the fixtures; the gate wiring).

Give the scanner the hinged-pair share and the short-sentence share, in report mode, behind a
named profile that is off unless a repo opts in and the file sits under a declared docs path.
Nothing this task adds ever produces a finding, changes an exit code, or blocks a hook.

**Files:**

- Modify: `claude/.claude/skills/writing-voice/evals/tellgrader/cmd/tellgrader/root.go`
  (the `--profile` and `--bands-dir` flags, threaded into `tellscan.Options`)
- Create: `claude/.claude/skills/writing-voice/evals/tellgrader/internal/tellscan/profile.go`
  (profile resolution, the opt-in file, the band loader)
- Create: `claude/.claude/skills/writing-voice/evals/tellgrader/internal/tellscan/measures.go`
  (hinged-pair share, short-sentence share)
- Modify: `claude/.claude/skills/writing-voice/evals/tellgrader/internal/tellscan/scan.go`
  (the new `Report` fields, emitted only under the profile)
- Create: `claude/.claude/skills/writing-voice/evals/tellgrader/internal/tellscan/profile_test.go`
- Create: `claude/.claude/skills/writing-voice/evals/tellgrader/internal/tellscan/testdata/`
  (the three fixture trees below)
- Create: `claude/.claude/docs/voice/bands/docs.json` (the seed band file and its schema;
  task 2 fills in the remaining audiences)
- Modify: `scripts/check.sh` (a `run` line for the tellgrader module's `make check`)

**Interfaces produced.** Plan two and plan three consume these names, so they are fixed here:

- Profile name: `docs-register`.
- CLI: `tellgrader --profile docs-register <file>` forces the profile on for any path;
  `--profile none` forces it off; omitting the flag resolves it from the repo opt-in.
  `--bands-dir <dir>` overrides the band directory, whose default is
  `~/.claude/docs/voice/bands`.
- Repo opt-in: a repo declares the profile by committing `.tellgrader.json` at its root:

  ```json
  { "profile": "docs-register", "paths": ["docs/"] }
  ```

  Resolution walks up from the scanned file's directory to the nearest `.tellgrader.json`,
  stopping at `$HOME` or `/`. The profile is on only when the file's path relative to that
  root starts with one of `paths`. A repo with no such file never gets the profile, whatever
  its directory names.
- Band file: `~/.claude/docs/voice/bands/<register>.json`, shape

  ```json
  {
    "register": "docs",
    "source": "the corpus manifest entry or measurement this band came from",
    "hinged_pair_share": { "low": 0.20, "high": 0.45 },
    "short_sentence_share": { "low": 0.10, "high": 0.25 },
    "avg_sentence_words": { "low": 15, "high": 20 }
  }
  ```

  A missing or unparseable band file is not an error: the measures are still reported, with
  the band echo absent.
- New `Report` fields, all `omitempty` so a report outside the profile is byte-identical to
  today's: `profile` (string), `hinged_pair_share` (float), `short_sentence_share` (float),
  `bands` (the loaded band object).

**Definitions to implement.** A hinged pair is two clauses joined by a comma plus a
coordinator, by a colon, by a semicolon, by a spaced dash, or by a chain of relative clauses.
The share is hinged sentences over total sentences. A short sentence is under eight words;
the share is short sentences over total sentences. Both reuse the existing
`splitSentences` and code-blanking in `cadence.go` so the sentence denominator matches the
cadence CV already reported. The doc comment on each measure must name
`~/Projects/cairn-cms/scripts/checks/measure-prose.mjs` as the reference implementation the
definitions track, and must record that the definition is unsettled and that no number
built on it gates.

**Acceptance criteria** (each testable from a command's output):

1. `make -C ~/.dotfiles/claude/.claude/skills/writing-voice/evals/tellgrader check` exits 0,
   covering `go vet`, `golangci-lint`, and `go test ./...`.
2. Fixture A, the required off-on-site-content proof. A testdata repo declaring
   `{ "profile": "docs-register", "paths": ["docs/"] }` at its root, with a site-content file
   at `src/content/posts/spring.md`. Scanning that file with no `--profile` flag produces a
   report whose JSON carries none of `profile`, `hinged_pair_share`, `short_sentence_share`,
   or `bands`.
3. Fixture B, the required on-by-default proof. The same testdata repo, file at
   `docs/extend/seam.md`. Scanning it with no `--profile` flag produces a report carrying
   `"profile": "docs-register"` and both share fields with values in `[0,1]`.
4. Fixture C, the opt-in-is-required proof. A testdata repo with no `.tellgrader.json`, file
   at `docs/extend/seam.md`. The report carries neither share field.
5. Fixture D, the force-on escape. Fixture A's site-content file scanned with
   `--profile docs-register` carries both share fields, proving a reviewer can grade an
   arbitrary file on demand without the repo opting in.
6. A band file present under `--bands-dir` appears in the report's `bands` field; the same
   scan with `--bands-dir /nonexistent` still reports both shares and omits `bands`.
7. No new finding check, no new exit code, and no change to `TellsPer1000Words`. Prove it:
   `tellgrader --register docs <any existing fixture>` produces the same `findings` array and
   the same exit code as before the change.
8. `bash ~/.dotfiles/scripts/check.sh` runs the tellgrader `make check` as a named step and
   the whole gate exits 0. The new `run` line names the step "tellgrader go check".

**Gate:** the tellgrader module's `make check`, then `bash ~/.dotfiles/scripts/check.sh`.

**Notes.** Skip the check.sh wiring cleanly if `golangci-lint` is absent on PATH: the `run`
line must fail loudly rather than silently pass, so it invokes `make check` directly and lets
a missing linter fail the gate. `go` is on PATH via Homebrew per the machine's tier map.
Do not touch `posthook.go`'s register routing; the profile is orthogonal to the register and
the hook keeps grading `.md` as `docs` or `agent` exactly as today.

---

### Task 2: The voice layer, the output style and the voice files

**Dependencies:** task 1 (the band file schema). **Deliverables:** 3.

**Files:**

- Modify: `claude/.claude/output-styles/writing-voice.md` (three tells added, nothing else)
- Modify: `claude/.claude/docs/voice/technical-doc-web.md`,
  `claude/.claude/docs/voice/technical-doc-go.md`,
  `claude/.claude/docs/voice/editor.md`, `claude/.claude/docs/voice/agent-facing.md`
  (each names its corpus entries and its advisory bands)
- Create: `claude/.claude/docs/voice/bands/editor.json`,
  `claude/.claude/docs/voice/bands/agent.json`
  (`docs.json` lands in task 1)

**The three tells**, added to the output style's "Avoid these structural habits" list and
nowhere else, in the list's existing voice:

- The two-headed heading: a heading that names two things joined by "and" or a colon, so the
  section beneath it covers two ideas.
- The abstract noun standing in for the concrete thing ("the solution", "the approach", "the
  mechanism") where the concrete name was available.
- The page describing itself ("this guide explains", "this section covers") instead of doing
  the thing it describes.

Nothing else is added to the output style. The spec is explicit that a longer prohibition
list narrows what a model avoids without changing what it produces.

**Interfaces produced:** `~/.claude/docs/voice/bands/{docs,editor,agent}.json`, which
tellgrader reads by default and which plan two's corpus manifest task updates once the
corpus entries are approved and measured. Each voice file gains a "Corpus entries and bands"
section at a stable heading, which is what plan three's drafters open.

**Acceptance criteria:**

1. `grep -c "two-headed heading" claude/.claude/output-styles/writing-voice.md` is 1, and the
   same for the other two tells; the file's diff adds three bullets and changes no other line.
2. Each of the four voice files carries a `## Corpus entries and bands` section naming the
   corpus entry ids for its audience (placeholders where the corpus is not yet approved, each
   marked `pending owner approval, decision 7`) and the numeric bands, matching the values in
   its band JSON.
3. `python3 -c 'import json,sys; [json.load(open(p)) for p in sys.argv[1:]]' claude/.claude/docs/voice/bands/*.json` exits 0
   and each file validates against the schema task 1 fixed.
4. `tellgrader --profile docs-register --bands-dir ~/.dotfiles/claude/.claude/docs/voice/bands <a docs file>`
   echoes the band values from `docs.json`.
5. `bash ~/.dotfiles/scripts/check.sh` exits 0.

**Notes.** The bands are advisory and stay advisory: the spec forbids any cadence number
becoming a gate until a track has twenty documents and three hundred sentences behind it.
Say so in each voice file's section so a later reader does not promote them.

---

### Task 3: The Vale hook grades a draft by its path

**Dependencies:** task 0. **Deliverables:** 3.

**Files:**

- Modify: `bin/.local/bin/vale-hook`
- Modify: `tests/test_vale_hook.py`

The spec's line is "The Vale hook grades a draft by its path, which step 2 of the review
chain makes sufficient." The hook already lints from the nearest `.vale.ini` by the file's
relative path, so Vale's own section globs do the grading. What is missing is that the
grading is invisible and untested, and that the two skip rules match substrings rather than
path segments. This task closes those three gaps and changes nothing else.

**Acceptance criteria:**

1. The `/superpowers/` skip and the `.md` extension test are anchored to path segments, so a
   repository whose own directory name contains `superpowers` is not exempted. A pytest case
   proves a file at `/x/mysuperpowers/docs/a.md` is linted and one at
   `/x/docs/superpowers/a.md` is skipped.
2. The advisory and error messages name the config root the hook resolved and the path it
   linted relative to that root, so an author can see which section selected their style. A
   pytest case asserts both strings appear in the output.
3. Three pytest cases prove path grading against a temporary repo carrying a two-section
   `.vale.ini`: a file under `docs/admin/` resolves to the Microsoft section, one under
   `docs/extend/` to the Google section, and one under `src/content/` to neither, producing
   no findings and exit 0.
4. The hook still fails open in every existing case: no Vale on PATH, no `.vale.ini` up the
   tree, unreadable file, malformed stdin. The existing pytest cases pass unchanged.
5. `uv run --with pytest --no-project python -m pytest tests/ -q` exits 0, and
   `bash ~/.dotfiles/scripts/check.sh` exits 0.

**Interfaces produced:** none plan two consumes. The hook's contract with the review chain is
that a page drafted at its published path is graded by that path's styles from the first
save, which criterion 3 is the proof of.

**Notes.** This is the one spec item whose wording implies no behavior change. The reading
taken here, that the change is to make path grading visible and tested rather than to alter
what the hook grades, is recorded so a later reader does not go looking for a larger change.
Raise it at the checkpoint if the owner meant something else.

---

### Task 4: The review agents

**Dependencies:** task 1 (the profile flag the agents invoke). **Deliverables:** 4.

**Files:**

- Modify: `claude/.claude/agents/prose-voice-reviewer.md`
- Modify: `claude/.claude/agents/cairn-register-editor.md`
- Modify: `claude/.claude/agents/diff-reviewer.md`
- Create: `claude/.claude/agents/figure-verifier.md`

**What changes, per the spec's Claude setup list:**

- `prose-voice-reviewer` and `cairn-register-editor` must be given a corpus entry in the
  dispatch and must refuse to grade without one. Each report carries a measurement table
  (sentences, average length, longest sentence, hinged-pair share, short-sentence share,
  paragraphs, paragraphs outside the bounds) beside the corpus entry's own numbers, and the
  verdict cites the entry. A verdict citing no corpus entry does not count. Where a brief
  names two entries, the page is compared against the closer of the two and the report names
  both. Each runs `tellgrader --profile docs-register --register <r> <file>` as its
  deterministic floor.
- `diff-reviewer` runs the scanner in report mode when the task's diff touches
  `docs/**/*.md`, and includes its numbers in the verdict. It must not return `fix` on a
  non-gating measurement alone; that is the spec's gameability risk stated as a rule.
- `figure-verifier` is new: read-only, `tools: Read, Grep, Glob, Bash`, `model:
  claude-opus-5`, `effort: high`. It grades every figure on a page by the two figure tests
  (remove the figure and see whether the prose still makes the point; read each paragraph and
  ask whether it is the text alternative of a diagram nobody drew), plus the register's
  2026-08-15 visual-layer rulings, the mermaid-default and SVG-exception routing, the
  committed-source-and-script requirement, and the alt-attribute rule. Its verdict per figure
  is one of `earns its place`, `decoration`, `should be a table`, `should be a numbered
  list`, or `missing figure`, each with a `file:line`.

**Interfaces produced:** the agent name `figure-verifier`, which plan two's figure tasks and
plan three's per-page chains dispatch. The measurement-table shape, which plan three's
receipts quote.

**Acceptance criteria:**

1. Each of the four files has valid YAML frontmatter with `name`, `description`, `tools`, and
   `model`, and `name` matches the filename stem. Prove it by parsing each frontmatter block
   with `python3 -c` and printing the four names.
2. `grep -l "corpus entry" claude/.claude/agents/{prose-voice-reviewer,cairn-register-editor}.md`
   lists both files, and each states that a verdict citing no corpus entry does not count.
3. `grep -n "docs-register" claude/.claude/agents/*.md` shows the profile named in
   `prose-voice-reviewer`, `cairn-register-editor`, and `diff-reviewer`.
4. `diff-reviewer.md` states the rule that a non-gating measurement alone never supports a
   `fix` verdict.
5. `figure-verifier.md` names all five verdict values and both figure tests.
6. `bash ~/.dotfiles/scripts/check.sh` exits 0.

**Notes.** `cairn-register-editor` and `diff-reviewer` are both live agents other passes
dispatch today. Keep every existing instruction that is not being replaced; this is an
addition to their dispatch shape, not a rewrite. New file means `stow -R claude` in task 7.

---

### Task 5: The two skills

**Dependencies:** task 0. **Deliverables:** 2.

**Files:**

- Create: `claude/.claude/skills/cairn-figure/SKILL.md`
- Modify: `claude/.claude/skills/writing-voice/SKILL.md`

`cairn-figure` holds the production path for figures on any cairn-family repo: when a figure
earns its place (the two tests), the two-lane routing rule (mermaid in the page by default,
hand-authored SVG the exception, no third tool), the requirement that every figure's source
and its generating script are committed, the text-alternative requirement and the containment
rule for authored docs diagrams, and the gates that check each part (`check:figures`,
`check:visuals`) with the `figure-verifier` agent as the judgment layer. Its description
triggers on figure, diagram, screenshot, and illustration work in a cairn repo.

The `writing-voice` skill gains an author-facing prose section carrying the brief-first
protocol (the brief file exists before the outline, the outline is reviewed before any
sentence) and the one-section-per-read rule, with the standing rule that a page for an
outside reader is never drafted end to end in an autonomous run.

**Interfaces produced:** the skill name `cairn-figure`, which plan two and plan three invoke;
the stable heading `## Author-facing prose` in the writing-voice skill, which plan three's
drafting dispatches cite.

**Acceptance criteria:**

1. `claude/.claude/skills/cairn-figure/SKILL.md` has frontmatter whose `name` is
   `cairn-figure` and whose `description` states when to use it, in the shape the other
   skills in that directory use. Parse the frontmatter and print the name.
2. The skill names both figure tests, the mermaid-default and SVG-exception rule, the
   commit-the-source rule, and the `figure-verifier` agent.
3. `grep -n "^## Author-facing prose" claude/.claude/skills/writing-voice/SKILL.md` returns a
   line, and the section states both the brief-first protocol and the one-section-per-read
   rule.
4. The writing-voice skill's existing sections are unchanged except for the addition. Confirm
   with `git diff --stat` showing one file and an insertion-only change.
5. `bash ~/.dotfiles/scripts/check.sh` exits 0.

**Notes.** New directory means `stow -R claude` in task 7, and the skill is not loadable
until that runs. Skill prose follows `~/.claude/docs/voice/agent-facing.md`.

---

### Task 6: The two CLAUDE.md files (BLOCKED ON THE OWNER)

**Dependencies:** tasks 1 through 5, since the four lines describe what they built.
**Deliverables:** 2 in the unblocked half (the drafted four lines, the ranked candidate
list); 1 in the blocked half (the edits themselves).

**Blocked on:** the owner's pick of which lines leave each file. The spec calls this a taste
call and an owner action, taken at the same sitting that approves the corpus (decision 7).
**This task produces the candidate list and stops. It must not edit either `CLAUDE.md`
until the owner has picked.**

**Files:**

- Create: `docs/superpowers/plans/2026-09-08-claude-md-displacement-candidates.md`
- Modify, only after the owner picks: `claude/.claude/CLAUDE.md`
- Modify, only after the owner picks and in a separate commit in a separate repo:
  `~/Projects/cairn-cms/CLAUDE.md`

**The budget arithmetic the candidate list must state.** `claude-context-budget` allows 6,000
approximate tokens, computed as bytes divided by four, so 24,000 bytes.
`claude/.claude/CLAUDE.md` is 23,995 bytes, five bytes of headroom.
`~/Projects/cairn-cms/CLAUDE.md` is 24,136 bytes, already 136 bytes over, so it must shed the
new lines' cost plus that overage before the hook stops firing.

**The four lines, drafted here for the owner to approve.** Each file gains four lines, no
more, naming: the standard's existence and where it lives; the brief-first and
one-section-per-read protocol for any page an outside reader will read; the rule that a claim
about the owner or about cairn's stance resolves to a line in an owner brief; and the
docs-register profile with the fact that no measure it reports gates.

**Acceptance criteria for the unblocked half:**

1. The candidate document exists and, for each of the two files, lists at least eight
   candidate lines or paragraphs to displace, each with its exact byte cost (measured, not
   estimated), its heading, and one sentence on what is lost and where that content still
   lives if it leaves.
2. The document states the arithmetic above and, per file, the byte total that must leave for
   the file to sit under budget with the four lines added.
3. The document carries the four drafted lines verbatim, per file, in each file's own voice.
4. Neither `CLAUDE.md` is modified. `git -C ~/.dotfiles status --short claude/.claude/CLAUDE.md`
   and `git -C ~/Projects/cairn-cms status --short CLAUDE.md` are both empty.
5. `bash ~/.dotfiles/scripts/check.sh` exits 0.

**Acceptance criteria for the blocked half, run only after the owner picks:**

6. `claude-context-budget ~/.dotfiles/claude/.claude/CLAUDE.md ~/Projects/cairn-cms/CLAUDE.md`
   exits 0.
7. Each file gained exactly four lines and lost exactly what the owner named.

**Notes.** The cairn edit lands in a different repository, which cairn's own gate does not
cover for `CLAUDE.md`. Before touching it, check `git -C ~/Projects/cairn-cms status --short`
and `pgrep -f /var/home/glw907/Projects/cairn-cms` for a live executor: that repo has warm
uncommitted work and polish passes in flight. If one is live, stand down and report; do not
race it. Commit the two files separately, in their own repositories.

---

### Task 7: The dotfiles ritual

**Dependencies:** tasks 1 through 6 accepted (task 6's unblocked half is enough).
**Deliverables:** 4.

**Files:**

- Modify: `docs/STATUS.md`
- Modify: `docs/HISTORY.md`
- Modify: `ROADMAP.md`
- Modify: `README.md`

**What each gets:**

- `docs/STATUS.md`, present tense only, target under 60 lines. The gate row gains the
  tellgrader Go check. The immediate next action names task 6's blocked half and plan two.
  Nothing historical is added here.
- `docs/HISTORY.md`, a newest-first entry for this pass: what landed, what the gate caught,
  and what a later pass would be wrong to rediscover. That last clause carries the three
  findings from this plan's own header, above all that tellgrader lives in the claude stow
  package with its own `make check` and is not a poplar artifact.
- `ROADMAP.md`, an `Active` entry for the cairn documentation standard: this pass is plan one
  of three, plan two is cairn's toolset and plan three the rewrite, the spec path is the
  standing input, and the workstation's continuing obligation is that the scanner, the voice
  files, the agents, and the skills stay in step with the standard.
- `README.md`, the "Intentionally untracked local tools" section records that `tellgrader`'s
  source is tracked in this repo under the `claude` package while its binary is installed to
  `~/.local/bin` by the module's own `make install`, alongside poplar's entry.

**Stow and manifest work:**

- Run `stow -R claude` from `~/.dotfiles`, then confirm the new paths resolve:
  `readlink -f ~/.claude/skills/cairn-figure/SKILL.md`,
  `readlink -f ~/.claude/agents/figure-verifier.md`, and
  `readlink -f ~/.claude/docs/voice/bands/docs.json` each point back under `~/.dotfiles`.
- Rebuild and reinstall the scanner:
  `make -C ~/.dotfiles/claude/.claude/skills/writing-voice/evals/tellgrader install`, then
  `tellgrader --help` shows `--profile` and `--bands-dir`.
- No new script is added to `~/.local/bin` and no stow package is added, so
  `bluefin/stow-packages.txt` is unchanged. Run `check-drift` and confirm it reports no new
  drift beyond the rebuilt `tellgrader` binary.

**Acceptance criteria:**

1. `wc -l docs/STATUS.md` is at most 60, and the file carries no history section.
2. `head -40 docs/HISTORY.md` shows this pass's entry newest-first, naming the tellgrader
   home-and-gate finding and the CLAUDE.md budget finding.
3. `ROADMAP.md` carries the initiative under `## Active` with the spec path.
4. The three `readlink -f` commands each resolve under `~/.dotfiles`.
5. `tellgrader --help` lists `--profile` and `--bands-dir`.
6. `check-drift` reports no unrecorded drift.
7. `bash ~/.dotfiles/scripts/check.sh` exits 0.

**Notes.** STATUS is present tense; anything that reads as history moves to HISTORY rather
than being summarized harder. The pre-existing STATUS carry-forwards from the 2026-09-04
Fable pass stay unless they are genuinely closed; do not silently drop another pass's items.

---

### Task 8: The hand-off to plan two

**Dependencies:** task 7. **Deliverables:** 2.

Write down exactly what plan two's first task verifies, and prove each line by running it.

**Files:**

- Create: `docs/superpowers/plans/2026-09-08-docs-standard-claude-infra-handoff.md`

**What plan two's first task verifies, the full list:**

1. **The profile flag is accepted.** `tellgrader --profile docs-register --register docs <file>`
   exits 0 and its JSON carries `profile`, `hinged_pair_share`, and `short_sentence_share`.
   `tellgrader --profile none <file>` carries none of them.
2. **The profile is off outside docs paths.** In a repo declaring
   `{ "profile": "docs-register", "paths": ["docs/"] }`, a file under `src/content/` scanned
   with no flag carries no share fields, and a file under `docs/` carries both.
3. **The opt-in mechanism is the one plan two will use.** `.tellgrader.json` at the repo root,
   the two keys `profile` and `paths`, resolved by walking up from the scanned file. Plan
   two's first task adds that file to `~/Projects/cairn-cms` and proves both halves of item 2
   against the real repo.
4. **The band files exist and load.** `~/.claude/docs/voice/bands/{docs,editor,agent}.json`
   parse as JSON and appear in a report's `bands` field. Plan two's corpus task fills their
   numbers once the corpus is approved.
5. **The hook change is in.** `vale-hook` names the resolved config root and relative path in
   its output, and its pytest suite covers the three path-grading cases.
6. **The agents are present and shaped.** `~/.claude/agents/figure-verifier.md` exists;
   `prose-voice-reviewer`, `cairn-register-editor`, and `diff-reviewer` each name the
   `docs-register` profile, and the first two refuse a dispatch carrying no corpus entry.
7. **The skills are present.** `~/.claude/skills/cairn-figure/SKILL.md` loads, and the
   writing-voice skill carries `## Author-facing prose`.
8. **The gate covers the scanner.** `bash ~/.dotfiles/scripts/check.sh` runs the tellgrader
   `make check` as a named step.
9. **What is still owed.** Task 6's blocked half, the four lines in each `CLAUDE.md`, pending
   the owner's pick, batched with the corpus approval sitting (decision 7).

**Acceptance criteria:**

1. The hand-off document carries all nine items, each with the exact command and its expected
   output.
2. Every command in the document has been run and its real output pasted beneath it, item 9
   excepted.
3. `docs/STATUS.md`'s immediate next action points at this document.
4. `bash ~/.dotfiles/scripts/check.sh` exits 0.

**Notes.** This document is the pass's product for plan two. Plan two's first task runs it top
to bottom before writing a line of cairn code, and a failing item is a blocker rather than a
warning.

---

## Task ledger

| # | Title | Depends on | Deliverables | Blocked |
|---|---|---|---|---|
| 0 | Pre-bake and coordination gate | none | 2 | no |
| 1 | tellgrader profile, measures, gate wiring | 0 | 4 | no |
| 2 | Voice layer: output style and voice files | 1 | 3 | no |
| 3 | Vale hook grades by path | 0 | 3 | no |
| 4 | Review agents | 1 | 4 | no |
| 5 | The two skills | 0 | 2 | no |
| 6 | Both CLAUDE.md files | 1 to 5 | 2 unblocked, 1 blocked | yes, owner |
| 7 | Dotfiles ritual | 1 to 6 | 4 | no |
| 8 | Hand-off to plan two | 7 | 2 | no |

Checkpoint after task 4: write STATUS, report spend against the 1.2M ceiling, and batch any
judgment call into the one combined question that also carries task 6's candidate list.

## Spec coverage

Every item the spec assigns to the workstation, and the task that carries it.

| Spec item | Task |
|---|---|
| Claude setup 1: both `CLAUDE.md` files gain four lines, displacing four | 6 |
| Claude setup 2: the output style gains three tells | 2 |
| Claude setup 3: the voice files name their corpus entries and bands | 2 |
| Claude setup 4: the scanner gains the two shares, behind the profile, with a band file per audience | 1, and the remaining band files in 2 |
| Claude setup 5: the Vale hook grades a draft by its path | 3 |
| Claude setup 6: the review agents change dispatch shape, and `figure-verifier` is new | 4 |
| Claude setup 7: `cairn-figure` is new, and writing-voice gains the author-facing section | 5 |
| Where each piece lives: the measurement instrument as a shared definition | 1, the doc comments naming `measure-prose.mjs` as the reference implementation |
| Where each piece lives: the review protocol | 4 for the reviewer shape, 5 for the drafting protocol |
| Unit 3c criterion 2: a fixture proves the profile does not fire on site content | 1, fixture A |
| Unit 3c criterion 3: both `CLAUDE.md` files stay within the budget hook | 6, blocked half |
| Unit 3c criterion 4: the tellgrader change clears its gate | 1, corrected to the module's own `make check` and wired into `scripts/check.sh` |

## Risks

- **The hinged-pair definition is unsettled.** The spec says so plainly, and the instrument
  moved twice during the proposal. Task 1's definitions track
  `measure-prose.mjs`, and a later change there desynchronizes the two. Nothing gates on
  either number, which is what keeps the risk cheap.
- **The two-repo crossing in task 6.** cairn-cms carries warm uncommitted work. The task
  checks for a live executor and stands down rather than racing.
- **The band numbers are placeholders until the corpus is approved.** Tasks 1 and 2 ship the
  mechanism with values marked pending. Plan two fills them. A reader who takes the seed
  numbers as measured would be wrong, so each file says so.
- **A new agent or skill is invisible until `stow -R claude` runs.** Task 7 carries it, so
  tasks 4 and 5 cannot be verified by loading the skill or dispatching the agent before then.
  Their acceptance criteria are file-shape checks for that reason.
