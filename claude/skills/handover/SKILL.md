---
description: Write a handover document to trove/tmp/ capturing in-flight task state. Use before switching to another coding agent so the next agent (via /trove:resume) can pick up. Not typically needed within Claude Code — /trove:session usually provides enough continuity from canonical files, plans, decisions, topics, and git log.
allowed-tools: Read, Write, Edit, Bash
disable-model-invocation: true
---

# Trove Handover

## Verify trove/ is set up

Check that `trove/` exists. If not, tell the user to run `/trove:init` first and stop.

## First, perform a save
Run `echo "$CLAUDE_PLUGIN_ROOT"` via the Bash tool to get the plugin's root path, then Read the file at `<that-path>/skills/save/SKILL.md` and follow its procedure exactly. This captures any durable meta-level changes (decisions, principles, plan updates, topic notes) into the trove files.

If nothing has changed since the last save, the save procedure exits as a no-op — that's fine; continue to the handover write below regardless.

This ordering means durable meta lives in the trove (where the next session loads it automatically), and the handover doc focuses on in-flight task state.

## Write the handover document

Create a file at `trove/tmp/handover-<YYYY-MM-DD-HHMM>.md` capturing:

- **Current task**: what you're working on, in one or two sentences
- **Decisions made this session**: brief summary; reference the structured entries in `trove/decisions/<slug>.md` (just created or updated by the preceding save) by filename
- **Approaches tried**: including what didn't work and why
- **Blockers**: anything stuck or waiting on input
- **Next steps**: concrete, actionable items for the next session
- **Relevant trove files**: paths the next session should read first to pick up the task

Use today's date for the filename timestamp (run `date +%Y-%m-%d-%H%M` via the Bash tool if needed).

## Goal
A fresh session reading this document should be able to resume seamlessly without scrolling back through the prior chat.

## After writing
Tell the user the exact path. Suggest that in their next session they invoke `/trove:resume` — it will load the canonical trove files and read this handover automatically.

## Notes
- `trove/tmp/` is git-ignored — handover docs are session-scoped, not permanent project memory.
- Once the next session has used the handover doc, it can be deleted, or pruned at the next `/trove:save`.
