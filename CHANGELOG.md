# Changelog

Integer versions. Newest first. Local installed version lives in `.dotfiles-version` (gitignored).

## v4 — 2026-09-01

Replaced the council skill. Removed `skills/council/` (itshussainsprojects
7-persona roleplay council — all personas written by one context, no
independent reasoning). Installed `skills/council-review/` from
ngmeyer/skills@701dfb8 via the official `npx skills` CLI (selective install,
update with `npx skills update`): DMAD council of 5 parallel advisors with
distinct reasoning methods, anonymous peer review, mandatory
devil's-advocate-vs-consensus pass, chairman synthesis; modes --quick /
--adaptive / --confidence / --measure-diversity / --jury. Vetted before
install (SkillSpector static clean + manual read). Rejected alternatives:
0xNyk council-of-high-intelligence, wan-huiyan agent-review-panel.
Updated the README skill listing and SETUP.md (verify step now checks
/council-review; added its skills-CLI registration line) accordingly.

## v3 — 2026-09-01

Installed 10 individually selected skills into `skills/` — a hand-picked
subset of two larger skill collections — via the official `npx skills` CLI
(skills.sh; selective per-skill installs, update with `npx skills update`),
after a usage audit + SkillSpector/manual security vetting (all clean,
verified byte-identical to vetted clones). From mattpocock/skills@6654f6b:
handoff (session-handoff docs), wayfinder (multi-session decision-ticket
planning), research (background primary-source research), domain-modeling
(CONTEXT.md glossary + ADR discipline), prototype (throwaway logic/UI
prototypes), grilling (wayfinder's interview dependency), and
setup-matt-pocock-skills (per-repo tracker/domain-doc scaffolding wayfinder
references). From cursor/plugins pstack@b9ddc83: technical-writing
(Diátaxis/Google-style/STE doc standard), blast-radius
(prove-the-safety-fact pre-merge breakage hunt), and unslop (AI-tell
catalog) — unslop installed only because technical-writing and blast-radius
chain it; a CLAUDE.md "unslop gate" rule blocks its aggressive
always-apply auto-trigger (a hard disable-model-invocation would break the
chained Skill calls). blast-radius references to pstack's how/why/arena are
left dangling deliberately (those skills were audit-rejected as overlaps).

Added a CLAUDE.md "Code review" rule declaring built-in `/code-review` the
default review path (cavecrew-reviewer for cheap quick passes). Skill
provenance lives here in the changelog, not in CLAUDE.md.

Pruned plugin cache 571MB → 18MB: removed orphaned ui-ux-pro-max-skill
cache, disabled taste-skill's leftover cache, 7 stale claude-mem versions
(kept active 13.21.2), and stale `settings.json.bak-wm`. Normalized model
setting capitalization to "Fable" in settings.json.

Repaired v2-era drift in SETUP.md: removed the ui-ux-pro-max marketplace
and install lines (dropped in v2), added the security-guidance and
frontend-design installs from claude-plugins-official (added in v2), noted
taste-skill's globally-disabled state, and added section 6b describing the
skills-CLI channel (re-registering the tracked `skills/` dirs with
`npx skills` so updates work on a fresh machine).

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
