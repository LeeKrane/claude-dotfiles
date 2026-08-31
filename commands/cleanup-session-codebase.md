Review everything we changed this session (git diff against the base branch). Clean it up:

Delete dead code: unused functions, variables, imports, params, and any commented-out blocks we left behind.
Remove leftover debug logging and stray TODOs that are already done.
Find duplicated logic introduced or worsened by these changes and factor it out — only where the abstraction is genuinely clearer, don't invent indirection.
Make naming and patterns consistent with the surrounding codebase, not just internally consistent.
Check for orphans: files, exports, config entries, or tests that nothing references anymore.

Before deleting or modifying anything, double-check each finding: search the whole repo for references — including dynamic/string-based usage, config entries, docs, and tests — and re-read the surrounding code to confirm it is genuinely dead or safe to change. If a finding can't be verified, don't touch it; flag it instead.

Scope this to code we touched. Don't refactor unrelated parts of the repo. Run the test suite and linter before and after so you can prove nothing broke. Show me a summary of what you removed and why, and flag anything you're unsure about instead of deleting it.
