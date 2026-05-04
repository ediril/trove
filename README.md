# Trove Coding

A disciplined approach to AI-assisted software development through iterative context management, delivered as a Claude Code plugin.

## Context Management, Not Context Engineering

Unlike context engineering, which often focuses on upfront creation of inventory, Trove is iterative and conversational. It's an optimised and simplified approach that focuses on outcomes, discovery, and delivery.

The term "trove" evokes a hoard of accumulated value — architecture decisions, patterns, domain knowledge, and lessons learned. Your project's trove emerges organically from conversations with your AI assistant rather than being authored upfront.

## This Repository

Trove ships as a Claude Code plugin under `claude/`. It is fully skill-based — there is no system prompt to install, no shell launcher to run. Once the plugin is installed, three slash-command skills drive the workflow:

- **`/trove:init`** — bootstrap a `trove/` skeleton (no-op if it already exists). On a project with existing code, seeds the canonical files from README, manifests, top-level structure, and a sampled read of code.
- **`/trove:session`** — begin a session; loads canonical files, plans, decisions, topics, and recent git log.
- **`/trove:save`** — update meta-entries from accumulated git changes.

## Installation

In any Claude Code session, add this repository as a marketplace and install the plugin:

```
/plugin marketplace add ediril/trove
/plugin install trove
```

Verify with `/plugin marketplace list` and `/plugin list`.

### Upgrade

```
/plugin marketplace update trove
/plugin update trove

/reload-plugins
```

## What is the trove?

The `trove/` directory is your project's meta-layer memory: principles, plans, decisions, rationale, terminology, lessons learned — things git and code can't capture.

Code-level facts (function signatures, behaviors, file structure) live in the code; the trove never duplicates them.

## Workflow

A "session" is a unit of work bracketed by `/trove:session` at the start, and `/trove:save` at the end.

1. **First time on a project**: invoke `/trove:init` once. On a project with existing code it will seed the canonical files from your README, manifests, top-level structure, and a sampled read of code.
2. **Begin a session**: invoke `/trove:session` — it loads canonical files, plans, decisions, topics, and recent git log, giving you continuity from the prior session.
3. **Iterate with Claude as usual**; you own git staging and commits.
4. **End the session**: invoke `/trove:save` to update the meta layer based on accumulated git changes.

The plugin assumes the user owns git state — Claude never runs `git add`, `git commit`, or any state-mutating git command.

All skills except `/trove:session` are explicit-invocation only — Claude won't auto-invoke them based on message content; you must use the slash command to trigger them. `/trove:session` may be auto-invoked when Claude detects the start of a Trove-managed task.

A `SessionStart` hook also auto-injects the canonical trove files plus `plans/` into the agent's context on session start, resume, and after compaction — keeping current direction and in-flight work fresh without manual reload. `decisions/` and `topics/` are read on demand based on the current task, keeping the auto-load size flat as the trove grows. The hook self-gates on the presence of a `trove/` directory, so projects without a trove are unaffected. Requires `jq`.

## Don't switch agents mid-feature

Trove's contract is that `trove/` plus git is the complete context. That contract holds at *clean* boundaries — after a `/trove:save` and ideally a commit. It does **not** hold mid-implementation, when in-flight state lives in chat (decisions just made, hypotheses being tested, partial diffs).

The recommended workflow is therefore:

1. Finish the unit of work in one agent.
2. `/trove:save` to land durable lessons in the trove.
3. Commit (or at least stage) what you have.
4. Then switch agents if needed.

If you must hand off mid-feature, do it via a chat message to the receiving agent describing the in-flight state — lighter and more accurate than a serialized handover doc, and it doesn't pretend the work has reached a saveable boundary when it hasn't.

## Other Coding Agents

Claude Code only, for now. Get in touch if you'd like to see Trove on another agent.
