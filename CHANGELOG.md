# Changelog

Integer versions. Newest first. Local installed version lives in `.dotfiles-version` (gitignored).

## v11 — 2026-09-07

New repo-scoped skills registry (`REPO-SKILLS.md`, root, tracked) and its
consumer `skills/repo-skills/SKILL.md` (`/repo-skills`): skills vetted and
wanted but never installed or enabled globally, applied per project instead —
a pinned skill copy under `.claude/skills/` (excluded via `.git/info/exclude`)
or a plugin re-enable in `.claude/settings.local.json`. First entries:
`video-shotcraft` (Vincentwei1021/video-shotcraft @ 5f047c7c, Remotion
product/promo videos) and `brag` (latent-spaces/brag @ 1f8d9ade, HeyGen
Hyperframes launch videos; Hyperframes CLI installed separately per project).
skill-scout step 8 gains a `project-scope` verdict that appends a registry
entry instead of installing. Removed plugin taste-skill@taste-skill and its
marketplace Leonxlnx/taste-skill entirely (globally disabled since v2, never
re-enabled anywhere): dropped from `enabledPlugins`, `extraKnownMarketplaces`,
the README plugin table, and the SETUP install lines; 7 plugins remain, all
enabled. dotfiles-apply gains a removal action form (plugin uninstall,
marketplace remove) so removal-only releases are not applied as no-ops.

## v10 — 2026-09-07

Removed plugin `frontend-design@claude-plugins-official` (uninstalled
via `claude plugin uninstall`, dropped from enabledPlugins). Verdict of
the 2026-09-07 skill-scout run + council: its SKILL.md is a strict
subset of the enabled `impeccable` plugin (aesthetic direction,
typography, anti-generic rules), with none of impeccable's critique,
audit, DESIGN.md, or live-browser machinery — two skills on the same UI
trigger for no capability gain. Same run skipped all 20 evaluated
candidates globally (emil design skill, refero, web-artifacts-builder,
ui-ux-pro-max, ponytail, diagram-design, visual-plan, graphify,
humanizer, karpathy skills, dream, brag, video-shotcraft, Context7,
mcp-builder, webapp-testing, seo-audit, programmatic-seo, ai-seo, cro);
verdict cached in project memory. Enabled plugin count is now 7 of 8
installed (taste-skill stays disabled).

## v9 — 2026-09-07

skill-scout report format rewrite (skills/skill-scout/SKILL.md), driven
by the first v8 scout run's terminal output and one opus peer review.
Step 7 ranked list is now a numbered list with one fact per line per
candidate — name plus a one-line "what it does" from its SKILL.md,
Overlap → counterpart, Cost (per form: skill always-on/on-invocation,
hook injected tok/session, MCP schema, hybrid halves joined with +),
Form, Score, Call with fixed council markers (council-corrected from X:
reason / council-unreviewed / council risk not applied — diversity
Low), Because (decisive fact, defined by the Flips-if test; cost
numbers must be paired with the usage count they are weighed against),
Flips if. Wide tables banned: every other report table capped at 4
columns, step 3 replacement comparison reoriented to measure |
candidate | counterpart, council table to candidate | call | what it
changed (step 5 preamble aligned). Step 4 skip one-liner removed —
every candidate goes through the step 7 block, briefing limited to
non-skip candidates.

## v8 — 2026-09-07

