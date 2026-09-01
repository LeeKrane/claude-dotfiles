---
name: cleanup-whole-codebase
description: "Review the entire repo and remove dead code, debug logging, and orphaned files/tests, double-checking every finding before deleting. Use only when explicitly invoked via /cleanup-whole-codebase."
disable-model-invocation: true
---

Review the WHOLE codebase — every file in the repo, not just this session's changes. Clean it up:

Delete dead code: unused functions, variables, imports, params, and commented-out blocks.
Remove leftover debug logging and stray TODOs that are already done.
Find duplicated logic and factor it out — only where the abstraction is genuinely clearer, don't invent indirection.
Make naming and patterns consistent across the codebase.
Check for orphans: files, exports, config entries, or tests that nothing references anymore.

Before deleting or modifying anything, double-check each finding: search the whole repo for references — including dynamic/string-based usage, config entries, docs, and tests — and re-read the surrounding code to confirm it is genuinely dead or safe to change. If a finding can't be verified, don't touch it; flag it instead.

Work in reviewable batches rather than one giant sweep. Run the test suite and linter before and after so you can prove nothing broke. Show me a summary of what you removed and why, and flag anything you're unsure about instead of deleting it.
