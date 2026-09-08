# cairn documentation standard, plan one of three: the Claude infrastructure pass

**Goal:** land the workstation half of the cairn documentation standard, so that plan two
(the cairn toolset) and plan three (the docs rewrite) build against a scanner, a written
measure definition, a set of voice files, review agents, and skills that already carry the
standard.

**Spec:** `~/Projects/cairn-cms/docs/superpowers/specs/2026-09-08-docs-standard-design.md`,
sections "Claude setup", "Where each piece lives", "Unit 3c: the workstation setup", and
"Owner decisions". Its parent proposal is
`~/Projects/cairn-cms/docs/internal/record/2026-09-08-polish-inputs/docs-standard-proposal.md`,
section "The Claude setup". All seven owner decisions are accepted as written; decision 7
puts the new cadence measures in tellgrader behind a docs-register profile that is off
outside docs paths.

**Repo:** `~/.dotfiles` (github.com/glw907/workstation), and only that repo. Revision 3
removes every write into `~/Projects/cairn-cms`. This pass reads cairn's `CLAUDE.md` to
measure it and writes nothing there.

**Budget:** ceiling 0.6M tokens, down from revision 2's 1.2M after task 1 split, the band
directory dropped, and task 6 shrunk to a measured document. Checkpoint interval four tasks
(after task 3, and at close).

**Size:** seven dispatched tasks (1a, 1b, 2, 3, 4, 5, 6) and three conductor tasks that
dispatch nothing (0, 7, 8). Tasks 7 and 8 are ledger and hand-off writing, which the
conducting rule already assigns to the conductor, and dispatching them would pay a subagent
to re-derive a pass narrative the conductor already holds.

**Split point, if the pass runs past its ceiling: task 6, whole.** Task 6 produces a document
for an owner sitting that happens after this pass either way. Task 7's dependency line
already runs without it, and nothing in plan two reads it. Cutting task 6 leaves 0, 1a, 1b,
2, 3, 4, 5, 7, 8 with no other edge to repair.

**This pass cannot close unit 3c.** Criterion 3, both `CLAUDE.md` files within the budget
hook, needs the owner's displacement pick, which decision 7 batches with the corpus approval.
Unit 3c closes at that sitting, not at this pass's end.

**Proportion, disclosed.** The spec sizes unit 3c at "roughly three to four tasks" and
decision 10 calls the Claude setup "small; the scanner change is about 285 lines". This plan
carries seven dispatched tasks. The gap is partly a wrong estimate (the scanner work is real,
and the fixtures and the written definition are not optional) and partly process the spec
does not fund (tasks 0, 6, and 8). Raise the number at the checkpoint.

**The plan itself is not prose-graded and carries no receipt.**

## What this pass found before it was written

Four corrections, each load-bearing for a task below. The first three survived review; the
fourth replaces a false claim revision 2 built two tasks on.

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
and `scripts/check.sh` does not run it today.** Task 1a wires it in.

**Both `CLAUDE.md` files are at or over the budget hook's ceiling already.**
`claude-context-budget` sets `CLAUDE_MD_BUDGET=6000` approximate tokens, measured as bytes
divided by four. `~/.dotfiles/claude/.claude/CLAUDE.md` is 23,995 bytes, about 5,998 tokens,
one line under. `~/Projects/cairn-cms/CLAUDE.md` is 24,136 bytes, about 6,034 tokens, which
is already over. So the spec's "four lines replace four others" understates the cairn file:
it must shed the four new lines' cost plus about 136 bytes of existing overage. Task 6
measures this and hands it to the owner sitting.

**The `.claude` tree is a stow package whose directories are already live.** `CLAUDE.md`,
`agents/`, `docs/`, `instructions/`, `output-styles/`, `settings.json`, `skills/`, and
`workflows/` under `~/.claude` are symlinks into `~/.dotfiles/claude/.claude/`. `agents/`,
`docs/`, and `skills/` are whole-**directory** symlinks (stow tree folding), so a new file
inside them, `agents/figure-verifier.md` or `skills/cairn-figure/SKILL.md`, is live the
instant it is written. **No `stow -R claude` is needed for a new file under an existing
folded directory, and revision 2's claim that one was is false.** Every task still edits the
stow source, never the `~/.claude/` path.

**Every write under `claude/.claude/` changes every session on this machine immediately.**
That follows from the previous finding and is the pass's largest operational risk. It is
stated as a global constraint and again in Risks.

## Global constraints (every task)

- Edit stow sources under `~/.dotfiles/claude/.claude/`, never the `~/.claude/` symlinks.
- **Live-surface rule.** A write under `claude/.claude/` takes effect in every project's
  sessions at the moment of the write, with no restow, no flag, and no staging. Every task
  touching that tree names in its report what a session in another repo sees differently and
  states the one-line revert. Behavior changes there are additive and degrade to today's
  behavior when their new input is absent; no task ships a rule that fails a dispatch which
  works today.
- The dotfiles working tree was clean at plan authoring. A task starts only when none of its
  own **Files** appears in `git -C ~/.dotfiles status --short`. Never `git add` a path
  outside the task's own list.
- Prose register: `CLAUDE.md`, skills, and agent definitions follow
  `~/.claude/docs/voice/agent-facing.md`; the repo docs follow the Google developer-doc
  register. No em dashes in anything this pass writes.
- Go written this pass invokes the `go-conventions` skill first, as the workstation rule
  requires. Comments follow Go Doc Comments; no em dashes. The module adds no new dependency.
- Every task ends with `bash ~/.dotfiles/scripts/check.sh` green, then stages exactly its own
  paths with `git add` and does not commit. The conductor commits each accepted task by path.
- Every commit message ends with:

  ```
  Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>
  Claude-Session: https://claude.ai/code/session_01EVUo5W1SXuvMxsqDx8xdtH
  ```

**Execution mode:** main-loop dispatch per task with the Agent tool, one
implementer-review-gate chain per dispatched task. The dotfiles repo has no repo-specific
implementer agent, so the implementer is `general-purpose` at `model: sonnet`, and the
reviewer is `diff-reviewer` (pinned `claude-opus-5` in its frontmatter). The gate is
`bash ~/.dotfiles/scripts/check.sh`. Task 1a additionally runs the tellgrader module's own
`make check`, and wires that command into `check.sh` so every later task's gate covers it.
With seven dispatched tasks and real file contention on `scripts/check.sh` and the tellgrader
package, this pass runs sequentially in the main loop rather than through `pass-execute.js`.

