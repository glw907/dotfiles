---
name: pico2-cleanup
description: Periodic Pico CSS v2 audit for the ops dashboard — version check, anti-pattern scan, inline style violations, and handbook doc sync. Run before major deploys or when Pico updates are suspected.
---

Audit the ops dashboard for Pico CSS v2 compliance. Checks version sync, CSS anti-patterns,
and inline style violations. Updates local docs and handbook pages after applying fixes.

## When to run

- Before a significant ops dashboard deploy
- When Pico CSS updates are suspected
- After a batch of new ops dashboard features

For inline-style enforcement during active development, the PreToolUse hook
(`check-template-inline-styles.sh`) handles Rule 6 in real time.

---

## Phase 0: Pico version check

1. WebFetch `https://registry.npmjs.org/@picocss/pico/latest` → extract the `version` field.
2. Read `pico-css/README.md` → note the documented version (currently `v2.1.1`).
3. Compare:

**Same version** → Report "Pico v2.x.x — up to date" and proceed to Phase 1.

**Patch/minor bump (e.g. 2.1.1 → 2.2.0):**
- WebFetch `https://github.com/picocss/pico/releases` for the changelog.
- Note any new CSS variables, removed features, or changed defaults relevant to our usage.
- Update `pico-css/README.md` with the new version and a brief change summary.
- Proceed to Phase 1.

**Major version bump (e.g. 3.x):**
- **STOP.** Do not proceed with the audit or apply any fixes.
- Report: "Pico has a new major version (vX.x.x). The audit recommendations are built on v2
  assumptions. Breaking changes may invalidate existing fix logic."
- Quote relevant breaking changes from the release notes.
- Ask the user how to proceed before continuing.

---

## Phase 1: Inline style scan (Rule 6)

Glob all `ops/src/templates/*.js` files.

For each file, find any `style="..."` attribute that is NOT `style="display:none"`.

Report each as:
- File and approximate line (quote the HTML line)
- Suggested class from `layout.js`, or instruction to add one
- Priority: **high** (all inline styles are high — they bypass the class system)

---

## Phase 2: CSS anti-pattern audit

**File:** `ops/src/templates/layout.js` — the inline `<style>` block.

1. Read `ops/src/templates/layout.js` in full.
2. Extract the content between `<style>` and `</style>` for analysis.

### Check 1: Direct property assignments on Pico-styled elements

**What to find:** `background:`, `background-color:`, `border-color:`, `color:`, `border:` used
as **direct CSS properties** on selectors targeting `button`, `input`, `select`, `textarea`,
`a[role="button"]`, `[role="button"]`.

**Exempt:** CUSTOM-tagged blocks for app-specific elements (`.badge`, `.drag-handle`, etc.).

**Correct pattern:** Use `--pico-background-color`, `--pico-border-color`, `--pico-color`.

### Check 2: Specificity fights on `:root` variable overrides

**What to find:** `--pico-*` color variables declared inside a plain `:root {}` block.

**Why:** Pico's blue theme sets these at `:root:not([data-theme=dark])` (specificity 0,2,0).
A plain `:root` (0,1,0) loses silently.

**Correct pattern:**
- Light: `:root:not([data-theme=dark]), [data-theme=light] { --pico-var: value; }`
- Dark: `[data-theme=dark] { --pico-var: value; }`
- Theme-independent spacing/radius variables: plain `:root` is fine.

### Check 3: `!important` overriding Pico

**What to find:** `!important` on properties targeting Pico-styled elements or `--pico-*` variables.

**Exempt:** CUSTOM-tagged blocks for app-specific elements where specificity genuinely requires it.

### Check 4: Uncatalogued PICO-EXTENSION / PICO-OVERRIDE blocks

1. Parse the upgrade checklist comment (top of `<style>` block).
2. Scan for all `PICO-EXTENSION` and `PICO-OVERRIDE` comment tags.
3. Report: any tagged blocks missing from the checklist; any checklist items with no matching tag.

### Check 5: Hardcoded colors where a `--pico-*` variable exists

**Common substitutions:**
- Primary blue → `var(--pico-primary)`
- Muted text → `var(--pico-muted-color)`
- Borders → `var(--pico-muted-border-color)`
- Card bg → `var(--pico-card-sectioning-background-color)`

**Exempt:**
- Semantic action colors (`#16a34a`, `#dc2626`) in PICO-EXTENSION button variants
- Status badge colors (CUSTOM badge block)
- `rgba()` for opacity/shadow variations
- `hsl()` values in the PICO-OVERRIDE muted-color block

### Check 6: Missing `margin-bottom: 0` on buttons in compact contexts

**What to find:** Buttons styled for compact use (table cells, nav, card headers, `[role="group"]`,
flex layouts) that don't reset Pico's default `margin-bottom: 1rem`.

### Check 7: Nonexistent `--pico-*` variable names

**What to find:** `var(--pico-*)` references where the variable name doesn't exist in Pico v2.

**Known valid (non-exhaustive):**
`--pico-spacing`, `--pico-border-radius`, `--pico-border-width`, `--pico-line-height`,
`--pico-color`, `--pico-background-color`, `--pico-muted-color`, `--pico-muted-border-color`,
`--pico-primary`, `--pico-primary-hover`, `--pico-primary-background`, `--pico-primary-border`,
`--pico-primary-inverse`, `--pico-primary-underline`, `--pico-primary-hover-underline`,
`--pico-card-background-color`, `--pico-card-border-color`,
`--pico-card-sectioning-background-color`, `--pico-table-border-color`,
`--pico-form-element-border-color`, `--pico-form-element-spacing-vertical`,
`--pico-form-element-spacing-horizontal`, `--pico-tooltip-background-color`,
`--pico-tooltip-color`, `--pico-box-shadow`

If a variable looks plausible but is not listed: flag for manual verification. Do not auto-fix.

---

## Report format

```
## Pico CSS Audit — [version status]

### Phase 1: Inline style violations
[findings or "Clean — no inline styles in template files"]

### Phase 2, Check 1: Direct property assignments
[findings or "Clean"]
...
### Phase 2, Check 7: Nonexistent variable names
[findings or "Clean"]

---
**Summary:** X issues found. Y are high priority.
```

For each finding: quote the CSS/HTML, explain the anti-pattern, show before/after fix,
assign priority (high / medium / low).

---

## After reporting

1. Present the full report.
2. Ask for approval before making any changes.
3. If approved, apply fixes one check at a time.
4. After all fixes:
   - Update the upgrade checklist in `layout.js` if PICO-EXTENSION/PICO-OVERRIDE tags changed.
   - Sync handbook: if design patterns changed, update
     `handbook/content/technical/ops-dashboard/design-guide.md`; if architecture changed,
     update `handbook/content/technical/ops-dashboard/architecture.md`.
5. Do NOT deploy. The user deploys when ready.
