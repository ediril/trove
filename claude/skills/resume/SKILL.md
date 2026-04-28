---
description: Resume work in an existing Trove project. Loads canonical trove files plus the most recent handover document from trove/tmp/. Use at the start of a fresh session when the previous session ended with /trove:handover.
allowed-tools: Read, Bash
disable-model-invocation: true
---

# Trove Resume

## Verify trove/ is set up
Check that `trove/` exists and contains the three canonical files:
- `trove/summary.md`
- `trove/terminology.md`
- `trove/practices.md`

If any are missing, tell the user to run `/trove:init` and stop.

## Find the most recent handover document
List `trove/tmp/` for files matching `handover-*.md`. Pick the most recent by filename timestamp (the format is `handover-YYYY-MM-DD-HHMM.md`, so lexical sort is also chronological).

If no handover document exists, tell the user there is nothing to resume from and suggest `/trove:session` instead. Stop.

## Read in this order
1. `trove/summary.md` — project purpose and current direction
2. `trove/terminology.md` — domain language
3. `trove/practices.md` — standing principles that apply to every session
4. All files in `trove/plans/` — captures current and planned work
5. All files in `trove/decisions/` — captures durable architectural decisions
6. All files in `trove/topics/` — captures cross-cutting connections, invariants, and co-change knowledge ("when changing X, also check Y")
7. The handover document — picks up where the prior session left off

Also run `git log -10 2>/dev/null` to see recent commits (silent if the repo has no commits).

## During the session
After the initial load, the user does not need to re-invoke this skill mid-session. Read additional trove files on demand as the work evolves.

## Acknowledge and proceed
Summarize in one or two sentences: which handover doc you read, what task it describes, and what the next step is according to it. Then await the user's instruction.

## Apply this philosophy throughout the session

- **Trove is the meta layer**: principles, plans, decisions, direction, terminology, rationale, lessons learned. Code-level facts (function signatures, behaviors, file structure) live in the code, not the trove.
- **User owns git state**: never run `git add`, `git commit`, or any state-mutating git command. AI changes appear as unstaged modifications; the user reviews and stages them.
- **Trove updates are user-triggered only**: do not auto-update trove files mid-session. The user invokes `/trove:save` when ready (typically at session end).
- **Code drift is real**: if you read a trove file and notice the code violates a documented principle or overrides a decision, flag it. Ask the user whether to update the trove or fix the code — do not auto-defer to the code; the principle may still hold.
