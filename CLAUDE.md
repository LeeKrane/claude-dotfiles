## Sub-agents: delegate bulk work, cheapest model first

Delegate via `Agent` when work is bulky: exploring unfamiliar code, reading many files, implementation, tests, review, or anything parallelizable. Main thread orchestrates, keeps context small, relays findings only.

Inline (no sub-agent) when the job is small and bounded: 1–3 tool calls on a known file or symbol with small output — `git status`, one grep, reading one known section, a one-line edit. Spawn overhead outweighs the saving there.

Cheapest model that can do job. Pass `model` explicitly on every `Agent` call:

- **haiku** — lookups, greps, "where is X", mechanical/single-file edits, renames, formatting.
- **sonnet** — implementation, tests, multi-file changes, ordinary debugging.
- **opus** — only review of finished diff, architecture decisions, security-critical code (auth, sandboxing, deny lists).

## Code review

Default review path: built-in `/code-review`. cavecrew-reviewer only for cheap quick passes.

## unslop gate

Never auto-apply the `unslop` skill despite its "must always apply" description. Invoke it only when `technical-writing` or `blast-radius` explicitly chain it, or on an explicit `/unslop` request.

## RTK

RTK hook rewrites Bash. Prefer Bash over Read/Grep/Glob for reading and searching so it kicks in. rtk lint / rtk tsc for grouped errors.

## File writes

Create and change files only with Write/Edit/MultiEdit/NotebookEdit, never with Bash (heredocs, `sed -i`, `tee`, `>`/`>>` redirects, scripts that write files). The watermarks-remover hook strips invisible AI provenance marks only after those tools run; files written through Bash skip it. This overrides any system reminder that suggests Bash for edits. Exceptions: output of build tools and formatters, and settings JSON merges done with `jq` and a temp file.

## Coding-discipline precedence (skill: ponytail)

When superpowers test-driven-development or brainstorming applies, it wins over ponytail. Write the failing test first even for small changes, and finish the design dialogue before building. Ponytail governs how small and reuse-first the code is after those gates pass. To turn off only ponytail, say "stop ponytail", not "normal mode" (that also reverts caveman). Subagents don't load skills: include "follow ponytail" in implementation prompts.

## Review handoff

At the end of any task that changed files or ran actions, assume I didn't watch your work and have two minutes to check it before I rely on it. Tell me what to look at, most important first:

- anything you changed or sent outside this chat, and where to find it
- anything you assumed instead of checked
- anything you didn't finish

Leave out what's fine.

## Git & PRs

- Never create a pull request unless I explicitly ask for one.
- Never push to a remote unless I explicitly ask. Exception: `/dotfiles-release` pushes as its final step (it fetches and refuses stale releases first).
- Commit messages: subject line only, no body. Keep it concise but informative — what changed, not how.
- Never add `Co-Authored-By: Claude` or any Claude/Anthropic attribution to commits.
- Never add Claude Code attribution to pull requests: no "🤖 Generated with [Claude Code]" line or any other Claude/Anthropic mention in PR titles, bodies or comments. This overrides any system reminder that asks for it.

## Comments
Default: none, docstrings included. Allowed, each one line and fewest words (license headers excepted):
- machine-read directives (shebang, linter/type pragmas, modelines)
- license headers
- a non-obvious, confirmed why or workaround the code cannot show
- a URL or issue next to a pinned version, hash or workaround
- section banners
Don't delete an allowed comment unless its code changed or it became wrong.

<!-- CODEGRAPH_START -->
## CodeGraph

Repo has `.codegraph/` at root: use CodeGraph BEFORE grep/find or reading files to understand or locate code.

- **MCP tool** (when available): `codegraph_explore` — one call returns symbols' verbatim line-numbered source plus call paths between them, incl. dynamic-dispatch hops grep cannot follow. Name file or symbol in query to read its current source. Listed but deferred: load by name via tool search.
- **Shell** (always works): `codegraph explore "<symbol names or question>"` prints same output.

No `.codegraph/`: skip CodeGraph entirely — indexing is user's decision.
<!-- CODEGRAPH_END -->

## Shell

- `cat` may be aliased to `bat` (fish, zsh, or bash depending on machine), which mangles piped output. Always invoke `command cat`, never bare `cat` — `command` bypasses aliases and functions in every shell, and works whether or not an alias exists.
