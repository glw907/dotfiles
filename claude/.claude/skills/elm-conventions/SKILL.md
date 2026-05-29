---
name: elm-conventions
description: >
  Mandatory rules for the bubbletea v2 UI layer (poplar's `internal/ui/`).
  Use before writing, reviewing, or modifying any bubbletea tea.Model,
  Update, View, or Cmd. Keeps the tea loop predictable and auditable:
  all state in models, mutations only in Update, I/O only in tea.Cmd,
  children signal parents via Msg types, shared state hoisted to root.
---

# Elm Architecture Conventions (Poplar UI)

Rules for the bubbletea UI layer in `internal/ui/`. These conventions
keep the tea loop predictable and auditable.

## Scope

Applies exclusively to `internal/ui/`. Does not apply to:

- `internal/mail/`: backend adapter; goroutines and mutexes are normal
- `internal/mailworker/`: forked worker code, channel-based async
- `internal/filter/`: stdin/stdout filters, no tea loop
- `cmd/poplar/`: bootstrap wiring before the tea loop starts

## Rule 1: All State in Models

Every component is a `tea.Model` struct. No package-level mutable
variables, no singletons, no shared mutable state outside the model
tree.

**Right:**
```go
type Sidebar struct {
    folders []mail.Folder
    cursor  int
    width   int
}
```

**Wrong:**
```go
var currentFolders []mail.Folder // package-level mutable state

type Sidebar struct {
    cursor int
}
```

## Rule 2: Update Is the Only Mutation Point

State changes happen only by returning a new model from `Update`. No
mutating model fields in `View`, `Init`, or `Cmd` closures.

**Right:**
```go
func (m Sidebar) Update(msg tea.Msg) (Sidebar, tea.Cmd) {
    switch msg := msg.(type) {
    case FoldersLoadedMsg:
        m.folders = msg.Folders
        return m, nil
    }
    return m, nil
}
```

**Wrong (mutation in View):**
```go
func (m Sidebar) View() string {
    m.lastRendered = time.Now() // mutation in View
    return m.render()
}
```

**Wrong (mutation in Cmd closure):**
```go
func fetchFolders(m *Sidebar, backend mail.Backend) tea.Cmd {
    return func() tea.Msg {
        folders, _ := backend.ListFolders()
        m.folders = folders // mutation in Cmd closure
        return nil
    }
}
```

## Rule 3: All I/O in Cmds

Blocking calls (backend methods, file I/O, network) run inside
`tea.Cmd` functions, never in `Update` or `View`. `Update` must return
instantly.

**Right:**
```go
func (m App) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
    switch msg := msg.(type) {
    case FolderSelectedMsg:
        return m, fetchHeaders(m.backend, msg.Name)
    }
    return m, nil
}

func fetchHeaders(b mail.Backend, folder string) tea.Cmd {
    return func() tea.Msg {
        headers, err := b.FetchHeaders(folder, nil)
        if err != nil {
            return ErrMsg{Err: err}
        }
        return HeadersLoadedMsg{Headers: headers}
    }
}
```

**Wrong:**
```go
func (m App) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
    switch msg := msg.(type) {
    case FolderSelectedMsg:
        headers, _ := m.backend.FetchHeaders(msg.Name, nil) // blocks UI
        m.headers = headers
        return m, nil
    }
    return m, nil
}
```

## Rule 4: Message-Driven Communication

Children signal parents by returning sentinel `Msg` types from
`Update`. Parent method calls, upward pointers, and callbacks stored
in child models are all prohibited.

**Right:**
```go
// Child defines its own message type
type FolderSelectedMsg struct {
    Name string
}

func (m Sidebar) Update(msg tea.Msg) (Sidebar, tea.Cmd) {
    switch msg := msg.(type) {
    case tea.KeyPressMsg:
        if msg.String() == "enter" {
            folder := m.folders[m.cursor]
            return m, func() tea.Msg {
                return FolderSelectedMsg{Name: folder.Name}
            }
        }
    }
    return m, nil
}

// Parent handles it in its own Update
func (m App) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
    switch msg := msg.(type) {
    case FolderSelectedMsg:
        return m, fetchHeaders(m.backend, msg.Name)
    }
    // delegate to children...
}
```

**Wrong:**
```go
type Sidebar struct {
    onSelect func(string) // callback — couples child to parent
}
```

## Rule 5: State Ownership, Not Duplication

Shared state lives in the root model and is passed to children as
read-only values during `Update` delegation or as constructor
parameters. Children never own copies of data they don't exclusively
control.

**Right:**
```go
type App struct {
    backend mail.Backend // owned by root
    styles  Styles       // computed once, shared read-only
    tabs    []Tab
    active  int
}

// Styles passed to child View
func (m App) View() string {
    return m.tabs[m.active].View(m.styles)
}
```

**Wrong:**
```go
type Sidebar struct {
    backend mail.Backend // child owns a copy of shared dependency
}

type MsgList struct {
    backend mail.Backend // another copy — who's authoritative?
}
```

**Exception:** A child may hold a reference to a read-only dependency
(like `mail.Backend`) if it needs to create `tea.Cmd` closures that
call backend methods. The child must never mutate the dependency or
cache its results as owned state. Results come back as `Msg` types
through the normal Update flow.

## Parent-Child Update Delegation Pattern

Parent handles its own messages first, then delegates to the active
child, collects all cmds via `tea.Batch`.

```go
func (m App) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
    var cmds []tea.Cmd

    // 1. Handle messages owned by the parent
    switch msg := msg.(type) {
    case FolderSelectedMsg:
        cmds = append(cmds, fetchHeaders(m.backend, msg.Name))
    case tea.WindowSizeMsg:
        m.width, m.height = msg.Width, msg.Height
    }

    // 2. Delegate to the active child
    var cmd tea.Cmd
    m.tabs[m.active], cmd = m.tabs[m.active].Update(msg)
    cmds = append(cmds, cmd)

    return m, tea.Batch(cmds...)
}
```

Rules:
- Parent handles its own Msg types before delegating.
- Every child returns `(ChildModel, tea.Cmd)`, never `(tea.Model, tea.Cmd)`.
- Collect all cmds into a slice; return `tea.Batch(cmds...)`.
- Never discard a cmd. Missed cmds cause silent dropped messages.

## Rule 6: Components Own Their Size Contract

Every component's `View()` returns content **at exactly its assigned
width and height**, no wider, no taller. The parent calls
`lipgloss.JoinHorizontal`/`JoinVertical` and trusts each child's
output. A child that returns lines wider than its assigned width
makes the joined output exceed terminal width. The terminal
soft-wraps and content displaces adjacent panes. **This is always
the child's bug, never the parent's.**

This is the canonical bubbles pattern: `viewport.View()` ends with
`Width().Height().MaxHeight().MaxWidth().Render(content)` (Width +
Height pad; MaxWidth + MaxHeight truncate). Research at
`docs/poplar/research/2026-04-26-bubbletea-norms.md` §2 cites
`viewport/viewport.go:518-525`. Poplar's `clipPane` helper in
`internal/ui/viewer.go` implements the same idiom.

**Right (self-guarded View):**
```go
func (m Component) View() string {
    out := /* compose content */
    return clipPane(out, m.width, m.height) // truncate + pad
}
```

**Right (width-honoring renderer, wordwrap + hardwrap):**
```go
// A renderer that takes width returns lines no wider than width.
// wordwrap respects word boundaries; hardwrap catches the residue
// (long URLs, long identifiers) that wordwrap won't break.
//
// Wordwrap-alone is broken: a single long URL or pasted token
// overflows. Always pair the two (norms §5).
func render(text string, width int) string {
    return ansi.Hardwrap(ansi.Wordwrap(text, width, ""), width, false)
}
```

**Right (display-cell-aware width math):**
```go
// lipgloss.Width measures display cells correctly for ASCII, box-
// drawing, and most BMP characters. Nerd Font SPUA-A glyphs
// (U+F0000-U+FFFFD) render as 2 cells but runewidth reports 1 — use
// displayCells (poplar's iconwidth.go helper) when measuring strings
// that may contain Nerd Font icons. Never `len()` for layout math.
w := displayCells(rowWithIcons)
```

**Wrong (defensive parent-side clip):**
```go
// Papering over a child contract violation. Fix the child instead.
func (m Parent) View() string {
    childView := lipgloss.NewStyle().MaxWidth(m.width).Render(m.child.View())
    return lipgloss.JoinHorizontal(lipgloss.Top, m.sidebar.View(), childView)
}
```

**Wrong (wordwrap without hardwrap):**
```go
text = ansi.Wordwrap(text, width, "") // a single long URL overflows
```

### WindowSizeMsg propagation

When a parent receives `tea.WindowSizeMsg`, it must:

1. Store the new dimensions on the model (or shared context).
2. Compute chrome margins and call `child.SetSize(width-wm, height-hm)`
   on every sized child.
3. **Also forward the message** into each child's `Update`. Bubbles
   components (viewport, textarea, list) rely on the msg to reset
   internal scroll/cursor state; `SetSize` alone is insufficient
   (research at `docs/poplar/research/2026-04-26-reference-apps.md` §4,
   §8 avoid #6).

The full contract lives in `docs/poplar/bubbletea-conventions.md`,
including the planning and review checklists that confirm this
discipline before and after any UI change. Load that doc before
planning UI/UX work, and run its review checklist after.

## Rule 7: Key Bindings via `key.Binding` and `key.Matches`

Keys are declared as `key.Binding` values in a `KeyMap` struct and
dispatched with `key.Matches(msg, binding)`, never via raw
`switch msg.String()` for actionable keys.

This is the canonical pattern across every reference app surveyed
(soft-serve, gh-dash, official examples; research at
`docs/poplar/research/2026-04-26-reference-apps.md` §3). Only glow
falls back to string switches, and that's listed as an anti-pattern
(ref-apps §8 avoid #4). `key.Matches` respects each binding's
`Enabled()` flag (norms §3, `key/key.go:130-138`), making per-state
activation declarative; string switches force inline state checks.

Poplar's keybindings are modifier-free single keys (ADR-0015, 0024,
0051, 0068, 0076). That doesn't change the declaration form. The
`KeyMap` struct still uses `key.Binding`; the help text just reads
`"k"` instead of `"↑/k"`.

**Right:**
```go
type GlobalKeys struct {
    Help key.Binding
    Quit key.Binding
}

func NewGlobalKeys() GlobalKeys {
    return GlobalKeys{
        Help: key.NewBinding(key.WithKeys("?"), key.WithHelp("?", "help")),
        Quit: key.NewBinding(key.WithKeys("q"), key.WithHelp("q", "quit")),
    }
}

func (m App) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
    if k, ok := msg.(tea.KeyPressMsg); ok {
        switch {
        case key.Matches(k, m.keys.Help):
            return m.openHelp(), nil
        case key.Matches(k, m.keys.Quit):
            return m, tea.Quit
        }
    }
    // ...
}
```

**Wrong:**
```go
// String switch is invisible to bubbles/help, can't be disabled
// per-state, can't be rebound.
switch msg.String() {
case "?":
    return m.openHelp(), nil
case "q":
    return m, tea.Quit
}
```

## Rule 8: Cursor Hoist (v2)

A focusable child does not render its own cursor as a styled rune
inside its `View()` string. It exposes `Cursor() *tea.Cursor`,
returning a populated cursor when focused and `nil` otherwise. The
parent App, in its own `View()`, walks the focus chain and pulls
the active cursor up into its returned `tea.View.Cursor`. One blink
ticker lives at the App level; per-input `cursor.Model` instances
go away. Set `VirtualCursor=false` on every textinput/textarea so
the App is the cursor authority. The input never paints a cursor
into its string.

This matches the shared-state-at-the-root rule (Rule 5): cursor
position and blink phase are App-scope concerns expressed by the
focused child.

**Right (child exposes a cursor):**
```go
func (m Compose) Cursor() *tea.Cursor {
    if m.focus != focusBody {
        return nil
    }
    c := tea.NewCursor(m.bodyCursorX, m.bodyCursorY)
    c.Style = m.styles.Cursor
    return c
}

func (m App) View() tea.View {
    v := tea.NewView(m.render())
    if m.compose != nil {
        v.Cursor = m.compose.Cursor()
    }
    return v
}
```

**Wrong (child renders cursor inline):**
```go
// Bypasses tea.Cursor; defeats blink coordination at the root.
func (m Compose) View() string {
    line := before + m.styles.Cursor.Render("█") + after
    return line
}
```

## Cmd Closures: Capture Values, Not Pointers

Cmd closures run after `Update` returns. Capturing a pointer to the
model means reading stale or mutated state.

**Right:**
```go
func fetchHeaders(b mail.Backend, folder string) tea.Cmd {
    return func() tea.Msg {
        headers, err := b.FetchHeaders(folder, nil)
        if err != nil {
            return ErrMsg{Err: err}
        }
        return HeadersLoadedMsg{Headers: headers}
    }
}

// Called with values extracted from the model:
return m, fetchHeaders(m.backend, msg.Name)
```

**Wrong:**
```go
func (m *App) fetchHeadersCmd() tea.Cmd {
    return func() tea.Msg {
        // m.activeFolder may have changed by the time this runs
        headers, _ := m.backend.FetchHeaders(m.activeFolder, nil)
        return HeadersLoadedMsg{Headers: headers}
    }
}
```

Extract the values you need before returning the Cmd. The closure
captures those values, not the model.

## Rule 9: Style Tests Assert Resolved Attributes

`lipgloss.Style{}` (zero value) `Render`s its argument unchanged.
`style.Render("test") != ""` passes for the zero-value style, so
that check proves nothing. Style smoke tests must assert the
*resolved attributes* that the style sets.

**Right:**
```go
if styles.HelpKey.GetForeground() == nil {
    t.Error("HelpKey has no foreground color")
}
if !styles.HelpKey.GetBold() {
    t.Error("HelpKey is not bold")
}
```

**Wrong:**
```go
// Passes against lipgloss.Style{} — proves nothing.
if styles.HelpKey.Render("test") == "" {
    t.Error("HelpKey rendered empty string")
}
```

`GetForeground` / `GetBackground` / `GetBold` / `GetItalic` /
`GetUnderline` return the resolved attribute (nil / false / true)
and let the test name a specific claim the style must satisfy.
ADR-0233.
