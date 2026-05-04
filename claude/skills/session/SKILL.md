---
description: Begin a fresh Trove Coding session by loading canonical trove files into context. Pair with /trove:save at session end.
allowed-tools: Read, Bash
---

# Trove Session

This skill is the cross-agent entry point for loading trove context. In Claude Code, a SessionStart hook runs the same loader automatically — invoking this skill there is only needed for the explicit acknowledgment pass.

## Verify trove/ is set up

Run via Bash: `[ -d trove ] && [ -f trove/summary.md ] && [ -f trove/terminology.md ] && [ -f trove/practices.md ] && echo ok`.

If the output isn't `ok`, tell the user to run `/trove:init` and stop.

## Load

Run the loader script and treat its stdout as auto-loaded project context — internalize the contents:

```bash
"${CLAUDE_PLUGIN_ROOT:-./claude}"/scripts/load-trove-session.sh
```

If `$CLAUDE_PLUGIN_ROOT` is not set (non-Claude-Code agents), the script lives in the trove plugin's install path; locate and run it from there.

The script is the single source of truth for what gets loaded — you do not need to know the file list yourself; just consume what the script emits.

## Acknowledge and proceed

Run `git log -10 2>/dev/null` (silent if no commits) for recent activity. Then briefly summarize what you've loaded — project domain, recent git activity, and current plans — in a short paragraph. Then await the user's instruction.

## Apply this philosophy throughout the session

- **Trove is the meta layer**: principles, plans, decisions, direction, terminology, rationale, lessons learned. Code-level facts (function signatures, behaviors, file structure) live in the code, not the trove.
- **User owns git state**: never run `git add`, `git commit`, or any state-mutating git command. AI changes appear as unstaged modifications; the user reviews and stages them.
- **Trove updates are user-triggered only**: do not auto-update trove files mid-session. The user invokes `/trove:save` when ready (typically at session end).
- **Code drift is real**: if you read a trove file and notice the code violates a documented principle or overrides a decision, flag it. Ask the user whether to update the trove or fix the code — do not auto-defer to the code; the principle may still hold.
