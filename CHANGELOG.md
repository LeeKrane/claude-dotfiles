# Changelog

Integer versions. Newest first. Local installed version lives in `.dotfiles-version` (gitignored).

## v2 — 2026-08-31

Added plugins security-guidance and frontend-design from the official
claude-plugins-official marketplace (ships with Claude Code, no
extraKnownMarketplaces entry needed). Uninstalled plugin ui-ux-pro-max and
removed its marketplace ui-ux-pro-max-skill. Kept taste-skill installed but
disabled it globally in settings.json (enabledPlugins false) — re-enable
per project via .claude/settings.local.json when building landing pages.
Replaced /cleanup command with /cleanup-session-codebase and
/cleanup-whole-codebase (adds verify-before-delete step).

## v1 — 2026-08-31

Baseline. Current state of the repo: settings.json (model fable, RTK + codegraph
hooks, statusline), 7 plugins (caveman, superpowers, claude-mem, impeccable,
ui-ux-pro-max, taste-skill, watermarks-remover), codegraph MCP server, custom
skills (context-audit, council), /cleanup command, versioning (CHANGELOG.md,
.dotfiles-version, /dotfiles-apply, /dotfiles-release). Fresh installs: follow
SETUP.md in full.