---

### Task 0: Coordination check (conductor, no dispatch) [DONE at `6fbc776`]

**Dependencies:** none. **Deliverables:** 1.

The plan file is already committed at `6fbc776`, whose `--name-only` names that file alone,
so the second deliverable of revision 2 is spent. What remains is the coordination check.

- Confirm `git -C ~/.dotfiles status --short` is empty, or that no listed path appears in any
  task's **Files**.
- Confirm no other executor holds the dotfiles repo. `pgrep -f <path>` matches the checking
  shell itself, so exclude it:

  ```sh
  pgrep -f /var/home/glw907/.dotfiles | grep -v "^$$\$"
  ```

  or list the cwd of every candidate and keep only those under the repo:

  ```sh
  for p in $(pgrep -f dotfiles); do readlink /proc/$p/cwd; done | sort -u
  ```

  **Expected result today: no live executor in `~/.dotfiles`.** The same check run against
  `~/Projects/cairn-cms` **does** return live executors (verified 2026-09-08: gate runs with
  cwds under `.claude/worktrees/chassis-a` and `chassis-b`). That is not a blocker for this
  pass, because revision 3 performs no write in cairn-cms at all.

**Acceptance criteria:** the dotfiles tree is clean and the process check returns nothing
under `~/.dotfiles` after the checking shell is excluded.

---

### Task 1a: The docs-register profile, opt-in discovery, the fixtures, and the gate wiring

**Dependencies:** task 0. **Deliverables:** 4 (the `--profile` flag; `.tellgrader.json`
discovery; the four fixtures; the `check.sh` wiring).

Give the scanner a named profile that is off unless the repo the scanned file lives in opts
in and the file matches that repo's declared globs. This task ships the switch and its
proof. Task 1b ships what the switch turns on. Nothing in either task ever produces a
finding, changes an exit code, or blocks a hook.

**Files:**

- Modify: `claude/.claude/skills/writing-voice/evals/tellgrader/cmd/tellgrader/root.go`
  (the `--profile` flag, threaded into `tellscan.Options`)
- Create: `claude/.claude/skills/writing-voice/evals/tellgrader/internal/tellscan/profile.go`
  (profile resolution and `.tellgrader.json` discovery)
- Modify: `claude/.claude/skills/writing-voice/evals/tellgrader/internal/tellscan/scan.go`
  (the new `Report` fields)
- Create: `claude/.claude/skills/writing-voice/evals/tellgrader/internal/tellscan/profile_test.go`
- Create: `claude/.claude/skills/writing-voice/evals/tellgrader/internal/tellscan/testdata/`
  (the fixture trees below, plus `testdata/golden/pre-profile.json`)
- Modify: `scripts/check.sh` (a `run` line for the tellgrader module's `make check`)

**Interfaces produced.** Plan two and plan three consume these names, so they are fixed here.

- Profile name: `docs-register`. There is no `--bands-dir` flag and no band directory; see
  Risks and the ruling recorded there.
- CLI: `tellgrader --profile docs-register <file>` forces the profile on for any path;
  `--profile none` forces it off; omitting the flag resolves it from the repo opt-in. The
  flag is a reviewer's explicit per-invocation act. **No agent definition carries it** (task
  4).
- Repo opt-in: a repo declares the profile by committing `.tellgrader.json` at its root. The
  schema, fixed here and handed to plan two:

  ```json
  {
    "profile": "docs-register",
    "include": ["docs/**"],
    "exclude": ["docs/internal/**", "docs/superpowers/**"]
  }
  ```

  `include` and `exclude` are glob lists, not path prefixes, so a repo can say "docs but not
  `docs/internal`", which cairn's own `.vale.ini` already needs and expresses as override
  sections. Resolution walks up from the scanned file's directory to the **nearest**
  `.tellgrader.json`, stopping at `$HOME` or `/`, the convention EditorConfig, markdownlint,
  and Vale all use and the one this repo's own `vale-hook` implements in `config_root()`.
  The nearest file wins outright; higher files are not merged. The profile is on when the
  file's path relative to that root matches an `include` glob and no `exclude` glob. A repo
  with no such file never gets the profile, whatever its directory names.
- New `Report` fields: `profile` (string) and `measures` (a nested object, described in task
  1b). Both are absent outside the profile, so a report outside the profile stays
  byte-identical to today's. The nested object is present or absent as a unit, which is what
  keeps a legitimate zero from being swallowed.

