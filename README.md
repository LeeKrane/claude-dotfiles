# Claude Code config

Personal global configuration for Claude Code (`~/.claude`). Clone into `~/.claude`. New machine: see `SETUP.md`. Claude Code is routed through the teamclaude proxy by the shell environment, not by `settings.json` — see the note at the top of `SETUP.md`.

## Layout

| Path | What |
|---|---|
| `CLAUDE.md` | Global instructions loaded into every session |
| `settings.json` | Permissions, hooks, model, statusline, plugins |
| `statusline-command.sh` | Statusline script (model, context fill, 5h/7d limits with ↻ reset times, pace-aware 7d color, prompt-cache flame/snowflake) |
| `hooks/block-env-access.sh` | PreToolUse Bash hook that blocks commands touching `.env` files (self-authored) |
| `hooks/test-block-env-access.sh` | Test for that hook: `bash ~/.claude/hooks/test-block-env-access.sh` prints `ALL PASS` |
| `hooks/patch-claude-mem-quota.sh` | SessionStart hook that patches claude-mem's worker so it stops pausing near a usage limit (self-authored) |
| `hooks/test-patch-claude-mem-quota.sh` | Test for that hook: `bash ~/.claude/hooks/test-patch-claude-mem-quota.sh` prints `ALL PASS` |
| `.claude/settings.json` | Project settings for this repo only: `worktree.bgIsolation: "none"`, so background sessions edit `main` in place |
| `.claude/CLAUDE.md` | Rules for this repo only: edit on `main`, never commit; only `/dotfiles-release` commits |
| `skills/cleanup-session-codebase/` | `/cleanup-session-codebase` skill (self-authored) |
| `skills/cleanup-whole-codebase/` | `/cleanup-whole-codebase` skill (self-authored) |
| `skills/dotfiles-apply/` | `/dotfiles-apply` skill (self-authored) |
| `skills/dotfiles-release/` | `/dotfiles-release` skill (self-authored) |
| `skills/skill-scout/` | `skill-scout` skill (self-authored) |
| `skills/repo-skills/` | `/repo-skills` skill (self-authored) |
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
| `skills/unslop/` | `unslop` skill (cursor/plugins pstack, via `npx skills`; description narrowed locally) |
| `skills/to-spec/` | `/to-spec` skill (mattpocock/skills@d653911, pinned copy) |
| `skills/to-tickets/` | `/to-tickets` skill (mattpocock/skills@d653911, pinned copy) |
| `skills/implement/` | `/implement` skill (mattpocock/skills@d653911, pinned copy; Skill calls remapped) |
| `skills/implement-spec/` | `/implement-spec` skill (mattpocock/skills@d653911, pinned copy; Skill calls remapped) |
| `skills/spec-review/` | `/spec-review` skill (mattpocock/skills@d653911, pinned copy; renamed from upstream `code-review`) |
| `skills/improve-codebase-architecture/` | `/improve-codebase-architecture` skill (mattpocock/skills@d653911, pinned copy; `CONTEXT.md` edit) |
| `skills/teach/` | `/teach` skill (mattpocock/skills@d653911, pinned copy) |
| `skills/to-questionnaire/` | `/to-questionnaire` skill (mattpocock/skills@d653911, pinned copy) |
| `skills/wizard/` | `wizard` skill (mattpocock/skills@d653911, pinned copy; off by `skillOverrides`, enabled per project via `pocock-extras`) |
| `skills/codebase-design/` | `codebase-design` skill (mattpocock/skills@d653911, pinned copy; `CONTEXT.md` edit; off by `skillOverrides`, enabled per project via `pocock-extras`) |
| `skills/ponytail/` | `ponytail` core skill only (DietrichGebert/ponytail@96608e0, pinned copy; no plugin or hooks; superpowers precedence set in CLAUDE.md) |
| `REPO-SKILLS.md` | Registry of repo-scoped skills (vetted, never global), installed per project via `/repo-skills` |
| `vendor/` | Locally edited or self-authored repo-scoped skills that `REPO-SKILLS.md` entries install from (provenance comment in each SKILL.md) |
| `CHANGELOG.md` | Integer-versioned changelog for this repo |

## settings.json

