Release a new dotfiles version: inspect what changed in `~/.claude`, bump the version, draft a `CHANGELOG.md` entry, bring `README.md` and `SETUP.md` in line with the changes, update the local version marker, and commit — without pushing.

## 1. Inspect what changed

Run, in `~/.claude`:

- `git status --short` — uncommitted changes.
- `git diff` (and `git diff --staged`) — the actual content of uncommitted changes.
- `git log` for commits made since the last `CHANGELOG.md` entry was written (compare against the commit that last touched `CHANGELOG.md`, e.g. `git log --oneline -- CHANGELOG.md` for the most recent one, then `git log <that-commit>..HEAD`).

Together these cover everything not yet reflected in the changelog, whether committed or still pending.

## 2. Nothing to release?

If there is no uncommitted diff and no commits since the last `CHANGELOG.md` entry, say so and stop. Do not create an empty release.

## 3. Bump the version

Read the topmost `## vN` heading in `CHANGELOG.md`. The new version is `N + 1`.

## 4. Draft the changelog entry

Write a summary-only entry — no per-step machine instructions (that inference is `/dotfiles-apply`'s job at apply time). Name concrete, specific things: plugins or marketplaces added/removed, MCP servers added, hooks changed, new commands or skills, settings changes, tool/dependency changes. A future `/dotfiles-apply` run must be able to infer real actions from this wording, so prefer "added plugin X from marketplace Y" over vague language like "updated some settings".

Use today's date. Prepend the new entry directly under the `# Changelog` header (and its intro line, if present), above the current topmost entry, so the file stays newest-first:

```markdown
## vN — YYYY-MM-DD

<summary of what changed>
```

## 5. Doc-consistency pass (README.md, SETUP.md)

The changelog records history; README and SETUP describe current state — check both against every change in this release:

- **README.md**: the file/skill tables (one row per skill, naming its source and install method — never a grouped placeholder row), the "Skills & commands" descriptions, the plugin table, and the CLAUDE.md-conventions summary. Add/remove/reword rows for anything this release added, removed, or renamed.
- **SETUP.md**: the marketplace-add and plugin-install command lists, the skills-CLI registration commands (section 6b), the verify step's slash-command and plugin-count checks, and any tool/dependency steps. A fresh machine following SETUP.md verbatim must end up matching this release's state — stale install lines here actively mislead `/dotfiles-apply` on other machines.
- Check any other tracked doc the release touches conceptually (e.g. `CLAUDE.md` summaries in README).

If nothing in a file is affected, say so and move on — don't rewrite for its own sake.

## 6. Update the local version marker

Write the new version number alone to `~/.claude/.dotfiles-version`. The machine drafting the release is by definition already current at the new version.

## 7. Commit

Stage the changelog, the doc updates from step 5, and any other changes covered by this release, and commit with a subject-only message (no body, no `Co-Authored-By` or other Claude/Anthropic attribution — per `CLAUDE.md`). Example subject: `Release v<N>: <short summary>`.

**Never push.** Leave the push to the user.

## Final report

State the new version number, the changelog entry drafted, and that the commit was made locally only (not pushed).
