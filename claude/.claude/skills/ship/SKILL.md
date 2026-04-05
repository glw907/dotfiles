---
name: ship
description: >
  Use when Go implementation work is done and ready to ship. Runs the
  full quality pipeline: go-review, /simplify, commit, push, and
  make install. Trigger on: "ship it", "ship", "done, ship",
  "review commit and install", "finish up", or when the user indicates
  Go work is complete and wants the standard ship workflow.
---

# Ship

Review, simplify, commit, push, and install a Go project in one pass.

## Pipeline

Run these steps sequentially. Stop on failure.

### 1. make check

```bash
make check
```

If vet or tests fail, fix the issues before proceeding.

### 2. Go convention review

Invoke the `go-review` skill. Fix any violations found, re-run `make check` after fixes.

### 3. Simplify

Invoke the `simplify` skill (`/simplify`). Fix any issues found, re-run `make check` after fixes.

### 4. Commit and push

Follow the standard git commit workflow from the system prompt. Stage specific files, write a descriptive commit message, push to remote.

### 5. Install

```bash
make install
```

Confirm the binary was installed successfully.

## When NOT to use

- Mid-implementation (not all changes are done yet)
- Non-Go projects
- When the user only wants a subset (e.g., just commit, just review)
