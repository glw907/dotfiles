# Calibration samples, 2026-06-09 (Fable 5)

Five first-pass drafts, one per register, written by Fable 5 with the full voice system
loaded. Purpose: mark what grates. Anything that reads as AI, as off-register, or simply
not like you, even if you cannot name why. Edit this file directly (strike, rewrite, or
add a `<- note`) or quote irritants in chat; marked phrases feed the Fable tell catalogue
and the register files. These drafts were not revised after the advisory hook ran; what
leaked through is the point.

## Sample 1: Go developer docs (a design note for a jrnl-md `search` subcommand)

jrnl-md search scans day files with a compiled regex and prints matching paragraphs under
their date headings. The unit of output is the paragraph, not the line: a journal entry
rarely survives being cut mid-thought, and the paragraph is already the format's natural
block. Search loads one file at a time and never builds an index. A year of daily entries
is a few megabytes; a linear scan finishes before an index could be opened, and an index
is state that can go stale. `--tag` narrows the scan to entries carrying the tag. `--on`
and `--from`/`--to` narrow by date using the filename, so date filters never read file
contents at all. Output is plain text to stdout. Pipe it to less, grep it again, or
redirect it to a file; the tool does not paginate.

## Sample 2: web developer docs (explaining the diagnostics condition registry)

A cairn site can fail in ways the engine can see coming. The binding missing at deploy,
the sending subdomain never onboarded, the allowlist with no owner row: each is a
condition the engine can name precisely at the moment it blocks something. The
diagnostics registry models each one as a CairnCondition with a stable id, and that id is
the spine of the 1:1:1 rule: one condition is one readiness-checklist line, one cairn
doctor check, and one runtime error. The rule exists because the three surfaces drift
when written separately, and a drifted surface is worse than none. An operator who fixes
what doctor reports and still hits the runtime error stops trusting both. A condition
added to the registry buys all three surfaces in one place, so they cannot disagree.

## Sample 3: agent-facing (a rule for handling post-hook feedback)

Treat prose-guard post-hook feedback as a revision trigger, not noise. The feedback fires
after a Write or Edit and lists advisory tells in the file you just touched. If a finding
sits in prose you wrote this turn, revise it now; the draft is fresh and a reword costs
one Edit. If it sits in pre-existing body text, leave it. Advisory findings never gate
work, and sweep noise in an old file belongs to the file's owner, not to you. Never
silence a finding by moving your own prose into a code fence. The fence tells the guard
the text is quoted material; using it on prose you are writing is a dodge, and the dodge
is itself a tell.

## Sample 4: commit message (adding a log event)

Add render.failed to the log vocabulary

Emit render.failed from createRenderer when a preview render throws, carrying the entry
id and the error message. Preview failures were the one diagnosable path with no event,
so an editor's blank preview was invisible in Workers Logs. Update the reference table in
the same pass.

## Sample 5: ECXC site content (a June training-update post)

Summer training starts Monday, June 15. We meet at the Service High lot at 4:00 PM,
Mondays, Wednesdays, and Fridays, through the end of July. Bring running shoes, a water
bottle, and a rain jacket; we go out in everything short of lightning. Mondays are
distance runs on the Hillside trails. Wednesdays we roller-ski the Coastal Trail, and
loaner skis are available if you don't have your own. Fridays are strength and games at
the school. New to the team? Just show up. The first week is easy volume while we sort
out groups, and nobody is behind in June. Parents: the summer schedule and the Talkeetna
camp dates are on the Resources page, and registration closes June 30.
