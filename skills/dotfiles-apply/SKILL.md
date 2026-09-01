---
name: dotfiles-apply
description: "After a git pull in ~/.claude, bring this machine up to date with any pending CHANGELOG.md versions. Use only when explicitly invoked via /dotfiles-apply."
disable-model-invocation: true
---

Apply any pending dotfiles versions to this machine. This repo (`~/.claude`) tracks changes in `CHANGELOG.md` (integer versions, newest first); each machine keeps its own installed version in a local, gitignored `.dotfiles-version` file. This command brings the machine up to date after a `git pull`.

## 1. Determine the installed version

Read `~/.claude/.dotfiles-version`.

- **File exists**: its content is the installed version. Continue to step 2.
- **File is missing**:
  - Check whether the machine is otherwise already set up — plugins installed (`claude plugin list` shows entries), hooks working, tools present per `SETUP.md`. If so, this machine predates the versioning system: treat it as `v1`, write `1` to `.dotfiles-version`, and continue to step 2.
  - If the machine looks like a genuinely fresh clone (no plugins installed, tools from `SETUP.md` missing), this is a first install, not a pending-version situation: follow `SETUP.md` in full instead of the rest of this command. When `SETUP.md` finishes, read the latest version from `CHANGELOG.md` (topmost `## vN`) and write it to `.dotfiles-version`. Stop — do not continue to step 2.

## 2. Determine the latest version

Read `~/.claude/CHANGELOG.md`. The latest version is the number in the topmost `## vN` heading.

## 3. Compare

- Installed == latest: report "up to date at vN", no actions taken. Stop.
- Installed > latest: this is unexpected (local marker ahead of the changelog) — most likely the repo hasn't been `git pull`ed yet, or the marker was hand-edited. Warn the user with both numbers and stop. Do not guess or "fix" it.
- Installed < latest: there are pending versions. Continue to step 4.

## 4. Apply pending versions, oldest first

For each version from `installed + 1` up to `latest`, in order:

1. Read that version's `CHANGELOG.md` entry. Entries are summaries, not step lists — infer the concrete actions needed by cross-referencing:
   - `SETUP.md` — for how a given tool/plugin/MCP server is normally installed.
   - `settings.json` — `enabledPlugins`, `extraKnownMarketplaces`, `hooks`, `env`, `permissions` — to see what should now be present.
   - `commands/` and `skills/` — to see what new commands or skills the entry refers to.
2. Typical actions this may translate to:
   - New plugin marketplace: `claude plugin marketplace add <org>/<repo>`
   - New plugin: `claude plugin install <plugin>@<marketplace>`
   - New MCP server: `claude mcp add <name> --scope user -- <command>`
   - New CLI tool: install per the relevant `SETUP.md` step.
   - Entry is documentation-only (README wording, a note, a comment) or describes something already present: nothing to execute.
3. Execute the inferred actions, then verify them (e.g. `claude plugin list`, `claude mcp list`, checking the relevant file exists).
4. Once that version's actions are verified (or confirmed to be no-ops), write that version number alone to `.dotfiles-version` before moving to the next pending version. Writing incrementally means a failure partway through leaves an honest marker (the last version fully applied), not a false "latest".

If an action fails, stop applying further versions, leave `.dotfiles-version` at the last version that fully succeeded, and report the failure clearly.

## 5. Final report

Summarize:

- Which versions were applied (or "up to date at vN" / the warning from step 3).
- What actions were taken for each.
- Anything needing manual follow-up — most commonly restarting Claude Code for hook or settings changes to take effect.

## Must not

- Never `git push` or create a pull request.
- Never edit `settings.local.json`.
- Never edit `CHANGELOG.md` (that's `/dotfiles-release`'s job).
- Never skip a pending version or jump straight to the latest without applying the ones in between.
