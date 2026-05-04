#!/usr/bin/env bash
# Trove session loader. Single source of truth for what gets loaded at
# session start.
#
# Two output modes:
#   default      — plain text on stdout. Used by skills/session/SKILL.md
#                  (which instructs the agent to run this script and treat
#                  its output as auto-loaded context). Cross-agent friendly.
#   --hook-json  — JSON wrapped per the SessionStart hook protocol
#                  ({"hookSpecificOutput": {...}}). Used by hooks/hooks.json
#                  in Claude Code.
#
# Self-gates on the presence of trove/ in $CLAUDE_PROJECT_DIR (or $PWD if
# that env var is not set). No-op otherwise, so it is safe to register
# globally — projects without a trove are unaffected.
#
# Loads the three canonical files (summary.md, terminology.md, practices.md)
# and the full content of plans/ — current in-flight work that is critical
# context, especially after compaction.
#
# Does NOT auto-load decisions/ or topics/. Those are reference material the
# agent should pull in on demand based on the current task. A fixed
# read-on-demand directive is emitted at the end of the load. (Relying on
# practices.md for the directive is unreliable — seed-generated practices.md
# varies by project.) Eager-loading every file would also balloon the
# auto-load as the trove grows; lode's lode-map.md was deliberately not
# carried over to trove for the same reason: directory structure plus
# descriptive filenames are the implicit map.

set -euo pipefail

mode="text"
case "${1:-}" in
  --hook-json) mode="hook-json" ;;
  "" ) ;;
  *) echo "usage: $(basename "$0") [--hook-json]" >&2; exit 2 ;;
esac

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$PWD}"
TROVE="$PROJECT_DIR/trove"

# Self-gate: do nothing if this project does not use trove.
if [[ ! -d "$TROVE" ]]; then
  exit 0
fi

# JSON output requires jq. Plain-text mode does not.
if [[ "$mode" == "hook-json" ]] && ! command -v jq >/dev/null 2>&1; then
  exit 0
fi

emit_file() {
  local path="$1"
  local label="$2"
  if [[ -f "$path" ]]; then
    printf '## %s\n\n' "$label"
    cat "$path"
    printf '\n\n'
  fi
}

emit_dir() {
  local dir="$1"
  local label="$2"
  if [[ -d "$dir" ]]; then
    local printed_header=0
    for f in "$dir"/*.md; do
      [[ -f "$f" ]] || continue
      if [[ $printed_header -eq 0 ]]; then
        printf '## %s\n\n' "$label"
        printed_header=1
      fi
      printf '### %s\n\n' "$(basename "$f")"
      cat "$f"
      printf '\n\n'
    done
  fi
}

context="$(
  printf '# Trove auto-loaded context\n\n'
  printf 'The following project meta-knowledge was loaded automatically from `trove/`. Treat as if `/trove:session` had run: read it, hold the principles in mind, and apply them throughout the session.\n\n'

  emit_file "$TROVE/summary.md"     "summary.md"
  emit_file "$TROVE/terminology.md" "terminology.md"
  emit_file "$TROVE/practices.md"   "practices.md"

  emit_dir "$TROVE/plans" "plans/"

  if [[ -d "$TROVE/decisions" || -d "$TROVE/topics" ]]; then
    printf '## Reference material (read on demand)\n\n'
    printf 'Reference files exist under `trove/decisions/` and `trove/topics/` and are NOT auto-loaded. Before non-trivial code changes, list those directories and read any files whose subject matches the area being changed. After the change, re-check them to verify nothing was missed (e.g., a known coupling).\n\n'
  fi
)"

# Skip output entirely if the trove is empty (no canonical files yet) — avoids
# emitting just a header with nothing under it.
if [[ -z "$(printf '%s' "$context" | tail -n +4)" ]]; then
  exit 0
fi

if [[ "$mode" == "hook-json" ]]; then
  jq -n --arg ctx "$context" '{
    "hookSpecificOutput": {
      "hookEventName": "SessionStart",
      "additionalContext": $ctx
    }
  }'
else
  printf '%s' "$context"
fi
