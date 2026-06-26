---
name: cairn-pass
description: >
  Invoke at the start or end of a plan in the cairn-cms rebuild, the embedded
  magic-link, GitHub-committing CMS library for SvelteKit/Cloudflare sites
  (numbered plans 00 through 08 plus the later named plans). The canonical source is
  the functional spec at cairn-cms/docs/superpowers/specs/2026-05-28-cairn-rebuild-functional-spec.md;
  the plans live in cairn-cms/docs/superpowers/plans/. Trigger on "start/execute/implement
  plan <N or name>", "continue", or "next plan" when the work is cairn-cms; this is also
  the entry point for a fresh session resuming a plan after a context clear. For a site's
  OWN roadmap (ecnordic/907-life numbered passes) use site-pass.
---

# Cairn Pass (cairn-cms rebuild)

The cairn-cms library is being rebuilt test-first as a numbered plan series, 00
(foundation) through 08 (scaffolder). The canonical source of truth is the
functional spec, which supersedes the older plan and architecture writeups now kept under
`docs/internal/history/`.
Each plan is written just-in-time after the prior one lands, under
`cairn-cms/docs/superpowers/plans/`.

The rebuild (plans 00 through 08) has landed and merged to `main`; stable `0.6.0` shipped
and both sites run it. Later engine work (public delivery, the CairnExtension dispatch, the
scaffolder) runs on a feature worktree off `main`. The current state, the branch topology, and
the open decisions live in `cairn-cms/docs/STATUS.md`, which this skill reads at pass-start and
updates at pass-end. Honor `cairn-cms`'s own `CLAUDE.md` and skills.

> **Which skill?** This is for the cairn-cms library rebuild. If the user means a
> site's own numbered passes (ecnordic-ski / 907-life roadmap), use **`site-pass`**.

## Starting a plan

This is the entry point at plan start, whether continuing in the session that wrote the
plan or resuming cold after a clear or a crash. STATUS.md's "immediate next action" line
names the plan to execute and the method; trust it and the plan file rather than
re-deriving the design.

1. **Read `cairn-cms/docs/STATUS.md`** for the current state and open decisions, the
   **functional spec** (sections relevant to the plan) for the locked decisions and
   architecture, and **the plan file in full** for the task-by-task steps and exit criteria.
2. Confirm you are in a feature worktree off `main`, not the `main` checkout itself.
   STATUS.md lists the active worktrees.
3. Execute task-by-task by dispatching each well-specified task to `cairn-implementer`
   (pinned Sonnet for token economy). The suite is the acceptance contract: the implementer
   writes or confirms the failing test first, makes it green, and clears the full gate
   (`npm run check` 0/0, `npm test` exit 0); the main loop reviews the diff and verifies the
   gate result before the next dispatch. Implement inline, or upshift the dispatch
   (`model: opus` / `model: fable`), only for novel correctness-critical logic the plan does
   not fully specify.
   When most of a plan's tasks are independent, suggest orchestrating them with the
   Workflow tool and let the user opt in.

> **Legacy discipline.** The frozen `legacy/` build only ever got smoke tests, not real
> use, so it is an accelerator and a behavioral reference, not a proven artifact to
> preserve. Port pure, framework-agnostic logic from it to move fast, but hold everything
> to the rebuild's current standards (Svelte 5 runes, DaisyUI v5, the a11y bar) and prove
> it with our own tests. Re-derive UI and framework-coupled code clean rather than copying
> legacy markup; copying v4/better-auth-era assumptions forward is what the Plan 05 review
> gate had to undo.

## Ending a plan: consolidation ritual

No plan is done until every step has run.

### 1. Simplify

Dispatch the code-simplifier agent over the code changed this plan. Use
`subagent_type` = **`code-simplifier:code-simplifier`** (the bare name errors).
Docs-only plans skip this.

### 2. Check and test

Run `npm run check` (svelte-check, 0 errors and 0 warnings) and `npm test` (the
unit, integration, and component projects; the integration layer runs in workerd
against a real miniflare D1, the component layer in a real browser). Green is the
bar, and that means `npm test` **exits 0**: a passing assertion count is not enough,
since an unhandled rejection can leave every test green while the process exits 1.
Fix every failure before continuing.

Then run `npm run check:comments` (the ESLint TSDoc + em-dash gate over `src/lib`). The
`cairn-implementer` gate and `npm run check` (svelte-check) do **not** cover it, so a TSDoc structure
slip (a multiline `/**` with text on the first line, a stray `{type}` tag) passes every other gate and
only fails on CI. Run it here, with the from-scratch consumer build, before calling a pass done. This
gate, and `check:reference:signatures` in step 5, are the two CI-only checks an `0.62.0`-era pass shipped
red because the local ritual skipped them.

