# Claude Infrastructure Pre-Pass

A charter for a fresh-context session. Read this top to bottom, then run it.

**Authorization (Geoff, 2026-05-28):** run this pre-pass first, before any cairn rebuild
execution. Touch whatever improves cairn performance, including global workstation config;
cross-project benefit is a welcome bonus. Go straight to action within the guardrails below.
These decisions are settled, so do not re-ask them.

## Purpose

Tune this workstation's Claude Code setup to best support building cairn-cms, which is about to
be rebuilt cleanly and test-first across nine plans. Use Opus 4.8's research strength to ground
every change in current (2026) best practice rather than habit. The trigger was the new model, not
any known deficiency, so treat this as an opportunity to raise the floor.

## Read first, then confirm nothing changed

- Memory `cairn-rebuild-initiative` (loads automatically) for the rebuild's shape and roadmap.
- Memory `cairn-auth-self-owned-d1-magic-link` and the prose-voice memories.
- Spec: `~/Projects/cairn/cairn-cms/docs/superpowers/specs/2026-05-28-cairn-rebuild-functional-spec.md`.
- Plan 00: `~/Projects/cairn/cairn-cms/docs/superpowers/plans/2026-05-28-cairn-rebuild-00-foundation.md`.

Do not start rebuild execution. That is a later session, beginning at Plan 00. This pre-pass only
improves the tooling that session will use.

## Guardrails

- Apply directly, then show the result as a `git diff` summary: CLAUDE.md accuracy, additive
  skills and subagents, MCP configuration, safe and common dev-command permission entries,
  research-orchestration habits, and additive non-disruptive hooks. Almost everything here is
  git-tracked through the dotfiles repo and therefore reversible.
- Propose first, apply only on an explicit yes: permission entries that carry security or
  destructive weight (anything beyond read-only or common safe dev commands); removing or
  rewriting an existing working skill or hook; any hook that fires on every edit or stop and could
  disrupt all sessions.
- Never commit secrets, never force-push, never grant broad wildcard permissions.

## Environment facts (verified 2026-05-28)

- `~/.claude/settings.json` is a stow symlink into `~/.dotfiles/claude/.claude/settings.json`
  (tracked in the `glw907/workstation` repo). `~/.claude/settings.local.json` is a real
  machine-local file (untracked). `~/.claude/CLAUDE.md` is likewise a stow symlink into the
  dotfiles `claude` package.
- `~/.claude/agents` exists but is empty, so custom subagents are greenfield.
- Hooks are configured inside `settings.json`, not in a hooks directory.
- MCP servers reach the session through the claude.ai connector (the deferred-tools list shows the
  Cloudflare Developer Platform, Gmail, Google Calendar, and Google Drive). There is no
  `~/.claude/.mcp.json`; investigate where MCP config actually lives before changing it.
- Dotfiles workflow: edit the source under `~/.dotfiles/claude/.claude/...`, then `cd ~/.dotfiles
  && stow -R claude`, then commit in the workstation repo. Adding a tracked script means copying it
  into `~/.dotfiles/bin/.local/bin/` and `stow -R bin`. The sync script is
  `~/.dotfiles/sync-dotfiles.sh`. `sudo -A` decrypts automatically via `claude-askpass`.
- `prose-guard` gates any documentation prose written (it rejects em dashes, anaphora runs of three,
  and the banned-word set). The `writing-voice` output style is always on, so it governs this work too.

## Method

Run it as its own small cycle. Going straight to action is authorized, so the heavy
brainstorm-then-approve gate is not required for the low-risk changes; still research before
changing anything.

1. **Inventory.** Read `settings.json`, `settings.local.json`, the global and cairn `CLAUDE.md`
   files, the skills list (built-in plus `~/.claude/skills` and plugin skills), `~/.claude/agents`,
   `~/.claude/output-styles`, and the MCP situation. Note what exists and what cairn work will lean on.
2. **Research (parallel, strong model).** Fan out agents over the official 2026 Claude Code and
   Agent SDK docs and current best practice, one per surface: skills authoring, subagent
   orchestration and model selection, hooks, MCP for Cloudflare and GitHub and SvelteKit dev,
   settings and permissions, and research orchestration (Workflow, parallel agents, deep-research).
   Each agent returns cited findings and concrete recommendations.
3. **Gap analysis.** Turn findings into a concrete change set, each item mapped to the cairn benefit
   and tagged apply-directly or propose-first per the guardrails.
4. **Implement.** Use `update-config` for settings and hooks, `fewer-permission-prompts` for the
   allowlist, `skill-creator` for new skills and agents, and direct edits for CLAUDE.md and docs.
   Honor the dotfiles workflow above. Commit each logical change.
5. **Verify.** `settings.json` stays valid JSON; new hooks fire; new skills and agents load; any docs
   pass `prose-guard`; dotfiles are stowed and committed; a quick sanity check that the cairn
   workflows still run.

## Candidate changes (hypotheses to validate by research, not prescriptions)

- A permissions allowlist for the rebuild's repetitive commands (npm, vitest, wrangler, svelte-check,
  `git status`/`diff`/`add`/`commit`, `gh`), to cut prompt friction across all nine plans.
- Reconsider `CLAUDE_CODE_SUBAGENT_MODEL=sonnet` (set in `.bashrc`). Research-heavy and review
  subagents may warrant Opus 4.8 while cheap fan-out stays on sonnet. Decide per role rather than one
  global value if the harness allows per-agent model selection.
- Custom review subagents for this exact stack: a Svelte 5 / SvelteKit idiom reviewer, a Cloudflare
  Workers reviewer (bundle size, startup limits, D1), a DaisyUI and accessibility reviewer, and a
  security reviewer (auth, cookies, CSRF). Wire them into the rebuild's code-review step.
- Confirm the Cloudflare Developer Platform MCP works in this setup and document its use for the
  rebuild's D1 provisioning. Check the GitHub surface.
- CLAUDE.md currency: the model is now Opus 4.8; verify the go-conventions, elm-conventions, and ship
  references; confirm the dotfiles, stow, and prose-voice notes hold. Keep durable orientation lean and
  let memory carry the rebuild detail.
- Lean harder on Workflow and parallel-agent research and the deep-research skill, given the stronger model.
- Consider an additive hook that runs `svelte-check` or `vitest` in the rebuild worktree on stop. Evaluate
  disruption first; this is a propose-first item.

## Done when

The change set is implemented (or proposed where a guardrail applies), committed, the dotfiles are
stowed and synced, and the result is verified. Write a short closing summary back into a memory (or
update `cairn-rebuild-initiative`) so the rebuild-execution session inherits the improved setup.
