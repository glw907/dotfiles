---
name: content-draft
description: "Draft website content (pages, posts, form copy) audience-first. Use BEFORE writing any new site page, post, or form copy, or when the user says \"draft a page\", \"write the X page\", \"write a post\", \"write copy for\". For website content only, NOT code, docs, specs, or commit messages. Loads the shared web-content method and the site's content-guide voice."
user_invocable: true
---

# Content Draft

Drive website-content drafting from the audience outward. This skill is for the web-content
register only. For code comments, docs, specs, or commit messages, use the technical voice instead.

Load the shared method at `~/.claude/docs/web-content-method.md` and the site's
`docs/content-guide.md`. Then work the steps in order.

## Steps

1. **Audience and purpose brief, first.** State, in writing, who the piece serves (for ecnordic,
   high-school athletes and their parents, usually both at once), what they already know, what they
   need or worry about, where and how they will read it, and the one action or takeaway it must
   land. If any of these is unknown, ask the user. Do not draft prose before this brief exists.

2. **Gather the concrete facts.** Pull the real specifics from the content-guide canonical facts:
   places, dates, schedule, gear, cost, sign-up. If a needed fact is missing, ask rather than invent.

3. **Load the register and its exemplars.** Read the off/on-voice exemplar pairs in the method doc
   and the site voice in the guide. The exemplars are the primary style control. Match them. The
   banned-word list is a backstop enforced by prose-guard, not your main lever.

4. **Outline, then critique the outline.** Write the headings and the one or two sentences each
   section must carry. Check the outline against the brief. Fix a weak structure here, before prose.

5. **Draft.** Write audience-first and concrete, matching the exemplars, with varied sentence and
   paragraph length. Use contractions. Let one-sentence paragraphs stand.

6. **Self-check.** Run the self-check from the method doc. If you used a banned word, flag it in your
   response with a one-line justification.

7. **Offer the score.** Offer to run the content-review skill before saving or committing.

## Hard rules

- The brief comes first. A draft with no stated audience is a failure of this skill.
- Ask for missing facts. Never invent a place, date, cost, or quote.
- This is website content. Do not apply it to code, docs, specs, or commits.
