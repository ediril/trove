---
description: Bootstrap a new Trove skeleton in the user's current project. Invoked explicitly by the user via /trove:init. Does nothing if trove/ already exists. For projects with existing code, seeds the canonical files from real project evidence (README, manifests, top-level structure, sampled code).
allowed-tools: Bash, Read, Write, Edit
disable-model-invocation: true
---

# Trove Init

Use the Bash tool to check whether `trove/` exists in the user's current working directory:

```bash
[ -d trove ] && echo "exists" || echo "missing"
```

If `trove/` already exists, stop. Tell the user the trove is already initialized and suggest invoking `/trove:session` to begin a fresh session, or `/trove:resume` if continuing from a prior session that ended with `/trove:handover`.

If `trove/` does not exist, create the directory skeleton (canonical files are created later — either by the seed procedure for existing projects, or as empty placeholders for greenfield projects):

```bash
mkdir -p trove trove/plans trove/decisions trove/topics trove/tmp
printf 'tmp/\n' > trove/.gitignore
echo "Trove directories created: trove/, trove/plans/, trove/decisions/, trove/topics/, trove/tmp/, trove/.gitignore"
```

## Detect existing project

After creating the skeleton, check whether this is an existing project that would benefit from seeding:

```bash
commits=$(git rev-list --count HEAD 2>/dev/null || echo 0)
non_trivial_files=$(git ls-files --cached --others --exclude-standard 2>/dev/null \
  | grep -vE '^(README\.md|LICENSE|\.gitignore|trove/)' \
  | awk -F/ 'NF<=2' \
  | wc -l | tr -d ' ')
echo "commits=$commits non_trivial_files=$non_trivial_files"
```

`git ls-files --cached --others --exclude-standard` lists tracked files plus untracked files that aren't ignored by `.gitignore` (or `.git/info/exclude` or the global exclude). README/LICENSE/.gitignore/trove are filtered out as they don't signal "real project content." `awk -F/ 'NF<=2'` keeps top-level files only. For non-git repos, `git ls-files` is silent and `non_trivial_files=0` — combined with `commits=0`, the project is treated as greenfield (trove-coding assumes git anyway).

Treat the project as **existing** if `commits > 1` OR `non_trivial_files > 0`. Otherwise treat it as **greenfield**.

## If existing project

Tell the user the project has existing code and that you'll seed the canonical files from it. Then run `echo "$CLAUDE_PLUGIN_ROOT"` via the Bash tool to get the plugin root, Read the file at `<that-path>/skills/init/seed.md`, and follow its procedure exactly. The seed procedure creates the three canonical files itself.

## If greenfield

Create empty canonical files and proceed to "Final guidance" — content will accrete organically:

```bash
touch trove/summary.md trove/terminology.md trove/practices.md
```

## Final guidance

Tell the user:

1. The three canonical files:
   - `trove/summary.md` — project purpose and current direction
   - `trove/terminology.md` — domain language
   - `trove/practices.md` — standing principles that apply to every session
2. Invoke `/trove:session` to begin the first session.