- `env`: `BASH_MAX_OUTPUT_LENGTH=150000`, `WATERMARKS_HOOK_MODE=clean` (read by the watermarks-remover plugin), `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1` (turns off auto-updater, telemetry, error reporting and `/bug`)
- `permissions.allow`: `mcp__codegraph__*`, `Bash(rtk read *)`, `Bash(rtk grep *)`
- `permissions.deny`: Read/Grep on `node_modules/`, `.nuxt/`, `.output/`, `dist/`, `.data/`, `.cache/`; Read/Edit/Grep on `**/.env` and `**/.env.*` (this also blocks the Read tool on `.env.example`; deny rules allow no exceptions)
- `permissions.defaultMode`: `auto` — safety classifier approves routine actions instead of prompting; falls back to default mode with a notice where auto mode is unavailable
- `model`: `opus[1m]` (Opus 5.5, 1M context)
- `autoCompactWindow`: `400000` (auto-compact budgets against 400K, not the 1M window; applies to every launch, `claude-plain` included)
- `outputStyle`: `Concise` (built-in style: leads with results, skips preamble and narration)
- `modelSettings`: pins Opus 5.5 effort to `medium` (its default; set via `/model`)
- `inputNeededNotifEnabled`, `agentPushNotifEnabled`: both `true`
- `attribution`: `commit` and `pr` both `""` (no Claude Code co-author trailer on commits, no "Generated with Claude Code" line in PRs)
- `statusLine`: shells out to `statusline-command.sh` (needs jq)
- `skillOverrides`: 65 skills set to `"off"` (no listing tokens, no `/name`): 63 unused ones chosen by a `/doctor` usage scan on 2026-11-20, plus `wizard` and `codebase-design` (2026-11-24). Plugins stay enabled, so their hooks keep running. Situational ones are turned back on per project through `REPO-SKILLS.md`; any one can also be turned back on in `/skills`

### Hooks

| Hook | Command | Purpose | Needs |
|---|---|---|---|
| SessionStart | `bash ~/.claude/hooks/patch-claude-mem-quota.sh` | Patches every cached claude-mem `worker-service.cjs`: usage thresholds and the 5-hour grace buffer go above 100%, so only a real provider rejection stops the observer, and the cooldown after a rejection drops from 30 to 2 minutes. Leaves non-matching builds alone; restarts the worker only when a file changed. Re-applies after plugin updates | bash, sed, jq, curl |
| UserPromptSubmit | `codegraph prompt-hook` | Injects CodeGraph context into the prompt | codegraph |
| PreToolUse (Bash) | `rtk hook claude` | Rewrites Bash calls through RTK for compact output | rtk |
| PreToolUse (Bash) | `bash ~/.claude/hooks/block-env-access.sh` | Blocks (exit 2) commands that touch `.env`, `.env.*` or `.env*`; allows `.env.example`/`.sample`/`.template`/`.tpl`/`.dist` and `.envrc`. Matches command text only, so obfuscated paths get through | bash, jq |

### Plugins

| Plugin | Marketplace | Purpose |
|---|---|---|
| `caveman@caveman` | JuliusBrussee/caveman | Ultra-compressed communication mode |
| `superpowers@superpowers-dev` | obra/superpowers | Core skills library: TDD, debugging, collaboration patterns |
| `claude-mem@thedotmack` | thedotmack/claude-mem | Persists context/memory across sessions |
| `impeccable@impeccable` | pbakaus/impeccable | Design fluency for frontend dev (polish, audit, critique) |
| `security-guidance@claude-plugins-official` | ships with Claude Code | Hooks-only security guardrails: pattern warnings + LLM diff review on commit/push |
| `skill-creator@claude-plugins-official` | ships with Claude Code | Create, improve, and eval skills; description-trigger optimization. Disabled (`enabledPlugins: false`, 1 use since install); enable it again when you write skills |
| `watermarks-remover@watermarks-remover` | guillaumemeyer/watermarks-remover | Removes AI provenance marks from generated files. On install it writes `WATERMARKS_HOOK_MODE` into `settings.json` and leaves a `settings.json.bak-wm` backup |

`enabledPlugins` and `extraKnownMarketplaces` in `settings.json` declare these; installation itself is not versioned (see `SETUP.md`).

## CLAUDE.md

