---
description: Begin a fresh Trove Coding session by loading canonical trove files into context. Pair with /trove:save at session end. For continuing prior work from a handover, use /trove:resume instead.
allowed-tools: Read, Bash
---

# Trove Session

## Verify trove/ is set up
Check that `trove/` exists and contains the three canonical files:
- `trove/summary.md`
- `trove/terminology.md`
- `trove/practices.md`

If any are missing, tell the user to run `/trove:init` and stop.

## Read the three canonical files (in this order)
1. `trove/summary.md` — project purpose and current direction
2. `trove/terminology.md` — domain language
3. `trove/practices.md` — standing principles that apply to every session

## Read plans, decisions, topics, and recent git activity
- Read all files in `trove/plans/` — captures current, in-progress, and planned work.
- Read all files in `trove/decisions/` — captures durable architectural and design decisions with their rationale.
- Read all files in `trove/topics/` — captures cross-cutting connections, invariants, and co-change knowledge ("when changing X, also check Y").
- Run `git log -10 2>/dev/null` — captures what was recently done (silent if the repo has no commits).

These give you continuity from the prior session without needing an explicit handover document.

## Notice but do not read handover docs
If `trove/tmp/` contains handover documents (files matching `handover-*.md`), do not read them. Briefly mention to the user that handover docs exist and ask whether they intended `/trove:resume` instead. Wait for their answer before proceeding.

## During the session
After the initial load, the user does not need to re-invoke this skill mid-session. Read additional trove files on demand as the work evolves.

## Acknowledge and proceed
Briefly summarize what you've loaded — project domain, recent git activity, and current plans — in a short paragraph. Then await the user's instruction.

## Apply this philosophy throughout the session

- **Trove is the meta layer**: principles, plans, decisions, direction, terminology, rationale, lessons learned. Code-level facts (function signatures, behaviors, file structure) live in the code, not the trove.
- **User owns git state**: never run `git add`, `git commit`, or any state-mutating git command. AI changes appear as unstaged modifications; the user reviews and stages them.
- **Trove updates are user-triggered only**: do not auto-update trove files mid-session. The user invokes `/trove:save` when ready (typically at session end).
- **Code drift is real**: if you read a trove file and notice the code violates a documented principle or overrides a decision, flag it. Ask the user whether to update the trove or fix the code — do not auto-defer to the code; the principle may still hold.
