# Migrate the workstation prose standard from prose-guard to Vale

Status: design approved 2026-06-21, pending spec review.
Owner: Geoff.
Scope: workstation-wide.

## Problem

`prose-guard`, a bespoke Python script
(`~/.dotfiles/bin/.local/bin/prose-guard`, stowed to `~/.local/bin`), enforces the writing-voice
standard. It runs as a Claude Code
PreToolUse and PostToolUse hook and as a manual sweep. It works, but it is a single-purpose tool
with no editor integration and no ecosystem. Vale is the established prose linter: syntax-aware,
widely used, with a published rule format, a package system, and an LSP for live squiggles in the
editor. The goal is to move the mechanical enforcement to Vale, gain editor-time feedback, and
retire `prose-guard`.

## What this is not

The writing-voice standard has two layers. The judgment layer lives in `~/.claude/CLAUDE.md`, the
`writing-voice` output style, `~/.claude/docs/prose-voice.md`, and the six register files under
`~/.claude/docs/voice/`. It carries the register exemplars, the personas, the dosage philosophy,
and the first-draft rule. That layer stays. This migration touches only the mechanical layer: the
lexicons and regexes that `prose-guard` checks, and the hook that runs them. The register docs keep
their prose guidance and hand their machine-checkable lists to Vale.

## Decisions already made

These are settled and are not open for re-litigation during planning:

1. **Workstation-wide.** Vale becomes the standard everywhere, not just in one repo.
2. **Style name is `Geoff`.** Vale styles are named after their owner (`Microsoft`, `Google`,
   `RedHat`). This is a one-owner house style, so it carries the owner's name. Every alert reads
   `Geoff.EmDash`, `Geoff.ContrastFrame`, and so on.
3. **The two statistical checks are dropped.** Anaphora (three or more sentences opening with the
   same word) and low burstiness (sentence-length variance) need whole-document counting that
   Vale's scope-based engine cannot express. They were advisory-only and were the source of the
   false positives seen on the cairn-cms docs. Dropping them is accepted.
4. **A Vale-backed blocking hook replaces the prose-guard hook.** Enforcement stays at write time
   for agent-authored prose, because the Vale LSP only helps a human editing in neovim. The hook
   blocks on error-severity alerts (the lexical and structural tiers) and never blocks on advisory.
5. **The cairn-cms CI gate is part of this initiative**, as its final step. It is the proof that the
   vendored-style path works end to end.

## Architecture

### Where Vale lives

A new `vale` stow package in `~/.dotfiles`, alongside `bash`, `bin`, and `claude`:

```
~/.dotfiles/vale/.config/vale/.vale.ini            -> ~/.config/vale/.vale.ini
~/.dotfiles/vale/.config/vale/styles/Geoff/*.yml   -> the ported rules
```

`.bashrc` gains `export VALE_CONFIG_PATH="$HOME/.config/vale/.vale.ini"` so any directory inherits
the standard. A repo with its own `.vale.ini` (cairn-cms) overrides the global config, because Vale
prefers a config found by walking up from the target file. The precedence of `VALE_CONFIG_PATH`
against an in-tree `.vale.ini` is verified during the first plan task before anything depends on it.

Vale itself is a pinned release binary in `~/.local/bin`, provisioned by a new
`~/.dotfiles/scripts/install-vale.sh` so a fresh machine is reproducible. The binary is not a
tracked dotfile; the install script and a pinned version are.

### The `Geoff` style: rule port

Each `prose-guard` construct maps to a Vale rule file with a severity. The tables below are the
full inventory mined from `prose-guard` and `test_prose_guard.py`. Word lists are shown in code
spans so this document does not trip the rules it describes.

**Lexical, error severity (blocking):**

| Rule file | Source list | Notes |
| --- | --- | --- |
| `Geoff/EmDash` | the em dash character | en dash for ranges is allowed |
| `Geoff/BannedPhrases` | `BANNED_PHRASES` (15) | `it's worth noting`, `delve`, `dive into`, and the rest |
| `Geoff/Openers` | `BANNED_OPENERS` (7) | scope: sentence start; `moreover`, `additionally`, `furthermore`, and the rest |
| `Geoff/Filler` | `FILLER_WORDS` (2) | `genuinely`, `honestly` |
| `Geoff/Marketing` | `MARKETING_WORDS` (9) | all tiers; `empower`, `streamline`, `supercharge`, and the rest |
| `Geoff/Slop` | `SLOP_WORDS` (4) | docs and general tiers; `tapestry`, `multifaceted`, `testament`, `seamless` |
| `Geoff/Judgment` | `JUDGMENT_WORDS` (20) | general tier only; `robust`, `leverage`, `comprehensive`, and the rest |

**Structural, error severity (blocking):** all six `STRUCTURAL` regexes port as `existence` rules
with the same patterns and scopes.

| Rule file | prose-guard kind |
| --- | --- |
| `Geoff/ContrastFrame` | negative antithesis (`it's not X, it's Y`) |
| `Geoff/NotJustBut` | the `not just X but Y` escalation |
| `Geoff/SetupColon` | the setup-colon payoff (`The point:` ...) |
| `Geoff/CopulaDodge` | `serves as a` / `stands as a` |
| `Geoff/ParticipialOpener` | participial wind-up at line start |
| `Geoff/BoldHeaderBullet` | the `**Bolded**:` fake-heading bullet |

**Advisory, suggestion or warning severity (never blocks):**

