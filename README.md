# Claude Code config

Personal global configuration for Claude Code (`~/.claude`). Clone into `~/.claude`. New machine: see `SETUP.md`.

## Layout

| Path | What |
|---|---|
| `CLAUDE.md` | Global instructions loaded into every session |
| `settings.json` | Permissions, hooks, model, statusline, plugins |
| `statusline-command.sh` | Statusline script (model, context fill, 5h/7d limits with ↻ reset times, pace-aware 7d color, prompt-cache flame/snowflake) |
| `skills/cleanup-session-codebase/` | `/cleanup-session-codebase` skill (self-authored) |
| `skills/cleanup-whole-codebase/` | `/cleanup-whole-codebase` skill (self-authored) |
| `skills/dotfiles-apply/` | `/dotfiles-apply` skill (self-authored) |
| `skills/dotfiles-release/` | `/dotfiles-release` skill (self-authored) |
| `skills/skill-scout/` | `skill-scout` skill (self-authored) |
| `skills/context-audit/` | `context-audit` skill (third-party, source unknown) |
| `skills/council-review/` | `council-review` skill (DMAD 5-advisor council; ngmeyer/skills, via `npx skills`) |
| `skills/handoff/` | `handoff` skill (mattpocock/skills, via `npx skills`) |
| `skills/wayfinder/` | `wayfinder` skill (mattpocock/skills, via `npx skills`) |
| `skills/research/` | `research` skill (mattpocock/skills, via `npx skills`) |
| `skills/domain-modeling/` | `domain-modeling` skill (mattpocock/skills, via `npx skills`) |
| `skills/prototype/` | `prototype` skill (mattpocock/skills, via `npx skills`) |
| `skills/grilling/` | `grilling` skill (mattpocock/skills, via `npx skills`) |
| `skills/setup-matt-pocock-skills/` | `setup-matt-pocock-skills` skill (mattpocock/skills, via `npx skills`) |
| `skills/technical-writing/` | `technical-writing` skill (cursor/plugins pstack, via `npx skills`) |
| `skills/blast-radius/` | `blast-radius` skill (cursor/plugins pstack, via `npx skills`) |
| `skills/unslop/` | `unslop` skill (cursor/plugins pstack, via `npx skills`; CLAUDE.md-gated) |
| `CHANGELOG.md` | Integer-versioned changelog for this repo |

## settings.json

- `env`: `BASH_MAX_OUTPUT_LENGTH=150000`, `WATERMARKS_HOOK_MODE=clean` (read by the watermarks-remover plugin)
- `permissions.allow`: `mcp__codegraph__*`, `Bash(rtk read *)`, `Bash(rtk grep *)`
- `permissions.deny`: Read/Grep on `node_modules/`, `.nuxt/`, `.output/`, `dist/`, `.data/`, `.cache/`
- `model`: `fable`
- `autocompactPercentageOverride`: `75`
- `inputNeededNotifEnabled`, `agentPushNotifEnabled`: both `true`
- `statusLine`: shells out to `statusline-command.sh` (needs jq)

### Hooks

| Hook | Command | Purpose | Needs |
|---|---|---|---|
| UserPromptSubmit | `codegraph prompt-hook` | Injects CodeGraph context into the prompt | codegraph |
| PreToolUse (Bash) | `rtk hook claude` | Rewrites Bash calls through RTK for compact output | rtk |

### Plugins

| Plugin | Marketplace | Purpose |
|---|---|---|
| `caveman@caveman` | JuliusBrussee/caveman | Ultra-compressed communication mode |
| `superpowers@superpowers-dev` | obra/superpowers | Core skills library: TDD, debugging, collaboration patterns |
| `claude-mem@thedotmack` | thedotmack/claude-mem | Persists context/memory across sessions |
| `impeccable@impeccable` | pbakaus/impeccable | Design fluency for frontend dev (polish, audit, critique) |
| `taste-skill@taste-skill` | Leonxlnx/taste-skill | Frontend design taste skills (brutalist, minimalist, soft, ...) — globally disabled; enable per project |
| `security-guidance@claude-plugins-official` | ships with Claude Code | Hooks-only security guardrails: pattern warnings + LLM diff review on commit/push |
| `frontend-design@claude-plugins-official` | ships with Claude Code | Distinctive, intentional visual design guidance for new UI |
| `skill-creator@claude-plugins-official` | ships with Claude Code | Create, improve, and eval skills; description-trigger optimization |
| `watermarks-remover@watermarks-remover` | guillaumemeyer/watermarks-remover | Removes AI provenance marks from generated files. On install it writes `WATERMARKS_HOOK_MODE` into `settings.json` and leaves a `settings.json.bak-wm` backup |

`enabledPlugins` and `extraKnownMarketplaces` in `settings.json` declare these; installation itself is not versioned (see `SETUP.md`).

## CLAUDE.md

