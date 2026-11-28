Instructions for an agent setting up Claude Code from this repo.
Run steps in order; verify each. Do not edit tracked files unless the user asks.

**Routing comes from the shell, not `settings.json`:** on NixOS hosts managed by `~/.dotfiles`, the login environment exports `ANTHROPIC_BASE_URL=http://localhost:3456` (teamclaude), and that repo also ships the fish functions; on other machines step 3b adds the export. The fish function `claude` unsets the base URL and runs Claude Code with experimental Code Mode through `HTTPS_PROXY` to teamclaude's MITM (`127.0.0.1:3456`), trusting its CA via `NODE_EXTRA_CA_CERTS`; it refuses to start while teamclaude is down, and if that CA is missing it warns and falls back to teamclaude's base URL without Code Mode. `claude-plain` is stock Claude Code: no teamclaude, no Code Mode (it still loads `settings.json`, including the 300K `autoCompactWindow`). `settings.json` must not set `ANTHROPIC_BASE_URL`: its `env` overrides the launch environment, which would disable Code Mode in `claude`. Until teamclaude runs (step 3b), use `claude-plain`, or `env -u ANTHROPIC_BASE_URL claude` where the export exists but the fish functions don't (`env` runs the binary, not a fish function). **Upgrading an older checkout:** releases up to v30 set `ANTHROPIC_BASE_URL` in `settings.json`. After pulling a newer one, NixOS hosts get the export from `~/.dotfiles` (switch, then log in again); on other machines add `export ANTHROPIC_BASE_URL=http://localhost:3456` to the shell profile, or `claude` silently skips teamclaude. Releases v31–v33 shipped billion-context and v33 added `claude-cm`; both are gone, `claude` now includes Code Mode: switch, then relaunch open sessions.

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
| jq | statusline, `.env` block hook, ponytail hooks | `sudo dnf install jq` (Debian: `apt install jq`) | `jq --version` |
| rtk | PreToolUse hook, permissions | no distro package — install from https://github.com/rtk-ai/rtk releases (or its install script) into PATH | `rtk --version` |
| codegraph | UserPromptSubmit hook, MCP server | project's own installer (see its repo/docs); installs a `~/.local/bin/codegraph` symlink; update later with `codegraph upgrade` | `codegraph --version` |
| Nerd Font | optional; statusline cache-glyph (flame U+F0238) renders as tofu without one | install any Nerd Font and set it as the terminal font | — |

Ensure `~/.local/bin` is on PATH.

## 3b. teamclaude (mandatory)

