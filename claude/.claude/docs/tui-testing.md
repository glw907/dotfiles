# TUI Testing with tmux

A methodology for testing terminal UI applications non-interactively
using tmux. Used by Claude Code to verify TUI configuration changes
without requiring human visual inspection.

## Why tmux

Terminal applications render to a pseudoterminal. tmux provides:

- **Detached sessions**: Launch apps without blocking the current shell
- **Keystroke injection**: `send-keys` simulates real user input
- **Screen capture**: `capture-pane` reads the rendered screen as text
- **Controlled dimensions**: Fixed terminal size for reproducible layout

This makes it possible to script "open the app, press these keys, check
what's on screen" as a repeatable verification loop.

## Core Commands

### Session Management

```bash
# Create session with specific dimensions
tmux new-session -d -s test -x 100 -y 30 'command'

# Kill session (always do this before creating a new one)
tmux kill-session -t test 2>/dev/null

# Check if session exists
tmux list-sessions 2>&1

# Check if the app process is still alive
pgrep -a appname
```

### Sending Input

```bash
# Literal characters (typed as if on keyboard)
tmux send-keys -t test 'hello world'

# Named keys
tmux send-keys -t test Enter
tmux send-keys -t test Escape
tmux send-keys -t test Tab
tmux send-keys -t test Space
tmux send-keys -t test BSpace        # Backspace

# Ctrl combinations
tmux send-keys -t test C-c
tmux send-keys -t test C-y
tmux send-keys -t test C-x

# Arrow keys
tmux send-keys -t test Up
tmux send-keys -t test Down

# Chaining with delays
tmux send-keys -t test 'G' && sleep 1
tmux send-keys -t test ':wq' Enter && sleep 0.5
```

**Important**: Always add `sleep` after `send-keys` to let the app
process the input before capturing the screen. Typical values:

| Action | Sleep |
|--------|-------|
| Single keystroke | 0.3-0.5s |
| Mode change / navigation | 0.5-1s |
| Command that triggers I/O | 1-2s |
| App startup | 3-8s |

### Capturing Output

```bash
# Capture visible pane content to stdout
tmux capture-pane -t test -p

# Capture specific line range (0-indexed)
tmux capture-pane -t test -p -S 0 -E 10    # first 11 lines

# Pipe to inspection tools
tmux capture-pane -t test -p | head -5      # top of screen
tmux capture-pane -t test -p | tail -3      # bottom of screen
tmux capture-pane -t test -p | grep "pattern"

# Check for non-printable characters
tmux capture-pane -t test -p | head -1 | cat -A
```

**Empty capture** usually means one of:

- The app crashed — check `pgrep -a appname`
- The screen is actually blank (a bug) — try `send-keys Enter`
- The session ended — check `tmux list-sessions`

## Testing Patterns

### Basic Verification

Launch, wait, capture, verify, clean up:

```bash
tmux kill-session -t test 2>/dev/null
tmux new-session -d -s test -x 80 -y 24 'myapp'
sleep 5
tmux capture-pane -t test -p | head -10
tmux kill-session -t test
```

### Interactive Workflow

Test a sequence of user actions:

```bash
tmux new-session -d -s test -x 80 -y 24 'myapp'
sleep 5

# Step 1: navigate
tmux send-keys -t test 'j' && sleep 0.5
tmux send-keys -t test 'j' && sleep 0.5
tmux send-keys -t test Enter && sleep 2

# Step 2: verify
tmux capture-pane -t test -p | head -5

# Step 3: more interaction
tmux send-keys -t test 'q' && sleep 1

tmux kill-session -t test
```

### Neovim-Specific

Query vim/neovim internal state by running ex commands:

```bash
# Check option value
tmux send-keys -t test ':set scrolloff?' Enter && sleep 1
tmux capture-pane -t test -p | tail -3

# Check filetype
tmux send-keys -t test ':echo &filetype' Enter && sleep 1
tmux capture-pane -t test -p | tail -3

# Check syntax group at cursor position (line, column)
tmux send-keys -t test ':echo synIDattr(synID(3,1,1),"name")' Enter
sleep 1 && tmux capture-pane -t test -p | tail -3

# Check highlight group definition
tmux send-keys -t test ':highlight GroupName' Enter
sleep 1 && tmux capture-pane -t test -p | tail -3

# List syntax matches for a group
tmux send-keys -t test ':syntax list GroupName' Enter
sleep 1 && tmux capture-pane -t test -p | tail -5

# Run lua and print result
tmux send-keys -t test ':lua print(vim.api.nvim_win_get_height(0))' Enter
sleep 1 && tmux capture-pane -t test -p | tail -3

# Check extmarks
tmux send-keys -t test ':lua print(#vim.api.nvim_buf_get_extmarks(0, ns_id, 0, -1, {}))' Enter

# Enable line numbers for position verification
tmux send-keys -t test ':set number' Enter && sleep 0.5
```

**Dismiss prompts**: Neovim shows "Press ENTER or type command to
continue" after many `:` commands. Send `Enter` before the next
command:

```bash
tmux send-keys -t test Enter && sleep 0.3
```

### aerc-Specific

aerc needs longer startup time to connect to the mail server:

```bash
tmux new-session -d -s test -x 140 -y 40 'aerc'
sleep 8

# Navigate to a folder
tmux send-keys -t test 'c' && sleep 0.5
tmux send-keys -t test 'Sent' Enter && sleep 2

# Open a message
tmux send-keys -t test Enter && sleep 3
tmux capture-pane -t test -p | head -15

# Toggle thread view
tmux send-keys -t test 'T' && sleep 2
```

### Testing for Crashes

When testing changes that might crash the app:

```bash
# Launch and interact
tmux new-session -d -s test -x 80 -y 30 'nvim file.txt'
sleep 4
tmux send-keys -t test 'Gotyping test' Enter && sleep 1

# Check if capture is empty (possible crash)
output=$(tmux capture-pane -t test -p)
if [ -z "$output" ]; then
    echo "Empty capture — checking process"
    pgrep -a nvim
    tmux list-sessions
fi
```

### Save and Verify File Content

Test that edits are saved correctly by writing to a temp file:

```bash
tmux send-keys -t test Escape && sleep 0.3
tmux send-keys -t test ':w /tmp/test-output.txt' Enter && sleep 1
cat /tmp/test-output.txt
```

## Limitations

- **No color information**: `capture-pane -p` outputs plain text. Colors
  must be verified indirectly by checking syntax groups and highlight
  definitions (see neovim-specific patterns above).
- **Timing-dependent**: If sleeps are too short, captures may show
  intermediate states. Increase sleep if results are inconsistent.
- **No mouse testing**: `send-keys` handles keyboard input only.
  Mouse-driven UI interactions can't be tested this way.
- **Unicode rendering**: Some Unicode characters may not render
  correctly depending on the tmux version and terminal.

## Troubleshooting

| Problem | Cause | Fix |
|---------|-------|-----|
| Empty capture | App crashed | Check `pgrep -a appname` |
| Stale session | Previous test didn't clean up | `tmux kill-session -t test` first |
| Wrong content | Sleep too short | Increase sleep after send-keys |
| "duplicate session" error | Session already exists | Kill it first |
| App shows prompt | Previous command left a prompt | Send `Enter` first |
| Garbled output | App uses alternate screen | Try `capture-pane -p -S -30 -E 30` |
