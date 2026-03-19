---
name: ui-polish
description: >
  Full visual quality audit for aksailingclub.org or ops.aksailingclub.org.
  Covers color usage, spatial hierarchy (Gestalt grouping), spacing rhythm,
  typography, touch targets, and responsive layout. Evaluates visually via
  screenshots (primary) and confirms root causes via code reading (secondary).
  Trigger on "UI polish", "visual audit", "design polish", "visual hierarchy",
  "color audit", "spacing issues", "how does X look", "mobile review",
  "responsive check", "mobile UX audit", "check how X looks on mobile".
---

# UI Polish Skill

Structured, evidence-based visual quality evaluation for the Alaska Sailing Club
site and ops dashboard. Each run: capture → analyze → plan → implement → verify.

Screenshots are the **primary source of truth**. Code reading confirms root causes
and catches non-visual issues (e.g., hardcoded hex that breaks in dark mode).

---

## Phase 1: Prompt for Target

Ask the user the following (one message; all optional except URL):

1. **URL** — Which page to evaluate? Offer defaults:
   - `https://aksailingclub.org` (main site homepage)
   - `https://ops.aksailingclub.org` (ops dashboard)
   - Or any specific path (e.g. `https://aksailingclub.org/members/waitlist/`)

2. **Scope** — Full page, or a specific element?
   - Full page (default)
   - A CSS selector (e.g. `table.waitlist-table`)
   - A plain-English description (e.g. "the navigation bar", "the event form")

3. **Focus areas** (multi-select; default = all):
   - Layout / spacing / visual grouping
   - Color usage and palette
   - Touch targets and mobile responsiveness
   - Typography and readability
   - Navigation patterns
   - Forms and inputs
   - Content density / information hierarchy

If the URL is `ops.aksailingclub.org/*`, CF Access auth is injected automatically.

---

## Phase 2: Capture Before Screenshots

**Always capture screenshots first, before touching any code.** These are the "before" baseline.
Even when resuming a session or continuing from a previous conversation, take fresh screenshots
before writing any fixes — the current state may differ from what you last saw.

Examine all screenshots thoroughly (Phase 3) before proposing or writing any changes.

Write the capture script to `/tmp/ui-polish-capture.js` and run from the ops directory.

### Breakpoints

| Name | Viewport (w×h) | Rationale |
|------|----------------|-----------|
| `small-phone` | 375×667 | iPhone SE — most constrained |
| `phone` | 390×844 | iPhone 14 / Android standard |
| `large-phone` | 430×932 | iPhone 14 Pro Max / large Android |
| `tablet` | 768×1024 | iPad portrait |
| `desktop` | 1024×768 | Small desktop / tablet landscape |

Screenshots saved to `/tmp/ui-polish/` as:
- `{breakpoint}-full.png` — full-page screenshot
- `{breakpoint}-element.png` — element screenshot (if selector given)

### Capture Script Template

Write the following to `/tmp/ui-polish-capture.js`, substituting `TARGET_URL`
and `ELEMENT_SELECTOR` (set to `null` if full-page only):

