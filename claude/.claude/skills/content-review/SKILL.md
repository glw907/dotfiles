---
name: content-review
description: "Review and score website content (pages, posts, form copy) against the audience-first rubric, then propose per-sentence fixes. Use after drafting or editing site content, before committing, or when the user says \"/content-cleanup\", \"clean up this content\", \"check for AI tells\", \"editorial pass\", \"review this page\", \"score this copy\". For website content only. Takes a file path."
user_invocable: true
---

# Content Review

Score a website-content file against the rubric and propose fixes. Run this as a fresh review of the
file, not as a continuation of the context that drafted it. Independent rubric-guided review is the
reliable form; self-critique in the drafting context is not.

Load the shared method at `~/.claude/docs/web-content-method.md` (the rubric, the level anchors, the
gold set) and the site's `docs/content-guide.md` (the voice).

## Steps

1. **Read** the target file, the content-guide, and the rubric with its level anchors.

2. **Run prose-guard** on the file for the machine signals:
   `prose-guard <file>`
   It reports burstiness, banned words, structural tells, and the advisory sweep. These feed the
   cadence and AI-tell dimensions. They are inputs, never the verdict.

3. **Score the seven dimensions** against their 0-to-5 level anchors. The machine signals feed
   cadence and AI-tell freedom. Agent judgment scores audience fit, concreteness, voice, structure,
   and key-fact clarity. Compute the raw score, then the normalized score (raw times 100 over 60).

4. **Check the hard gates:** a banned word or phrase, an unverified or fabricated claim, a
   safety or standard-of-care promise, a cost misstatement. Any hit blocks publish.

5. **Decide the band:** Publish (80+, no gate hit), Hold (60 to 79), or Redraft (below 60).

6. **Report, band first.** Lead with the band. Then the hard-gate status. Then the score table.
   Then a per-sentence findings list. Each finding quotes the sentence, names the specific pattern,
   proposes a replacement, and gives a one-line reason. If nothing is flagged, say so.

7. **Apply only approved edits.** Ask "apply all, apply some (specify), or skip?". Edit only the
   approved sentences. Change nothing else. Never change meaning to fix rhythm; flag those as needing
   human judgment and skip.

## Hard rules

- The band leads; the 0-to-100 number is secondary.
- Cite a named pattern or leave the sentence alone. No "improved the flow" rewrites.
- Re-check each proposed replacement against the catalog before presenting it.
- This is website content. Do not apply it to code, docs, specs, or commits.
