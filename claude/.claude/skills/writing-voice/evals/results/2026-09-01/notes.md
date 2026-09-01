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
5. **Lexicon status.** The slop lexicon in the grader is the provisional local list; the
   external-research pass (published tell taxonomies, evidenced word lists) had not
   landed when these numbers were taken. Regrade after extending it; em-dash and
   structural checks, which produced every finding above, will not change.

## Method notes for the next run

Keep the A/B alternation and the three grading layers. Fix the explainer assertion.
Consider a second run per arm to expose variance before trusting single-digit deltas.
