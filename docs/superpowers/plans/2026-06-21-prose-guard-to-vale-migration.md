# prose-guard to Vale Migration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the bespoke `prose-guard` script with Vale as the workstation-wide writing-voice linter, porting its rules into a `glw907` Vale style, keeping a write-time blocking hook, and retiring `prose-guard` once Vale is proven.

**Architecture:** A new `vale` dotfiles stow package carries a global `.vale.ini` and the `glw907` style (one universal voice style, scoped per domain). A thin `vale-hook` wrapper replaces `prose-guard`'s Claude Code hook modes. cairn-cms vendors the style and gates its docs in CI. `prose-guard` is removed last, after the Vale hook is live and proven.

**Tech Stack:** Vale (Go binary), YAML (Vale rules), Python 3 (the hook wrapper and the fixture test runner), INI (Vale config), GNU Stow, GitHub Actions.

**Source spec:** `docs/superpowers/specs/2026-06-21-prose-guard-to-vale-migration-design.md`

**The rule inventory** is mined from `~/.dotfiles/bin/.local/bin/prose-guard` and `~/.dotfiles/tests/test_prose_guard.py`. Both are the canonical reference while porting.

---

## Phase 0: Provision Vale and verify its model

### Task 1: Install a pinned Vale and confirm the rule schema and config precedence

**Files:**
- Create: `~/.dotfiles/scripts/install-vale.sh`
- Create (scratch, deleted at end of task): `/tmp/vale-probe/`

- [ ] **Step 1: Write the install script**

```bash
#!/usr/bin/env bash
# install-vale.sh: install a pinned Vale release binary into ~/.local/bin.
set -euo pipefail

VALE_VERSION="3.9.1"   # pin; bump deliberately
ARCH="$(uname -m)"
case "$ARCH" in
  x86_64) VALE_ARCH="64-bit" ;;
  aarch64|arm64) VALE_ARCH="arm64" ;;
  *) echo "unsupported arch: $ARCH" >&2; exit 1 ;;
esac

URL="https://github.com/errata-ai/vale/releases/download/v${VALE_VERSION}/vale_${VALE_VERSION}_Linux_${VALE_ARCH}.tar.gz"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "Downloading Vale ${VALE_VERSION} ..."
curl -fsSL "$URL" -o "$TMP/vale.tar.gz"
tar -xzf "$TMP/vale.tar.gz" -C "$TMP" vale
install -m 0755 "$TMP/vale" "$HOME/.local/bin/vale"
echo "Installed: $("$HOME/.local/bin/vale" --version)"
```

- [ ] **Step 2: Run the install script and confirm the binary**

Run: `bash ~/.dotfiles/scripts/install-vale.sh && vale --version`
Expected: prints `vale version 3.9.1` (or the pinned version). If the asset name differs for this release, correct `VALE_ARCH`/`URL` against the GitHub release page before continuing.

- [ ] **Step 3: Build a throwaway probe to verify the rule schema**

```bash
mkdir -p /tmp/vale-probe/styles/Probe
cat > /tmp/vale-probe/styles/Probe/EmDash.yml <<'YML'
extends: existence
message: "Em dash is a tell. End the sentence, or use a colon, comma, or parens."
level: error
nonword: true
tokens:
  - '—'
YML
cat > /tmp/vale-probe/.vale.ini <<'INI'
StylesPath = styles
MinAlertLevel = suggestion

[*.md]
BasedOnStyles = Probe
INI
printf 'A line with an em dash — like this.\n' > /tmp/vale-probe/bad.md
printf 'A clean line with no tells.\n' > /tmp/vale-probe/good.md
```

- [ ] **Step 4: Run Vale on the probe and confirm error reporting plus JSON output**

Run: `cd /tmp/vale-probe && vale --output=JSON bad.md; echo "---"; vale good.md`
Expected: the JSON for `bad.md` contains a `Probe.EmDash` alert with `"Severity":"error"`; `good.md` reports nothing. Record the exact JSON shape (the keys `Check`, `Severity`, `Line`, `Message`), because the hook in Phase 3 parses it.

