---
name: visual-fidelity
description: The port/migration method for reference-faithful UI work — reference capture, device catalogue, build-with-screenshot-loop, fresh-context verifier gate, the owner-eyes deploy gate, and the pixel-diff CI rider. Invoke at the START of any site rebuild, theme port, or design migration (cairn-family or otherwise), and when a visual result must match an existing reference rather than merely look good.
---

# Visual fidelity (ports, rebuilds, migrations)

Born from two production visual misses (2026-07-05: 907.life typography, ecxc.ski structure)
whose mechanical gates were all green. The failure class: verbal specs lose the design,
and the builder's own context grades its work "close" (Anthropic's Fable 5 prompting guide:
fresh-context verifiers outperform self-critique). This skill is the countermeasure stack,
each step traced to evidence in docs/internal/pre-beta-harvest.md (cairn-cms) and the
2026-07-05 research report.

## The method, in order

1. **Reference capture BEFORE any plan.** Full-page screenshots of every page of the real
   site at the family widths (320/390/768/1440/2560; at minimum phone + desktop). No design
   plan is authored from a verbal inventory alone — the ecxc failure began at plan time.
2. **Device catalogue.** An agent (vision-capable, Opus+) READS the references plus the
   source CSS and produces the structural + typographic device catalogue: chrome anatomy,
   composition per page template, card/band recipes, every typographic device (wordmark,
   stamps, links, quotes, code), color PLACEMENT (where each hue actually lands). Exact
   values from the source, never paraphrase.
3. **Build with the canonical loop.** The builder gets reference IMAGES (not descriptions)
   plus the catalogue, and works Anthropic's canonical loop: implement, screenshot the
   result, compare to the reference, list differences, fix. Tokens transfer color and
   faces; STRUCTURE requires building the structure — a theme layer over a mismatched
   scaffold cannot reach a different composition.
4. **Fresh-context verifier gate.** A verifier agent that did NOT build grades each page:
   reference and render as SEPARATE LABELED image blocks (Anthropic vision docs; composite
   images are unproven), per width, verdict per visual device, differences classified
   COSMETIC vs STRUCTURAL. The builder's own "matches" is never accepted.
5. **The one-check rule (deploy gate).** The main loop READS the final renders itself, and
   a member/user-facing site gets the owner's before/after approval. Nothing deploys
   unlooked-at. Deploy watchers verify the run's exact head sha (stale greens happen).
6. **Pixel-diff CI rider.** After fidelity is achieved, freeze it: Playwright
   `toHaveScreenshot` specs at the family widths in the site's own CI, baselines rendered
   by the canonical CI runner (never trust a local render as canonical; regen by FILE PATH,
   not title grep — a grep that can't fail verifies nothing).

## Known anti-patterns (each cost a real deploy)

- The official frontend-design skill is for ORIGINAL aesthetics; it has no
  reference-comparison step. Do not reach for it on a port.
- "Zero chrome edits needed" on a non-blog design is a failure signature, not a win.
- Instrumental goals (test the seams) never outrank the terminal goal (the site looks
  right); frame experiments as measurements, not constraints.
- Acceptance criteria containing "looks like X" cannot be graded by the context that
  built X.