**Acceptance criteria** (each testable from a command's output):

1. **The baseline is captured first.** Before any code change, run the current binary over
   `internal/tellscan/testdata` and commit the output as `testdata/golden/pre-profile.json`,
   including a hook-mode (`--hook`) capture. Every "same as before" claim below compares
   against that file.
2. `make -C ~/.dotfiles/claude/.claude/skills/writing-voice/evals/tellgrader check` exits 0,
   covering `go vet`, `golangci-lint`, and `go test ./...`.
3. Fixture A, the off-on-site-content proof (unit 3c criterion 2). A testdata repo declaring
   the schema above, with a site-content file at `src/content/posts/spring.md`. Scanning that
   file with no `--profile` flag produces a report carrying neither `profile` nor `measures`.
4. Fixture B, the on-by-default proof and the exclude proof. The same testdata repo, files at
   `docs/extend/seam.md` and `docs/internal/note.md`. With no flag, the first carries
   `"profile": "docs-register"` and a `measures` object; the second carries neither.
5. Fixture C, the opt-in-is-required proof, hermetic. A tree built under `t.TempDir()` with
   `HOME` set to that temp root, containing **no** `.tellgrader.json` at any level including
   every ancestor up to the temp `HOME`, and a file at `docs/extend/seam.md`. The report
   carries neither field. The test must not depend on the developer's real home, and the
   resolver must accept a stop root the test can set.
6. Fixture D, the force-on escape. Fixture A's site-content file scanned with
   `--profile docs-register` carries both fields, proving a reviewer can grade an arbitrary
   file on demand without the repo opting in.
7. **No regression.** The `findings` array and the exit code for every case in
   `testdata/golden/pre-profile.json` are byte-identical after the change, `TellsPer1000Words`
   is unchanged, no new check is registered in `checks`, and the existing `scan_test.go` cases
   pass unmodified.
8. **The hook is untouched.** `tellgrader --hook` output is byte-identical to the captured
   hook-mode golden, including over a fixture inside an opted-in tree. A test asserts it.
9. `bash ~/.dotfiles/scripts/check.sh` runs the tellgrader `make check` as a named step and
   the whole gate exits 0. The new `run` line names the step "tellgrader go check".

**Gate:** the tellgrader module's `make check`, then `bash ~/.dotfiles/scripts/check.sh`.

**Pre-extractions for the dispatch** (a cold implementer needs each of these, and starts with
zero context):

1. `Options` is `{Register Register; Path string}` today; `Report` has nine fields in a fixed
   order, and new fields are appended, never interleaved, for criterion 7.
2. `splitSentences` and `blankFencedCode` are unexported package-locals in `cadence.go`.
   `Scan` calls `blankFencedCode` **after** comment extraction, so anything new consumes
   `prose`, not `input`.
3. `.golangci.yml` enables `modernize`, `unparam`, `misspell`, and `errcheck` with
   `check-type-assertions`. `unparam` flags a helper whose parameter is always the same value.
4. `make check` takes about 16 s and passes today, so a red result is the implementer's own
   change.
5. `scripts/check.sh` `cd`s to the repo root first, so the make path is repo-relative or
   absolute; the helper signature is `run "<name>" <cmd> <args...>`.
6. Go tooling ignores `testdata`, so a `.tellgrader.json` there is inert and safe.
7. `run` already loops over several files, so the profile resolves **per file**, not once per
   invocation.
8. `~/.claude/...` is a symlink path, so an upward walk from a file opened through it
   terminates at `$HOME` without entering `~/.dotfiles`. A `.tellgrader.json` committed in the
   dotfiles repo does not apply to a file edited through `~/.claude`. Say so in the doc
   comment.
9. Invoke `go-conventions` first.

**Notes.** Do not touch `posthook.go`'s register routing; the profile is orthogonal to the
register and the hook keeps grading `.md` as `docs` or `agent` exactly as today. The
`check.sh` wiring invokes `make check` directly and lets a missing `golangci-lint` fail the
gate loudly rather than pass silently; `go1.27.1` and `golangci-lint 2.13.2` are both on PATH
via Homebrew today, and that dependency is recorded in Risks.

---

### Task 1b: The two measures and their written definition

**Dependencies:** task 1a. **Deliverables:** 3 (the two measures; `MEASURES.md`; the rebuild,
install, and README manifest record).

**Files:**

- Create: `claude/.claude/skills/writing-voice/evals/tellgrader/internal/tellscan/measures.go`
- Create: `claude/.claude/skills/writing-voice/evals/tellgrader/internal/tellscan/measures_test.go`
- Create: `claude/.claude/skills/writing-voice/evals/tellgrader/MEASURES.md`
- Modify: `README.md` (the "Intentionally untracked local tools" section)

**The instrument ruling this task implements.** The tell scanner is the canonical measurement
instrument for the workstation. Its definitions of a sentence split, a hinged pair, the
short-sentence share, and the prose-only selector are the reference, and
`~/Projects/cairn-cms/scripts/checks/measure-prose.mjs` is a consumer that plan two conforms
to this definition or retires against it. Revision 2 had the citation pointing the other way,
which put the canonical definition inside the one repo the spec says must not own it.

**`MEASURES.md` content.** A workstation document beside the scanner, written for a reader
implementing or checking a second implementation. It states:

- The sentence splitter, exactly: the regex, whether short sentences are dropped (tellgrader
  drops none), and that the denominator is the prose-only sentence count.
- The selector: headings excluded, list items excluded together with their wrapped
  continuation lines, and how each is recognized.
- The hinged-pair rule: two clauses joined by a comma plus a coordinator, a colon, a
  semicolon, a spaced dash, or a chain of relative clauses, **including the serial-list
  exclusion** (a `, and` preceded by another comma in the same sentence is a list item, not a
  hinge).
- The short-sentence rule: under eight words.
- The unit: **fractions in `[0,1]`**, stated as an explicit `unit` field in the JSON, never
  integer percentages. `measure-prose.mjs` emits integer percentages today; that divergence
  is named in this document as the thing plan two closes.
- That the hinged-pair definition is unsettled, that it moved twice during the proposal, that
  no number built on it gates anything, and that it carries no band.

**The report shape** (fixed here, consumed by plan two and plan three):

```json
"profile": "docs-register",
"measures": {
  "unit": "fraction",
  "selector": "prose",
  "sentences": 148,
  "hinged_pair_share": 0.31,
  "short_sentence_share": 0.12
}
```

The object is present or absent as a unit (a pointer field or an equivalent), so
`hinged_pair_share: 0.0` on a docs file with no hinged pairs is reported, not omitted.

**Acceptance criteria:**

1. `make -C ...tellgrader check` exits 0.
2. Fixture B from task 1a now carries a `measures` object whose `unit` is `"fraction"`,
   whose `selector` is `"prose"`, and whose two shares are in `[0,1]`.
3. A fixture whose docs file contains no hinged pair reports `"hinged_pair_share": 0.0`
   present in the JSON, not omitted. This is the regression the nested object exists to
   prevent.
4. A fixture exercising the serial-list exclusion: a sentence of the shape
   "a, b, and c" contributes no hinge, while "it ran, and the gate passed" contributes one.
   Both assertions are in `measures_test.go`.
5. `MEASURES.md` exists beside the scanner and states every item in the list above. A grep
   for "serial", "fraction", "prose", and "unsettled" each returns a line.
6. Task 1a's criteria 7 and 8 still hold: `findings`, exit codes, and `--hook` output remain
   byte-identical to the golden.
7. `make -C ...tellgrader install` succeeds and `tellgrader --help` lists `--profile`.
   `README.md`'s "Intentionally untracked local tools" section records that tellgrader's
   source is tracked in this repo under the `claude` package while its binary is installed to
   `~/.local/bin` by the module's own `make install`, alongside poplar's entry.
8. `bash ~/.dotfiles/scripts/check.sh` exits 0.

**Notes.** Reuse `splitSentences` and the code blanking in `cadence.go` so the denominator
matches the cadence CV, and record in `MEASURES.md` that this choice is what makes the
tellgrader number differ from any implementation using a different splitter. Invoke
`go-conventions` first.

---

### Task 2: The voice layer

**Dependencies:** task 1b (`MEASURES.md`, which the voice files point at). **Deliverables:** 2.

**Files:**

- Modify: `claude/.claude/output-styles/writing-voice.md` (three tells added, nothing else)
- Modify: all five files under `claude/.claude/docs/voice/`: `technical-doc-web.md`,
  `technical-doc-go.md`, `editor.md`, `agent-facing.md`, and `commit-and-pr.md`

**Blast radius, disclosed.** The output style loads into every session in every repo, so the
three tells govern drafting in poplar, dubplate, and all four sites from the moment the file
is written. The voice files are read by the `writing-voice` skill for every repo. Both are
low-harm and spec-funded; the disclosure is the point.

**The three tells**, added to the output style's "Avoid these structural habits" list and
nowhere else, in the list's existing voice. Each carries its provenance, because the charter's
principle is that the workstation keeps no house voice of its own:

- The two-headed heading: a heading that names two things joined by "and" or a colon, so the
  section beneath it covers two ideas. Cite the Google developer documentation style guide's
  headings guidance by name and URL (https://developers.google.com/style/headings), and
  verify the URL resolves before writing it.
- The abstract noun standing in for the concrete thing ("the solution", "the approach", "the
  mechanism") where the concrete name was available.
- The page describing itself ("this guide explains", "this section covers") instead of doing
  the thing it describes.

For the second and third, either cite a published standard by name and URL, verified to
exist and to say what is claimed, or mark the tell literally **reported-only** with its
source given as the 2026-09 benchmark observation. A tell with no external standard behind it
must not read as a cited rule.

Nothing else is added to the output style. The spec is explicit that a longer prohibition
list narrows what a model avoids without changing what it produces.

**The voice files.** Each of the five gains a section at the stable heading
`## The docs-register measures`, which plan three's drafters open. The section states:

- That `tellgrader` reports `hinged_pair_share` and `short_sentence_share` for a file in a
  repo that has opted in, and that the definitions live in the scanner's `MEASURES.md`, named
  by absolute path.
- That the measures are **report-only, carry no band, and gate nothing**, and that the
  hinged-pair definition is unsettled. No number in these files is a threshold.
- That the corpus for this audience is held by the consuming repo and reaches a review through
  the dispatching brief. **No file names a cairn corpus entry id**, which keeps shared
  workstation infrastructure from pointing into one repo's internal directory.
- For `commit-and-pr.md`, that the profile never resolves for a commit message, so the section
  records the measures' existence and its own exemption rather than a practice.

**Acceptance criteria:**

1. `grep -c "two-headed heading" claude/.claude/output-styles/writing-voice.md` is 1, and the
   same for the other two tells; the file's diff adds three bullets and changes no other line.
2. Each of the three tells carries either a named standard with a URL that resolves, or the
   literal string `reported-only`. Print the three bullets to prove it.
3. Each of the five voice files carries `## The docs-register measures`, names `MEASURES.md`
   by absolute path, and states the report-only and no-band rules.
4. `grep -rn "corpus/" claude/.claude/docs/voice/` returns nothing, and no voice file names a
   corpus entry id.
5. `bash ~/.dotfiles/scripts/check.sh` exits 0.

**Interfaces produced:** the stable heading `## The docs-register measures` in all five voice
files.

**Spec note.** Claude setup 3 asks that the voice files "name their corpus entries and bands".
Revision 3 delivers the section and defers the entry ids and any band to plan two, because no
corpus exists yet and the banked benchmark's finding 6 advises against recording an unsound
number in a committed file. Record this deferral at the checkpoint.

---

### Task 3: The Vale hook grades a draft by its path

**Dependencies:** task 0. **Deliverables:** 3.

**Files:**

- Modify: `bin/.local/bin/vale-hook`
- Modify: `tests/test_vale_hook.py`

The spec's line is "The Vale hook grades a draft by its path, which step 2 of the review chain
makes sufficient." The hook already lints from the nearest `.vale.ini` by the file's relative
path, so Vale's own section globs do the grading. This task keeps the smallest true change:
the grading becomes visible and tested, and the two substring skips become segment tests.

**The one behavior change, disclosed.** Anchoring the `/superpowers/` skip to a path segment
**changes hook behavior in every repo on this machine**, not only in cairn. A repository whose
own directory name contains `superpowers` stops being exempted. Revision 2 said the task
"changes nothing else" while carrying this; the change is small, correct, and now stated.

**Acceptance criteria:**

1. A baseline is captured first: run the current hook over the existing seven pytest cases and
   save its stdout, stderr, and exit codes. Every "unchanged" claim below compares against
   that capture, not against memory.
2. The `/superpowers/` skip is a path-segment test, and the `.md` test uses
   `os.path.splitext` on the basename (an extension is not a path segment; revision 2's
   wording invited an invented mechanism). Pytest cases prove a file at
   `/x/mysuperpowers/docs/a.md` is linted and one at `/x/docs/superpowers/a.md` is skipped.
3. On a findings path, the advisory and error messages name the config root the hook resolved
   and the path it linted relative to that root. A pytest case asserts both strings. The hook
   prints nothing when there are no findings, so this criterion is asserted only where
   findings exist.
4. **The path-grading cases assert on the hook's own output, not on Vale's section
   resolution.** Three pytest cases against a temporary repo carrying a two-section
   `.vale.ini`, built with the `StylesPath` pattern already in `tests/vale/run-fixtures.sh`
   (styles live at `~/.config/vale/styles`, populated by `vale sync`, and are not in this
   repo). Each case feeds prose that trips a style-specific rule and asserts the hook reports
   the resolved root and relative path it selected: `docs/admin/` under the Microsoft section,
   `docs/extend/` under the Google section, and `src/content/` under neither. The third case
   needs a positive control, because `run_vale` ignores Vale's exit code and returns `None` on
   any failure, so "no findings" is indistinguishable from fail-open without one.
5. The hook still fails open in every existing case: no Vale on PATH, no `.vale.ini` up the
   tree, unreadable file, malformed stdin. The seven existing pytest cases pass unchanged
   against the criterion 1 capture, and the exit codes are unchanged, including the 2 the
   PostToolUse contract depends on for an error-tier finding.
6. `uv run --with pytest --no-project python -m pytest tests/ -q` exits 0, and
   `bash ~/.dotfiles/scripts/check.sh` exits 0.

**Interfaces produced:** none plan two consumes beyond the hook's own behavior. The contract
with the review chain is that a page drafted at its published path is graded by that path's
styles from the first save, which criterion 4 proves.

**Notes.** The hook is a single-file Python script with a `_load()`-by-SourceFileLoader test
harness. The em dash is banned in this repo's Python comments, and
`scripts/check-py-comments.sh` (ruff docstring rules) runs in the gate over the same file. The
reading taken here, that the spec's line asks for visible and tested path grading rather than
new grading behavior, is recorded so a later reader does not go looking for a larger change;
raise it at the checkpoint if the owner meant something else.

---

### Task 4: The review agents

**Dependencies:** task 1a (the profile the agents describe but do not force).
**Deliverables:** 4.

**Files:**

- Modify: `claude/.claude/agents/prose-voice-reviewer.md`
- Modify: `claude/.claude/agents/cairn-register-editor.md`
- Modify: `claude/.claude/agents/diff-reviewer.md`
- Create: `claude/.claude/agents/figure-verifier.md`

**Containment, the ruling this task implements.** These are live agents. `diff-reviewer` is
the per-task reviewer in every repo's chain, `cairn-register-editor` is dispatched by the
`register-check` skill, and `prose-voice-reviewer` by the `writing-voice` skill. cairn-cms has
live gate runs in two worktrees right now. Two rules follow, and both are hard:

- **No agent definition carries `--profile`.** The flag is the force-on escape that bypasses a
  repo's opt-in for any path, and these agents are dispatched on site content in ecxc-ski and
  907-life, which decision 7 exists to keep cairn's measures away from. Each agent invokes
  `tellgrader --register <r> <file>` with no profile flag and lets repo resolution decide.
  Forcing the profile stays a reviewer's explicit, per-invocation act.
- **No agent refuses to grade for lack of a corpus entry.** The rule is conditional: when a
  corpus manifest exists in the repo being graded, use it and cite the entry; when none
  exists, grade as today and note the absence. The unconditional refusal, if it is wanted at
  all, is plan two's chain C's to add in the same task that lands the approved manifest.
  Revision 2's unconditional rule would have turned every existing dispatch into a failure the
  moment it was written, and `cairn-register-editor`'s current line 29 already cites a
  `~/.claude/docs/register-exemplars/cairn/` directory that does not exist on this machine, so
  "corpus entry" has no resolvable referent today.

**What changes, per the spec's Claude setup list:**

- `prose-voice-reviewer` and `cairn-register-editor` gain the measurement table (sentences,
  average length, longest sentence, hinged-pair share, short-sentence share, paragraphs,
  paragraphs outside the bounds) and the conditional corpus rule above. Where a brief names
  two entries, the page is compared against the closer of the two and the report names both.
  Each runs `tellgrader --register <r> <file>` as its deterministic floor, and degrades to
  today's behavior when `tellgrader` is absent or the profile does not resolve.
- `diff-reviewer` runs the scanner in report mode when the task's diff touches `docs/**/*.md`,
  and includes its numbers in the verdict. It must not return `fix` on a non-gating
  measurement alone; that is the spec's gameability risk stated as a rule. It degrades to
  today's behavior when the scanner is absent or reports no measures, and never errors on
  either.
- `figure-verifier` is new: read-only, `tools: Read, Grep, Glob, Bash`, `model:
  claude-opus-5`, `effort: high`. It grades every figure on a page by the two figure tests
  (remove the figure and see whether the prose still makes the point; read each paragraph and
  ask whether it is the text alternative of a diagram nobody drew), plus the register's
  2026-08-15 visual-layer rulings, the mermaid-default and SVG-exception routing, the
  committed-source-and-script requirement, and the alt-attribute rule. Its verdict per figure
  is one of `earns its place`, `decoration`, `should be a table`, `should be a numbered
  list`, or `missing figure`, each with a `file:line`.

**Acceptance criteria.** These are behavioral, not file-shape checks: the agents' directory is
a folded symlink, so each file is live the instant it is written and can be exercised.

1. Each of the four files has valid YAML frontmatter with `name`, `description`, `tools`, and
   `model`, `name` matches the filename stem, and each file resolves through `~/.claude/agents/`
   with no restow. Prove the last part with `readlink -f ~/.claude/agents/figure-verifier.md`.
2. **A dispatch carrying no corpus entry still returns a report.** Dispatch
   `cairn-register-editor` on a short fixture page in a repo with no corpus manifest and show
   the returned report: it grades, notes the missing corpus, and does not refuse. This is the
   criterion that proves the live surface was not broken.
3. **The agents do not force the profile.** `grep -n -- "--profile" claude/.claude/agents/`
   returns nothing. A dispatch of `prose-voice-reviewer` on a site-content fixture returns a
   report whose scanner block carries no `measures` object.
4. A dispatch of `prose-voice-reviewer` on a fixture inside an opted-in tree returns a report
   whose measurement table carries the two shares, sourced from the scanner rather than
   restated by the model.
5. `diff-reviewer.md` states the rule that a non-gating measurement alone never supports a
   `fix` verdict, and states the degrade-to-today rule.
6. `figure-verifier.md` names all five verdict values and both figure tests, and a dispatch on
   a two-figure fixture page returns one verdict per figure with a `file:line`.
7. `bash ~/.dotfiles/scripts/check.sh` exits 0.

**Interfaces produced:** the agent name `figure-verifier`, which plan three's per-page chains
dispatch and which plan two must add to its chain D (see task 8). The measurement-table shape,
which plan three's receipts quote.

**Notes.** Keep every existing instruction that is not being replaced; this is an addition to
three agents' dispatch shape, not a rewrite. Report what a session in another repo sees
differently, per the live-surface rule, and state the one-line revert (`git -C ~/.dotfiles
checkout -- claude/.claude/agents/<file>`).

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
rule for authored docs diagrams, and the gates that will check each part, with the
`figure-verifier` agent as the judgment layer. Its description triggers on figure, diagram,
screenshot, and illustration work in a cairn repo.

**The gates do not exist yet.** `check:figures` at seven assertions and the `check:visuals`
hole are unit 3b, which is plan two. The skill describes them as the standard they will
enforce and says plainly that they are not runnable today, so a reader does not try.

**The writing-voice skill's section replaces, not duplicates.** The skill already carries
`## The brief is a contract` at line 60. The author-facing prose work belongs in that section,
which is extended and renamed to `## Author-facing prose`, carrying its existing
brief-is-a-contract content plus the brief-first protocol (the brief file exists before the
outline, the outline is reviewed before any sentence), the one-section-per-read rule, and the
standing rule that a page for an outside reader is never drafted end to end in an autonomous
run. Revision 2 added a parallel section and then forbade reconciling the two.

**Acceptance criteria:**

1. `claude/.claude/skills/cairn-figure/SKILL.md` has frontmatter whose `name` is
   `cairn-figure` and whose `description` states when to use it, in the shape the other skills
   in that directory use. The skill resolves through `~/.claude/skills/cairn-figure/SKILL.md`
   with no restow; prove it with `readlink -f`, and load the skill to show it is discoverable.
2. The skill names both figure tests, the mermaid-default and SVG-exception rule, the
   commit-the-source rule, and the `figure-verifier` agent, and states that `check:figures`
   and `check:visuals` are plan two's work and are not runnable today.
3. `grep -n "^## Author-facing prose" claude/.claude/skills/writing-voice/SKILL.md` returns a
   line, `grep -c "^## The brief is a contract"` returns 0, and the renamed section carries the
   old section's brief-is-a-contract paragraph verbatim plus the brief-first and
   one-section-per-read rules.
4. `git diff --stat` shows exactly two files, and the writing-voice diff changes only that one
   section's heading and body.
5. `bash ~/.dotfiles/scripts/check.sh` exits 0.

**Interfaces produced:** the skill name `cairn-figure`, which plan two and plan three invoke;
the stable heading `## Author-facing prose`, which plan three's drafting dispatches cite.

**Notes.** Skill prose follows `~/.claude/docs/voice/agent-facing.md`. Both writes are live
immediately in every repo, per the live-surface rule.

---

### Task 6: The CLAUDE.md displacement candidates (document only)

**Dependencies:** tasks 1a through 5, since the four lines describe what they built.
**Deliverables:** 1.

**This task writes one document in `~/.dotfiles` and edits no `CLAUDE.md` in any repo.** The
displacement pick is a taste call and an owner action, taken at the same sitting that approves
the corpus (decision 7). Revision 2 carried a blocked half that reached into cairn-cms;
revision 3 removes it, so this pass has no cross-repo write and no stand-down guard to
satisfy. **This task is the pass's split point**: if the ceiling runs short, cut it whole.

**Files:**

- Create: `docs/superpowers/plans/2026-09-08-claude-md-displacement-candidates.md`

**The budget arithmetic the document must state.** `claude-context-budget` allows 6,000
approximate tokens, computed as bytes divided by four, so 24,000 bytes.
`claude/.claude/CLAUDE.md` is 23,995 bytes, five bytes of headroom.
`~/Projects/cairn-cms/CLAUDE.md` is 24,136 bytes, **already 136 bytes over**, so it must shed
the new lines' cost plus that overage before the hook stops firing.

**The four lines, drafted here for the owner to approve.** Each file gains four lines, no
more, naming: the standard's existence and where it lives; the brief-first and
one-section-per-read protocol for any page an outside reader will read; the rule that a claim
about the owner or about cairn's stance resolves to a line in an owner brief; and the
docs-register profile with the fact that no measure it reports gates.

**Acceptance criteria:**

1. The document exists and, for each of the two files, lists **four** ranked candidate lines
   or paragraphs to displace, ranked by cost-to-value, each with its exact byte cost
   (measured with `wc -c` on the extracted text, not estimated), its heading, and one sentence
   on what is lost and where that content still lives if it leaves. Four per file is what an
   owner reads to pick four; revision 2's eight-plus per file was accretion.
2. The document states the arithmetic above, including the 136-byte cairn overage, and gives
   per file the byte total that must leave for the file to sit under budget with the four
   lines added.
3. The document carries the four drafted lines verbatim, per file, in each file's own voice,
   with each line's byte cost.
4. **No `CLAUDE.md` is modified anywhere.** `git -C ~/.dotfiles status --short
   claude/.claude/CLAUDE.md` is empty, and the task performs no write in
   `~/Projects/cairn-cms` at all.
5. `bash ~/.dotfiles/scripts/check.sh` exits 0.

**Notes.** Reading cairn's `CLAUDE.md` is safe with live executors in that repo; writing is
what revision 3 removed. The edits themselves are owed by the owner sitting that approves the
corpus, and task 8 records that debt.

---

### Task 7: The dotfiles ritual (conductor, no dispatch)

**Dependencies:** tasks 1a through 6 accepted. **Deliverables:** 4.

**Files:**

- Modify: `docs/STATUS.md`
- Modify: `docs/HISTORY.md`
- Modify: `ROADMAP.md`

The README manifest record moved into task 1b, the task that installs the binary, so this task
carries four deliverables: the three ledger files and the drift verification.

**What each gets:**

- `docs/STATUS.md`, present tense only, target under 60 lines. The gate row gains the
  tellgrader Go check. The immediate next action names the hand-off document by absolute path
  and the owner sitting that owes the `CLAUDE.md` edits. Nothing historical is added here.
- `docs/HISTORY.md`, a newest-first entry for this pass: what landed, what the gate caught,
  and what a later pass would be wrong to rediscover. That last clause carries this plan's
  four findings, above all that tellgrader lives in the claude stow package with its own `make
  check` and is not a poplar artifact, that the `.claude` subdirectories are folded symlinks
  so a new file is live without a restow, and the CLAUDE.md byte arithmetic.
- `ROADMAP.md`, an `Active` entry for the cairn documentation standard: this pass is plan one
  of three, plan two is cairn's toolset and plan three the rewrite, the spec path is the
  standing input, and the workstation's continuing obligation is that the scanner, the voice
  files, the agents, and the skills stay in step with the standard.
- **Drift verification.** No new script is added to `~/.local/bin` and no stow package is
  added, so `bluefin/stow-packages.txt` is unchanged. Run `check-drift` and confirm it reports
  no new drift beyond the rebuilt `tellgrader` binary. `stow -R claude` is unnecessary for
  this pass's new files (folded directories) but remains harmless; run it only if `check-drift`
  asks for it.

**Acceptance criteria:**

1. `wc -l docs/STATUS.md` is at most 60, and the file carries no history section.
2. `head -40 docs/HISTORY.md` shows this pass's entry newest-first, naming the tellgrader
   home-and-gate finding, the folded-symlink finding, and the CLAUDE.md budget finding.
3. `ROADMAP.md` carries the initiative under `## Active` with the spec path.
4. `readlink -f ~/.claude/skills/cairn-figure/SKILL.md` and
   `readlink -f ~/.claude/agents/figure-verifier.md` each resolve under `~/.dotfiles`.
5. `tellgrader --help` lists `--profile`.
6. `check-drift` reports no unrecorded drift.
7. `bash ~/.dotfiles/scripts/check.sh` exits 0.

**Notes.** STATUS is present tense; anything that reads as history moves to HISTORY rather
than being summarized harder. The pre-existing STATUS carry-forwards from the 2026-09-04 Fable
pass stay unless they are genuinely closed; do not silently drop another pass's items.

---

### Task 8: The hand-off to plan two (conductor, no dispatch)

**Dependencies:** task 7. **Deliverables:** 1.

**Files:**

- Create: `docs/superpowers/plans/2026-09-08-docs-standard-claude-infra-handoff.md`

The document names the artifacts plan two's preflight verifies and the obligations plan two
must add. It does **not** re-run acceptance criteria already proved per task; revision 2's
nine items bought the same verification twice. Plan two's P1 opens this document at
`~/.dotfiles/docs/superpowers/plans/2026-09-08-docs-standard-claude-infra-handoff.md`, and
`docs/STATUS.md` carries that absolute path so P1 can find it without rediscovery.

**The artifacts plan two's preflight verifies, by path and name, six items:**

1. **The profile flag.** `tellgrader --profile docs-register <file>` carries `profile` and a
   `measures` object; `tellgrader --profile none <file>` carries neither. Binary at
   `~/.local/bin/tellgrader`.
2. **The discovery schema.** `.tellgrader.json`, the three keys `profile`, `include`, and
   `exclude`, glob-valued, resolved by walking up from the scanned file to the nearest such
   file and stopping at `$HOME` or `/`, nearest wins, no merging. The document carries the
   exact JSON plan two will commit at `~/Projects/cairn-cms/.tellgrader.json`.
3. **The measure definition.**
   `~/.claude/skills/writing-voice/evals/tellgrader/MEASURES.md`, the canonical definition of
   the sentence split, the hinged pair with its serial-list exclusion, the short-sentence
   share, the `prose` selector, and the fraction unit.
4. **The Vale hook change.** `~/.local/bin/vale-hook` names the resolved config root and the
   relative path it linted on any findings path, and its pytest suite covers the four
   path-grading cases.
5. **The two skills.** `~/.claude/skills/cairn-figure/SKILL.md` loads, and
   `~/.claude/skills/writing-voice/SKILL.md` carries `## Author-facing prose`.
6. **The figure-verifier agent.** `~/.claude/agents/figure-verifier.md` exists and returns one
   verdict per figure with a `file:line`.

**The two obligations plan two must add to itself:**

1. **Create `~/Projects/cairn-cms/.tellgrader.json`** with the schema in item 2. No task in
   plan one or plan two creates it today, and it is the sole mechanism by which the profile
   ever fires without an explicit flag, so without it the docs-register profile is dead on
   arrival in the repo it was built for.
2. **Add `figure-verifier` to plan two's chain D.** Plan two mentions the agent nowhere today,
   and its figure work is the first consumer.

**What is still owed, carried, not verified:** the four lines in each `CLAUDE.md`, pending the
owner's pick from task 6's candidate document, batched with the corpus approval sitting
(decision 7). Unit 3c closes at that sitting.

**Acceptance criteria:**

1. The document carries the six artifacts, each with one command and its real pasted output,
   and the two obligations, each with the exact content or name plan two needs.
2. The document re-proves nothing already proved by a task's own acceptance criteria.
3. `docs/STATUS.md`'s immediate next action names this document's absolute path.
4. `bash ~/.dotfiles/scripts/check.sh` exits 0.

**Notes.** A failing item is a blocker for plan two, not a warning.

---

## Task ledger

| # | Title | Dispatched | Depends on | Deliverables | Blocked |
|---|---|---|---|---|---|
| 0 | Coordination check [DONE at `6fbc776`] | no, conductor | none | 1 | no |
| 1a | Profile, discovery, fixtures, gate wiring | yes | 0 | 4 | no |
| 1b | The two measures and `MEASURES.md` | yes | 1a | 3 | no |
| 2 | Voice layer: output style and five voice files | yes | 1b | 2 | no |
| 3 | Vale hook grades by path | yes | 0 | 3 | no |
| 4 | Review agents | yes | 1a | 4 | no |
| 5 | The two skills | yes | 0 | 2 | no |
| 6 | CLAUDE.md displacement candidates (document only) | yes | 1a to 5 | 1 | no |
| 7 | Dotfiles ritual | no, conductor | 1a to 6 | 4 | no |
| 8 | Hand-off to plan two | no, conductor | 7 | 1 | no |

Seven dispatched tasks, ceiling 0.6M. Checkpoint after task 3: write STATUS, report spend
against the ceiling, and batch every judgment call into one combined question, including the
proportion number, the task 2 corpus-id deferral, and the task 3 spec reading.

## Spec coverage

Every item the spec assigns to the workstation, and the task that carries it.

| Spec item | Task |
|---|---|
| Claude setup 1: both `CLAUDE.md` files gain four lines, displacing four | 6 produces the measured candidates; the edits are the owner sitting's |
| Claude setup 2: the output style gains three tells | 2 |
| Claude setup 3: the voice files name their corpus entries and bands | 2, for the section and the measures; entry ids and any band deferred to plan two, disclosed in task 2 |
| Claude setup 4: the scanner gains the two shares, behind the profile | 1a for the profile and discovery, 1b for the measures; no band file, per the ruling in Risks |
| Claude setup 5: the Vale hook grades a draft by its path | 3 |
| Claude setup 6: the review agents change dispatch shape, and `figure-verifier` is new | 4 |
| Claude setup 7: `cairn-figure` is new, and writing-voice gains the author-facing section | 5 |
| Where each piece lives: the measurement instrument as a shared definition | 1b, `MEASURES.md` beside the scanner, with `measure-prose.mjs` as the consumer plan two conforms or retires |
| Where each piece lives: the review protocol | 4 for the reviewer shape, 5 for the drafting protocol |
| Unit 3c criterion 2: a fixture proves the profile does not fire on site content | 1a, fixture A |
| Unit 3c criterion 3: both `CLAUDE.md` files stay within the budget hook | not closable this pass; 6 measures it, the owner sitting closes it |
| Unit 3c criterion 4: the tellgrader change clears its gate | 1a, corrected to the module's own `make check` and wired into `scripts/check.sh` |

## Risks

- **The `~/.claude` tree is live, and this pass has no feature flag.** Tasks 2, 4, and 5 change
  what every session in every repo sees at the instant of the write, with no restow and no
  staging. The mitigations are the live-surface rule in Global constraints (name the visible
  change and the one-line revert in every report), the containment rules in task 4 (no forced
  profile, no unconditional refusal), and the degrade-to-today requirement on every new agent
  step. A half-landed pass leaves additive state, not broken state.
- **No bands ship this pass, by ruling.** The banked benchmark's finding 6 advises keeping the
  hinged-pair share in the scanner's report and out of any committed manifest, because its
  definition moved twice and each move changed the numbers by more than the width of the human
  band. Revision 2 shipped a band directory, three band JSON files, a `--bands-dir` flag, a
  loader, and a missing-file tolerance path to hold six placeholder numbers no gate reads,
  which is heavier than any comparable instrument. Revision 3 drops all of it. Bands, if any
  are ever wanted, come from plan two's measured corpus and live in the consuming repo's
  `.tellgrader.json`. The hinged-pair share stays unbanded.
- **The hinged-pair definition is unsettled.** `MEASURES.md` is the canonical statement.
  `measure-prose.mjs` already implements the serial-list exclusion for its `and`/`or`
  coordinator pair; its `but`/`so`/`yet`/subordinator pattern carries no such exclusion, which
  is itself one of the divergences. Its other divergences are the ones `MEASURES.md`'s
  "Divergences from cairn's measure-prose.mjs" section names: a different sentence splitter
  that drops sentences under three words and uses a stricter sentence-boundary test, a
  narrower coordinator set, a colon/semicolon test that requires trailing whitespace, a
  different relative-clause rule, a stricter continuation-indent test, and it emits integer
  percentages where the scanner emits fractions.
  Plan two conforms it or retires it. Nothing gates on either number, which is what keeps the
  risk cheap.
- **The gate now depends on `go` and `golangci-lint`.** Task 1a's `check.sh` line fails loudly
  when either is missing, so a machine without `golangci-lint` fails every unrelated dotfiles
  change. Both are present via Homebrew today (`go1.27.1`, `golangci-lint 2.13.2`).
- **`~/.claude` is a symlink path.** An upward `.tellgrader.json` walk from a file opened
  through `~/.claude` terminates at `$HOME` without entering `~/.dotfiles`, so a
  `.tellgrader.json` committed in the dotfiles repo does not govern files edited that way.
  Recorded in `MEASURES.md` and in the profile doc comment.
- **cairn-cms has live executors.** Verified 2026-09-08. Revision 3 performs no write in that
  repo, so the contention is not this pass's to manage; task 6 only reads `CLAUDE.md`.

## Post-mortem

**Built.** All seven dispatched tasks (1a, 1b, 2, 3, 4, 5, 6) and both conductor tasks (7, 8)
are done. Every dispatched task took exactly one fix round except 1b, which took two, closed by
conductor decision rather than a third dispatch. Commits: 1a `c523f0b`; 1b `fc143ec` then fixes
`c217769` and `064168f`; 2 `7f63c0e` then `ecf31ab` (re-sourcing the two-headed-heading tell to
the register ruling after review found Google's own headings page recommends two of the
forbidden forms); 3 `019e1e8` then `f1a3ec5` (tests re-asserted on the rendered phrase after
review proved them passing against the old hook); 4 `f32315c` then `e2d1ea7` (the register
editor lacked a Bash tool); 5 `5a2990d` then `7436dcb` (the repro fence added to the figure
skill); 6 `3d21e72` (document only, no `CLAUDE.md` touched).

**Verified.** `bash ~/.dotfiles/scripts/check.sh` exits 0, covering the new tellgrader `make
check` step alongside the existing shell, ruff-D, vale-hook pytest, vale-fixture, and gitleaks
checks. `check-drift` reports the rebuilt `tellgrader` binary as the only drift this pass
introduces; the Plexamp flatpak and GNOME sleep-setting drift it also reports predate this pass
and are unrelated to any file this plan touches. The six hand-off artifacts each carry a real
command and its pasted output in
`docs/superpowers/plans/2026-09-08-docs-standard-claude-infra-handoff.md`.

**Decisions locked.** The review agents carry no `--profile` flag and refuse nothing for lack
of a corpus entry (task 4). The tell scanner is the canonical measurement instrument, with
`MEASURES.md` beside it and `measure-prose.mjs` as the consumer plan two conforms or retires
(task 1b). No band ships this pass; the hinged-pair share stays reported-only and unbanded
(Risks). The two-headed-heading tell is sourced to the register ruling, not to Google, whose
headings guidance recommends two of the forms this workstation forbids (task 2). Unit 3c cannot
close inside this pass; both `CLAUDE.md` files still need the owner's four-line pick from the
displacement-candidates document, batched with the docs-standard corpus approval.

**Blockers.** None encountered during execution.

**Budget.** Ceiling 0.6M tokens; the pass closed under it by the per-task implementer and
reviewer reports. Zero planning misses (no ambiguity surfaced after the revision-3 plan
approval that a planning question would have caught) and zero execution sittings (no pull-in
after approval beyond the single combined question batched at the task-3 checkpoint, which the
plan's own checkpoint interval called for).
