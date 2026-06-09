# Register: agent-facing instructions

The reader is Claude or another model: a CLAUDE.md, a skill, an agent definition, a hook
message. The persona is an operator writing a runbook for another operator. Every sentence
is a rule, the mechanism that makes the rule necessary, or a mechanical test for applying
it. There is no audience management at all. No encouragement, no hedging, no transitions,
no warmth.

Defaults and negations are stated explicitly ("Silence is the default", "NOT the gate")
because the reader will otherwise take the cheap path. Evidence appears only when it raises
a rule's authority, like a named shipped bug or a known trap.

## Traits

- Rule first, reason in the same sentence or the next one. Never reason-then-rule.
- Convert judgment calls into mechanical tests the reader can execute.
- Name the trap and its mechanism, then the required behavior.
- State what done means in numbers and exit codes, not adjectives.
- Load-bearing rules carry their evidence: the bug that happens when the rule is broken.
- Cut anything a competent agent would do anyway. Length is a cost; every retained sentence
  must change behavior.

## Exemplars

From the cairn-implementer agent, the verification contract. Negates the likely shortcut,
gives the failure mechanism, ends with the required behavior:

```
A passing targeted test is NOT the gate. A browser component test can pass while
svelte-check fails (esbuild does not type-check) and while the full run exits non-zero
on an unhandled rejection. Before you report DONE, all three of these must hold, and you
must paste the evidence. If you cannot satisfy all three, you are not done. Report
BLOCKED with the exact failing output rather than committing a red gate.
```

From the go-conventions skill, the comment gate. A judgment call converted into a
mechanical test, with the default named:

```
Mechanical test: if the comment paraphrases the next <=5 lines, delete it. The
paraphrase test is the primary check, and the single most effective filter against
AI-shaped in-function comments. Godoc on unexported symbols is opt-in, not opt-out:
comment only when name + signature leaves something a competent Go reader wouldn't
immediately know. Silence is the default.
```

From the go-conventions skill, defensive checks. Two-word imperatives, then a decision
procedure that resolves every ambiguous case:

```
Trust internal callers. Validate at boundaries (user input, config load, external APIs).
Boundary test: if the zero value can occur through the package's own API (constructor
accepts nil, optional field), the check stays. If only constructed-and-handed-off code
reaches it, it's T22.
```

From the cairn admin design system, a load-bearing rule. Rule, mechanism, fix, then the
shipped bugs that prove it:

```
data-theme goes on a bare wrapper, never on an element that also carries styled classes.
Every scoped rule is a descendant selector, so a class on the theme element itself never
matches. Put data-theme on an outer div and the styled layout one level in. This broke
the drawer (it stayed display:block) and both auth pages (they would not center); both
were real shipped bugs.
```

From the cairn CLAUDE.md, the logging rule. Rule, timing, and the architectural reason the
rule is cheap to follow, in two sentences:

```
When a pass adds a diagnosable code path, give it an event in the vocabulary rather than
a bare console call, and update the reference table in the same pass. The logger is
internal (exported from no package subpath), so its API is free to grow; the event names
are the public-observable contract.
```

## Off-voice contrast

The same content in the register this file exists to prevent:

```
It's important to remember that testing is a crucial part of the workflow! Before
reporting that you're done, you'll want to make sure all the various checks pass.
Generally speaking, it's a good idea to run the full suite, as this helps ensure
everything works as expected.
```
