## Sub-agents: always delegate, cheapest model first

All work via sub-agents (`Agent` tool), never inline — exploration, implementation, tests, review. Main thread orchestrates, keeps context small, relays findings only.

Cheapest model that can do job. Pass `model` explicitly on every `Agent` call:

- **haiku** — lookups, greps, "where is X", mechanical/single-file edits, renames, formatting.
- **sonnet** — implementation, tests, multi-file changes, ordinary debugging.
- **opus** — only review of finished diff, architecture decisions, security-critical code (auth, sandboxing, deny lists).

## Code review

Default review path: built-in `/code-review`. cavecrew-reviewer only for cheap quick passes.

## unslop gate

Never auto-apply the `unslop` skill despite its "must always apply" description. Invoke it only when `technical-writing` or `blast-radius` explicitly chain it, or on an explicit `/unslop` request.

## RTK

RTK hook rewrites Bash. Prefer Bash over Read/Grep/Glob for file ops so it kicks in. rtk lint / rtk tsc for grouped errors.

## Git & PRs

- Never create a pull request unless I explicitly ask for one.
- Never push to a remote unless I explicitly ask.
- Commit messages: subject line only, no body. Keep it concise but informative — what changed, not how.
- Never add `Co-Authored-By: Claude` or any Claude/Anthropic attribution to commits.

<!-- CODEGRAPH_START -->
## CodeGraph

Repo has `.codegraph/` at root: use CodeGraph BEFORE grep/find or reading files to understand or locate code.

- **MCP tool** (when available): `codegraph_explore` — one call returns symbols' verbatim line-numbered source plus call paths between them, incl. dynamic-dispatch hops grep cannot follow. Name file or symbol in query to read its current source. Listed but deferred: load by name via tool search.
- **Shell** (always works): `codegraph explore "<symbol names or question>"` prints same output.

No `.codegraph/`: skip CodeGraph entirely — indexing is user's decision.
<!-- CODEGRAPH_END -->

## Shell

- `cat` may be aliased to `bat` (fish, zsh, or bash depending on machine), which mangles piped output. Always invoke `command cat`, never bare `cat` — `command` bypasses aliases and functions in every shell, and works whether or not an alias exists.
