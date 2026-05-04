# Seed procedure

This procedure is invoked by `/trove:init` when an existing project is detected. It is not a user-invocable skill on its own.

When this procedure runs, `/trove:init` has already created the directory skeleton (`trove/`, `trove/plans/`, `trove/decisions/`, `trove/topics/`, `trove/tmp/`, `trove/.gitignore`) but **has not** created the three canonical files. This procedure creates them.

The flow is read-write-tell: read source material, write the output directly, tell the user where the result landed. **No draft-and-approve loop in chat** — the canonical files on disk are the draft, and the user reviews them via normal `git diff` / edit afterward.

## Read project docs and metadata

Read what's there. Skip what's missing — do not fabricate.

- `README.md` — project purpose, direction, audience
- `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, `STYLEGUIDE.md`, `CLAUDE.md` — practices
- Manifest files: `package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod`, `Gemfile`, `pom.xml`, `build.gradle` — name, description, scripts, dependencies signal terminology
- `LICENSE` — for completeness only
- Top-level directory names (excluding `node_modules/`, `.git/`, `dist/`, `build/`, `target/`, `vendor/`, virtualenv dirs)
- Existing `docs/` content if present
- `git log -20 --oneline --no-merges 2>/dev/null` — recent direction signal (silent if not a git repo or no commits)

## Read code with a meta lens

Don't rely on docs alone — they're often thin. Sample the actual code, but read it for **meta-signal**, not as documentation.

**What to read** (sampled, not exhaustive):
- Project entrypoint(s): `src/index.ts`, `main.py`, `cmd/<binary>/main.go`
- A handful of representative source files across different top-level dirs
- 1–2 test files — tests often carry the cleanest domain language
- Configuration that reveals conventions: linter configs (eslint, ruff, golangci-lint), type checker configs (tsconfig, mypy.ini), CI workflows
- Type/schema definitions if obvious: `types/`, `schema.ts`, `models.py`

**What to extract:**
- Domain terminology — recurring class/type/concept names that carry meaning beyond generic programming → `terminology.md`
- Standing practices visible in tooling or repetition (typed functions everywhere, `Result` types instead of exceptions, etc.) → `practices.md`
- Project shape in 1–2 sentences (web + worker + queue; plugin system; CLI + library) → `summary.md`

**What NOT to extract:**
- Specific function behaviors, signatures, or call sites — code documents itself
- Module-by-module summaries — that's not meta, it's documentation
- Detailed API surfaces or schemas — they live in code

## Write the three canonical files

Write directly using the Write tool. The files do not exist yet (init left them uncreated specifically so this step can write fresh), so no prior Read is needed.

**`summary.md`** — one paragraph: what the project is for, who it serves, current direction, and project shape in a phrase. Source from README, manifest description, recent commits, and the code's overall structure.

**`terminology.md`** — short `term — meaning` lines for domain language a fresh contributor would not already know. Pull from recurring class/type names, manifest description, READMEs, and any glossaries. Skip generic programming terms.

**`practices.md`** — standing principles that apply project-wide. Pull from `CONTRIBUTING.md`, `CLAUDE.md`, style guides, conventions visibly enforced (linter config, type checker, CI checks), and visible repetition in code (e.g., "all functions typed"). Each entry is a rule with a one-line rationale. **Do not invent practices** the project hasn't actually adopted.

If the project doesn't already document an equivalent (in `CONTRIBUTING.md`, `CLAUDE.md`, or similar), add a *suggested starter* before/after change practice — explicitly marked as a starter for the user to validate or remove. This addresses the recurring AI failure mode where the model changes one site and misses parallel sites that need updating. Suggested wording:

> **Before any non-trivial code change:** grep for all callers/consumers of what you're touching; search for the same pattern elsewhere in the codebase; check `trove/topics/` for relevant cross-cutting notes. **After the change:** re-grep to verify nothing was missed; check parallel files (test, story, mock, dashboard config) for the same change.

Where evidence is thin elsewhere, leave a single-line TODO rather than fabricating. Example: `TODO: practices.md is empty — add as principles emerge from sessions.`

## After writing

Tell the user the trove has been seeded and where the three canonical files landed. Suggest:
- Reviewing the seeded content and editing as needed
- Invoking `/trove:session` to begin the first session

## Constraints
- **No code-level facts.** Function signatures, module structure, file paths, behaviors — these belong in the code, not the trove.
- **No topic notes at seed time.** `trove/topics/` accretes via save as cross-cutting connections, invariants, and co-change knowledge are discovered during real session work — do not speculatively populate it during seeding.
- **No fabrication.** If the evidence isn't there, leave a TODO and move on.
- **No git mutations.** Never run `git add`, `git commit`, or any state-changing git command.
