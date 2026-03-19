---
name: asc-doc-review
description: Review session for documentation opportunities (ASC/handbook projects)
---

Review this session's transcript for documentation opportunities.

## Guidelines

**Only suggest documenting if ALL these apply:**
1. It's an architectural decision, troubleshooting discovery, useful pattern, or operational procedure
2. It's NOT obvious from code
3. It would help future sessions or future administrators
4. It isn't already captured in an existing handbook page or CLAUDE.md

**Be conservative** — over-documentation wastes tokens and reduces performance.

## Decision Framework

**Where to document:**

| What | Where |
|------|-------|
| Architectural decisions, troubleshooting discoveries, integration details, infrastructure procedures | Handbook technical section (`handbook/content/technical/`) — edit the relevant existing page |
| Operational procedures for volunteers (how to use the CMS, ops dashboard, MembershipWorks, Google Workspace) | Handbook user section (`handbook/content/user/`) — edit the relevant existing page |
| Critical constants that must be immediately visible every session (API key locations, org IDs, webhook IDs) | CLAUDE.md "Critical Constants" section |
| Short workflow conventions used every session (commit style, deploy commands) | CLAUDE.md "Common Operations" section |
| Cross-session factual memory too short for a handbook page | MEMORY.md |
| GitHub issue tracking conventions, things that don't fit handbook audience | `docs/` (rare) |
| Cross-site patterns (DNS, Cloudflare API) | `~/Projects/cloudflare-sites/CLAUDE.md` or its `docs/services/` |
| One-off fixes, incidental decisions | Don't document |

**Handbook routing quick reference** (matches CLAUDE.md maintenance table):

- CSS, templates, shortcodes → `handbook/content/technical/website/patterns.md`
- Site architecture → `handbook/content/technical/website/architecture.md`
- Site operations / deploy → `handbook/content/technical/website/operations.md`
- Cloudflare services → `handbook/content/technical/infrastructure/cloudflare-setup.md`
- Membership workflow → `handbook/content/technical/infrastructure/membership-workflow.md`
- MembershipWorks admin settings → `handbook/content/technical/infrastructure/membershipworks-config.md`
- Notification routing (primary) → `handbook/content/technical/infrastructure/notifications.md`
- Discord notifications → `handbook/content/technical/infrastructure/discord.md` + notifications.md
- Email routing → `handbook/content/technical/infrastructure/email.md` + notifications.md
- Ops dashboard features → `handbook/content/technical/ops-dashboard/architecture.md`
- Ops dashboard design → `handbook/content/technical/ops-dashboard/design-guide.md`
- Ops dashboard automated testing → `handbook/content/technical/ops-dashboard/automated-testing.md`
- CSS verification lessons → `handbook/content/technical/reference/css-verification.md`
- Icon assignments → `handbook/content/technical/reference/icon-vocabulary.md`
- Integration map → `handbook/content/technical/reference/integrations.md`
- Website editorial standards (voice, tone, posts, pages) → `handbook/content/style-guides/website-content.md`
- Handbook user doc writing standards → `handbook/content/style-guides/user-docs.md`
- Handbook technical doc writing standards → `handbook/content/style-guides/technical-docs.md`

## Process

1. Review the session transcript
2. Identify 0-3 items worth documenting (be strict)
3. For each item, determine the correct destination using the framework above
4. For handbook destinations:
   - If the destination is under `handbook/content/user/`: read `handbook/content/style-guides/user-docs.md` first
   - If the destination is under `handbook/content/technical/`: read `handbook/content/style-guides/technical-docs.md` first
   - Read the target file to find the right section, then propose the addition as a diff (may be a new paragraph or subsection, not just 1-2 lines)
5. For CLAUDE.md / MEMORY.md: propose a concise addition (1-3 lines)
6. Ask for approval before making any changes
7. Only update files after explicit approval

## Output Format

If you find something worth documenting:

```
Found N item(s) worth documenting:

1. [Brief description]
   → Add to: [absolute file path] — [section name]
   → Why: [reason — what future problem this prevents]

Proposed change:
[show diff]

Approve? (yes/no)
```

If nothing significant:

```
No significant documentation opportunities found. Session focused on [brief summary].
```