```javascript
const { chromium } = require('playwright');
const path = require('path');
const fs = require('fs');
const { execSync } = require('child_process');

const TARGET_URL = 'REPLACE_ME';
const ELEMENT_SELECTOR = null; // or 'css-selector-string'

const BREAKPOINTS = [
  { name: 'small-phone',  width: 375,  height: 667,  mobile: true  },
  { name: 'phone',        width: 390,  height: 844,  mobile: true  },
  { name: 'large-phone',  width: 430,  height: 932,  mobile: true  },
  { name: 'tablet',       width: 768,  height: 1024, mobile: true  },
  { name: 'desktop',      width: 1024, height: 768,  mobile: false },
];

const OUTPUT_DIR = '/tmp/ui-polish';
fs.mkdirSync(OUTPUT_DIR, { recursive: true });

// CF Access auth — injected automatically for ops.aksailingclub.org
const CF_CLIENT_ID = '355524dff8edea34539419e97c66a085.access';
const CF_CLIENT_SECRET = execSync(
  "bash -c 'source ~/.bashrc && echo -n $CF_ACCESS_CLIENT_SECRET'"
).toString().trim();

const isOps = TARGET_URL.includes('ops.aksailingclub.org');
const extraHeaders = isOps ? {
  'CF-Access-Client-Id': CF_CLIENT_ID,
  'CF-Access-Client-Secret': CF_CLIENT_SECRET,
} : {};

const MOBILE_UA = 'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1';
const DESKTOP_UA = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36';

(async () => {
  const browser = await chromium.launch();

  for (const bp of BREAKPOINTS) {
    console.log(`Capturing ${bp.name} (${bp.width}×${bp.height})...`);
    const context = await browser.newContext({
      viewport: { width: bp.width, height: bp.height },
      extraHTTPHeaders: extraHeaders,
      userAgent: bp.mobile ? MOBILE_UA : DESKTOP_UA,
      deviceScaleFactor: 2,
    });
    const page = await context.newPage();
    await page.goto(TARGET_URL, { waitUntil: 'networkidle', timeout: 30000 });

    // Full-page screenshot
    await page.screenshot({
      path: path.join(OUTPUT_DIR, `${bp.name}-full.png`),
      fullPage: true,
    });

    // Element screenshot (if selector given)
    if (ELEMENT_SELECTOR) {
      try {
        const el = await page.locator(ELEMENT_SELECTOR).first();
        await el.screenshot({
          path: path.join(OUTPUT_DIR, `${bp.name}-element.png`),
        });
      } catch (e) {
        console.warn(`  Element "${ELEMENT_SELECTOR}" not found at ${bp.name}`);
      }
    }

    await context.close();
  }

  await browser.close();
  console.log(`\nScreenshots saved to ${OUTPUT_DIR}/`);
})();
```

### Run Command

```bash
cd /home/glw907/Projects/aksailingclub-org/ops && node /tmp/ui-polish-capture.js
```

Playwright is installed in `ops/` — always `cd ops` before running.

---

## Phase 3: Analyze

Two complementary passes. **Screenshots are primary.** Code reading confirms root
causes and catches non-visual issues.

Lead with the two smallest viewports (375, 390) — they expose the most constraints.

### 3a. Visual Analysis (screenshots — primary)

Read each screenshot with the `Read` tool (multimodal).

#### Color

- Semantic color applied correctly?
  - Green = success / approval / active
  - Red = danger / delete / error
  - Blue = primary action / link
  - No semantic overloading (e.g., green used for "info")
- Color as sole differentiator? (accessibility: must pair with icon or label)
- Muted/de-emphasized colors used for secondary info (metadata, timestamps, helpers)?
- Palette internally consistent, or are there one-off hues?
- Contrast: body text ≥ 4.5:1, large text / UI components ≥ 3:1 (WCAG AA)

#### Spatial Hierarchy / Visual Grouping (Gestalt Proximity)

- Do related items cluster visually? Gap *within* a group < gap *between* groups.
- Name/title → subordinate details (contact info, metadata): does the subordinate
  block read as attached to its primary item?
- Card anatomy: clear visual separation between header / body / footer regions?
- Form fields: does each label + input + helper text read as a unit?
- Lists: items feel distinct without feeling disconnected?
- At small viewports: does grouping survive reflow, or do items orphan?

#### Spacing Rhythm

- Consistent spacing across the page, or some sections cramped / others loose?
- Spacing adapts at breakpoints — tighter at small-phone, more generous at desktop?
- Key elements have enough white space to breathe (visual importance via surrounding space)?

#### Typography

- Body text ≥ 16px (iOS auto-zooms inputs below 16px → layout shift)
- Secondary/caption text ≥ 14px; never below 12px
- Line height ≥ 1.4 for body; slightly tighter for headings
- Font weight variation reinforces hierarchy?

#### Touch Targets (mobile breakpoints only)

