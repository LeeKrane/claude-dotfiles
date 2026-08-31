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
claude plugin marketplace add nextlevelbuilder/ui-ux-pro-max-skill
claude plugin marketplace add Leonxlnx/taste-skill
claude plugin marketplace add guillaumemeyer/watermarks-remover
```

```
claude plugin install caveman@caveman
claude plugin install superpowers@superpowers-dev
claude plugin install claude-mem@thedotmack
claude plugin install impeccable@impeccable
claude plugin install ui-ux-pro-max@ui-ux-pro-max-skill
claude plugin install taste-skill@taste-skill
claude plugin install watermarks-remover@watermarks-remover
```

Verify: `claude plugin list` shows all 7 enabled.

Note: watermarks-remover patches `settings.json` on install (adds `env.WATERMARKS_HOOK_MODE`, writes a `settings.json.bak-wm` backup). The key is already tracked, so there should be no diff. If `git -C ~/.claude status --short` shows `settings.json` modified afterwards, inspect the diff; discard with `git -C ~/.claude checkout -- settings.json` unless the change is wanted. `settings.json.bak-wm` is gitignored and can be deleted.

## 7. Verify

```
jq --version && rtk --version && codegraph --version
claude mcp list
claude plugin list
```

Then start `claude` in any directory and confirm:

- statusline renders
- `/cleanup-session-codebase`, `/cleanup-whole-codebase`, `/council`, `/context-audit` appear in the slash-command list
- `git -C ~/.claude status --short` is empty
- `autoMode` is not tracked; run auto-mode setup on this machine if you want it

## 8. Record the installed dotfiles version

This repo tracks changes in `CHANGELOG.md` (integer versions, newest first). Now that setup is complete, mark this machine as current with the latest version:

```
grep -m1 -oP '## v\K[0-9]+' ~/.claude/CHANGELOG.md > ~/.claude/.dotfiles-version
```

`.dotfiles-version` is local and gitignored — it is not part of the repo.

**This is a one-time step.** For later updates, do not re-run this file: `git pull` in `~/.claude`, then run `/dotfiles-apply`, which reads `CHANGELOG.md` and brings the machine up to date with whatever changed since the version recorded here.
