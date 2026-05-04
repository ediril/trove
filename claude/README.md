# Trove Coding — Claude Code plugin

Workflow framework for maintaining project meta-knowledge alongside code. Provides three skills:

- **`/trove:init`** — bootstrap a `trove/` skeleton (no-op if it already exists). On a project with existing code, seeds the canonical files from README, manifests, top-level structure, and a sampled read of code — written directly to disk for review.
- **`/trove:session`** — begin a session; loads canonical files, plans, decisions, topics, and recent git log.
- **`/trove:save`** — update trove meta-entries from accumulated git changes.

In addition, a **SessionStart hook** auto-injects the canonical trove files (`summary.md`, `terminology.md`, `practices.md`) plus the full content of `plans/` into the agent's context on session start, resume, and after compaction. `decisions/` and `topics/` are read on demand. The hook is global but self-gates on the presence of a `trove/` directory, so projects without a trove are unaffected. See [Auto-loading at session start](#auto-loading-at-session-start) below.

## Installation

In any Claude Code session, add this repository as a marketplace and install the plugin:

```
/plugin marketplace add ediril/trove
/plugin install trove
```

Verify with `/plugin marketplace list` and `/plugin list`. The three skills become available as `/trove:init`, `/trove:session`, and `/trove:save`.

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

A "session" is a unit of work bracketed by `/trove:session` at the start, and `/trove:save` at the end.

1. **First time on a project**: invoke `/trove:init` once. On a project with existing code it will seed the canonical files from your README, manifests, top-level structure, and a sampled read of code — written directly to disk for review.
2. **Begin a session**: invoke `/trove:session` — it loads canonical files, plans, decisions, topics, and recent git log, giving you continuity from the prior session. (The SessionStart hook also auto-loads canonicals + plans on every fresh start, resume, and compaction — so post-compaction recovery doesn't require manual reload.)
3. **Iterate with Claude as usual**; you own git staging and commits.
4. **End the session**: invoke `/trove:save` to update the meta layer based on accumulated git changes.

The plugin assumes the user owns git state — Claude never runs `git add`, `git commit`, or any state-mutating git command.

All skills except `/trove:session` are explicit-invocation only — Claude won't auto-invoke them based on message content; you must use the slash command to trigger them. `/trove:session` may be auto-invoked when Claude detects the start of a Trove-managed task.

## Don't switch agents mid-feature

Trove's contract is that `trove/` plus git is the complete context. That contract holds at *clean* boundaries — after a `/trove:save` and ideally a commit. It does **not** hold mid-implementation, when in-flight state lives in chat (decisions just made, hypotheses being tested, partial diffs, what the user said two turns ago).

The recommended workflow is therefore:

1. Finish the unit of work in one agent.
2. `/trove:save` to land durable lessons in the trove.
3. Commit (or at least stage) what you have.
4. Then switch agents if needed.

If you must hand off mid-feature, do it via a chat message to the receiving agent describing the in-flight state — that's lighter and more accurate than a serialized handover doc, and it doesn't pretend the work has reached a saveable boundary when it hasn't.

## Auto-loading at session start

Once installed, the plugin registers a `SessionStart` hook that fires on `startup`, `resume`, and `compact`. The hook script (`scripts/load-trove-session.sh`) is global — it runs in every Claude Code session — but self-gates on `[ -d trove ]` and exits silently in projects without a trove directory.

When a `trove/` exists, the hook reads the three canonical files (`summary.md`, `terminology.md`, `practices.md`) and the full content of `plans/` (current in-flight work), then injects them as `additionalContext` so the agent has them in scope without manual `/trove:session`. This closes the gap that used to appear after compaction (where the agent lost context-loaded files) and after `/trove:save` updates trove files mid-session.

`decisions/` and `topics/` are intentionally **not** auto-loaded. They're reference material the agent reads on demand when the current task surfaces a relevant area. The hook itself emits a fixed read-on-demand directive — that guidance is part of the framework, not user content, so it's reliable across projects regardless of what `practices.md` happens to contain. This keeps the auto-load size flat as the trove grows. (The predecessor "lode" framework had a `lode-map.md` index that was deliberately not carried over to trove: directory structure plus descriptive filenames serve the same purpose without the maintenance burden.)

Requires `jq` on the user's PATH. If `jq` is unavailable the hook exits silently — you can still use `/trove:session` manually.

The hook does not replace `/trove:session` entirely. The skill still does the explicit "ack and summarize what was loaded" pass. Practical pattern:
- Fresh project session: invoke `/trove:session` to get the explicit summary.
- Mid-conversation compaction or after `/trove:save`: rely on the hook.
