# Model economy: pricing, history, and mechanics

The on-demand expansion of CLAUDE.md's `## Model economy` section. Read this
when the inline rule isn't enough context to make a call: why the seat split
exists, what things cost, and how the Fable overflow mechanics work. The
inline section in CLAUDE.md is binding; this doc is background.

## Pricing and rate buckets

Fable output costs $50/MTok (2x Opus 5, ~3x Sonnet 5, 10x Haiku 4.5) on the
tightest rate-limit bucket. That gap is why the seat split exists at all: a
Fable conductor doing execution-shaped work (dispatch grinding, gate-running,
bulk reads) is paying the most expensive tier for work that doesn't need it.

Reviewers pin `claude-opus-5` (dated-ID pins repointed 2026-07-26; same price
as 4.8, better recall and precision, separate rate bucket). Beside a Fable
planner and Sonnet implementers, the Opus gate buys cross-model diversity
against correlated self-review blind spots; under an Opus 5 execution
conductor it's still a fresh-context gate.

## Opus 5 narrowed Fable's seat (ratified 2026-07-26)

Before this ratification, Fable held a wider execution role. The narrowing
confined Fable to the sittings where taste, ambiguity, and doctrine are the
product: brainstorming, spec and plan authorship, arc post-mortems, final
user-facing prose. An Opus 5 conductor took execution: dispatch decisions,
diff review, finding triage, gate-running. The mechanical consequence: a
Fable planning sitting ends at plan approval, and execution runs in a fresh
Opus 5 session, with the pre-baked artifacts (committed plan, STATUS
pointer, refreshed memory) as the whole handoff.

Never downshift the planner below Opus 5. A weak plan compounds into rework
that exceeds the savings; a cheap implementer executing a frontier-authored
plan is the stable configuration.

## Fable allocation economics (permanent inclusion since 2026-07-20)

The access whiplash is over: as of 2026-07-20, Fable 5 is permanently
included on the Max plan at roughly 50% of regular usage limits (verified
online 2026-07-26; no expiry). There is no cutoff to plan around; the scarce
resource is the weekly Fable allocation. Spend it where Fable is
differentiated (the planning and taste sittings), never on execution-shaped
work Opus 5 covers at half the API price and none of the allocation.

Permanence also means sittings need no hoarding: a brainstorm or spec
sitting is a routine, legitimate Fable use.

## Beyond the allocation: the overflow playbook

Beyond the weekly allocation, Fable runs on usage credits at API rates
($10/$50). `~/.claude/docs/fable-post-cutoff-system.md` governs this as the
OVERFLOW playbook: batch-first (50% discount), per-dispatch one-shots, and
the SUGGESTION RULES baked there (never silently spend Fable credits, never
silently absorb Fable-tier work; propose job + mode + size in one sentence
and let Geoff decide).

## The self-check, with its origin incident

Self-check at session start and on any cost signal: a Fable conductor doing
execution-shaped work (dispatch grinding, gate-running, bulk reads) gets
flagged immediately with a recommendation to hand off to an Opus 5 session.

This rule exists because an ecxc session silently burned ~1M tokens on
2026-07-13. The flag came from Geoff, not the conductor. That order — Geoff
catching it instead of the conductor self-reporting — is the defect the
self-check exists to close.
