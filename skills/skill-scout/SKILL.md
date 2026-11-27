---
name: skill-scout
description: "Vet Claude Code skills/plugins before installing them. Use when the user says 'scout skills', 'evaluate this skill/plugin', 'should I install <skill or plugin>', asks whether a skill/plugin repo is worth adopting, wants to search findskills.org / skills.sh for skills, or asks how to integrate a skill. Not for authoring skills or plain installs the user already decided on."
argument-hint: "[skill/plugin/repo URL(s), or search terms]"
---

# Skill Scout

Judge each candidate on what it does, check it against what is installed, scan it, then let the user decide placement and integration. No usage mining, scoring, or council. Never install or edit config before the user approves.

## 1. Candidates

List the installed inventory once: `~/.claude/skills/`, `enabledPlugins` in `settings.json`, hook events and commands, and the rules in `~/.claude/CLAUDE.md`.

- **Named** (URL, `owner/repo`, `owner/repo@skill`): vet those.
- **Search terms or a work area**: one haiku subagent searches `npx -y skills@latest find <term>` and, if `FINDSKILLS_API_KEY` is set, `curl -sS -m 30 -H "Authorization: Bearer $FINDSKILLS_API_KEY" 'https://findskills.org/api/v1/search?q=<term>&limit=10'`. At most 3 terms. It returns one deduped line per hit: `owner/repo@skill | what | installs/stars | url`. Drop hits already installed. Ask with one multiSelect AskUserQuestion which hits to vet.

## 2. Vet (one sonnet subagent per candidate, in parallel)

Clone into `~/.cache/skill-scout/<date>/` and record its HEAD full SHA as the Pin. Give the subagent the clone path and the step-1 inventory. It reads the SKILL.md and referenced files and returns:

- **What**: one line, from the SKILL.md, not the repo blurb.
- **Pros**: at most 3 short bullets.
- **Cons**: at most 3 short bullets (token weight, dependencies, keys, scope).
- **Conflicts**: installed skills, hooks or CLAUDE.md rules it duplicates or contradicts, each named; else "none".
- **Security**: run `skillspector scan <dir> --no-llm --format json --output <file>`, then skim the files for exfiltration, credential handling, hidden network/exec steps, and anti-refusal text. Result: `clean`, `false positives: <why>`, or `RISK: <finding>`. Scan missing or erroring: `RISK: not scanned`, never `clean`.
- **Integration options**, each only if it fits this skill, else "n/a":
  - **Hook**: the behavior is a deterministic rule that must fire every time. Name the event (PreToolUse, PostToolUse, UserPromptSubmit, Stop, SessionStart) and what the script does.
  - **Global CLAUDE.md line**: one rule, only when the skill would not trigger or behave right without it.
  - **Project CLAUDE.md instruction** (repo skill only): one line a project's CLAUDE.md gets when the skill is enabled there.

## 3. Report

One block per candidate, no tables:

```
<name> — <what>
Pros: …
Cons: …
Conflicts: …
Security: …
Integration fits: hook (<event>) | global CLAUDE.md line | project CLAUDE.md line | none
```

## 4. Ask

AskUserQuestion, one question per candidate (4 per call): **Global skill** / **Repo skill** / **Skip**. A `RISK` security result goes in the question text.

Then, only for candidates not skipped, ask a multiSelect per candidate listing only the integration options marked as fitting for the chosen placement: hook and global CLAUDE.md line for global; hook, global CLAUDE.md line and project CLAUDE.md line for repo. Show the exact line or hook in the option description. No fitting options: skip the question.

## 5. Apply (approved only)

- **Global**: install with the first channel that works: `claude plugin install` (if the plugin brings no unwanted skills), else `npx -y skills@latest add <repo> --skill <name> --agent claude-code --global --yes`, else a vendored copy with a provenance comment (repo @ commit, vet date, local edits).
- **Repo**: install nothing. Append an entry to `~/.claude/REPO-SKILLS.md` with every field its header lists; Pin is the step-2 SHA, Vetted holds date and security result. Setup sub-bullets: the project CLAUDE.md line as `claude-md:`, a repo hook or other project config as a `config:` JSON fragment for `settings.local.json`, dependencies and keys as `manual:`. A repo hook script must ship with the skill or be an inline command.
- **Hook**: draft the script and `settings.json` entry via the `update-config` skill; show both before enabling.
- **Global CLAUDE.md line**: add it to `~/.claude/CLAUDE.md`.
- Dependencies and API keys are user follow-ups (`! <cmd>`); never write an empty `env` key.

Tracked files in `~/.claude` changed: suggest `/dotfiles-release`; never run it unasked.