- Apple HIG: 44×44pt minimum; Material Design: 48×48dp; WCAG 2.5.5: 44×44px
- Adjacent target spacing ≥ 8px
- Check: buttons, icon-only controls, table row actions, nav links

#### Navigation

- Tabs, hamburger, bottom-nav: does the pattern serve the user's primary tasks?
- Active state clearly distinguishable?
- Tab labels visible (not icon-only) at phone width?

#### Forms and Inputs

- Input height ≥ 44px; full-width on mobile
- Correct `type` attributes (`email`, `tel`, `number`, `search`)
- Labels above inputs, not placeholder-only
- Submit button: full-width or prominently sized at phone width

#### Content Density

- Tables with >4 columns: is there a mobile strategy (scroll, hide, card)?
- Primary task reachable without scrolling at each breakpoint?
- Wide tables: does horizontal scroll have a visual affordance?

### 3b. Code Reading Pass (secondary — root-cause confirmation)

After visual findings, scan relevant source files to confirm root causes and
catch non-visual issues:

**Hardcoded colors outside the palette**
- Ops: `#` values not in the established semantic set (`#16a34a` green, `#dc2626` red,
  badge colors defined in design-guide.md)
- Main site: values not matching `custom.css` custom properties

**Dark mode gaps**
- Colors set via hardcoded hex instead of `--pico-*` variables won't adapt to
  `data-theme="dark"`

