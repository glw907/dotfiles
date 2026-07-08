---
name: design-refinement
description: Use when polishing an EXISTING page or UI toward a pinned benchmark or "truly designed" finish — the third design skill, between frontend-design (origination) and visual-fidelity (matching an external original). Axis passes, felt-refinement audits, knob ledgers, conductor render reads.
---

# Design refinement

For work that is neither inventing an aesthetic (`frontend-design`) nor matching an external
original (`visual-fidelity`): an existing page whose bones are ratified and whose remaining
distance is composition, register, and craft. Born on the ASC home/education passes
(2026-07-08); the research behind it is in the `site-page-review-gate` memory, rule 11a
(arXiv 2605.30335: element patches are "locally coherent, globally incoherent," and adding
context prose to narrow patches measurably regresses results).

## The method

1. **Pin the benchmark.** Refinement needs a reference render, not adjectives. Use the
   project's pinned benchmark (e.g. `docs/design-benchmark/` in the ASC repo) or capture the
   current ratified state before touching anything. The benchmark is graded against the way a
   port is graded against its original.
2. **Translate every note to an axis, then batch.** Owner notes arrive as element complaints
   ("the list is too loud"); dispatch them as whole-page/section passes on a named axis —
   hierarchy, density, rhythm, register, alignment, contrast. Same-axis notes batch into one
   pass. Never dispatch "tighten"/"subordinate"/"modern" verbatim, and never layer a third
   narrow instruction on a twice-failed element: widen the regeneration unit instead.
3. **Passes, not patches.** Spacing/alignment/hierarchy, then type/color/token conformance,
   then states/interaction/a11y — each covering the whole surface in scope.
4. **The felt-refinement audit** (endgame): read-only designer lenses (typography/rhythm,
   color/surface/depth, interaction/motion) audit the DEPLOYED page against the benchmark and
   return a ledger — every knob marked already-right / recommend (with the exact change and a
   felt rating) / not-applicable. Calibration is binding: the burden of proof is on the
   change; a mostly already-right ledger is the expected outcome of auditing good work. The
   conductor adjudicates the ledger; one fixer applies only what survives, with interactive
   proof for anything a static screenshot can't show (focus, selection, hover, cursor).
5. **The conductor reads renders at every checkpoint.** Builders stop at their best render
   BEFORE committing; the directing context reads against the benchmark and approves or sends
   one adjustment. Builder self-praise is never the gate. Deploys happen at readiness points
   only — never per-round while an owner review conversation is open.
6. **Owner questions are questions.** "Should X be Y?" gets a committed, reasoned design
   answer before any execution. Registers: fun/warm pages fail differently from formal ones —
   get the dose words from the owner ("felt refinement, don't overdo"; "brochure, not landing
   page") and quote them verbatim in every dispatch.

## Knob calibration (the kind of thing the audit checks, not a checklist)

Optical alignment; hanging punctuation; proper typographic characters; tabular figures;
letter-spacing on caps; modular scale conformance; measure control; leading tuned to size and
measure; widow/orphan prevention; `text-wrap: balance`/`pretty`; near-black ink; near-white
grounds; transparent borders over gray; layered low-opacity shadows; radius consistency;
`::selection`; focus-visible consistency across EVERY link family (the off-prose ones get
missed); link underline treatment (rest translucency, hover strengthen); easing and duration;
reduced motion; image aspect intent and frame consistency; list markers; asymmetric spacing
following hierarchy; em-based optical nudges that outlive their type size (re-measure after
any type change); cursor affordance on icon buttons; font loading vs layout shift.

## Anti-patterns (each cost a real round)

- Element-by-element prose dispatches with the owner as the only composition reader.
- The builder's "looks good" accepted without a fresh read (self-grading).
- A hand-tuned optical value (an em nudge, a line-count min-height) surviving a type change
  it was calibrated against.
- Deploying every merge to the review surface during an active review (the owner reads a
  moving target and stale tabs multiply).
- Treating the owner's design questions as commands (three corner treatments shipped before
  one design exchange settled the question).
