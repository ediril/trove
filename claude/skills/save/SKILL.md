---
description: Update trove/ to reflect meta-level changes since the last commit. Invoked explicitly by the user via /trove:save.
allowed-tools: Bash, Read, Edit, Write
disable-model-invocation: true
---

# Trove Save

## Verify trove/ is set up

Check that `trove/` exists. If not, tell the user to run `/trove:init` first and stop.

## Check whether anything has changed since the last save

First, run:

```bash
last_save_commit=$(cat trove/tmp/.last-save 2>/dev/null || echo "")
last_save_status=$(cat trove/tmp/.last-save-status 2>/dev/null || echo "")
current_head=$(git rev-parse HEAD 2>/dev/null || echo "")
current_status=$(git status --porcelain | sort)
```

If `last_save_commit` equals `current_head` AND `last_save_status` equals `current_status`, nothing has changed since the last `/trove:save`. Tell the user "no changes detected since the last `/trove:save` — nothing to update" and stop. This catches both the truly-no-changes case and the immediate re-invocation case (where save's own uncommitted writes from the previous run are still present).

## Scope: see what changed

If there are changes to review, run:
- `git status`
- `git diff HEAD`
- `git log $last_save_commit..HEAD 2>/dev/null` (or `git log -10 2>/dev/null` if `last_save_commit` is empty)

The user's workflow assumption: each task starts from a clean working tree, AI changes appear as unstaged modifications, the user stages approved iterations and commits when done. Your scope of review is everything since the last save — uncommitted changes plus any commits made since `last_save_commit`.

## What to update

For each change visible in the diff, ask: does this affect a documented **principle, plan, decision, topic, terminology entry, or direction** in the trove? Update only those entries.

**Code-level facts stay in the code.** Do not duplicate them into trove files.

### Content-type rules

When you have something to write, the rules below say *where it lands*. If a piece of content doesn't fit any of these, it belongs in code (or `tmp/`), not in the trove.

| Content                                                                                                           | Lands in                                                 |
| ----------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------- |
| Standing rule, project-wide, no alternatives debate                                                               | `practices.md`                                           |
| Fork-in-the-road: 2+ concrete options, choice with non-trivial rationale, rejected branches plausibly revisitable | `decisions/<slug>.md`                                    |
| Enduring shape of an area: invariants, contracts, internal patterns; not project-wide; not point-in-time          | `topics/<descriptive>.md`                                |
| Co-change / ripple: "when changing X, also check/update Y"                                                        | `topics/<area>-couplings.md` (or augment existing topic) |
| Plan status, progress, scope changes                                                                              | `plans/`                                                 |
| Project's overall direction changed                                                                               | `summary.md`                                             |
| New domain term or redefinition                                                                                   | `terminology.md`                                         |
| Anything observable from reading the source                                                                       | (don't write — it's code)                                |

**On `decisions/`**: only create one when *all three* hold — multiple concrete options were considered, the choice carried non-trivial rationale (not "industry standard" / "framework requires"), and rejected branches could plausibly be revisited. Use the structure: **Context → Decision → Rationale → Alternatives considered → Consequences**. Recall the conversation — decisions may not be visible in the diff yet.

**On topic notes (`topics/<descriptive>.md`)**: only write one when *all three* hold — area-specific (not project-wide), describes enduring shape (not a point-in-time call), and carries invariants/contracts/terminology-cluster heavier than a one-line entry. Use a descriptive slug for the filename (e.g., `pipeline-handoffs.md`, `auth-session-flow.md`). Save is forward-only — do not retroactively reorganize past entries in `decisions/` or `practices.md` into topics.

**On co-change / ripple notes (`topics/<area>-couplings.md`)**: when the user catches a missed place during this session ("you also need to update Y"), or when an invisible coupling between sites becomes apparent, capture it as a topic note. Lead with: *"When changing X, also check/update Y. Discovered when [reason]."* This is the trove's main mechanism for accruing implicit-coupling knowledge over time — the next session inherits the lesson instead of repeating the miss. Augment an existing couplings file when one fits, otherwise create a new one with a descriptive slug (e.g., `cic-yaml-couplings.md`).

### Housekeeping

- **`trove/tmp/`**: review handover documents (`handover-*.md`). If any describe work that has since been completed/committed, ask the user whether to delete them — stale handovers add noise.

## What "good" looks like

The trove is the *meta layer*, not a changelog and not code documentation:

- BAD (changelog): "Added retry logic on 2026-04-25."
- ALSO BAD (code-level fact): "API client retries 3 times with exponential backoff (100ms, 200ms, 400ms)."
- GOOD (decision + rationale): "Retry policy: 5xx and network errors only, never 4xx. Rationale: 4xx indicates a client-side bug; retrying masks the real issue."

## When code and trove disagree

If the diff shows code that violates a documented principle or overrides a decision, do not silently update the trove. Ask the user: should the trove entry be updated (the principle no longer holds), or should the code be fixed (the principle still holds and the code drifted)?

## After saving
Report which trove files were updated and why (one line each). Then record the current commit and working-tree fingerprint as the last-save markers so the no-change check works on the next invocation:

```bash
git rev-parse HEAD 2>/dev/null > trove/tmp/.last-save
git status --porcelain | sort > trove/tmp/.last-save-status
```

Update both markers even if no trove files were modified (e.g., when no meta-level changes were found in the diff) — the markers track "we checked at this point," not "we wrote something."

## Constraints
- Never run `git add`, `git commit`, or any state-mutating git command. The user controls the commit.
- Do not perform speculative updates. If a code change doesn't affect any documented meta entry, no trove update is needed.
- If no meaningful meta-level change is visible in the diff, say so and update nothing.
