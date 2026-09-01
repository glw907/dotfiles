# Benchmark run 2026-09-01, iteration 3 (brief contract + judge priority)

Two changes from iteration 2, one per layer. Treatment: the router gained "The brief is a
contract" (a stated length or format is a requirement, met by saying more about the given
facts, never by padding or invention). Measurement: judges now carry an explicit priority
order: fabrication outweighs polish, deriving an obvious specific from a stated fact is
interpolation rather than invention, and a missed floor is a real defect. The comparison
arm is the iteration-2 with-skill drafts, and both arms were graded under the new judging
rules, so the rubric change cannot favor either side. The run executed as a Workflow
pipeline (draft straight into judge per eval, 24 agents, no errors).

## Headline

| Metric | New (iter 3) | Old (iter 2 drafts) |
|---|---|---|
| Assertion pass rate | 95.8% (69/72) | 93.1% (67/72) |
| Blind preference wins | 7 | 5 |
| Factual-fidelity rubric | 4.25 | 4.67 |
| Tell violations | 4 | 0 |

## What the fixes did

1. **The word-floor fix worked everywhere it was aimed.** The quickstart landed at 172
   words against the old draft's 102, the release notes at 159 against 93, and the go-cli
   page at 313 against 235; three of the seven new-arm wins were decided by the old draft
   missing a floor the new one hits. The failure mode from iteration 2 (facts discipline
   plus terseness undershooting a stated range) did not recur.
2. **The judge priority rules changed real verdicts.** Interpolated flag and env-var
   spellings, graded as inventions in iteration 2, were explicitly credited as fair
   interpolation this round. Fabrication was penalized consistently in both directions:
   the old readme's unsupported claims cost it eval-00, and the new drafts' inventions
   (a config-show source-attribution behavior in go-cli, an unverified "I verified this
   resolves the 403" in the reply) cost them evals 01 and 07. The design-note flip from
   iteration 2, where polish beat honesty, reversed under the explicit priority.
3. **Fabrication persists at a residual level in both directions.** One invented specific
   appeared in two of twelve new drafts. The register line reduces it; nothing eliminates
   single-draft slips. This now looks like variance to be priced with multiple runs, not
   a systematic register defect.

## Regressions and residuals

- Spaced em dashes crept back: four across two new docs drafts (go-cli, design-note),
  the only deterministic violations in the new arm. Google wants the em dash unspaced and
  the register says so; drafting attention seems to trade between rules. Nothing new to
  write yet, but a recurring slip would argue for promoting the rule into the register's
  exemplar text rather than its rule list.
- Rubric means are not comparable across judge cohorts. This round's judges scored
  the old arm's rubric higher (4.44 vs 4.23 overall) while preferring the new arm 7-5
  under the priority rules. Preference under stated priorities and assertion pass rate
  are the stable metrics; free rubric means drift with the judge cohort and should be
  read only within a run.
- **The explainer lead-with-diagnosis assertion failed both arms for the third straight
  run** and remains non-discriminating. Reword it before the corpus is next used for a
  treatment comparison; it costs a point in every arm and measures nothing.
- Comment-eval variance continued but favored the new arm this time (package comment
  present, helper density right), consistent with coin-flip variance rather than
  treatment effect. Multiple runs per arm remains the open method improvement.

## Trend

| Run | Arm | Assertions | Blind |
|---|---|---|---|
| Iter 1 | skill vs bare baseline | 90.3% vs 77.8% | 8-4 |
| Iter 2 | +facts line vs iter-1 skill | 93.1% vs 88.9% | 8-4 |
| Iter 3 | +brief contract vs iter-2 skill | 95.8% vs 93.1% | 7-5 |

Each register amendment has beaten its predecessor under blind judging, with the residual
failures shrinking from systematic (fabrication class) to mechanical (dash spacing) to
variance (single-draft slips).