**Spacing inconsistencies**
- rem values that don't fit Pico's 20px-root scale (e.g., `0.3rem` = 6px where
  `0.25rem` = 5px or `0.375rem` = 7.5px would fit Pico's scale better)

**Missing CSS annotations** — new or modified blocks lacking:
- `/* PICO-OVERRIDE */` — changing a Pico default
- `/* PICO-EXTENSION */` — adding something Pico lacks
- `/* CUSTOM */` — pure app code

**Un-annotated `!important`** — values without `/* D:verified */` or `/* D:unverified */`

**Inline styles in template files** — any `style=` attribute other than
`style="display:none"` in `ops/src/templates/`

### Severity Classification

- **Critical** — functionality blocked or content unreadable
- **High** — significant friction; user likely to fail task or abandon
- **Medium** — noticeable awkwardness; workaroundable
- **Low** — polish / nice-to-have / code hygiene

---

## Phase 4: Present Findings + Confirm

Present each finding in this format:

```
### [Severity] Finding Title

**Breakpoints affected:** small-phone, phone
**What's wrong:** [concrete description with visual evidence]
**Principle:** [Gestalt proximity / Apple HIG / WCAG / Pico palette / etc.]
**Recommended fix:** [specific CSS change, class, or component substitution]
**Implementation:** [file to edit, section, exact change]
```

After all findings, ask:
> "Should I implement any of these? Say 'all', list specific numbers, or skip any
> you want to handle manually."

---

## Phase 5: Implement

For each approved fix, implement then re-capture affected breakpoints to confirm.

### Implementation Rules

#### Ops dashboard (`ops/src/templates/`)

- Never add `style=` attributes (except `style="display:none"`)
- Before writing a new class: grep `layout.js` for an existing equivalent
- All new CSS blocks in the `<style>` block in `layout.js`, tagged:
  - `/* PICO-OVERRIDE */` — changing a Pico default
  - `/* PICO-EXTENSION */` — adding something Pico lacks
  - `/* CUSTOM */` — pure app code
- New `!important` values: tag `/* D:unverified */` immediately; add to the upgrade
  checklist comment at the top of the `<style>` block
- Colors: use `--pico-*` variables; hardcode only for new named semantic colors;
  always include a `[data-theme="dark"]` override for hardcoded values
- Spacing: use rem values aligned to Pico's 20px root scale (Pico root = 20px)

#### Main site (`assets/css/custom.css`)

- Group new rules under the nearest relevant section comment
- Prefer custom properties (`--body-px`, `--section-end-spacing`, etc.) over magic numbers
- Document any new custom property with a comment
- No `!important` unless strictly necessary; annotate with reason if used
- Never edit `themes/blowfish/` — override in `layouts/` and `assets/css/custom.css`

### Verification Loop

After implementing fixes, run a full before/after capture at all breakpoints:

**Step 1: Preserve before screenshots**

Before re-running the capture script, copy the existing screenshots to `before-` prefixed
names so they aren't overwritten:

```bash
cd /tmp/ui-polish
for f in *.png; do cp "$f" "before-$f"; done
```

**Step 2: Re-capture all breakpoints**

Run the full capture script (all 5 breakpoints — do not narrow the `BREAKPOINTS` array).
This gives a complete before/after set across the entire responsive range, not just the
breakpoints that were the obvious targets of the fix. Fixes often have unintended effects
at other sizes.

```bash
cd /home/glw907/Projects/aksailingclub-org/ops && node /tmp/ui-polish-capture.js
```

**Step 3: Compare each breakpoint pair**

Read both files for each breakpoint with the `Read` tool and compare explicitly:

```
before-small-phone-full.png  →  small-phone-full.png
before-phone-full.png        →  phone-full.png
before-large-phone-full.png  →  large-phone-full.png
before-tablet-full.png       →  tablet-full.png
before-desktop-full.png      →  desktop-full.png
```

If an element selector was captured, compare those too.

**Step 4: Report**

For each finding that was implemented:
> "**[Finding]** — Before: [what was wrong]. After: [resolved / regression at {breakpoint} / still needs adjustment]."

Call out any breakpoint where the fix introduced a regression, even if the target
breakpoint looks correct.

**Step 5: Iterate if needed**

Max 3 attempts per finding before flagging:
> "This may need manual inspection — [describe what's blocking automated verification]."

### Common Ops Patterns

```css
/* Responsive table wrapper — PICO-EXTENSION */
.table-responsive { overflow-x: auto; -webkit-overflow-scrolling: touch; }

/* Touch-friendly button — PICO-EXTENSION */
.btn-touch { min-height: 2.75rem; min-width: 2.75rem; } /* 44px at Pico 20px root */

/* Hide column on mobile — CUSTOM */
@media (max-width: 576px) { .hide-mobile { display: none; } }

/* Stack button group vertically on mobile — PICO-OVERRIDE */
@media (max-width: 576px) { [role="group"] { flex-direction: column; } }

/* Zero out Pico role=group margin in table cells — PICO-OVERRIDE */
table td > [role="group"] { display: flex; width: fit-content; margin-bottom: 0; }
```

### Common Main Site Patterns

```css
/* assets/css/custom.css */
@media (max-width: 640px) {
  .date-compact .full-date { display: none; }
  .date-compact .short-date { display: inline; }
}
```

---

## Phase 6: Update Handbook Documentation

Per CLAUDE.md, update relevant handbook docs in the same session:

| Changed | Update |
|---------|--------|
| Ops dashboard CSS / layout patterns | `handbook/content/technical/ops-dashboard/design-guide.md` |
| Ops dashboard architecture | `handbook/content/technical/ops-dashboard/architecture.md` |
| Main site CSS / templates / shortcodes | `handbook/content/technical/website/patterns.md` |

Update the **Last updated** line at the bottom of the doc with a brief summary
(date + description of additions/changes). Do not create new handbook pages —
add to existing sections.

---

## Key Reference: Pico CSS v2 (ops dashboard)

- Root font-size: **20px** — all rem values compute against 20px base
- `[role="group"]` has `margin-bottom: 20px` by default — zero it in table cells
- Bold in tables: `.fw-semibold` class, NOT `<strong>`
- Muted color override: `hsl(215, 16%, 32%)` light / `hsl(215, 14%, 75%)` dark
- Dark mode via `data-theme="dark"` on `<html>`
- Modals via native `<dialog>` with `openModal(id)` / `closeModal(id)`
- Icons via Phosphor CDN: `<i class="ph ph-*">`
- Full rules and anti-patterns: `.claude/instructions/pico-css-rules.md`
- Design system reference: `handbook/content/technical/ops-dashboard/design-guide.md`