**Prove the consumer build, not only `npm test`.** The package ships TypeScript inside its `.svelte`
files, so a consumer-bundler incompatibility (a Vite 8 / Rolldown parse failure, an import-resolution
gap) surfaces only when a consumer builds, never in the library's own `npm test`. The showcase e2e is
that gate: `npm --prefix examples/showcase run test:e2e` builds the showcase, then runs Playwright. Off
CI, local Playwright reuses a stale preview server (`reuseExistingServer` is on when `CI` is unset), so a
local "all green" can pass against a stale build. Before calling a pass releasable, either push the
branch for a CI `e2e` run or force a from-scratch consumer build: `rm -rf
examples/showcase/{node_modules,package-lock.json}`, then a fresh install and `npm run build`. This is
how `0.60.0` shipped a broken consumer build; see the `cairn-0-60-e2e-dist-build-failure` memory.

### 3. Review gate

Fan out the relevant review subagents in parallel and fold their findings in
before committing. Match the subagent to what the plan touched:
`svelte-reviewer`, `cloudflare-workers-reviewer`, `web-auth-security-reviewer`
(always for auth, session, cookie, token, or signing changes),
`daisyui-a11y-reviewer`. They complement `/code-review`, not replace it.

### 4. Live admin smoke

For any plan touching the `/admin` surface, run the live admin smoke against a
real Worker (`wrangler dev`). Under the rebuilt self-owned auth, mint a session
by inserting a D1 session row directly (no better-auth cookie, no email loop);
the final magic-link click in a browser stays a user step. Follow
`cairn-cms/docs/internal/admin-smoke-test.md`. Record results as evidence. Skip for plans that do not touch `/admin`.

### 5. Documentation

Documentation is a pass dimension, not a follow-up. Before the pass is done, update the docs for
whatever it changed. The standing principle is that docs stay current and never drift, so a pass
fixes every doc its change touched, including the inbound references on other pages.

- Update the relevant `docs/` arm: the reference page for any public-API change, and the guides,
  explanation, or tutorial as the change touches them. Update `CHANGELOG.md` and the upgrade guide
  (`docs/guides/upgrade-cairn.md`) for any **behavior** change, not only a rename, with a short
  per-version entry. The "Consumers must:" convention below applies to the changelog; a behavior change
  that needs no consumer action still gets an entry that says so, so an upgrader who hits it has a
  reference.
- **Hunt drift on a removed or renamed symbol.** When a pass removes a symbol from the public surface
  or renames it, the reference page is not the only place that names it. `grep -rn` the whole `docs/`
  tree (and `README.md`) for the old name and any reference anchor (`core.md#<oldname>`), and repoint
  or rewrite every hit. The reference-coverage gate does not catch a stale inbound link.
- **Run all four doc gates.** `npm run check:reference` (the export-coverage gate fails on an
  undocumented export), `npm run check:reference:signatures` (the documented signature must match the
  real exported type, so a member added to an exported function's return, like `helpLoad` on
  `createContentRoutes`, fails until the reference signature carries it), `npm run check:package` (the
  entry-point shapes), and `npm run check:docs` (the link gate, which fails on a dead relative link or a
  stale `#anchor` anywhere under `docs/`). All four must pass. `check:reference:signatures` is CI-only
  and easy to skip locally, so run it by name here. A public-API change is not done until its reference
  page matches and no doc links to a name the pass removed.
- Append any design friction the writing surfaced to `docs/internal/docs-friction-log.md`, one entry
  per finding with its perspective (developer or editor) and a short note. Triage candidates into
  `ROADMAP.md` (Now or Next) and the STATUS carry-forwards. This repo keeps no separate backlog file.
- Keep `ROADMAP.md` current, the same as the reference docs. A pass that shipped a roadmap item marks it
  done and removes it from the live tiers; a pass that surfaced a new direction files it into the right
  tier. The roadmap is a forward view, not a changelog: shipped history lives in STATUS and the
  post-mortems. A backlog file only ever appended to drifts heavy and resurfaces dead work (the
  hardening initiative had to prune a stale friction log for exactly this), so prune as you go.

A docs-only pass skips the engine check and test (step 2) but still does this step, including the doc
gates. See the `docs-is-a-pass-dimension` memory.

### 6. Update tracking

Append the post-mortem to the active plan file (what was built, what was verified
with evidence, decisions locked in, blockers). Then update `cairn-cms/docs/STATUS.md`,
the canonical rolling status, with where the work is now, what is next, the open
decisions, and the carried follow-ups. STATUS.md lives on `main`, so update it there as
part of the merge. Durable cross-cutting gotchas stay as focused `cairn-*` memories, and
locked architecture decisions stay in the functional spec. Do **not** write cairn state
into a consumer site's `STATUS.md`; that is the site's own.

