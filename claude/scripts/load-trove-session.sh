#!/usr/bin/env bash
# SessionStart hook: auto-load canonical trove files into the agent's context.
#
# Self-gates on the presence of trove/ in $CLAUDE_PROJECT_DIR. No-op otherwise,
# so it is safe to register globally — projects without a trove are unaffected.
#
# Loads the three canonical files (summary.md, terminology.md, practices.md)
# and the full content of plans/ — current in-flight work that's critical
# context, especially after compaction.
#
# Does NOT auto-load decisions/ or topics/. Those are reference material the
# agent should pull in on demand based on the current task — practices.md
# already directs the agent to check trove/topics/ before non-trivial code
# changes. Eager-loading every file would balloon the auto-load as the trove
# grows; lode's lode-map.md was deliberately not carried over to trove for
# the same reason (avoid maintenance burden + drift; let directory structure
# and descriptive filenames be the implicit map).

set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$PWD}"
TROVE="$PROJECT_DIR/trove"

# Self-gate: do nothing if this project doesn't use trove.
if [[ ! -d "$TROVE" ]]; then
  exit 0
fi

# Require jq for safe JSON output. If unavailable, exit silently rather than
# emit malformed output that would confuse the agent.
if ! command -v jq >/dev/null 2>&1; then
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

  # Surface handover docs without reading them — mirrors /trove:session
  # behavior of asking whether the user meant /trove:resume.
  if compgen -G "$TROVE/tmp/handover-*.md" >/dev/null 2>&1; then
    printf '## Notice\n\n'
    printf 'Handover documents exist in `trove/tmp/`. If you intended to continue prior work, run `/trove:resume` to load the most recent one.\n\n'
  fi
)"

# Skip output entirely if the trove is empty (no canonical files yet) — avoids
# injecting just a header with nothing under it.
if [[ -z "$(printf '%s' "$context" | tail -n +4)" ]]; then
  exit 0
fi

jq -n --arg ctx "$context" '{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": $ctx
  }
}'
