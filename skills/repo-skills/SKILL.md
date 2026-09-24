---
name: repo-skills
description: "Use when setting up a project for Claude Code, on the first session in a new repo, or when the user asks to enable skills for this repo, set up skills for this project, asks which repo-scoped skills fit, or wants a skill available only in this project without installing it globally. Not for global skill installs, skill authoring, or evaluating/vetting candidate skills (that is skill-scout)."
argument-hint: "[skill names…] [--list]"
---

## Overview
Enable or install repo-scoped skills from the vetted registry `~/.claude/REPO-SKILLS.md` into the current project only — never globally, never by editing `~/.claude`.

## 1. Read the registry
Read `~/.claude/REPO-SKILLS.md` in full (every entry's fields).

## 2. Detect the project and evaluate signals
- Root: `git rev-parse --show-toplevel`; if not a git repo, ask for the target directory.
- For each entry, evaluate its Signals field literally against this root: repo names first (match the root directory's basename or the repo name in `git -C <root> remote get-url origin`), then dependency and file checks (`package.json` deps, named files), then explicit user phrasing quoted in the entry. A repo name in parentheses after a file check narrows that check to that repo.
- Current state: already installed (`<root>/.claude/skills/<name>/SKILL.md`) or enabled (`<root>/.claude/settings.local.json` key)? Already installed → propose `skip` (or `reinstall` only if the user asks or the registry Pin changed; reinstall = remove `<root>/.claude/skills/<name>` first). Already installed but one of the entry's Setup `config:` keys is missing from `<root>/.claude/settings.local.json` → propose `setup-only`: apply the Setup items, leave the skill files alone.

## 3. Report and stop for confirmation
Table: entry | signal found | already enabled? | proposed action. Below it, per proposed entry, list its Setup items (`config:` applied in step 4, `manual:` shown as follow-ups). Names passed as args = pre-approved → go to step 4 for those only. Otherwise ask which entries to apply; do not proceed on silence.
`--list`: registry summary + match table, then stop. No changes.

## 4. Apply, per type
- skill, Path `.`: shallow pinned fetch into `<dest>` = `<root>/.claude/skills/<name>`:
  ```
  mkdir -p <dest> && git -C <dest> init -q && git -C <dest> remote add origin <source>
  git -C <dest> fetch --depth 1 -q origin <pin> && git -C <dest> checkout -q --detach FETCH_HEAD
  rm -rf <dest>/.git
  ```
  If the fetch of `<pin>` is refused, fall back to a full `git clone --no-checkout` + `git checkout --detach <pin>`; never substitute another commit. If `<root>/.claude/skills/<name>` already exists, stop with the step-2 skip/reinstall decision — never clone into or over it. Fast path: copy the named vetted clone (minus `.git`) if `git -C <clone> rev-parse HEAD` == pin AND `git -C <clone> status --porcelain` is empty; otherwise use the network path.
- skill, Path ≠ `.`: same shallow fetch at pin into a scratch dir `<dest>`, then `cp -r <dest>/<Path> <root>/.claude/skills/<name>`, remove scratch. Same fallback, existing-dir check, and fast path (checked on `<clone>/<Path>`).
- After either: `EXCL=$(git -C <root> rev-parse --git-path info/exclude)`; `mkdir -p "$(dirname "$EXCL")"`; append `.claude/skills/<name>/` to `$EXCL` if not already present. Never touch the tracked `.gitignore` unless asked. If the target is not a git repo (step 2 asked for a directory), skip the exclude and the `git status` check in step 5 and say so in the report.
- plugin: read `<root>/.claude/settings.local.json` (or `{}`), merge the literal `enabledPlugins`/`skillOverrides` JSON fragment given in the entry's Enable field without disturbing other keys, write back (jq/python).
- Setup `config:` items (any type, and the `setup-only` action): deep-merge each literal JSON fragment into `<root>/.claude/settings.local.json` after the install. Objects merge recursively, arrays are unioned, and scalars from the fragment win: `jq -s 'def m($a;$b): if ($a|type)=="object" and ($b|type)=="object" then reduce ($b|keys[]) as $k ($a; .[$k] = m($a[$k]; $b[$k])) elif ($a|type)=="array" and ($b|type)=="array" then $a + ($b - $a) else $b end; m(.[0]; .[1])' settings.local.json fragment.json`. Never use a shallow `+` or `dict.update`, which replaces whole `permissions` or `hooks` objects. `manual:` items are never executed; carry them to the final report.
- mcp (reserved): would add under `mcpServers` in `<root>/.mcp.json`; ask for exact command/args first.
- Never run the skill's own setup (`npm install`, pip, Hyperframes install). Report unmet `Depends` as manual follow-ups.

## 5. Verify
SKILL.md exists and `name:` matches / settings key present; every Setup `config:` key is present in `settings.local.json` with the fragment's value; if `<root>` is a git repo, `git -C <root> status --short` shows nothing unexpected (skipped otherwise, per the step-4 note); tell the user a new `claude` session is needed.

## 6. Final report
Applied entries + how, skipped + why, `Depends` and Setup `manual:` follow-ups (install commands as `! <cmd>`, env var names to fill, smoke test).

## Must not
- Never install into `~/.claude/skills/` or edit `~/.claude/settings.json`.
- Never edit `~/.claude` beyond reading `REPO-SKILLS.md`.
- Never commit inside the target project.
- Never substitute another commit for the pin.
- Never append registry entries — that is skill-scout's job (its step 8 security gate makes the Vetted field trustworthy); no `--add` flag.