**Changelog convention (enforced).** If the pass made any breaking change to the public
surface, its `CHANGELOG.md` entry must carry a `Consumers must:` line per breaking change,
stating the concrete consumer action (the rename, the moved import, the new required
argument). A non-breaking change needs no such line. This convention exists so a site
crossing several `0.x` versions reads the actions off the changelog instead of
rediscovering each rename. The `0.x` changes also accumulate in the upgrade guide
(`docs/guides/upgrade-cairn.md`), one per-version entry each; add the pass's entry there too,
for a behavior change as well as a rename.

**Release notes (on publish).** Every publish ships a GitHub Release, and its body is the
changelog window since the last published tag, not an empty release. When a publish rolls
several held minors into one (the common case in this initiative), the release body summarizes
each minor in the window and carries every `Consumers must:` line from the breaking ones. The
release is also what fires the OIDC trusted-publishing workflow, so cutting it with real notes
is the publish step, not a chore after it. Cut it with `gh release create v<x.y.z> --target main`.

### 7. Commit

Commit in the cairn-cms feature worktree, following the repo's git conventions.
Simplify first (step 1), commit specific files, and push or merge only when the user
asks.

### 8. Draft the next plan (while context is warm)

Preferred, not skippable lightly. The just-landed pass is fresh now: its patterns,
carried follow-ups, and lessons are in context, and re-deriving them cold next
session is waste. So before stopping, draft the next plan. Run
`superpowers:brainstorming` first to settle the open design decisions with the user
(the spec locks most of it; surface only what it leaves open), then
`superpowers:writing-plans` to author the numbered plan file. Keep the
design-and-approval gate: never auto-write a plan without the user's calls on the
open decisions. The plan stays revisable next session. Skip only when the next pass's
direction is unsettled or the user wants to stop here.

### 9. Pre-bake, then continue in this session

Plan and execution share the session by default; a plan written here gets executed here. The
pre-bake still happens first, as insurance against a crashed or interrupted session rather
than as a handoff. Do **not** run the `superpowers:writing-plans` "which execution method?"
question (main-loop execution is the default).

- **Pre-bake the durable artifacts.** Commit the plan (push if the user wants it pushed).
  Update STATUS.md so its **immediate next action** line names the new plan, its path, and
  the method (main-loop execution, test-first, full gate per task, on a worktree off `main`).
  Refresh the relevant `cairn-*` memory so a cold session recalls the initiative. Leave the
  tree clean. Anything load-bearing must live in the plan, the spec, STATUS.md, or memory,
  never only in the conversation.
- **Then proceed straight into "Starting a plan" above**, in this same session.

Recommend a context clear only when the session that produced the plan ran long and noisy
(a sprawling brainstorm, several dead ends). In that case give the exact resume prompt and
the launch directory (inside `cairn-cms`, so its hooks and memory load). Example: "Execute
the component grammar plan (`docs/superpowers/plans/<file>.md`)." See the
`clear-context-before-implementing-plans` memory for this default's history.

## Execution discipline (lessons from Plan 07)

- **One implementer per dispatch, verified.** When dispatching `cairn-implementer` (parallel
  independent tasks, or a worktree-isolated change), wait for each result and verify its commit
  (git log and status) before depending on it. On an API overload or 5xx, wait and retry once
  deliberately; never fire a second dispatch while one may still be in flight, because a cleared
  overload fires every queued retry at once. See the `plan-execution-dispatch-discipline` memory.
- **Verify a plan's locked build assumptions.** When a plan locks a packaging, build, or
  module-resolution mechanism (for example `publishConfig.exports`, an export condition, or a
  source-to-`dist` swap), confirm it against the real toolchain at the first task that touches it
  rather than trusting the lock. Plan 07's locked `publishConfig.exports` swap did not work on
  npm 11.
- **Vale findings are tiered.** The `vale-hook` drives a fix only on an error-tier finding (exit 2);
  warnings and suggestions ride along as advisory context. Do not gate commits or spend effort on the
  advisory tier, especially when it sits in a doc's pre-existing body.
- **Suggest the Workflow tool at the right moments.** It runs only on the user's explicit
  opt-in ("use a workflow"), so name the moment when it would pay off, including the review
  gate of a large pass (an adversarial find-and-verify sweep catches more than the flat
  reviewer fan-out), a plan whose tasks are mostly independent, and a repo-wide audit or
  migration. One sentence naming the shape and rough scale is enough.

## When NOT to use

- A site's own numbered passes: use `site-pass`.
- Mid-plan debugging or single-file edits.