| Rule file | Source |
| --- | --- |
| `Geoff/AdvisoryOpeners` | `ADVISORY_OPENERS` (7) |
| `Geoff/AdvisoryPhrases` | `ADVISORY_PHRASES` (6) |
| `Geoff/AdvisoryWords` | `ADVISORY_WORDS` (11) |
| `Geoff/FablePhrases` | `FABLE_PHRASES` (5) |
| `Geoff/DefinitionalPivot` | `FABLE_PATTERNS` (the `the honest/real/true X is` regex) |
| `Geoff/PassiveAgent` | `PASSIVE_AGENT` (passive with a named agent) |
| `Geoff/Tricolon` | `ADJ_TRICOLON` (kept advisory; noisy, so suggestion not warning) |
| `Geoff/SpacedHyphen` | `SPACED_HYPHEN` |
| `Geoff/Emoji` | `EMOJI` |

**Dropped (no Vale equivalent):** anaphora, low burstiness. These are the only two losses.

### Register and tier scoping

`prose-guard` chooses a tier by path in `classify()`: `general` for `**/src/content/**/*.md`,
`docs` for any other `.md`, and `comments` for a code file. Vale expresses this in `.vale.ini`
sections by glob:

- `[*.md]` runs the docs severities (`Geoff/Slop` on, `Geoff/Judgment` off).
- `[{**/src/content/**,**/content/**}/*.md]` runs the general tier, which adds `Geoff/Judgment`.
- Code extensions map to formats so Vale lints comment text only, matching the `comments` tier.

Vale handles Markdown scoping natively, skipping fenced and inline code by scope rather than by the
hand-rolled stripping in `prose-guard`. Frontmatter is excluded so field
values are not scanned. Vale's comment-only linting covers the common languages; where its language
set is narrower than `prose-guard`'s `CODE_EXTS`, that gap is documented in the style README rather
than hidden.

### The Vale-backed hook

A new `vale-hook` wrapper in `~/.dotfiles/bin/.local/bin` replaces the two `prose-guard` modes. The
two lines in `~/.claude/settings.json` change from `prose-guard --hook` and `prose-guard
--post-hook` to `vale-hook --pre` and `vale-hook --post`.

- **`--pre` (PreToolUse, blocking):** read the Write or Edit tool-call JSON from stdin, resolve the
  post-write content of the target file, write it to a temp file with the target's extension, and
  run `vale --output=JSON --minAlertLevel=error`. On any error-severity alert, print the Claude
  hook deny-decision JSON with the alerts and exit 0. On clean content, exit 0 with no output. On
  any internal error, exit 0 so a hook bug never blocks real work. The temp-file step sidesteps any
  stdin-format quirk in Vale.
- **`--post` (PostToolUse, advisory):** run Vale at `--minAlertLevel=suggestion`, return the
  findings as advisory `additionalContext`, and never block.

The wrapper reuses `prose-guard`'s tool-call parsing logic for resolving the content of a Write
versus an Edit, so the two hooks behave identically on which bytes get checked.

### cairn-cms CI gate

cairn-cms gets its own `.vale.ini` scoped to the published docs (`docs/reference/`, `docs/guides/`,
`docs/explanation/`, `docs/tutorial/`, and the root `*.md`). It vendors a snapshot of the `Geoff`
style under `.vale/styles/Geoff/` so CI is self-contained, matching how this repo already pins its
toolchain with a committed lockfile. A `check:vale` npm script runs `vale --minAlertLevel=error`
over the doc set, and a CI step in `.github/workflows/test.yml` runs it on a pinned Vale install.

The published docs already pass the error tier today: the manual sweep showed only advisory hits.
The gate is confirmed green with a real Vale run before the CI step is committed. A small
`check:vale:sync` script compares the vendored style against the dotfiles canonical and reports
drift, so the snapshot does not silently diverge.

## Deprecation sequence

Order matters so there is never an enforcement gap.

1. Install Vale, build the `Geoff` style, write the global config, and get the fixtures passing.
2. Land the `vale-hook` wrapper and flip `settings.json`. Prove a dirty draft is still blocked and
   a clean one passes.
3. Repoint the docs: `CLAUDE.md`, the `writing-voice` output style, `prose-voice.md`, and the six
   register files change every `prose-guard` mechanics reference to Vale. The judgment-layer prose
   is untouched.
4. Update the affected memories (the prose-guard-tiers memory and its neighbors).
5. Wire the cairn-cms CI gate and confirm it is green.
6. Retire `prose-guard`: remove it from the `bin` stow package, run `stow -R bin`, and drop
   `test_prose_guard.py` in favor of the Vale fixtures. The script stays in git history.

## Testing

- **Rule fidelity.** A fixtures suite holds a known-bad and a known-good snippet for each ported
  rule, seeded from the trigger and non-trigger cases in `test_prose_guard.py`. A test script runs
  Vale over the fixtures and asserts the expected alerts fire on the bad snippets and stay silent on
  the good ones. This guarantees behavioral parity for every rule that survives the port.
- **The hook.** A test feeds `vale-hook --pre` a dirty tool-call JSON and a clean one and asserts
  deny versus allow, plus a malformed-input case that must fail open.
- **The gate.** `check:vale` is run locally over the cairn-cms docs and must exit 0 before the CI
  step is committed.

## Risks and open items

- **Vale config precedence.** The interaction between `VALE_CONFIG_PATH` and an in-tree `.vale.ini`
  is verified empirically in the first task. If the env var overrides a local config rather than
  yielding to it, the global config is delivered a different way (for example, a per-repo
  `.vale.ini` that sets `StylesPath` to the global styles).
- **Comment-language coverage.** Vale's comment-only linting may cover fewer languages than
  `prose-guard`'s Pygments set. The shortfall is measured and documented, not papered over.
- **Regex translation.** Vale's `existence` rules use RE2 (Go regexp), which lacks lookarounds.
  Two `prose-guard` patterns use a lookbehind for sentence splitting; they are rewritten to RE2 or
  expressed with Vale's `scope: sentence` instead.
