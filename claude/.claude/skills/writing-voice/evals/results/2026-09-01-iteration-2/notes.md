# Benchmark run 2026-09-01, iteration 2 (facts-discipline line)

One variable changed from iteration 1: every register file and the router skill gained a
facts-discipline rule (work only from given or verified facts; an unstated specific is an
invention; leaving a detail out beats completing the picture). The twelve with-skill tasks
reran on the amended registers, same prompts, same model. The comparison arm is the
iteration-1 with-skill drafts, judged blind by fresh Opus judges with A/B alternating.

## Headline

| Metric | New registers | Old registers |
|---|---|---|
| Assertion pass rate | 93.1% (67/72) | 88.9% (64/72) |
| Judge rubric mean (1-5) | 4.13 | 4.13 |
| Factual-fidelity rubric | **4.08** | **3.67** |
| Tell violations | 0 | 2 |
| Blind preference wins | 8 | 4 |

The change moved exactly the dial it aimed at. The overall rubric is flat, factual
fidelity rose 0.41, and on the evals where iteration 1 diagnosed fabrication the new
drafts pass:
release notes and commit invent nothing (the old commit's fabricated "verified by" section
was called out by name), the quickstart stays inside the supplied facts where the old
draft invented a NOAA site lookup, and the readme's failure shrank from four invented
features plus a mischaracterized auth model to one marginal interpretation of magic-link
addressing.

## What did not improve

1. **Fabrication is reduced, not eliminated.** The readme draft still asserts one behavior
   the task does not state. The line helps; it does not guarantee.
2. **Judges price polish against facts inconsistently.** The design-note judge preferred
   the old draft for genre fit while noting it invented index-size numbers the new draft
   refused to invent. Strict-facts drafts read denser, and a judge without an explicit
   weighting sometimes rewards the fluent fabricator. If facts should dominate, the judge
   rubric needs an explicit priority, mirroring the LongWriter trick of telling the judge
   which dimension to ignore or weight.
3. **Two comment-eval losses are run variance, not regression.** The new go-doc draft
   omitted the package comment; the new TSDoc draft over-documented the private helper.
   Both are single-sample coin flips the conventions already forbid; a second run per arm
   would price this variance (iteration-1 notes already recommended it).
4. **The word-floor problem worsened.** The facts-plus-terseness combination pushed the
   quickstart to 102 words against a 150 floor. Facts discipline removes padding, and
   nothing in the register says a minimum brief is part of the contract. Either the
   registers need a line that a stated length is a requirement, or the corpus floors are
   unrealistic for fact-limited tasks; decide before iteration 3.
5. **The go-cli judge counted derived names as inventions** (flag spellings implied by the
   three settings). The assertion language should distinguish stated-fact violations from
   reasonable derivations, or judges will grade honest interpolation as fabrication.

## Carried from iteration 1

The explainer lead-with-diagnosis assertion again failed both arms identically and stays
non-discriminating; reword it. The same-family-judge caveat (Opus judging Sonnet) and the
uncalibrated flat-cadence CV threshold still stand.