- **Sub-agents** — bulk work goes through sub-agents, cheapest model first (haiku for lookups/mechanical edits, sonnet for implementation, opus only for finished-diff review or security-critical code); small bounded jobs (1–3 tool calls on a known file) run inline since spawn overhead outweighs the saving. Keeps the main thread's context small.
- **RTK** — search with Bash (rg/grep/find) so the RTK hook compacts output; read known files with Read.
- **File writes** — create and change files only with Write/Edit/NotebookEdit or the REPL `write()`/`edit()` helpers, never through Bash, because the watermarks-remover hook only cleans files written by those tools. Exceptions: build/formatter output and `jq` settings merges.
- **Coding-discipline precedence** — superpowers TDD and brainstorming win over the `ponytail` skill (failing test first, design dialogue before building); ponytail governs how small and reuse-first the code is after that. Claude loads `ponytail` via the Skill tool before writing or changing code; subagent implementation prompts say "follow ponytail".
- **Review handoff** — at the end of any task that changed files or ran actions, Claude lists what to check first, most important first: changes made or sent outside the chat and where to find them, assumptions it did not verify, and unfinished work. Things that are fine are left out.
- **Git & PRs** — no PRs and no pushes unless explicitly asked; commit messages are subject-only, no body, overriding caveman-commit; never add `Co-Authored-By: Claude` or other Claude/Anthropic attribution to commits or PRs (titles, bodies, comments). For this repo only, `.claude/CLAUDE.md` adds: edit on `main` without worktrees or branches, never commit; `/dotfiles-release` makes the only commits.
- **Comments** — none by default, docstrings included; allowed only as one-liners: machine-read directives, license headers, a non-obvious confirmed why or workaround, a URL or issue next to a pinned version/hash/workaround, section banners, and ponytail `shortcut:` notes. Allowed comments are kept unless their code changed or they became wrong.
- **CodeGraph** — the block between the `CODEGRAPH_START`/`CODEGRAPH_END` markers is written by the `codegraph` installer and compressed locally; re-running `codegraph install` resets it to stock text. Applies only in repos with `.codegraph/`; the MCP server is disabled for this repo.

## Skills & commands

Some skills are *repo-scoped*: vetted and wanted, but deliberately never installed or enabled globally. They are recorded in `REPO-SKILLS.md` (source, pinned commit, signals, enable recipe) and installed per project by `/repo-skills`. Currently: `video-shotcraft`, `brag`, `obsidian-notes-creator`, and for `krane-solutions-business-orchestration` `hormozi-offer`, `pricing-strategy`, `business-model`, `objection-destroyer`, `marketing-council` (manual-only), for `KraneticFitness` the 11-skill `replica-skill` pack, `convert-documents-to-markdown` (anydoc, vendored with local edits in `vendor/`, needs the `anydoc` CLI from the NixOS dotfiles), `pdf-to-obsidian-notes` (self-authored in `vendor/`: PDF to cleaned Markdown to Obsidian study notes; `Requires` the anydoc and obsidian-notes-creator entries, which `/repo-skills` installs alongside), and for both `KraneticFitness` and `krane-solutions-business-orchestration` `condom` (manual-only pre-ship security and legal audit, once backend code exists). The registry also holds `plugin`-type entries for skills that are installed but turned off globally in `settings.json` `skillOverrides`, which a project turns back on with `"on"` in its `.claude/settings.local.json`: `engineering-skills` (wayfinder, setup-matt-pocock-skills, domain-modeling, grilling, prototype), `codebase-cleanup` (cleanup-session-codebase, cleanup-whole-codebase, blast-radius), `superpowers-extras`, `frontend-design` (impeccable, claude-mem design-is), `claude-mem-planning`, `claude-mem-github`, `caveman-workflows`, `caveman-cloud`, `writing-cleanup` (watermarks-remover skills), `office-documents` (anthropic-skills docx/pptx/xlsx/pdf) and `pocock-extras` (wizard, codebase-design).

### Self-authored skills

