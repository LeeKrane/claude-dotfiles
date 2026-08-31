# Claude Code config

Personal global configuration for Claude Code (`~/.claude`). Clone into `~/.claude`. New machine: see `SETUP.md`.

## Layout

| Path | What |
|---|---|
| `CLAUDE.md` | Global instructions loaded into every session |
| `settings.json` | Permissions, hooks, model, statusline, plugins |
| `statusline-command.sh` | Statusline script (model, context fill, rate limits) |
| `commands/cleanup.md` | `/cleanup` slash command |
| `commands/dotfiles-apply.md` | `/dotfiles-apply` slash command |
| `commands/dotfiles-release.md` | `/dotfiles-release` slash command |
| `skills/context-audit/` | `context-audit` skill |
| `skills/council/` | `council` skill (+ `personas/`, `templates/`) |
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
| `ui-ux-pro-max@ui-ux-pro-max-skill` | nextlevelbuilder/ui-ux-pro-max-skill | UI/UX design intelligence: styles, palettes, fonts, charts |
| `taste-skill@taste-skill` | Leonxlnx/taste-skill | Frontend design taste skills (brutalist, minimalist, soft, ...) |
| `watermarks-remover@watermarks-remover` | guillaumemeyer/watermarks-remover | Removes AI provenance marks from generated files. On install it writes `WATERMARKS_HOOK_MODE` into `settings.json` and leaves a `settings.json.bak-wm` backup |

`enabledPlugins` and `extraKnownMarketplaces` in `settings.json` declare these; installation itself is not versioned (see `SETUP.md`).

## CLAUDE.md

- **Sub-agents** — all work goes through sub-agents, cheapest model first (haiku for lookups/mechanical edits, sonnet for implementation, opus only for finished-diff review or security-critical code). Keeps the main thread's context small.
- **RTK** — prefer Bash over Read/Grep/Glob so the RTK hook can rewrite calls for compact output; use `rtk lint`/`rtk tsc` for grouped errors.
- **Git & PRs** — no PRs and no pushes unless explicitly asked; commit messages are subject-only, no body; never add `Co-Authored-By: Claude` or other Claude/Anthropic attribution.
- **CodeGraph** — the block between the `CODEGRAPH_START`/`CODEGRAPH_END` markers is written by the `codegraph` installer; applies only in repos with `.codegraph/`.
- **Shell** — `cat` is aliased to `bat` on the origin machine, which corrupts piped output; always call `/usr/bin/cat` directly.

## Skills & commands

- `/cleanup` — reviews the session's diff and removes dead code, debug logging, and orphaned files/tests.
- `/dotfiles-apply` — after a `git pull`, brings this machine up to date with any pending `CHANGELOG.md` versions.
- `/dotfiles-release` — after editing this repo, bumps the version, drafts a `CHANGELOG.md` entry, and commits (never pushes).
- `context-audit` — audits Claude Code settings, CLAUDE.md, and skills for token waste; returns a health score.
- `council` — convenes 7 expert personas to debate a decision and produce a synthesized verdict.

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
