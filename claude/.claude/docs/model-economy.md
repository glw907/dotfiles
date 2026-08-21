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
against correlated self-review blind spots; under a Fable conductor the Opus
reviewer is both the fresh-context gate and the diff reader the thin
conductor never is.

## Fable conducts (revised 2026-08-21)

The 2026-07-26 ratification split the seat: Fable planned and judged, an
Opus 5 conductor executed. The split existed because execution is long,
tool-heavy, and cache-read-dominated, and that cost compounds fastest under
Fable's 2x API price. Routing execution to Opus 5 halved the rate on the
most expensive part of a pass.

Four drivers, all confirmed by Geoff on 2026-08-21, reversed it. Opus 5
execution sessions made poorer dispatch and triage calls than the plan
quality deserved. The plan-approval handoff (fresh session, resume prompt,
re-reading artifacts) cost attention and tokens. Passes should run longer
without Geoff present. The Fable allowance has not been the constraint in
practice.

Fable now conducts a coding project from brainstorm through post-mortem in
one session. The plan-approval gate stays the single human gate; it is no
longer a model boundary. The handoff to a fresh Opus 5 session is gone.

**The conductor is thin.** During execution, Fable never reads a source
file, a diff, a test log, or a gate transcript. It consumes structured
reports from agents and makes only the decisions that need judgment: accept,
re-dispatch with a correction, split, upshift, stop. A conductor caught
reading diffs or grinding edits inline flags itself and dispatches.

**The per-task chain replaces the conductor's own diff read.** Each plan
task runs implementer, then diff reviewer, then gate. The repo's
Sonnet-pinned implementer returns a fixed shape: files touched, gate result,
decisions the plan did not cover, anything it could not do. The
`diff-reviewer` agent (`claude-opus-5`) takes the task's acceptance criteria
and the implementer's report, reads the diff, and returns a verdict (accept,
fix, escalate) with blocking findings at `file:line`. One re-dispatch on
`fix`; a second `fix` verdict goes to the conductor as a decision. The
repo's full gate runs inside the chain, never in the main loop. Domain
reviewers (svelte, a11y, security, workers) still fan out at pass end.

## The allowance fact (verified 2026-08-21)

On Max, Fable 5 draws from the same weekly pool as every other model and may
consume up to 50% of it. Past that cap, usage falls to credits at API rates
or a model switch. The help page states no per-model weighting, and none
could be verified
(https://support.claude.com/en/articles/15424964-claude-fable-5-on-your-plan,
verified 2026-08-21).

The 50% cap on the weekly pool is the binding constraint, not API price. The
design that follows from it minimizes Fable's context size, never the
number of Fable turns: a thin conductor that reads structured reports
instead of diffs spends less pool per turn, so it can run more turns before
hitting the cap.

## Beyond the allocation: the overflow playbook

Beyond the weekly allocation, Fable runs on usage credits at API rates
($10/$50). `~/.claude/docs/fable-post-cutoff-system.md` governs this as the
OVERFLOW playbook: batch-first (50% discount), per-dispatch one-shots, and
the SUGGESTION RULES baked there (never silently spend Fable credits, never
silently absorb Fable-tier work; propose job + mode + size in one sentence
and let Geoff decide).

## The self-check, with its origin incident

The self-check inverts under a Fable conductor. A conductor caught reading
a source file, a diff, a test log, or a gate transcript during execution, or
grinding mechanical edits inline, flags itself immediately and dispatches
the work to the appropriate agent instead of continuing to do it inline.

This rule's root incident predates the inversion but still names the
failure mode it guards against: an ecxc session silently burned ~1M tokens
on 2026-07-13 doing execution-shaped work in the main loop. The flag came
from Geoff, not the conductor. That order, Geoff catching it instead of the
conductor self-reporting, is the defect the self-check exists to close.

## Pass sizing: the poplar 1b narrative

CLAUDE.md's Pass sizing rule states the practice; this is the incident that
produced it. Geoff has no direct insight into when a pass is overloading.
He sees per-item summaries in which every addition reads as small and
adjacent; the orchestrator holds the whole dispatch list. Detecting
accumulation and raising it unprompted is the orchestrator's duty, and a
pass that quietly doubles costs far more than one split early. Three
failure modes, all named from poplar pass 1b:

- **A grant is not headroom.** "Use a workflow", "we can spread this over
  several passes", "you have latitude" authorize a mechanism or a boundary,
  never more work. Restate what a grant does and does not authorize before
  acting on it.
- **Accretion by adjacency.** Work joins a task because it sits next to what
  that task already does. Each addition is defensible alone and none is
  weighed against the total. Pass 1b's conformance task took a coverage
  ledger, an unowned method, two doc corrections and two late defect fixes
  on top of a full plate, and Geoff had to raise the size question twice
  before the orchestrator said anything.
- **Splitting tasks instead of splitting the pass (Geoff, 2026-07-30).** A
  pass can be split at a logical point, and repeated task splits are the
  signal that it should be. Pass 1b split task 6 into 6a/6b, task 7 into
  7a/7b and task 11 into 11a/11b, turning twelve planned tasks into fifteen.
  Every split was individually correct; each was made because that task had
  outgrown its own written boundary. The orchestrator read them as three
  separate incidents and never considered splitting the pass, until Geoff
  asked whether it had run too long. Splitting a task keeps the work inside
  the pass; only splitting the pass lets work leave, which is why
  task-splitting is the more comfortable move: it looks like sizing
  discipline while changing nothing about the commitment.

Practice: count your own splits before answering "is this pass too long".
The count is the evidence and it is sitting in your dispatch history. A
second task split inside one pass is the prompt to propose splitting the
pass; a third means the proposal is overdue. A pass that exists because its
predecessor burst its scope is already on notice and gets watched harder,
not less. When proposing, name the cut point (usually the last clean
self-contained task), name what each half carries, and give the follow-up
pass a number rather than leaving its work homeless. Also: state a task's
deliverable count when dispatching it, and say plainly when it passes
roughly four distinct deliverables or when anything is added after
dispatch. Route discovered work to the pass that first leans on it, not the
pass that found it. Prefer turning a discovered artifact into a standing
input that later passes consume over making it a task now. Never add scope
to a task already in flight unless it would otherwise build against
something known wrong, and say so explicitly when doing it. Closing out and
refreshing beats pushing a long session further: both output quality and
token cost favor the clean boundary.

## Research basis (2026-08-21)

- Anthropic's multi-agent research system
  (https://www.anthropic.com/engineering/multi-agent-research-system): the
  lead runs on the frontier model, workers run cheaper, and the pattern
  still costs about 15x a single agent's tokens.
- When and how to use multi-agent systems
  (https://claude.com/blog/building-multi-agent-systems-when-and-how-to-use-them):
  split work by information boundary, not by task count.
- Sub-agents docs (https://code.claude.com/docs/en/sub-agents): a fresh
  (non-fork) subagent returns only its final message to the caller.
- Workflows docs (https://code.claude.com/docs/en/workflows): intermediate
  results stay in script variables rather than the caller's context; the
  tool's cost warning is advisory, not a hard limit.
- Model config docs (https://code.claude.com/docs/en/model-config): `effort`
  is set per agent and is cheaper to tune than a model swap.
- GitHub issue 41143
  (https://github.com/anthropics/claude-code/issues/41143): `maxTurns` is
  documented but not reliably enforced.