skill-scout skill rewrite (skills/skill-scout/SKILL.md), peer-reviewed by
three independent reviewers. New mandatory step 5: every scout run with
candidates auto-invokes the council-review skill (one council per run,
`--measure-diversity` always on; full mode on any FULL overlap, replace
call, hook/hybrid candidate, or top-two scores within 3 points; `--quick`
otherwise; new `--no-council` opt-out flag). The council debates four
questions — overlap correctness, real-vs-imagined gaps, fit with this
setup, and form (skill vs hook vs hybrid) — from a neutral question with
the draft verdict placed in CONTEXT as one option, a preamble asking for
a per-candidate Recommendation table and skipping cwd auto-context, and
explicit rules for consuming Error Catch / Value Tension / Blind Spots /
What You Lose / Diversity Check and for pre-flight declines. Step 3 adds
a replacement comparison table (always-on cost per form — skill, plugin,
hook, MCP — on-invocation cost, capability delta, trigger quality,
provenance, security) ending in keep/replace/alongside/skip. Step 4
score now has scales (fit and benefit 1–5, overlap penalty 0/2/4, token
penalty 0–3 by net always-on tokens) and a form check naming the hook
event. Step 8 gains install branches for keep, alongside, replace, hook
(drafted via update-config, shown before enabling, skill never
installed) and hybrid. Security gate: findings get explicit
dispositions, hook-bound candidates still scanned and read. Old
"offer /council-review on close calls" step removed.

## v7 — 2026-09-01

Statusline rewrite (statusline-command.sh), decided via /council-review
runs plus format interview. New: 7-day rate-limit segment now shows its
reset moment as ↻ + German two-letter weekday + local time (weekday
dropped when the reset lands today) — absolute weekday+time chosen over
a relative countdown; 7-day color is now pace-aware (severity = max of
raw percent and burn pace vs elapsed window fraction, so 40% one day
into the week goes red while 40% at mid-week stays green). New
prompt-cache segment as the last element: green Nerd Font flame
(U+F0238) while warm, gold flame + minutes-remaining when under ~25% of
TTL, muted-blue snowflake when cold/expired; self-omits on Claude Code
<2.1.251 or before the first API response (note: jq's `//` treats
`false` as absent — `.prompt_cache.warm` needs an explicit null check).
The 5h segment's "resets" label is now the same ↻ icon. Removed the
(NNNK/NNNK) token-count text from the ctx segment (bar + percent only).
Refactored all field extraction into a single jq call (was ~8 forks per
render). Council-rejected and not added: 7d bar, threshold-gated
display, spend_limit segment, session cost, lines added/removed, mode
flags, PR/worktree/vim/elapsed-time segments.

## v6 — 2026-09-01

Installed plugin skill-creator from claude-plugins-official (ships with
Claude Code). Authored self-made skill skill-scout with it: researches,
evaluates, and vets candidate skills/plugins against real usage data
(history.jsonl + claude-mem mining, FULL/PARTIAL/NONE overlap matrix,
fit × benefit − overlap ranking with per-candidate work/token briefings,
mandatory SkillSpector + full-manual-read security gate, install-channel
preference marketplace > npx skills > vendoring, /council-review --quick
offer on close calls, analyze-then-ask default — never installs without
approval). Model-invoked on explicit phrases ("scout skills", "evaluate
this skill/plugin", "audit my skills", "should I install X") and via
/skill-scout.

Converted the four self-authored commands to skills 1:1 (user-invoked
only, disable-model-invocation): /dotfiles-release, /dotfiles-apply,
/cleanup-session-codebase, /cleanup-whole-codebase now live under
skills/; the commands/ directory is removed. Slash invocation unchanged.

Known pitfall documented: the watermarks-remover clean-mode PostToolUse
hook strips `description:` lines from markdown frontmatter written via
the Write/Edit tools — write skill frontmatter via shell commands, or
temporarily disable the hook, when authoring skills.

## v5 — 2026-09-01

Extended the /dotfiles-release command with a doc-consistency pass: before
committing, it now checks README.md (file/skill tables, per-skill
descriptions, plugin table) and SETUP.md (marketplace/install command
lists, skills-CLI registrations, verify-step checks) against the release's
changes, so current-state docs can no longer drift from the changelog the
way SETUP.md did between v2 and v4. Commit step renumbered accordingly.
README now distinguishes self-authored commands (the four cleanup/dotfiles
slash commands) from installed third-party skills, with source attribution
per entry (context-audit marked "source unknown"). Repaired v2-era drift in
the README plugin table: removed ui-ux-pro-max, added security-guidance and
frontend-design, marked taste-skill globally disabled.

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
