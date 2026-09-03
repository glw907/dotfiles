# Guards on long unattended work

Full procedures for the two mandatory guards the global CLAUDE.md names. Read this when
arming either one.

## Runaway guard (any workflow expected to run past ~30 minutes)

Nothing intervenes unless the main loop watches from outside (proven 2026-07-02: a sweep
agent burned ~5 hours grooming its own agent-memory index). At launch, arm a background
Bash guard polling the workflow transcript dir every ~5 minutes, alarming on either
signature: the newest `agent-*.jsonl` idle past ~25 minutes (stall; `journal.jsonl` only
records agent starts and finishes, so a long-running task looks idle there; poll the
agent transcripts, learned 2026-09-02), or any `agent-*.jsonl` past ~900KB and still
growing (token runaway; ~3.5-4 chars/token; an implementer polling its own background
gate run also inflates its transcript, so confirm with a tail sample before killing).
Intervention: TaskStop, relaunch with `resumeFromRunId` (done steps replay from cache;
give the re-run task a note to review and keep-or-revert any partial uncommitted work).
Prevention rides the prompts: memory-keeping agentTypes get an explicit "skip
agent-memory maintenance" line, and each step states a scope expectation so an agent
that blows past it self-reports. For expensive sweeps, add a hard turn-level token
target, which makes `agent()` calls throw at the ceiling.

## Battery floor (unattended work on battery; Geoff, 2026-09-02)

GNOME suspends this laptop after 15 idle minutes ON BATTERY (AC never suspends), which
freezes agents mid-flight and can kill their API streams (proven 2026-09-02: a suspend
orphaned an implementer's stream and stalled a pass ~2 hours). Size hold durations from
the clock, never as a round number of hours: an overnight hold ends around 09:00 local
(Geoff, 2026-09-03; compute `sleep` seconds as time-until-09:00), and a daytime hold ends
when the dispatched work is expected done, renewing if it runs long. Long unattended work
arms BOTH: a sleep inhibitor held for the duration (background Bash, self-expiring, released
at pass end; hold BOTH channels, since GNOME's idle logic honors its own session
inhibitors while logind honors systemd ones: `systemd-inhibit --what=sleep ... sleep NNN`
AND `gnome-session-inhibit --inhibit suspend ... sleep NNN`; inhibit `suspend` ONLY, never
`suspend:idle`: the `idle` flag stops the session from ever counting as idle, which keeps
the DISPLAY awake for the whole hold (Geoff caught this live 2026-09-02), while `suspend`
alone blocks auto-suspend and lets the screen blank), and a battery watchdog
polling
`/sys/class/power_supply/BAT*/{capacity,status}` every ~2 minutes, triggering at 11%
while `Discharging` (silent on AC; 11% so state is saved by 10%). On trigger, stand
down: TaskStop the workflow and guards, WIP-commit partial work on the feature branch,
write STATUS with the exact resume prompt (including any `resumeFromRunId`), release the
inhibitor so the machine may sleep, and report. Suspend evidence lives in `journalctl`;
check it before diagnosing any long-running background work as slow or stalled.

## Concurrent sessions (Geoff runs several at once)

Guards are per-session and stack safely: the machine stays awake while ANY session holds
an inhibitor, and sleep returns when the last one releases. At the battery floor every
session's watchdog fires and each saves its OWN state; no cross-session coordination is
needed. Two rules follow. Name each inhibitor for its initiative (`--who` /
`--app-id`) so ownership is legible in `systemd-inhibit --list`. And touch only your
own guards: never TaskStop, kill, or release an inhibitor, runaway guard, or watchdog
another session armed; `pgrep` and inhibitor listings will show siblings, and a
same-named process from another session is theirs, not a leak.
