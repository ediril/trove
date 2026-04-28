# Trove Coding — Claude Code plugin

Workflow framework for maintaining project meta-knowledge alongside code. Provides five skills:

- **`/trove:init`** — bootstrap a `trove/` skeleton (no-op if it already exists). On a project with existing code, seeds the canonical files from README, manifests, top-level structure, and a sampled read of code — written directly to disk for review.
- **`/trove:session`** — begin a session; loads canonical files, plans, decisions, topics, and recent git log
- **`/trove:resume`** — same as `/trove:session` plus reads the most recent handover doc (use when continuing from `/trove:handover`)
- **`/trove:save`** — update trove meta-entries from accumulated git changes
- **`/trove:handover`** — write a handover doc (use before switching to another coding agent)

## Installation

In any Claude Code session, add this repository as a marketplace and install the plugin:

```
/plugin marketplace add ediril/trove
/plugin install trove
```

Verify with `/plugin marketplace list` and `/plugin list`. The five skills become available as `/trove:init`, `/trove:session`, `/trove:resume`, `/trove:save`, and `/trove:handover`.

### Upgrade

```
/plugin marketplace update trove
/plugin update trove

/reload-plugins
```

## What is the trove?

`trove/` is your project's meta-layer memory: principles, plans, decisions, rationale, terminology, lessons learned — things git and code can't capture.

Code-level facts (function signatures, behaviors, file structure) live in the code; the trove never duplicates them.

## Workflow

A "session" is a unit of work bracketed by `/trove:session` (or `/trove:resume`) at the start, and `/trove:save` at the end.

1. **First time on a project**: invoke `/trove:init` once. On a project with existing code it will seed the canonical files from your README, manifests, top-level structure, and a sampled read of code — written directly to disk for review.
2. **Begin a session**: invoke `/trove:session` — it loads canonical files, plans, decisions, topics, and recent git log, giving you continuity from the prior session. (Use `/trove:resume` instead only when the previous session ended with `/trove:handover`.)
3. **Iterate with Claude as usual**; you own git staging and commits.
4. **End the session**: invoke `/trove:save` to update the meta layer based on accumulated git changes.
5. **Switching to another coding agent**: invoke `/trove:handover` before switching, then `/trove:resume` in the new agent to pick up.

Within Claude Code, your typical loop is just `/trove:session` → work → `/trove:save`. `/trove:handover` and `/trove:resume` are for cross-agent transitions.

The plugin assumes the user owns git state — Claude never runs `git add`, `git commit`, or any state-mutating git command.

All skills except `/trove:session` are explicit-invocation only — Claude won't auto-invoke them based on message content; you must use the slash command to trigger them. `/trove:session` may be auto-invoked when Claude detects the start of a Trove-managed task.