[teamclaude](https://github.com/KarpelesLab/teamclaude) pools the Team/Enterprise seats and rotates on quota. Once the shell exports `ANTHROPIC_BASE_URL=http://localhost:3456`, `claude` cannot connect until this proxy runs — do this step before the first `claude` start (or bypass it as described in the note at the top). Non-NixOS machines: after this step, export `ANTHROPIC_BASE_URL=http://localhost:3456` in the shell profile yourself. Never export `HTTPS_PROXY` globally: only the `claude` wrapper sets it, per launch, because it routes all HTTPS through teamclaude's MITM. teamclaude stores and refreshes the seat tokens itself in `~/.config/teamclaude.json` (untracked, never copy it into this repo).

**NixOS hosts managed by `~/.dotfiles`:** skip the `npm install -g` and `teamclaude service install` below. The global npm prefix is read-only in the Nix store there, so both fail. `~/.dotfiles` ships teamclaude instead: `pkgs/teamclaude/package.nix` pins the version, and its wrapper sets `TEAMCLAUDE_DISABLE_AUTOUPDATE=1`. `modules/home/common/teamclaude.nix` adds a `systemd.user.services.teamclaude` unit on every host, desktops, servers and Pis. Run `just switch <host>` in `~/.dotfiles`, then continue with `teamclaude login` and the `autoUpdate` step below. To bump the version, edit `version` and `hash` in `pkgs/teamclaude/package.nix` together with the pin here, then switch again.

Needs Node.js 20+. Install the pinned version (prefix `sudo` if `npm config get prefix` is a system path like `/usr/local`):

```
npm install -g @karpeleslab/teamclaude@1.1.21
```

Add every seat (browser OAuth, run once per seat):

```
teamclaude login
```

Disable self-update so a compromised npm release is never installed automatically — do this before starting the service:

```
f=~/.config/teamclaude.json; t=$(mktemp) && jq '.autoUpdate = false' "$f" > "$t" && mv "$t" "$f"
```

Run it as a per-user service (systemd `--user` unit on Linux, LaunchAgent on macOS):

```
teamclaude service install
```

Verify: `teamclaude accounts` lists every seat, `teamclaude status` shows the proxy up, `jq .autoUpdate ~/.config/teamclaude.json` prints `false`. NixOS hosts: `curl -sk --noproxy '' --proxy http://127.0.0.1:3456 https://www.example.org/ -o /dev/null && grep -q 'END CERTIFICATE' ~/.config/teamclaude-ca.pem` succeeds (the MITM CA `claude` needs for Code Mode).

Updating later is manual: bump the pinned version here, then `npm install -g @karpeleslab/teamclaude@<version>` and `systemctl --user restart teamclaude`.

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

Verify: `claude plugin list` shows all 7: 6 enabled and `skill-creator` disabled (`enabledPlugins: false` in `settings.json`).

Note: watermarks-remover patches `settings.json` on install (adds `env.WATERMARKS_HOOK_MODE`, writes a `settings.json.bak-wm` backup). The key is already tracked, so there should be no diff. If `git -C ~/.claude status --short` shows `settings.json` modified afterwards, inspect the diff; discard with `git -C ~/.claude checkout -- settings.json` unless the change is wanted. `settings.json.bak-wm` is gitignored and can be deleted.

## 6b. Skills installed via the skills CLI (skills.sh)

The `skills/` directory is tracked in this repo, so the clone already contains every skill — nothing to install. To register them with the skills CLI so `npx skills update` can pull upstream updates on this machine, optionally re-run the original installs (they overwrite with identical content):

```
npx -y skills@latest add mattpocock/skills --skill handoff --skill wayfinder --skill research --skill domain-modeling --skill prototype --skill grilling --skill setup-matt-pocock-skills --agent claude-code --global --yes
npx -y skills@latest add cursor/plugins --skill technical-writing --skill blast-radius --skill unslop --agent claude-code --global --yes
npx -y skills@latest add ngmeyer/skills --skill council-review --agent claude-code --global --yes
```

After an update run, review the diff before committing — skills are re-vetted on refresh (see CHANGELOG v3).

`skills/to-spec/`, `to-tickets/`, `implement/`, `implement-spec/`, `spec-review/`, `improve-codebase-architecture/`, `teach/`, `to-questionnaire/`, `wizard/` and `codebase-design/` are pinned copies of mattpocock/skills@d653911 with local edits (see the provenance comment in each SKILL.md), not CLI installs. Do not add them with `npx skills`: that would overwrite the edits (see CHANGELOG v32).

`skills/ponytail/` is a pinned copy of DietrichGebert/ponytail@96608e0 (core skill only), not a CLI install. Do not re-install it with `npx skills` or the ponytail plugin marketplace: the plugin brings hooks this setup deliberately skips (see CHANGELOG v27).

skill-scout's search calls `npx skills find <term>` (same CLI, already covered above) and, when `FINDSKILLS_API_KEY` is set (free key via `npx findskills auth` or findskills.org/developers), the findskills.org API.

## 6c. Repo-scoped skills

`REPO-SKILLS.md` lists skills that are vetted but never installed globally (currently `video-shotcraft`, `brag`, `obsidian-notes-creator`, and for `krane-solutions-business-orchestration` `hormozi-offer`, `pricing-strategy`, `business-model`, `objection-destroyer`, `marketing-council` (manual-only), for `KraneticFitness` the 11-skill `replica-skill` pack, `convert-documents-to-markdown` (anydoc, vendored with local edits in `vendor/`, needs the `anydoc` CLI from the NixOS dotfiles), `pdf-to-obsidian-notes` (self-authored in `vendor/`, `Requires` the anydoc and obsidian-notes-creator entries), for both `KraneticFitness` and `krane-solutions-business-orchestration` `condom` (manual-only), `playwright-cli`, `security-audit` and `create-formal-verification-skill`). It also holds `plugin`-type entries for skills that `settings.json` `skillOverrides` turns off globally (`engineering-skills`, `codebase-cleanup`, `superpowers-extras`, `frontend-design`, `claude-mem-planning`, `claude-mem-github`, `caveman-workflows`, `caveman-cloud`, `writing-cleanup`, `office-documents`, `pocock-extras`). Nothing to do on a fresh machine. In a project that wants one, run `/repo-skills`. It installs a pinned copy into that project's `.claude/skills/` only, or for a `plugin` entry writes `"on"` overrides into that project's `.claude/settings.local.json`.

## 7. Verify

```
jq --version && rtk --version && codegraph --version
bash ~/.claude/hooks/test-block-env-access.sh   # prints ALL PASS
bash ~/.claude/hooks/test-patch-claude-mem-quota.sh   # prints ALL PASS
bash ~/.claude/hooks/test-require-ponytail.sh   # prints ALL PASS
bash ~/.claude/hooks/test-inject-ponytail-agent.sh   # prints ALL PASS
teamclaude status
claude mcp list
claude plugin list
```

Then start `claude` in any directory and confirm:

- statusline renders
- `/advisor` prints `Advisor: Opus 5.5` (needs `CLAUDE_CODE_ENABLE_EXPERIMENTAL_ADVISOR_TOOL=1` from `settings.json`)
- `/council-review`, `/repo-skills`, `/handoff`, `/dotfiles-release`, `/to-spec`, `/spec-review` appear in the slash-command list, and `/cleanup-session-codebase`, `/context-audit`, `/wayfinder`, `/wizard`, `/codebase-design` do not (turned off by `skillOverrides`)
- `git -C ~/.claude status --short` is empty
- `autoMode` (auto-mode environment context) is not tracked; `permissions.defaultMode: auto` in `settings.json` is, so auto mode is on by default — run auto-mode setup on this machine if prompted

## 8. Record the installed dotfiles version

This repo tracks changes in `CHANGELOG.md` (integer versions, newest first). Now that setup is complete, mark this machine as current with the latest version:

```
grep -m1 -oP '## v\K[0-9]+' ~/.claude/CHANGELOG.md > ~/.claude/.dotfiles-version
```

`.dotfiles-version` is local and gitignored — it is not part of the repo.

**This is a one-time step.** For later updates, do not re-run this file: `git pull` in `~/.claude`, then run `/dotfiles-apply`, which reads `CHANGELOG.md` and brings the machine up to date with whatever changed since the version recorded here.
