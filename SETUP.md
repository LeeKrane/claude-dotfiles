Instructions for an agent setting up Claude Code from this repo.
Run steps in order; verify each. Do not edit tracked files unless the user asks.

## 1. Prerequisites

- `git`, `bash`, `curl`.
- Claude Code itself: `claude --version`. If missing, install per https://docs.claude.com/en/docs/claude-code.

## 2. Clone

```
git clone <repo-url> ~/.claude
```

If `~/.claude` already exists:

```
mv ~/.claude ~/.claude.bak.$(date +%s)
git clone <repo-url> ~/.claude
```

Then copy back from the backup anything the user wants to keep (`.credentials.json`, `projects/`, `history.jsonl`, etc.).

## 3. Tools

| Tool | Purpose | Install | Verify |
|---|---|---|---|
| jq | statusline | `sudo dnf install jq` (Debian: `apt install jq`) | `jq --version` |
| rtk | PreToolUse hook, permissions | no distro package — install from https://github.com/rtk-ai/rtk releases (or its install script) into PATH | `rtk --version` |
| codegraph | UserPromptSubmit hook, MCP server | project's own installer (see its repo/docs); installs a `~/.local/bin/codegraph` symlink; update later with `codegraph upgrade` | `codegraph --version` |
| bat | optional | `sudo dnf install bat` | — |
| Nerd Font | optional; statusline cache-glyph (flame U+F0238) renders as tofu without one | install any Nerd Font and set it as the terminal font | — |

Ensure `~/.local/bin` is on PATH.

## 4. Log in

Run `claude` and log in (`/login`) — `.credentials.json` is not tracked. On a reinstall it can be copied back from the backup made in step 2.

## 5. MCP server

```
claude mcp add codegraph --scope user -- codegraph serve --mcp
```

Verify: `claude mcp list` shows `codegraph`.

## 6. Plugins

`settings.json` already lists marketplaces (`extraKnownMarketplaces`) and plugins (`enabledPlugins`). Start `claude` once, exit, then `claude plugin list`. For anything missing, run:

```
claude plugin marketplace add JuliusBrussee/caveman
claude plugin marketplace add obra/superpowers
claude plugin marketplace add thedotmack/claude-mem
claude plugin marketplace add pbakaus/impeccable
claude plugin marketplace add guillaumemeyer/watermarks-remover
```

```
claude plugin install caveman@caveman
claude plugin install superpowers@superpowers-dev
claude plugin install claude-mem@thedotmack
claude plugin install impeccable@impeccable
claude plugin install watermarks-remover@watermarks-remover
claude plugin install security-guidance@claude-plugins-official
claude plugin install skill-creator@claude-plugins-official
```

(`claude-plugins-official` ships with Claude Code — no `marketplace add` needed.)

Verify: `claude plugin list` shows all 7, all enabled.

Note: watermarks-remover patches `settings.json` on install (adds `env.WATERMARKS_HOOK_MODE`, writes a `settings.json.bak-wm` backup). The key is already tracked, so there should be no diff. If `git -C ~/.claude status --short` shows `settings.json` modified afterwards, inspect the diff; discard with `git -C ~/.claude checkout -- settings.json` unless the change is wanted. `settings.json.bak-wm` is gitignored and can be deleted.

## 6b. Skills installed via the skills CLI (skills.sh)

The `skills/` directory is tracked in this repo, so the clone already contains every skill — nothing to install. To register them with the skills CLI so `npx skills update` can pull upstream updates on this machine, optionally re-run the original installs (they overwrite with identical content):

```
npx -y skills@latest add mattpocock/skills --skill handoff --skill wayfinder --skill research --skill domain-modeling --skill prototype --skill grilling --skill setup-matt-pocock-skills --agent claude-code --global --yes
npx -y skills@latest add cursor/plugins --skill technical-writing --skill blast-radius --skill unslop --agent claude-code --global --yes
npx -y skills@latest add ngmeyer/skills --skill council-review --agent claude-code --global --yes
```

After an update run, review the diff before committing — skills are re-vetted on refresh (see CHANGELOG v3).

skill-scout's Find stage also calls `npx skills find <term>` (same CLI, already covered above) and, for higher-volume search, the findskills.org API. Optionally set `FINDSKILLS_API_KEY` (free key via `npx findskills auth` or findskills.org/developers) — without it, Find still works but findskills allows only one guest query per run before rate-limiting.

## 6c. Repo-scoped skills

`REPO-SKILLS.md` lists skills that are vetted but never installed globally (currently `video-shotcraft`, `brag`). Nothing to do on a fresh machine. In a project that wants one, run `/repo-skills` — it installs a pinned copy into that project's `.claude/skills/` only.

## 7. Verify

```
jq --version && rtk --version && codegraph --version
claude mcp list
claude plugin list
```

Then start `claude` in any directory and confirm:

- statusline renders
- `/cleanup-session-codebase`, `/cleanup-whole-codebase`, `/council-review`, `/context-audit`, `/repo-skills` appear in the slash-command list
- `git -C ~/.claude status --short` is empty
- `autoMode` is not tracked; run auto-mode setup on this machine if you want it

## 8. Record the installed dotfiles version

This repo tracks changes in `CHANGELOG.md` (integer versions, newest first). Now that setup is complete, mark this machine as current with the latest version:

```
grep -m1 -oP '## v\K[0-9]+' ~/.claude/CHANGELOG.md > ~/.claude/.dotfiles-version
```

`.dotfiles-version` is local and gitignored — it is not part of the repo.

**This is a one-time step.** For later updates, do not re-run this file: `git pull` in `~/.claude`, then run `/dotfiles-apply`, which reads `CHANGELOG.md` and brings the machine up to date with whatever changed since the version recorded here.
