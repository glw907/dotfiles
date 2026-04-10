# Elm Architecture Conventions (Poplar UI)

Rules for the bubbletea UI layer in `internal/ui/`. These conventions
keep the tea loop predictable and auditable.

## Scope

Applies exclusively to `internal/ui/`. Does not apply to:

- `internal/mail/` — backend adapter, goroutines and mutexes are normal
- `internal/aercfork/` — forked worker code, channel-based async
- `internal/filter/` — stdin/stdout filters, no tea loop
- `cmd/poplar/` — bootstrap wiring before the tea loop starts

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

**Wrong — mutation in View:**
```go
func (m Sidebar) View() string {
    m.lastRendered = time.Now() // mutation in View
    return m.render()
}
```

**Wrong — mutation in Cmd closure:**
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
`Update`. No parent method calls, no upward pointers, no callbacks
stored in child models.

**Right:**
```go
// Child defines its own message type
type FolderSelectedMsg struct {
    Name string
}

func (m Sidebar) Update(msg tea.Msg) (Sidebar, tea.Cmd) {
    switch msg := msg.(type) {
    case tea.KeyMsg:
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
- Never discard a cmd — missed cmds cause silent dropped messages.

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
