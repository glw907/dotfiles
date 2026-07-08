---
name: design-refinement
description: Use when polishing an EXISTING design — a page, app screen, or artifact whose bones are approved — toward a benchmark or "truly designed" finish. The refinement counterpart to origination skills (frontend-design) and port-matching skills (visual-fidelity): axis passes, felt-refinement audits, knob ledgers, and separated render reads.
---

# Design refinement

For the common case no generation tool serves: the design exists, its owner has approved its
bones, and the remaining distance is composition, register, and craft. This is not origination
(inventing an aesthetic) and not porting (matching an external original) — it is closing the
last fifteen percent on your own work, and knowing when to stop.

The failure mode this method exists to prevent has a studied name (arXiv 2605.30335, "locally
coherent, globally incoherent"): element-by-element patches, each locally correct, that
degrade the whole — and the study's key negative result is that adding surrounding-context
prose to narrow patches makes results WORSE, not better. The fix is a different unit of work,
not better patch prompts.

## The method

1. **Pin the benchmark.** Refinement needs a reference render, never adjectives. Capture the
   current approved state (or the project's best page) at the design's real widths, commit the
   captures, and grade every pass against them the way a port is graded against its original.
   If the benchmark evolves, re-pin deliberately — new captures, owner sign-off — never let it
   drift. No benchmark exists? Pinning one is step zero, not optional.
2. **Translate every note to an axis, then batch.** Owner notes arrive as element complaints
   ("this list is too loud"). Never dispatch them verbatim. Translate to a named design axis —
   hierarchy, density, rhythm, register, alignment, contrast — batch same-axis notes, and
   re-scope the work to the whole page or section on that axis. A note that recurs after one
   anchored fix is the incoherence signature: WIDEN the regeneration unit; never layer a third
   narrow instruction.
3. **Passes, not patches.** Structure iteration as whole-surface passes: (a) spacing,
   alignment, and hierarchy; (b) type, color, and token conformance; (c) states, interaction,
   and accessibility. Each pass covers everything in scope, so local fixes compose.
4. **The felt-refinement audit** (the endgame): read-only designer lenses — typography and
   rhythm; color, surface, and depth; interaction and motion — audit the DEPLOYED or built
   state against the benchmark and return a LEDGER: every knob evaluated, marked
   already-right / recommend (with the exact change and a felt-impact rating) /
   not-applicable. The calibration is binding and worth quoting verbatim in every lens prompt:
   the burden of proof is on the change, and a mostly already-right ledger is the expected
   outcome of auditing good work — never manufacture recommendations to look useful. A
   directing context adjudicates the ledger; one fixer applies only what survives, with
   interactive proof for anything a static screenshot cannot show (focus rings, selection
   color, hover states, cursor affordances).
5. **Separate who builds from who reads.** The builder's self-screenshot is for its own
   correction, never the gate. A context that did not build the work reads the renders — at
   minimum the directing context reads a full-surface render at every checkpoint, before any
   commit. Builders stop at their best render and wait; deploys to the owner's review surface
   happen at readiness points only, never per-round while a review conversation is open (the
   owner ends up reviewing a moving target, and stale tabs multiply confusion).
6. **The owner's words are calibration data.** Dose statements ("don't overdo it", "this is
   felt refinement", "less designed than the landing page — it's a brochure") are load-bearing
   and travel verbatim into every dispatch. When the owner hasn't stated a dose, ask for it as
   a named level — **felt-only** (invisible-until-touched craft: selection, focus, wrapping,
   optical fixes), **standard** (felt-only plus register and rhythm corrections), or **deep**
   (standard plus composition rework within the approved bones) — one question, before the
   pass. And the owner's design QUESTIONS ("should this have rounded corners?") are questions:
   they get a committed, reasoned answer before any execution. Converting an owner's
   uncertainty into a work item launders an open question into a decision nobody made.
7. **Persist the ledger.** Commit the audit ledger beside the benchmark captures. The next
   pass starts from the recorded already-right verdicts instead of re-auditing and possibly
   re-litigating settled decisions — the ledger is what stops refinement from oscillating.
   An entry is re-opened only when the code it graded has changed or the owner overrules it.

## Hard scope limits

- Refinement never changes the stack: no dependency swaps, no library migrations, no framework
  moves, unless the owner explicitly requests one. (A motion-polish pass that migrates the
  animation library has left refinement.)
- The audit runs at the design's full declared width set (e.g. 320/390/768/1440/2560 for a
  responsive site), plus dark mode where the design ships it, plus interaction states — a
  single-desktop-screenshot audit reliably misses the defects owners find first.
- Every audit includes one explicit coherence question: **does anything here read as
  AI-default?** (the recognizable template looks: the cream-serif-terracotta cluster, the
  dark-page-acid-accent cluster, uniform rounded cards with accent rails, gradient heroes,
  emoji section markers). Refinement that installs a template look has failed even if every
  knob passes.

## Knob calibration (the kinds of thing an audit evaluates — not a checklist to satisfy)

Optical alignment; hanging punctuation; proper typographic characters (curly quotes, real
ellipses, correct dashes); tabular figures where digits column; letter-spacing on caps and
eyebrows; modular-scale conformance; measure control (45–75ch); leading tuned to size and
measure; widow and orphan prevention; text-wrap balance on headings; near-black ink and
near-white grounds; palette constraint with tonal variation; borders via transparency rather
than flat gray; layered low-opacity shadows; radius consistency across every framed element;
selection color; focus-visible consistency across EVERY link family (the ones outside the
main prose class get missed); link underline treatment (rest translucency, hover strengthen);
transition durations and easing; reduced-motion coverage; image aspect intent and frame
consistency; custom list markers; asymmetric spacing that follows hierarchy; heading margins
(tighter above, looser below); cursor affordance on icon-only buttons; font loading versus
layout shift.

## Anti-patterns (each observed to cost a real round)

- Element-by-element prose dispatches, with the owner as the only person reading whole
  compositions.
- Accepting the builder's "looks good" without a fresh-context read (self-grading).
- Hand-tuned optical values — an em-based nudge, a line-count min-height — surviving a type
  change they were calibrated against. Re-measure every optical constant after any type
  change; em units scale with the wrong font when the reference element changes.
- Deploying every merge to the owner's review surface mid-review.
- Treating the owner's design questions as commands (one real page shipped three corner
  treatments before a single design exchange settled the question).
- Inventing copy during refinement. The existing approved text — or the owner's supplied
  text — is the specification; trims are deletion-only (cut whole clauses, never paraphrase)
  so every surviving word stays the author's own.
