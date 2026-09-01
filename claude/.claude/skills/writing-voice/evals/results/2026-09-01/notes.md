# Benchmark run 2026-09-01 (iteration 1, baseline)

First run of the corpus. Both arms drafted on Sonnet; judges ran on Opus, blind, with
A/B position alternating by eval.

## Headline

| Metric | With skill | Baseline |
|---|---|---|
| Assertion pass rate | 90.3% (65/72) | 77.8% (56/72) |
| Judge rubric mean (1-5) | 4.35 | 3.77 |
| Tell violations (deterministic scan) | 2 | 8 |
| Blind preference wins | 8 | 4 |

The two with-skill tell violations are both flat-cadence flags (explainer-reply CV 0.29,
tsdoc-comments CV 0.28). Baseline violations were spaced em dashes (6), a `### Summary`
scaffold header, and a bold-lead bullet list.

## Analyst findings

1. **Fabrication is the with-skill arm's failure mode.** Three of the four blind losses
   (readme-architecture-web, release-notes, go-cli-config-docs) trace to the with-skill
   draft inventing specifics the task never supplied: a configurable branch and CI
   pickup, migration internals and R2 wiring steps, a flag-vs-env usage recommendation.
   Judges weighed invention above sentence-level polish every time. The register
   exemplars appear to encourage confident specificity that slides into invention. The
   highest-value skill improvement is a facts-discipline line in the registers; this
   corpus can measure whether it works.
2. **Skill-shaped terseness has costs at the edges.** Both quickstart drafts landed under
   the task's 150-word floor (with-skill thinner still), and the two with-skill
   flat-cadence flags come from short, clipped genres. Terseness is mostly winning the
   rubric, but it trades against minimum-length briefs and rhythm.
3. **The lead-with-the-answer assertion failed both arms identically** on
   explainer-reply: both opened with the fix, and the diagnosis waited for paragraph two.
   Either the assertion over-specifies (fix-first is arguably answer-first) or the reply
   register needs to distinguish diagnosis-first from remedy-first. Non-discriminating as
   written; reword or accept both openings in iteration 2.
4. **Comment registers discriminate well.** go-doc-comments and python-docstrings showed
   the clearest quality gaps (missing package comment; 13-line Args:/Yields: docstrings
   restating hints), all caught by assertions grounded in the conventions skills.
5. **Lexicon status.** After the external-research pass landed
   (`../../research/2026-09-01-ai-tell-evidence-base.md`), the grader's lexicon was
   rebuilt evidence-tiered (Kobak Tier-A hard list, register rules labeled as such) and
   two checks were added (participial-tail, assistant-voice). Regrading all 24 drafts
   changed nothing: zero lexical or syntactic hits in either arm. On current Claude-family
   models the surviving tells are structural and punctuational (spaced em dashes, scaffold
   headers, bold-lead bullets, flat cadence), which matches the published decay finding
   that famous marker words collapsed after mid-2024 while register signals persist.

## Method notes for the next run

Keep the A/B alternation and the three grading layers; the research validates the design
(decomposed binary checklists roughly double judge-human agreement versus holistic
scores). Three corrections it argues for: the judges here are Opus grading Sonnet, both
Anthropic, and same-family judge and subject share blind spots, so add a cross-family
judge or at least note the bias; the flat-cadence CV threshold of 0.35 is self-chosen
since no published threshold exists, so calibrate it against a local human corpus before
trusting flat-cadence flags; and fix the explainer lead-with-diagnosis assertion. Consider
a second run per arm to expose variance before trusting single-digit deltas.