- [ ] **Step 5: Verify config precedence (the spec's open risk)**

```bash
mkdir -p /tmp/vale-probe/sub
cat > /tmp/vale-probe/sub/.vale.ini <<'INI'
StylesPath = ../styles
MinAlertLevel = suggestion
[*.md]
BasedOnStyles = Probe
Probe.EmDash = NO
INI
printf 'Em dash — here.\n' > /tmp/vale-probe/sub/x.md
```

Run: `cd /tmp/vale-probe/sub && VALE_CONFIG_PATH=/tmp/vale-probe/.vale.ini vale x.md`
Expected: determine empirically whether the in-tree `sub/.vale.ini` wins (no alert, because `EmDash = NO`) or `VALE_CONFIG_PATH` wins (an alert fires). Write the result into the plan's Task 7 note so the global-config delivery matches reality. Vale's documented behavior is that a config found by directory walk takes precedence; if this probe disagrees, Phase 2 uses the per-repo `.vale.ini` + shared `StylesPath` fallback described in the spec.

- [ ] **Step 6: Clean up the probe and commit the install script**

```bash
rm -rf /tmp/vale-probe
cd ~/.dotfiles && git add scripts/install-vale.sh
git commit -m "Add a pinned Vale install script"
```

---

## Phase 1: Build the glw907 style

The style folder is built outside stow first (`~/.dotfiles/vale/.config/vale/styles/glw907/`), tested with a local `.vale.ini`, then stowed in Phase 2. Every rule gets a fixture pair (a bad sample that must alert, a good sample that must stay silent).

### Task 2: Scaffold the style directory and the fixture test runner

**Files:**
- Create: `~/.dotfiles/vale/.config/vale/styles/glw907/` (directory)
- Create: `~/.dotfiles/vale/tests/fixtures/` (directory)
- Create: `~/.dotfiles/vale/tests/run-fixtures.sh`
- Create: `~/.dotfiles/vale/tests/.vale.ini` (the test harness config)

- [ ] **Step 1: Create the test harness config**

```ini
# ~/.dotfiles/vale/tests/.vale.ini — exercises every glw907 rule at suggestion level
StylesPath = ../.config/vale/styles
MinAlertLevel = suggestion

[*.md]
BasedOnStyles = glw907

[*.go]
BasedOnStyles = glw907

[*.ts]
BasedOnStyles = glw907
```

- [ ] **Step 2: Write the fixture runner**

```bash
#!/usr/bin/env bash
# run-fixtures.sh: assert each fixture file produces (or does not produce) the
# expected glw907 alert. A *.bad.md fixture must raise its named rule; a
# *.good.md fixture must raise nothing.
set -uo pipefail
cd "$(dirname "$0")"
fail=0

for bad in fixtures/*.bad.*; do
  [ -e "$bad" ] || continue
  rule="glw907.$(basename "$bad" | cut -d. -f1)"
  if ! vale --output=JSON "$bad" | grep -q "\"$rule\""; then
    echo "FAIL: $bad did not raise $rule"; fail=1
  fi
done

for good in fixtures/*.good.*; do
  [ -e "$good" ] || continue
  out="$(vale --output=line "$good" 2>/dev/null)"
  if [ -n "$out" ]; then
    echo "FAIL: $good raised alerts but should be clean:"; echo "$out"; fail=1
  fi
done

[ "$fail" -eq 0 ] && echo "fixtures: OK" || echo "fixtures: FAILED"
exit "$fail"
```

- [ ] **Step 3: Make the runner executable and confirm it runs (with no fixtures yet)**

Run: `chmod +x ~/.dotfiles/vale/tests/run-fixtures.sh && cd ~/.dotfiles/vale/tests && ./run-fixtures.sh`
Expected: prints `fixtures: OK` (no fixtures present yet, so nothing fails).

- [ ] **Step 4: Commit the scaffold**

```bash
cd ~/.dotfiles
git add vale/tests/run-fixtures.sh vale/tests/.vale.ini
git commit -m "Scaffold the glw907 Vale style test harness"
```

### Task 3: Port the lexical error rules (one worked rule, then the full set)

**Files:**
- Create: `~/.dotfiles/vale/.config/vale/styles/glw907/EmDash.yml`
- Create: `~/.dotfiles/vale/.config/vale/styles/glw907/BannedPhrases.yml`
- Create: `~/.dotfiles/vale/.config/vale/styles/glw907/Openers.yml`
- Create: `~/.dotfiles/vale/.config/vale/styles/glw907/Filler.yml`
- Create: `~/.dotfiles/vale/.config/vale/styles/glw907/Marketing.yml`
- Create: `~/.dotfiles/vale/.config/vale/styles/glw907/Slop.yml`
- Create: `~/.dotfiles/vale/.config/vale/styles/glw907/Judgment.yml`
- Test: `~/.dotfiles/vale/tests/fixtures/*.bad.md`, `*.good.md`

- [ ] **Step 1: Write the failing fixture for EmDash**

```bash
cd ~/.dotfiles/vale/tests
printf 'A sentence with an em dash — right here.\n' > fixtures/EmDash.bad.md
printf 'A sentence with an en dash range 3–5 and no em dash.\n' > fixtures/EmDash.good.md
```

- [ ] **Step 2: Run the runner to see EmDash fail**

Run: `cd ~/.dotfiles/vale/tests && ./run-fixtures.sh`
Expected: `FAIL: fixtures/EmDash.bad.md did not raise glw907.EmDash` (the rule does not exist yet).

- [ ] **Step 3: Write EmDash.yml**

```yaml
# styles/glw907/EmDash.yml
extends: existence
message: "Em dash is a tell. End the sentence, or use a colon, a comma, or parentheses."
link: "https://vale.sh"
level: error
nonword: true
tokens:
  - '—'
```

- [ ] **Step 4: Run the runner; EmDash passes**

Run: `cd ~/.dotfiles/vale/tests && ./run-fixtures.sh`
Expected: no `EmDash` failure. The en-dash good fixture stays clean (the token list holds only the em dash, U+2014).

- [ ] **Step 5: Write the remaining six lexical rules**

`BannedPhrases.yml` (`ignorecase` so casing does not matter):

```yaml
# styles/glw907/BannedPhrases.yml
extends: existence
message: "'%s' is a banned phrase. Say it plainly."
level: error
ignorecase: true
tokens:
  - "it's worth noting"
  - "when it comes to"
  - "dive into"
  - "delve"
  - "let's explore"
  - "at the end of the day"
  - "game.?changer"
  - "state-of-the-art"
  - "look no further"
  - "in today's world"
  - "to be honest"
  - "to be frank"
  - "the honest answer is"
  - "in the realm of"
  - "in the world of"
```

`Openers.yml` (sentence-initial only, so `scope: sentence` plus a `^` anchor):

```yaml
# styles/glw907/Openers.yml
extends: existence
message: "'%s' is a banned opener. Start with the subject."
level: error
ignorecase: true
scope: sentence
tokens:
  - '^(?:Moreover|Additionally|Furthermore|In conclusion|Needless to say|Certainly|It should be noted)\b'
```

`Filler.yml`:

```yaml
# styles/glw907/Filler.yml
extends: existence
message: "'%s' is throat-clearing filler. Cut it."
level: error
ignorecase: true
tokens:
  - '\bgenuinely\b'
  - '\bhonestly\b'
```

`Marketing.yml` (blocked in every tier):

```yaml
# styles/glw907/Marketing.yml
extends: existence
message: "'%s' is marketing language. Use a plain word."
level: error
ignorecase: true
tokens:
  - empower
  - streamline
  - supercharge
  - turbocharge
  - revolutionize
  - effortless
  - effortlessly
  - plethora
  - myriad
```

`Slop.yml` (docs and general tiers; the `.vale.ini` toggles it off where it should not run):

```yaml
# styles/glw907/Slop.yml
extends: existence
message: "'%s' reads as slop. Use a plain word."
level: error
ignorecase: true
tokens:
  - tapestry
  - multifaceted
  - testament
  - seamless
```

`Judgment.yml` (general tier only; `.vale.ini` enables it only in content scope):

```yaml
# styles/glw907/Judgment.yml
extends: existence
message: "'%s' is a judgment word with no exact sense here. Be specific or cut it."
level: error
ignorecase: true
tokens:
  - robust
  - leverage
  - comprehensive
  - dedicated
  - curated
  - tailored
  - foster
  - elevate
  - transformative
  - pivotal
  - thriving
  - meticulous
  - nuanced
  - embark
  - harness
  - bolster
  - groundbreaking
  - cutting-edge
  - innovative
  - foundational
```

- [ ] **Step 6: Write fixtures for the six new rules**

```bash
cd ~/.dotfiles/vale/tests
printf 'This is worth noting for the reader.\n' > fixtures/BannedPhrases.bad.md
printf 'This matters for the reader.\n' > fixtures/BannedPhrases.good.md
printf 'Moreover, the cache helps.\n' > fixtures/Openers.bad.md
printf 'The cache also helps.\n' > fixtures/Openers.good.md
printf 'This is genuinely useful.\n' > fixtures/Filler.bad.md
printf 'This is useful.\n' > fixtures/Filler.good.md
printf 'We empower teams to ship.\n' > fixtures/Marketing.bad.md
printf 'Teams ship faster.\n' > fixtures/Marketing.good.md
printf 'A rich tapestry of features.\n' > fixtures/Slop.bad.md
printf 'A set of features.\n' > fixtures/Slop.good.md
# Judgment is general-tier only; the harness .vale.ini runs all rules, so it fires here.
printf 'A robust and comprehensive system.\n' > fixtures/Judgment.bad.md
printf 'A reliable system that covers the cases.\n' > fixtures/Judgment.good.md
```

- [ ] **Step 7: Run the runner; all lexical rules pass**

Run: `cd ~/.dotfiles/vale/tests && ./run-fixtures.sh`
Expected: `fixtures: OK`. If a good fixture trips a different rule (for example a marketing word inside a slop sample), reword that good fixture so it carries exactly one targeted construct.

- [ ] **Step 8: Commit**

```bash
cd ~/.dotfiles
git add vale/.config/vale/styles/glw907/ vale/tests/fixtures/
git commit -m "Port the glw907 lexical rules with fixtures"
```

### Task 4: Port the structural error rules

**Files:**
- Create: `glw907/ContrastFrame.yml`, `NotJustBut.yml`, `SetupColon.yml`, `CopulaDodge.yml`, `ParticipialOpener.yml`, `BoldHeaderBullet.yml`
- Test: fixtures for each

These reuse the exact `prose-guard` regexes (`STRUCTURAL`, lines 107-128 of the script). Vale uses RE2, which has no lookarounds; none of these six use a lookaround, so they port verbatim.

- [ ] **Step 1: Write the failing fixtures**

```bash
cd ~/.dotfiles/vale/tests
printf "It's not a linter, it's a philosophy.\n" > fixtures/ContrastFrame.bad.md
printf 'It is a linter that enforces one standard.\n' > fixtures/ContrastFrame.good.md
printf 'This is not just fast but also clean.\n' > fixtures/NotJustBut.bad.md
printf 'This is fast and clean.\n' > fixtures/NotJustBut.good.md
printf 'The point: this matters.\n' > fixtures/SetupColon.bad.md
printf 'This matters.\n' > fixtures/SetupColon.good.md
printf 'The cache serves as a buffer.\n' > fixtures/CopulaDodge.bad.md
printf 'The cache buffers reads.\n' > fixtures/CopulaDodge.good.md
printf 'Building on this, the cache helps.\n' > fixtures/ParticipialOpener.bad.md
printf 'The cache helps.\n' > fixtures/ParticipialOpener.good.md
printf -- '- **Cache**: it buffers reads for the page.\n' > fixtures/BoldHeaderBullet.bad.md
printf -- '- The cache buffers reads.\n' > fixtures/BoldHeaderBullet.good.md
```

- [ ] **Step 2: Run the runner to see all six fail**

Run: `cd ~/.dotfiles/vale/tests && ./run-fixtures.sh`
Expected: six `FAIL: ... did not raise glw907.<rule>` lines.

- [ ] **Step 3: Write the six structural rules**

```yaml
# styles/glw907/ContrastFrame.yml
extends: existence
message: "Explicit 'not X, it's Y' antithesis. Prefer an implicit contrast or a plain statement."
level: error
ignorecase: true
raw:
  - "\\b(it|this|that)'?s?\\s+(not|isn'?t)\\b[^.!?;]{3,60}[,;]\\s+(it|this|that|but)'?s?\\b"
```

```yaml
# styles/glw907/NotJustBut.yml
extends: existence
message: "The 'not just X but Y' escalation reads as AI. State the point directly."
level: error
ignorecase: true
raw:
  - "\\bnot\\s+just\\b[^.!?]{5,60}\\bbut\\s+(also\\s+)?"
```

```yaml
# styles/glw907/SetupColon.yml
extends: existence
message: "The 'The point:' setup-payoff is a tell. Fold it into the sentence."
level: error
ignorecase: true
raw:
  - "\\b(the\\s+)?(point|takeaway|truth|reality|bottom line|catch|kicker)\\s*:\\s+[A-Z]"
```

```yaml
# styles/glw907/CopulaDodge.yml
extends: existence
message: "Use 'is' instead of 'serves as a' / 'stands as a'."
level: error
ignorecase: true
raw:
  - "\\b(serves?|stands?|acts?|functions?)\\s+as\\s+a\\b"
```

```yaml
# styles/glw907/ParticipialOpener.yml
extends: existence
message: "Start with the subject, not a participial bridge."
level: error
ignorecase: true
scope: sentence
raw:
  - "^\\s*(building on|recognizing|leveraging|drawing on|having established|taking)\\b[^,]{0,40},\\s"
```

```yaml
# styles/glw907/BoldHeaderBullet.yml
extends: existence
message: "The '**Bolded**:' fake-heading bullet is the AI list default. Write a plain bullet."
level: error
ignorecase: true
raw:
  - "^\\s*[-*]\\s+\\*\\*[^*]+\\*\\*\\s*[:—-]\\s+(it|this|that|these|those|they|we|you|our|your|its|a|an|the)\\b"
```

- [ ] **Step 4: Run the runner; structural rules pass**

Run: `cd ~/.dotfiles/vale/tests && ./run-fixtures.sh`
Expected: `fixtures: OK`. If `ParticipialOpener` or `BoldHeaderBullet` misfires on scope, confirm Vale applies `raw` against the matched scope; for the line-anchored bullet rule, drop `scope` (default `text`) so `^` matches line starts as in `prose-guard`'s `re.MULTILINE`.

- [ ] **Step 5: Commit**

```bash
cd ~/.dotfiles
git add vale/.config/vale/styles/glw907/ vale/tests/fixtures/
git commit -m "Port the glw907 structural rules with fixtures"
```

### Task 5: Port the advisory rules (suggestion and warning)

**Files:**
- Create: `glw907/AdvisoryOpeners.yml`, `AdvisoryPhrases.yml`, `AdvisoryWords.yml`, `FablePhrases.yml`, `DefinitionalPivot.yml`, `PassiveAgent.yml`, `Tricolon.yml`, `SpacedHyphen.yml`, `Emoji.yml`
- Test: fixtures for each

- [ ] **Step 1: Write the failing fixtures**

```bash
cd ~/.dotfiles/vale/tests
printf 'Importantly, the cache helps.\n' > fixtures/AdvisoryOpeners.bad.md
printf 'The cache helps.\n' > fixtures/AdvisoryOpeners.good.md
printf 'This allows you to ship faster.\n' > fixtures/AdvisoryPhrases.bad.md
printf 'You ship faster.\n' > fixtures/AdvisoryPhrases.good.md
printf 'This will unlock new value.\n' > fixtures/AdvisoryWords.bad.md
printf 'This adds two features.\n' > fixtures/AdvisoryWords.good.md
printf 'That is worth noticing here.\n' > fixtures/FablePhrases.bad.md
printf 'Note this here.\n' > fixtures/FablePhrases.good.md
printf 'The honest answer is it depends.\n' > fixtures/DefinitionalPivot.bad.md
printf 'It depends on the input.\n' > fixtures/DefinitionalPivot.good.md
printf 'The record was written by the logger.\n' > fixtures/PassiveAgent.bad.md
printf 'The logger writes the record.\n' > fixtures/PassiveAgent.good.md
printf 'It is fast, clean, and small.\n' > fixtures/Tricolon.bad.md
printf 'It is fast and small.\n' > fixtures/Tricolon.good.md
printf 'A token a - b here.\n' > fixtures/SpacedHyphen.bad.md
printf 'A range 3-5 here.\n' > fixtures/SpacedHyphen.good.md
printf 'Done ✅ today.\n' > fixtures/Emoji.bad.md
printf 'Done today.\n' > fixtures/Emoji.good.md
```

- [ ] **Step 2: Run the runner to see them fail**

Run: `cd ~/.dotfiles/vale/tests && ./run-fixtures.sh`
Expected: nine `FAIL: ... did not raise` lines.

- [ ] **Step 3: Write the advisory rules**

`level: suggestion` for the soft tells, `warning` for passive voice (matching `prose-guard`'s advisory weighting). Word-list rules:

```yaml
# styles/glw907/AdvisoryOpeners.yml
extends: existence
message: "'%s' opener reads as AI as a habit. Consider starting with the subject."
level: suggestion
ignorecase: true
scope: sentence
tokens:
  - '^(?:Importantly|Notably|Of course|Ultimately|Overall|In essence|At its core)\b'
```

```yaml
# styles/glw907/AdvisoryPhrases.yml
extends: existence
message: "'%s' is a soft AI phrase. A plainer construction usually reads better."
level: suggestion
ignorecase: true
tokens:
  - "allows you to"
  - "enables you to"
  - "makes it easy to"
  - "a wide range of"
  - "a variety of"
  - "vast array"
```

```yaml
# styles/glw907/AdvisoryWords.yml
extends: existence
message: "'%s' is a soft tell. Consider a plainer word."
level: suggestion
ignorecase: true
tokens:
  - leverage
  - unlock
  - elevate
  - foster
  - boost
  - vital
  - crucial
  - essential
  - dynamic
  - journey
  - passion
```

```yaml
# styles/glw907/FablePhrases.yml
extends: existence
message: "'%s' is a near-dodge of a banned phrase. Say it plainly."
level: suggestion
ignorecase: true
tokens:
  - "worth noticing"
  - "worth a glance"
  - "worth taking seriously"
  - "high-leverage"
  - "highest-leverage"
```

```yaml
# styles/glw907/DefinitionalPivot.yml
extends: existence
message: "Staged 'the honest/real/true X is' pivot. Fine once; as a habit it reads as AI."
level: suggestion
ignorecase: true
raw:
  - "\\bthe (honest|real|true) \\w+ is\\b"
```

```yaml
# styles/glw907/PassiveAgent.yml
extends: existence
message: "Passive voice with a named agent. Active is usually clearer."
level: warning
ignorecase: true
raw:
  - "\\b(?:is|are|was|were|been|being|be)\\s+(?:\\w+ed|\\w+en|built|sent|made|kept|held|run|read|set|done|found|paid|told|drawn|known)\\b\\s+by\\b"
```

```yaml
# styles/glw907/Tricolon.yml
extends: existence
message: "A three-item list can read as AI. Keep the item that earns its place."
level: suggestion
raw:
  - "\\b([a-z]{3,}),\\s+([a-z]{3,}),?\\s+and\\s+([a-z]{3,})\\s*[.!?]"
```

```yaml
# styles/glw907/SpacedHyphen.yml
extends: existence
message: "A spaced hyphen used as a dash. Use a real connector or restructure."
level: suggestion
ignorecase: true
raw:
  - "[a-z]\\s-\\s[a-z]"
```

```yaml
# styles/glw907/Emoji.yml
extends: existence
message: "Emoji in technical prose reads as a tell."
level: suggestion
nonword: true
raw:
  - "[\\x{1F300}-\\x{1FAFF}\\x{2600}-\\x{27BF}\\x{2B00}-\\x{2BFF}]"
```

- [ ] **Step 4: Run the runner; advisory rules pass**

Run: `cd ~/.dotfiles/vale/tests && ./run-fixtures.sh`
Expected: `fixtures: OK`. The `Tricolon` good fixture (`fast and small`) and the `SpacedHyphen` good fixture (`3-5`, no surrounding spaces) must stay silent. If `Emoji` does not match, confirm Vale's RE2 Unicode class syntax (`\x{...}`) against the probe from Task 1 and adjust the ranges.

- [ ] **Step 5: Commit**

```bash
cd ~/.dotfiles
git add vale/.config/vale/styles/glw907/ vale/tests/fixtures/
git commit -m "Port the glw907 advisory rules with fixtures"
```

### Task 6: Add the style README documenting coverage and the dropped checks

**Files:**
- Create: `~/.dotfiles/vale/.config/vale/styles/glw907/README.md`

- [ ] **Step 1: Write the README**

Document, in plain prose: that `glw907` is the universal voice style; the three severity tiers (error blocks, warning and suggestion advise); the two `prose-guard` checks with no Vale equivalent that are deliberately dropped (anaphora and low burstiness); and the comment-language coverage note (Vale lints comment text for its supported languages, which may be a narrower set than `prose-guard`'s `CODE_EXTS`; list the languages confirmed in Phase 3 Task 9). Keep all banned tokens inside code spans so this file does not trip its own rules.

- [ ] **Step 2: Commit**

```bash
cd ~/.dotfiles
git add vale/.config/vale/styles/glw907/README.md
git commit -m "Document the glw907 style coverage and dropped checks"
```

---

## Phase 2: Global config and stow wiring

### Task 7: Write the global .vale.ini with tier scoping and stow the package

**Files:**
- Create: `~/.dotfiles/vale/.config/vale/.vale.ini`
- Modify: `~/.dotfiles/bash/.bashrc` (add the `VALE_CONFIG_PATH` export; confirm the real filename under `bash/` first)
- Modify: `~/.dotfiles/README.md` (add `vale` to the stow-packages list)

- [ ] **Step 1: Write the global config**

Encodes the three tiers from the spec. `Slop` runs in docs and general; `Judgment` runs in general (content) only. Apply the Task 1 Step 5 precedence finding: if `VALE_CONFIG_PATH` overrides an in-tree config, this file stays minimal and per-repo configs set their own `StylesPath`; if the in-tree config wins (the documented behavior), this is the global fallback below.

```ini
# ~/.config/vale/.vale.ini — workstation-global writing-voice standard
StylesPath = styles
MinAlertLevel = suggestion

[*.md]
BasedOnStyles = glw907
glw907.Judgment = NO

[{**/src/content/**,**/content/**}/*.md]
BasedOnStyles = glw907
glw907.Judgment = error

[*.{go,ts,tsx,js,jsx,mjs,cjs,svelte,py,sh,bash,rs,java,c,h,cpp,css,scss}]
BasedOnStyles = glw907
glw907.Slop = NO
glw907.Judgment = NO
```

- [ ] **Step 2: Add the bashrc export**

Append to the tracked bashrc (confirm the path, likely `~/.dotfiles/bash/.bashrc`):

```bash
export VALE_CONFIG_PATH="$HOME/.config/vale/.vale.ini"
```

- [ ] **Step 3: Stow the package and confirm the symlinks**

Run:
```bash
cd ~/.dotfiles && stow -R vale && ls -l ~/.config/vale/.vale.ini ~/.config/vale/styles/glw907/EmDash.yml
```
Expected: both paths are symlinks into `~/.dotfiles/vale/...`.

- [ ] **Step 4: Confirm Vale runs against the global config from an arbitrary directory**

Run:
```bash
cd /tmp && printf 'Moreover, an em dash — here.\n' > /tmp/voice-check.md
VALE_CONFIG_PATH="$HOME/.config/vale/.vale.ini" vale /tmp/voice-check.md; rm /tmp/voice-check.md
```
Expected: `glw907.Openers` and `glw907.EmDash` both alert at error level.

- [ ] **Step 5: Commit**

```bash
cd ~/.dotfiles
git add vale/.config/vale/.vale.ini bash/.bashrc README.md
git commit -m "Add the global Vale config and stow the vale package"
```

---

## Phase 3: The Vale-backed hook

### Task 8: Write the vale-hook wrapper with tests

**Files:**
- Create: `~/.dotfiles/bin/.local/bin/vale-hook`
- Create: `~/.dotfiles/tests/test_vale_hook.py`

The wrapper reuses `prose-guard`'s tool-call parsing (read `prose-guard` lines 371-408 for `main_hook`/`main_post_hook` and how it resolves Write vs Edit content). It writes the resolved content to a temp file with the target's extension, runs Vale, and on `--pre` emits a deny decision for any error-severity alert.

- [ ] **Step 1: Write the failing hook tests**

```python
# ~/.dotfiles/tests/test_vale_hook.py
import json, subprocess, sys
HOOK = ["python3", "/home/glw907/.dotfiles/bin/.local/bin/vale-hook"]

def run(mode, payload):
    p = subprocess.run(HOOK + [mode], input=json.dumps(payload),
                       capture_output=True, text=True)
    return p.returncode, p.stdout

def test_pre_blocks_dirty_write():
    payload = {"tool_name": "Write",
               "tool_input": {"file_path": "/tmp/x.md",
                              "content": "Moreover, this is wrong.\n"}}
    code, out = run("--pre", payload)
    assert code == 0
    decision = json.loads(out)
    assert decision["hookSpecificOutput"]["permissionDecision"] == "deny"
    assert "Openers" in out

def test_pre_allows_clean_write():
    payload = {"tool_name": "Write",
               "tool_input": {"file_path": "/tmp/x.md",
                              "content": "This sentence is clean.\n"}}
    code, out = run("--pre", payload)
    assert code == 0
    assert out.strip() == ""

def test_pre_fails_open_on_garbage():
    p = subprocess.run(HOOK + ["--pre"], input="not json",
                       capture_output=True, text=True)
    assert p.returncode == 0
    assert p.stdout.strip() == ""
```

- [ ] **Step 2: Run the tests to see them fail**

Run: `cd ~/.dotfiles && python3 -m pytest tests/test_vale_hook.py -v`
Expected: failures (the `vale-hook` script does not exist yet).

- [ ] **Step 3: Write the wrapper**

```python
#!/usr/bin/env python3
"""vale-hook: run Vale as a Claude Code hook.

  vale-hook --pre   PreToolUse. Reads the tool-call JSON on stdin, resolves the
                    post-write content, runs Vale at error level, and prints a
                    deny decision on any alert. Clean content prints nothing.
  vale-hook --post  PostToolUse. Runs Vale at suggestion level and prints the
                    findings as advisory additionalContext. Never blocks.

Any internal error exits 0 with no output: a hook bug must never block work.
"""
import json, os, subprocess, sys, tempfile

VALE = os.path.expanduser("~/.local/bin/vale")

def _resolve(payload):
    """Return (path, content) for a Write/Edit call, or (None, None) to skip."""
    name = payload.get("tool_name", "")
    ti = payload.get("tool_input", {})
    path = ti.get("file_path")
    if not path:
        return None, None
    if name == "Write":
        return path, ti.get("content", "")
    if name == "Edit":
        # Best-effort: scan the new text being introduced.
        if "new_string" in ti:
            return path, ti["new_string"]
        return path, ti.get("content", "")
    return None, None

def _run_vale(path, content, min_level):
    ext = os.path.splitext(path)[1] or ".md"
    with tempfile.NamedTemporaryFile("w", suffix=ext, delete=False) as fh:
        fh.write(content)
        tmp = fh.name
    try:
        out = subprocess.run(
            [VALE, "--output=JSON", f"--minAlertLevel={min_level}", tmp],
            capture_output=True, text=True).stdout
        data = json.loads(out) if out.strip() else {}
    finally:
        os.unlink(tmp)
    # Vale keys results by filename; flatten to a list of alert dicts.
    alerts = []
    for _file, items in (data.items() if isinstance(data, dict) else []):
        alerts.extend(items)
    return alerts

def main_pre():
    payload = json.load(sys.stdin)
    path, content = _resolve(payload)
    if path is None:
        return 0
    alerts = _run_vale(path, content, "error")
    if not alerts:
        return 0
    lines = [f"  [{a['Severity']}] {a['Check']}: {a['Message']}" for a in alerts]
    reason = ("Writing-voice check (Vale) found tells that block this write:\n"
              + "\n".join(lines)
              + "\n\nRevise the prose and try again. See ~/.config/vale/styles/glw907/README.md.")
    print(json.dumps({"hookSpecificOutput": {
        "hookEventName": "PreToolUse",
        "permissionDecision": "deny",
        "permissionDecisionReason": reason}}))
    return 0

def main_post():
    payload = json.load(sys.stdin)
    path, content = _resolve(payload)
    if path is None:
        return 0
    alerts = _run_vale(path, content, "suggestion")
    if not alerts:
        return 0
    lines = [f"  [{a['Severity']}] {a['Check']}: {a['Message']}" for a in alerts]
    ctx = "Vale advisory tells (not blocking):\n" + "\n".join(lines)
    print(json.dumps({"hookSpecificOutput": {
        "hookEventName": "PostToolUse",
        "additionalContext": ctx}}))
    return 0

if __name__ == "__main__":
    try:
        mode = sys.argv[1] if len(sys.argv) > 1 else "--pre"
        sys.exit(main_post() if mode == "--post" else main_pre())
    except Exception:
        sys.exit(0)  # fail open
```

- [ ] **Step 4: Make it executable and run the tests**

Run: `chmod +x ~/.dotfiles/bin/.local/bin/vale-hook && cd ~/.dotfiles && python3 -m pytest tests/test_vale_hook.py -v`
Expected: 3 passed. Confirm the Claude Code PreToolUse deny schema keys (`permissionDecision`, `permissionDecisionReason`) against the installed Claude Code version; if the schema differs, match `prose-guard`'s current `--hook` output shape exactly, since that shape is known to work.

- [ ] **Step 5: Cross-check the deny schema against prose-guard**

Run: `sed -n '371,395p' ~/.dotfiles/bin/.local/bin/prose-guard`
Expected: read the exact JSON `prose-guard` prints on a block. If it differs from the wrapper's output, update `main_pre` to emit the identical structure, then re-run the tests.

- [ ] **Step 6: Commit**

```bash
cd ~/.dotfiles
git add bin/.local/bin/vale-hook tests/test_vale_hook.py
git commit -m "Add the Vale-backed Claude Code hook wrapper"
```

### Task 9: Confirm comment-language coverage, then flip the hook in settings.json

**Files:**
- Modify: `~/.claude/settings.json` (the two hook command lines)

- [ ] **Step 1: Measure comment-only linting coverage**

```bash
cd /tmp
printf '// Moreover, an em dash — here.\nconst x = 1;\n' > probe.ts
printf '# Moreover, an em dash — here.\nx = 1\n' > probe.py
printf '// Moreover, an em dash — here.\npackage main\n' > probe.go
for f in probe.ts probe.py probe.go; do echo "== $f =="; vale "$f"; done
rm -f probe.ts probe.py probe.go
```
Expected: each file alerts on `Openers`/`EmDash` inside the comment only (the code line `const x = 1;` is not scanned). Record which of `prose-guard`'s `CODE_EXTS` Vale does and does not cover, and write the result into the Task 6 README. Where Vale lacks a comment scope for a language, note it as a known coverage gap.

- [ ] **Step 2: Read the current hook block**

Run: `python3 -c "import json,sys; print(json.dumps(json.load(open('/home/glw907/.claude/settings.json'))['hooks'], indent=2))"`
Expected: shows the PreToolUse `prose-guard --hook` and PostToolUse `prose-guard --post-hook` entries.

- [ ] **Step 3: Flip the two commands**

Change `prose-guard --hook` to `vale-hook --pre` and `prose-guard --post-hook` to `vale-hook --post`, leaving the matchers and event names unchanged.

- [ ] **Step 4: Prove the live hook blocks a dirty write and allows a clean one**

In a fresh Claude Code turn (or by replaying the hook manually), attempt to write a file containing `Moreover, x.` and confirm the write is denied with the Vale reason; then write a clean line and confirm it succeeds. Manual replay:
```bash
echo '{"tool_name":"Write","tool_input":{"file_path":"/tmp/x.md","content":"Moreover, this.\n"}}' | vale-hook --pre
echo '{"tool_name":"Write","tool_input":{"file_path":"/tmp/x.md","content":"This is clean.\n"}}' | vale-hook --pre
```
Expected: the first prints a deny JSON naming `glw907.Openers`; the second prints nothing.

- [ ] **Step 5: Commit the settings change**

```bash
# settings.json is tracked in the claude stow package:
cd ~/.dotfiles && git add claude/.claude/settings.json
git commit -m "Switch the Claude Code prose hook from prose-guard to vale-hook"
```

---

## Phase 4: Repoint the docs and memories

### Task 10: Update the judgment-layer docs to reference Vale

**Files:**
- Modify: `~/.claude/CLAUDE.md`
- Modify: `~/.claude/output-styles/writing-voice.md`
- Modify: `~/.claude/docs/prose-voice.md`
- Modify: `~/.claude/docs/voice/*.md` (the six register files, only where they name `prose-guard`)

- [ ] **Step 1: Find every prose-guard mention in the judgment layer**

Run: `grep -rn "prose-guard\|prose_guard" ~/.claude/CLAUDE.md ~/.claude/output-styles/ ~/.claude/docs/`
Expected: a list of lines to edit. Each one changes the mechanical reference (the tool name, the `~/.local/bin/prose-guard` path, the "hook blocks" description) to Vale and `vale-hook`, while keeping the judgment-layer prose (registers, exemplars, dosage, the first-draft rule) intact.

- [ ] **Step 2: Edit each file**

Replace mechanical references: `prose-guard` becomes `vale` / `vale-hook`; "the `prose-guard` hook blocks" becomes "the `vale-hook` hook blocks on error-severity Vale alerts"; the canonical-encoding line that points at `~/.local/bin/prose-guard` points at `~/.config/vale/styles/glw907/` and `vale-hook`. Keep the banned-construction lists in the docs as written (they are guidance, and Vale enforces them now).

- [ ] **Step 3: Confirm no stale mechanical references remain**

Run: `grep -rn "prose-guard\|prose_guard" ~/.claude/ | grep -v "/projects/\|/file-history/\|/tasks/\|/history.jsonl"`
Expected: no live references in CLAUDE.md, the output style, or the docs. References inside a deprecation note (if any) are acceptable.

- [ ] **Step 4: Commit**

```bash
cd ~/.dotfiles
git add claude/.claude/CLAUDE.md claude/.claude/output-styles/writing-voice.md claude/.claude/docs/
git commit -m "Repoint the writing-voice docs from prose-guard to Vale"
```

### Task 11: Update the affected memories

**Files:**
- Modify the cairn-cms project memory entries that describe `prose-guard` mechanics.

- [ ] **Step 1: Find the memory files**

Run: `grep -rln "prose-guard\|prose_guard" ~/.claude/projects/-home-glw907-Projects-cairn-cms/memory/`
Expected: `prose-guard-tiers.md`, `cairn-prose-cleanup-not-mechanical.md`, and any neighbor.

- [ ] **Step 2: Update each memory and its MEMORY.md pointer**

Rewrite the `prose-guard-tiers` memory to describe Vale's severity tiers (error blocks via `vale-hook`, warning and suggestion advise) and the `glw907` style, and note the two dropped statistical checks. Update the one-line pointer in `MEMORY.md`. Leave the dosage and cleanup-philosophy memories' guidance intact, changing only the tool name.

- [ ] **Step 3: Confirm the edits saved (memories are not a git repo)**

No commit needed; memory files live under `~/.claude/projects/.../memory/` and are not tracked in dotfiles git. Confirm each edited file reads correctly.

---

## Phase 5: cairn-cms CI gate (the proof)

### Task 12: Vendor the style into cairn-cms and add the local gate

**Files:**
- Create: `~/Projects/cairn-cms/.vale.ini`
- Create: `~/Projects/cairn-cms/.vale/styles/glw907/` (vendored copy)
- Create: `~/Projects/cairn-cms/scripts/check-vale-sync.mjs`
- Modify: `~/Projects/cairn-cms/package.json` (add `check:vale` and `check:vale:sync`)

- [ ] **Step 1: Vendor the style**

```bash
cd ~/Projects/cairn-cms
mkdir -p .vale/styles
cp -R ~/.dotfiles/vale/.config/vale/styles/glw907 .vale/styles/glw907
```

- [ ] **Step 2: Write the repo .vale.ini scoped to published docs**

```ini
# cairn-cms/.vale.ini — gate the published docs on the glw907 voice standard
StylesPath = .vale/styles
MinAlertLevel = error

[{docs/reference,docs/guides,docs/explanation,docs/tutorial}/**/*.md]
BasedOnStyles = glw907
glw907.Judgment = NO

[{README,ROADMAP,SECURITY,CHANGELOG}.md]
BasedOnStyles = glw907
glw907.Judgment = NO
```

- [ ] **Step 3: Add the npm scripts**

In `package.json` scripts, add:
```json
"check:vale": "vale docs/reference docs/guides docs/explanation docs/tutorial README.md ROADMAP.md SECURITY.md CHANGELOG.md",
"check:vale:sync": "node scripts/check-vale-sync.mjs"
```

- [ ] **Step 4: Write the drift check**

```javascript
// scripts/check-vale-sync.mjs — fail if the vendored glw907 style drifts from the dotfiles canonical
import { readdirSync, readFileSync, statSync } from 'node:fs';
import { join } from 'node:path';
import { homedir } from 'node:os';

const vendored = '.vale/styles/glw907';
const canonical = join(homedir(), '.dotfiles/vale/.config/vale/styles/glw907');

function files(dir) {
  return readdirSync(dir).filter((f) => statSync(join(dir, f)).isFile()).sort();
}
let drift = false;
const a = files(vendored), b = files(canonical);
if (a.join() !== b.join()) { console.error(`file set differs:\n  vendored: ${a}\n  canonical: ${b}`); drift = true; }
for (const f of a.filter((x) => b.includes(x))) {
  if (readFileSync(join(vendored, f), 'utf8') !== readFileSync(join(canonical, f), 'utf8')) {
    console.error(`drift: ${f}`); drift = true;
  }
}
if (drift) { console.error('check-vale-sync: vendored glw907 style is out of sync'); process.exit(1); }
console.log('check-vale-sync: OK');
```

- [ ] **Step 5: Run the gate locally and confirm it is green**

Run: `cd ~/Projects/cairn-cms && npm run check:vale; echo "EXIT: $?" && npm run check:vale:sync`
Expected: `check:vale` exits 0 (the published docs already pass the error tier per the spec's sweep finding); `check:vale:sync` prints OK. If `check:vale` reports an error-level alert, fix that doc line (it is a real tell) and re-run.

- [ ] **Step 6: Commit**

```bash
cd ~/Projects/cairn-cms
git add .vale.ini .vale/styles/glw907 scripts/check-vale-sync.mjs package.json
git commit -m "Gate the published docs on the glw907 Vale voice standard"
```

### Task 13: Wire Vale into cairn-cms CI

**Files:**
- Modify: `~/Projects/cairn-cms/.github/workflows/test.yml`

- [ ] **Step 1: Add a Vale install-and-run step**

Add a step to the existing job (after `check:prose`), installing the pinned Vale and running the gate:

```yaml
      - name: Install Vale
        run: |
          curl -fsSL https://github.com/errata-ai/vale/releases/download/v3.9.1/vale_3.9.1_Linux_64-bit.tar.gz \
            | tar -xz -C /usr/local/bin vale
      - run: npm run check:vale:sync
      - run: npm run check:vale
```

- [ ] **Step 2: Validate the workflow YAML locally**

Run: `cd ~/Projects/cairn-cms && python3 -c "import yaml,sys; yaml.safe_load(open('.github/workflows/test.yml')); print('yaml OK')"`
Expected: `yaml OK`. (The sync step fails in CI if the vendored style ever drifts, which is the intended guard.)

- [ ] **Step 3: Commit, then push only with Geoff's go-ahead**

```bash
cd ~/Projects/cairn-cms
git add .github/workflows/test.yml
git commit -m "Run the Vale docs gate in CI"
```
This is the one step that touches a shared CI surface and the published repo. Confirm with Geoff, then push and watch the run.

---

## Phase 6: Retire prose-guard

### Task 14: Remove prose-guard once Vale is live and proven

**Files:**
- Delete: `~/.dotfiles/bin/.local/bin/prose-guard`
- Delete: `~/.dotfiles/tests/test_prose_guard.py`

- [ ] **Step 1: Confirm the Vale hook has been live and clean**

Confirm Phase 3 Task 9 is done (settings.json points at `vale-hook`) and that several real writes have passed through it this session. Do not start this task until the Vale hook is the active hook.

- [ ] **Step 2: Remove the script and its tests, then restow**

```bash
cd ~/.dotfiles
git rm bin/.local/bin/prose-guard tests/test_prose_guard.py
stow -R bin
ls -l ~/.local/bin/prose-guard 2>&1 || echo "prose-guard symlink gone (expected)"
```
Expected: the `prose-guard` symlink is gone; `vale-hook` remains stowed and on PATH.

- [ ] **Step 3: Final grep for stale references**

Run: `grep -rn "prose-guard" ~/.dotfiles/ --include='*.md' --include='*.sh' --include='*.json' | grep -v "docs/superpowers/"`
Expected: no live references outside the spec and plan (which keep the name for history).

- [ ] **Step 4: Commit**

```bash
cd ~/.dotfiles
git commit -m "Retire prose-guard; Vale is now the writing-voice linter"
```

- [ ] **Step 5: Update the dotfiles README stow-packages and CLAUDE.md inventory**

Confirm `~/.dotfiles/README.md` lists `vale` and no longer implies `prose-guard` is the linter, and that `~/.claude/CLAUDE.md`'s tooling inventory matches. Commit any final wording.

```bash
cd ~/.dotfiles && git add README.md claude/.claude/CLAUDE.md
git commit -m "Update the dotfiles inventory for the Vale migration" || true
```

---

## Self-Review

**Spec coverage:** Phase 0 covers install and the precedence/schema risks. Phase 1 covers the full rule port (lexical, structural, advisory) and the two dropped checks. Phase 2 covers the stow package, global config, tier scoping, and the `VALE_CONFIG_PATH` export. Phase 3 covers the hook wrapper and the settings flip, plus the comment-coverage measurement. Phase 4 covers the doc and memory repoint. Phase 5 covers the vendored cairn-cms gate, the drift check, and CI. Phase 6 covers retirement in the spec's order. Style composition (the per-domain scoping and overlay model) is realized in Task 7's `.vale.ini` and Task 12's repo config.

**Placeholder scan:** every code step shows complete content. The two empirical points (config precedence, comment-language coverage) are explicit verification steps with a defined fallback, not deferred work.

**Type and name consistency:** rule names match between the YAML files, the fixtures (`<RuleName>.bad.md`), the `glw907.<RuleName>` references, and the hook output. The style name is `glw907` throughout. The hook modes are `--pre` and `--post` in both the wrapper and `settings.json`.

**Open dependency:** Phase 5 Task 13 Step 3 (the push to cairn-cms CI) needs Geoff's explicit go-ahead, since it touches the shared published repo.