- **Sub-agents** — all work goes through sub-agents, cheapest model first (haiku for lookups/mechanical edits, sonnet for implementation, opus only for finished-diff review or security-critical code). Keeps the main thread's context small.
- **RTK** — prefer Bash over Read/Grep/Glob so the RTK hook can rewrite calls for compact output; use `rtk lint`/`rtk tsc` for grouped errors.
- **Git & PRs** — no PRs and no pushes unless explicitly asked; commit messages are subject-only, no body; never add `Co-Authored-By: Claude` or other Claude/Anthropic attribution.
- **CodeGraph** — the block between the `CODEGRAPH_START`/`CODEGRAPH_END` markers is written by the `codegraph` installer; applies only in repos with `.codegraph/`.
- **Shell** — `cat` is aliased to `bat` on the origin machine, which corrupts piped output; always call `/usr/bin/cat` directly.

## Skills & commands

### Self-authored skills

- `/cleanup-session-codebase` — reviews the session's diff and removes dead code, debug logging, and orphaned files/tests; double-checks every finding before deleting.
- `/cleanup-whole-codebase` — same cleanup across the entire repo, not just the session's diff; double-checks every finding before deleting.
- `/dotfiles-apply` — after a `git pull`, brings this machine up to date with any pending `CHANGELOG.md` versions.
- `/dotfiles-release` — after editing this repo, bumps the version, drafts a `CHANGELOG.md` entry, syncs README/SETUP, and commits (never pushes).
- `skill-scout` — researches, evaluates, and vets candidate skills/plugins against real usage data: overlap matrix with replacement comparisons (measured always-on and on-invocation token cost, capability delta, keep/replace/alongside/skip), scaled fit/benefit/overlap/token scoring, skill-vs-hook form check, then an automatic `council-review` debate on overlap, gaps, fit, and form (`--no-council` to opt out), SkillSpector + manual security gate, and channel-ordered install with keep/alongside/replace/hook/hybrid branches — reporting before anything is installed. Also `/skill-scout`.

### Installed skills (third-party; source per entry)

- `context-audit` (source unknown) — audits Claude Code settings, CLAUDE.md, and skills for token waste; returns a health score.
- `/council-review` — runs a decision through 5 parallel advisors with distinct reasoning methods, anonymous peer review, a devil's-advocate pass, and a chairman verdict (`--quick`/`--adaptive`/`--confidence`/`--jury`).
- `/handoff` — compacts the current conversation into a handoff document (state, next steps, suggested skills) so a fresh session continues without re-deriving the plan.
- `/wayfinder` — plans work too big for one session as a map of decision tickets on the repo's issue tracker, resolved one per session until the route is clear.
- `research` — spawns a background agent that investigates a question against primary sources and saves a cited Markdown file into the repo.
- `domain-modeling` — actively sharpens project vocabulary: challenges conflicting terms, maintains `CONTEXT.md` as a glossary, records ADRs for hard-to-reverse decisions.
- `prototype` — builds throwaway prototypes to answer one design question: a clickable state-machine HTML demo (logic) or URL-param-switchable UI variants (look).
- `grilling` — interviews the user in structured rounds over a design tree until every decision is settled; wayfinder's conversation primitive.
- `/setup-matt-pocock-skills` — one-time per-repo scaffolding: issue-tracker choice, triage labels, and domain-doc layout that wayfinder and friends read.
- `/technical-writing` — layered doc standard (Diátaxis mode, Google developer style, STE sentence rules, Global English) for docs, RFCs, readmes, and PR descriptions.
- `/blast-radius` — hunts what a change breaks beyond the diff and proves the one safety fact by running real code; unproven stays labeled unproven.
- `/unslop` — strips AI writing tells (31-pattern catalog) and adds voice; gated in CLAUDE.md to run only when chained by technical-writing/blast-radius or invoked explicitly.

## Versioning

This repo uses simple integer versions (v1, v2, v3, …) tracked in `CHANGELOG.md`, newest first. Each entry is a summary of what changed — not a step list — since `/dotfiles-apply` infers the concrete actions at apply time by cross-referencing `SETUP.md`, `settings.json`, `skills/`, and `commands/`.

Each machine keeps its own installed version in `.dotfiles-version`, a local, gitignored file (never committed — the whole point is that it tracks what *this* machine has applied, which can lag behind the repo).

- After pulling changes on an existing machine: run `/dotfiles-apply` to bring it up to date.
- After editing this repo: run `/dotfiles-release` to bump the version and record what changed.

## External tools

| Tool | Used by |
|---|---|
| codegraph | UserPromptSubmit hook, MCP server, CLAUDE.md |
| rtk | PreToolUse hook, permissions |
| jq | statusline |
| bat | optional; only backs the `cat` alias |

## Not tracked

Session and project transcripts, caches, daemon state, the plugin install cache, `plans/`, and secrets (`.credentials.json`, daemon/session keys) are never committed. `.gitignore` is an allowlist, so any new runtime file stays ignored by default.

The `autoMode` block (auto-mode environment context, incl. trusted repos) is per-machine and intentionally not versioned. `settings.local.json` and `settings.json.bak*` are never tracked. `.dotfiles-version` (this machine's installed dotfiles version, see "Versioning" above) is also never tracked.
