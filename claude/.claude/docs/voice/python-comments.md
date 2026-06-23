# Register: Python code comments

The reader is a Python coder or an agent already looking at the code. A comment exists to carry
what the code cannot: a why, a constraint, a piece of evidence. Placement and function come before
prose style. The empirical baseline is PEP 257, the CPython standard library (terse one-line
docstrings, sparse `#` comments concentrated where intent is non-obvious), and the workstation's
own scripts in `~/.local/bin`. Type hints carry the types, so the docstring never restates them.

## When a comment exists

- Comment why, almost never what. The paraphrase test applies: if the docstring is the signature in
  English, or the `#` comment restates the next line, delete it.
- A docstring on a public function is a one-liner stating intent, or nothing when the name and the
  hints already say it. The script is small; a missing docstring is not a defect.
- An `Args:`, `Returns:`, or `Raises:` block earns its place only for a contract the signature
  cannot show: a unit, a bound, a None-semantic, an exception a caller must handle.
- A `#` comment justifying odd-looking code sits immediately above it and carries evidence: the
  issue URL, the spec citation, the observed symptom.
- A real gap is a concrete `# TODO(glw907): ...`, never an apology folded into the docstring.
- Standard idioms stay silent. A Python reader knows `with`, a comprehension, and an unpacking.

## Length scales with distance from the reader

A public entry point gets a full docstring: a capitalized imperative sentence with a period, the
contract stated, an `Args:` line only where a parameter hides a constraint. An internal helper gets
a one-line docstring or a bare `#` line. An inline aside is a lowercase fragment or a plain
sentence, candid about a hack. Length follows the code's surprise, not a fixed shape: a tricky
parser function earns a paragraph, a one-line wrapper earns nothing.

## Exemplars

A public function, terse, stating intent the name does not quite carry:

```python
def slugify(title: str) -> str:
    """Return a URL-safe slug, collapsing runs of punctuation to a single hyphen."""
    ...
```

A contract the signature cannot express, in a sparing `Args:` block:

```python
def retry(fn: Callable[[], T], attempts: int = 3) -> T:
    """Call fn until it returns, backing off between tries.

    Args:
        attempts: total tries, not retries; attempts=1 means no retry.
    """
    ...
```

The why behind odd-looking code, with the receipt:

```python
# CPython rounds half-to-even, so 2.5 rounds to 2; the spec wants half-up, hence the Decimal.
total = (Decimal(raw) ).quantize(Decimal("1"), rounding=ROUND_HALF_UP)
```

An intentional swallow, marked so the emptiness reads as a decision:

```python
try:
    os.remove(lockfile)
except FileNotFoundError:
    pass  # already gone; a missing lock is the state we want
```

A scheduled gap, concrete and owned:

```python
# TODO(glw907): drop this shim once the D1 migration lands; it double-writes for now.
```

## Anti-patterns (do not imitate)

The docstring that restates the signature:

```python
def add(a: int, b: int) -> int:
    """Takes two ints, a and b, and returns an int."""
    return a + b
```

The module banner repeating what the path and git already carry:

```python
# ======================================================================
# slugify.py - slug helpers
# Author: glw907  Created: 2026-06-22  Version: 1.0
# ======================================================================
```

## Off-voice contrast

The AI comment spray this register exists to prevent: narrating each step, restating the types,
no information the code lacks:

```python
# This function loops through the items
for item in items:
    # Check if the item is valid
    if is_valid(item):
        # Increment the counter by one
        count += 1  # count is an integer
```

## The T-P catalogue (T-P1 through T-P13)

The numbered tells the `python-conventions` skill cites. Each is an AI-shaped habit with its
mechanical fix; the worked examples below cover the tells the exemplars above do not already show.

| id | name | rule |
|---|---|---|
| T-P1 | docstring restating the signature | if it is the signature in English, delete it |
| T-P2 | reflexive docstring on a trivial helper | a private helper gets a docstring only for unobvious behavior |
| T-P3 | `Args:`/`Returns:` duplicating type hints | document a constraint, not a type the hint declares |
| T-P4 | `# This function` / restating the next line | the paraphrase test; comment the surprise |
| T-P5 | module or class docstring banner | one prose sentence; no banner art, no metadata git tracks |
| T-P6 | type info in the docstring | annotate the signature; the docstring states intent |
| T-P7 | hedging or apologetic docstring | state the invariant; a real gap is a concrete `# TODO(glw907):` |
| T-P8 | uniform docstring rhythm | length follows complexity |
| T-P9 | uniform "Foo does X" shape | imperative mood, varied sentence shape across neighbors |
| T-P10 | speculative `Raises:` entries | document only an exception a caller must handle |
| T-P11 | over-explaining Python idioms | never explain `with` or a comprehension to a Python reader |
| T-P12 | task-framing or changelog comments | git carries the task and the fix |
| T-P13 | restated-annotation `#` comment | the annotation is the type statement; delete the comment |

T-P3, the `Args:` block duplicating the hints. The signature already says `int` and `str`; document
the constraint the type cannot:

```python
# off-voice: every parameter restated as its type
def crop(path: str, width: int) -> bytes:
    """Crop an image.

    Args:
        path: a string, the file path.
        width: an integer, the width.
    """
# in-voice: an Args: line only for the part the type cannot carry
def crop(path: str, width: int) -> bytes:
    """Crop an image to width, preserving aspect ratio.

    Args:
        width: target width in pixels; must be even, the encoder rejects odd widths.
    """
```

T-P9, the uniform "Foo does X" shape across neighbors. Imperative mood, varied openers:

```python
# off-voice: every docstring molded to the same frame
def load(p): """This function loads the config."""
def save(p): """This function saves the config."""
def reset(): """This function resets the config."""
# in-voice: imperative, and varied where the work differs
def load(p): """Read the config, falling back to defaults on a missing file."""
def save(p): """Write the config atomically through a temp file and rename."""
def reset(): """Restore the shipped defaults."""
```

T-P11, the explained idiom. A Python reader knows `with` and a comprehension:

```python
# off-voice
# use a context manager so the file closes automatically
with open(path) as f:
    # build a list of stripped lines using a comprehension
    lines = [ln.strip() for ln in f]
# in-voice: silence, unless a non-obvious why hides here
with open(path) as f:
    lines = [ln.strip() for ln in f]
```

T-P12, the changelog comment. Git carries the task and the fix:

```python
# off-voice
# added 2026-06 to fix the double-encode bug, see #91
text = raw.encode("utf-8")
# in-voice: the why, only if it is not obvious; the issue link only if it argues the code
text = raw.encode("utf-8")  # the upstream feed double-encodes latin-1; normalize here
```
