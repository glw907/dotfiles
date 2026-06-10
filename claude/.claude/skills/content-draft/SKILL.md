---
name: content-draft
description: "Draft website content (pages, posts, form copy) brief-first. Use BEFORE writing any new site page, post, or form copy, or when the user says \"draft a page\", \"write the X page\", \"write a post\", \"write copy for\". For website content only, NOT code, docs, specs, or commit messages. Loads the shared web-content method and the site's generative content guide."
user_invocable: true
---

# Content Draft

Drive website-content drafting from a structured brief through the site's generative guide. This
skill is for the web-content register only. For code comments, docs, specs, or commit messages,
use the technical voice instead.

Load the shared method at `~/.claude/docs/web-content-method.md` and the site's
`docs/content-guide.md` (the generative authority: load-bearing rules, container budgets, and a
recipe per content type). If the site has a voice corpus (the guide names it), read the entries
nearest the piece. Then work the steps in order.

## Steps

1. **Build the brief, first.** Write it to `docs/content-briefs/<piece>.md` in the site repo.
   Four parts, no prose: the verifiable facts (every place, time, date, name, cost, and rule the
   piece will state), the audience questions the piece must answer, the one next step, and the
   container plan (which UI containers the prose renders into, from the site's directive
   vocabulary). Mark every unknown as `[ASK: question]`. Do not draft before the brief exists.

2. **Draft recipe by recipe.** Each container in the plan gets its recipe's shape and its budget
   from the guide. Imitate the recipe exemplars' stance and density, never their wording. Carry
   every `[ASK]` from the brief into the draft verbatim; never pad around a gap, and never invent
   a place, date, cost, or quote. Vary the shapes: sentence counts, bullet architectures,
   paragraph sizes.

3. **Self-check.** Run the method's self-check, plus the brief checks: every brief fact landed
   exactly once, every `[ASK]` survived visibly, no container over its budget.

4. **Offer the gate check.** Offer to run the content-review skill before saving or committing.

## Hard rules

- The brief comes first and is a committed file, not a thought. A draft with no brief is a
  failure of this skill.
- A gap is an `[ASK]`, never padding. Drafting never blocks on the user.
- Budgets are layout constraints, not suggestions. An over-budget container is a bug.
- This is website content. Do not apply it to code, docs, specs, or commits.
