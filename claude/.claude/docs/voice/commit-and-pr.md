# Register: commit messages and PR bodies

The reader is a future developer skimming `git log` for what changed and why, often years
later and mid-debugging. Write as the same maintainer as the doc registers, at telegram
length.

## Traits

- Imperative subject naming the change. The body is one to four plain declarative
  sentences.
- The body separates what changed from why it was needed; the why is a prior observed fact
  or fragility, never a narrative of the session that produced the commit.
- Scope fences where they help the skimmer: "no behavior change", "visual-only".
- The vocabulary is the repo's own (passes, STATUS, gates), not generic engineering filler.
- No adjectives, no process narration, no restating the diff line by line.

## Exemplars

A what paragraph and a why paragraph, the motivating failure stated as observed fact
(poplar):

```
Archive dogfood track; route all passes to the rebuild

The dogfood poplar client is finished. Archive it at tag poplar-legacy and branch
legacy, kept as reference and a Go-idiom source for the greenfield rebuild. Make the
rebuild the sole active track.

Two parallel trackers in one repo made a fresh context misroute 'continue' to the
retired dogfood work after every context clear. Flip the always-loaded routing rule, the
dogfood STATUS, the poplar-pass skill, and the CLAUDE.md banner so 'continue' and 'next
pass' unambiguously mean the rebuild.
```

One sentence of what, one of scope (cairn-cms):

```
Polish the login confirmation: shared brand snippet and inset help note

Reuse one brand() snippet across the form and confirmation states, and rework the
confirmation into a soft success tile with an InfoIcon inset note and a plain 'use a
different email' link. Visual-only refinement of the 0.37.0 branded confirmation; no
behavior change.
```

A pure why bracketed by two concrete whats (poplar):

```
Rebuild: codify pass-end ritual as a standing STATUS default

Add a Pass-end ritual section to the rebuild STATUS, with updating the STATUS as its
first and non-optional step. Previously the ritual lived only inside each pass's starter
prompt, so it depended on that prompt restating it. Point the Pass 5 starter and the
always-loaded routing rule at the new section.
```

Invariant preserved, direction of travel, and the migration path, in two sentences
(poplar):

```
catkin: drop auto-Reflow from WithWidth

Source stays pristine; wrap moves to render time in subsequent tasks. Reflowed() remains
for callers that want the legacy wrap-into-source behaviour.
```

## Off-voice contrast

The same content in the register this file exists to prevent:

```
Refactored the login confirmation flow for better maintainability

In this commit, I noticed that the brand markup was duplicated, so I went ahead and
extracted it into a reusable snippet. I also took the opportunity to improve the
confirmation UI, which now looks much cleaner. This should make future changes easier!
```
