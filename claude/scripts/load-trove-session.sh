#!/usr/bin/env bash
# SessionStart hook: auto-load canonical trove files into the agent's context.
#
# Self-gates on the presence of trove/ in $CLAUDE_PROJECT_DIR. No-op otherwise,
# so it is safe to register globally — projects without a trove are unaffected.
#
# Mirrors what /trove:session reads: summary.md, terminology.md, practices.md,
# and all files in plans/, decisions/, topics/. Skips git log -10 (cheap to
# re-run on demand) and the handover-doc prompt (replaced with a brief notice).

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

  emit_dir "$TROVE/plans"     "plans/"
  emit_dir "$TROVE/decisions" "decisions/"
  emit_dir "$TROVE/topics"    "topics/"

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
  "continue": true,
  "additionalContext": $ctx
}'