- `/cleanup-session-codebase` — reviews the session's diff and removes dead code, debug logging, and orphaned files/tests; double-checks every finding before deleting.
- `/cleanup-whole-codebase` — same cleanup across the entire repo, not just the session's diff; double-checks every finding before deleting.
- `/dotfiles-apply` — after a `git pull`, brings this machine up to date with any pending `CHANGELOG.md` versions.
- `/dotfiles-release` — after editing this repo, fetches the remote (refuses if a newer version exists upstream), bumps the version, drafts a `CHANGELOG.md` entry, syncs README/SETUP, commits, and pushes to `origin` (refusing to force if the remote moved).
- `skill-scout` — two-stage. Find searches findskills.org's API and skills.sh's `npx skills find` (WebSearch/WebFetch fallback) for candidate skills/plugins, and the user picks which are worth a closer look via AskUserQuestion; Vet then evaluates only those picks against real usage data: overlap matrix with replacement comparisons (measured always-on and on-invocation token cost, capability delta, keep/replace/alongside/skip), scaled fit/benefit/overlap/token scoring, skill-vs-hook form check, a capabilities list per candidate plus an intent check (AskUserQuestion: which aspects the user would actually use, and where — all projects or specific repos; answers rescore fit/benefit and lean the call toward project-scope), then an automatic `council-review` debate on overlap, gaps, fit, and form (`--no-council` to opt out), SkillSpector + manual security gate, per-candidate integration research after approval (placement, dependencies, env var names, config fragments such as `skillOverrides`, trigger interplay, stack fit with RTK/caveman/teamclaude, smoke test) applied on approval, and channel-ordered install with keep/alongside/replace/hook/hybrid branches — reporting before anything is installed, as a per-candidate one-fact-per-line list (description, overlap, cost, form, score, call, because, flips-if, intent). An Integrate mode skips straight to integration research for an already-vetted skill. Also `/skill-scout`.
- `/repo-skills` — reads `REPO-SKILLS.md`, matches each entry's signals (repo name, deps, files, user phrasing) against the current project, reports a match table, and on approval installs a pinned copy (or a copy of a vendored skill from `vendor/`) under the project's `.claude/skills/<name>/` (excluded via `.git/info/exclude`) or re-enables a plugin in its `.claude/settings.local.json`, installs any entries named in its `Requires` field first, then deep-merges the entry's Setup `config:` fragments into that file (a `setup-only` action applies them to an already-installed skill) and lists `manual:` items as follow-ups. Never global. `--list` reports without changing anything.

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
- `/to-spec` (mattpocock/skills@d653911, pinned copy) — turns the current conversation into a spec on the project's issue tracker, without an interview.
- `/to-tickets` (same pin) — splits a plan, spec, or conversation into tracer-bullet tickets that declare their blocking edges, published to the configured tracker.
- `/implement` (same pin) — implements a piece of work from a spec or tickets; calls `superpowers:test-driven-development` and `/spec-review` (local edit).
- `/implement-spec` (same pin) — implements the result of `/to-spec` and `/to-tickets` ticket by ticket; same local Skill remaps as `/implement`.
- `/spec-review` (same pin; upstream `code-review`, renamed so the built-in `/code-review` stays the default) — reviews the diff since a fixed point on two axes in parallel subagents: repo coding standards and the originating spec.
- `/improve-codebase-architecture` (same pin; uses `CONTEXT.md`) — scans for deepening opportunities, presents them as an HTML report, then grills through the one you pick. Calls `codebase-design`, which is off globally; enable `pocock-extras` in projects that use it.
- `/teach` (same pin) — stateful teaching across sessions: mission, glossary, resources and a learning record in the workspace.
- `/to-questionnaire` (same pin) — turns a decision you can't answer alone into a Markdown questionnaire for someone else to fill in.
- `wizard` (same pin; off globally, `pocock-extras` in `REPO-SKILLS.md`) — generates an interactive bash script from `template.sh` that walks a human through manual steps (dashboards, credentials, CI secrets, cutovers).
- `codebase-design` (same pin; off globally, `pocock-extras`) — deep-module vocabulary (module, interface, depth, seam, adapter, leverage, locality) and a design-it-twice pattern with parallel subagents.
- `ponytail` (DietrichGebert/ponytail@96608e0, core skill only, pinned copy) — "lazy senior dev" mode: smallest complete change, reuse before new code, no speculative abstraction, replies end with what was skipped; levels `/ponytail lite|full|ultra`. Yields to superpowers TDD/brainstorming per CLAUDE.md.
- `/technical-writing` — layered doc standard (Diátaxis mode, Google developer style, STE sentence rules, Global English) for docs, RFCs, readmes, and PR descriptions.
- `/blast-radius` — hunts what a change breaks beyond the diff and proves the one safety fact by running real code; unproven stays labeled unproven.
- `/unslop` — strips AI writing tells (31-pattern catalog) and adds voice; its description limits it to runs chained by technical-writing/blast-radius or invoked explicitly.

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
| jq | statusline, SETUP teamclaude step |
| teamclaude | mandatory: pools Team/Enterprise seats, rotates on quota; per-user service on port 3456, pinned `1.1.21` with `autoUpdate: false` (SETUP step 3b; NixOS hosts get it from `~/.dotfiles` instead of npm); on NixOS hosts the fish `claude` function runs Claude Code with Code Mode through its MITM (refuses to start if teamclaude is down; falls back to the base URL without Code Mode if its CA is missing), `claude-plain` is stock Claude Code |

## Not tracked

Session and project transcripts, caches, daemon state, the plugin install cache, `plans/`, and secrets (`.credentials.json`, daemon/session keys) are never committed. `.gitignore` is an allowlist, so any new runtime file stays ignored by default.

The `autoMode` block (auto-mode environment context, incl. trusted repos) is per-machine and intentionally not versioned. `settings.local.json` and `settings.json.bak*` are never tracked. `.dotfiles-version` (this machine's installed dotfiles version, see "Versioning" above) is also never tracked.
