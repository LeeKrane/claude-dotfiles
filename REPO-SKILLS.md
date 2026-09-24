# Repo-scoped skills registry

A repo-scoped skill is vetted and wanted, but deliberately never installed or
enabled globally: absent from `~/.claude/skills/`, or disabled in
`settings.json`. Zero always-on tokens in sessions that don't need it. It is
installed or enabled only in the projects that want it, one of two ways:

- **Skill install**: a pinned copy of the source's skill files lands at
  `<project>/.claude/skills/<name>/`, excluded via the project's own
  git exclude file (`git rev-parse --git-path info/exclude`) (never its tracked `.gitignore`, unless asked).
- **Plugin enable** (no entry uses it yet): plugin installed globally but
  disabled in `settings.json`; a project re-enables it via `enabledPlugins`
  (or `skillOverrides`) in `<project>/.claude/settings.local.json`, which
  this repo never tracks.

`/repo-skills` (`skills/repo-skills/SKILL.md`) reads this file, matches each
entry's Signals against the current project, and applies Enable for whatever
the user approves. `skill-scout` appends entries here whenever a candidate's
verdict is **project-scope** (its step 10) — vetted, wanted, never global.

Fields per entry, one per line: Type (skill | plugin | mcp), Path (subdir of
the source holding the installable skill; `.` = repo root), Depends, What,
Signals, Global state, Source, Pin, Vetted, Enable (for `plugin` type: a literal `enabledPlugins` or `skillOverrides` JSON fragment; otherwise prose naming the exact install action), Cost, Refresh, Setup (optional; integration items from skill-scout's step 10 as sub-bullets tagged `config:` — a literal JSON fragment `/repo-skills` merges into `<project>/.claude/settings.local.json` — or `manual:` — dependencies, env var names, CLAUDE.md line, smoke test, shown as follow-ups, never run).

## video-shotcraft

- Type: skill
- Path: `.` (`.claude-plugin/plugin.json` sets `"skills": "./"`)
- Depends: none at install; its instructions run unpinned `npx remotion …`; optional JianYing export needs `pip install pyJianYingDraft`
- What: cinematic product/promo videos with Remotion, built from shot recipe cards, a validated "Ink Press" template, and bundled SFX/BGM
- Signals: `remotion` in `package.json` deps; `remotion.config.ts`; user asks for a product/promo video
- Global state: not installed globally, not vendored into this repo
- Source: https://github.com/Vincentwei1021/video-shotcraft
- Pin: `5f047c7cfe10d6616fe59160a750fcfaea510b2e`
- Vetted: 2026-09-07, skill-scout + council, project-scope. SkillSpector CRITICAL = static noise (0% coverage); real notes: unpinned `npx remotion`, optional pip install, gallery page fetches api.github.com, CI-only sudo apt
- Enable: shallow-fetch Pin into `<project>/.claude/skills/video-shotcraft` and drop `.git` (fast path: copy the vetted clone `~/.cache/skill-scout/2026-09-07/B/video-shotcraft` if its HEAD equals Pin and its tree is clean)
- Cost: 0 always-on until enabled; on invocation SKILL.md ≈1.1k tok + top-level references/ ≈10k tok; per-shot recipe cards under references/shots/ total ≈35k words (≈47k tok) but load one card per shot
- Refresh: re-run skill-scout on upstream, diff against Pin, re-vet notes above, bump Pin

## brag

- Type: skill (subdir of a plugin repo)
- Path: `skills/brag`
- Depends: Hyperframes CLI (`npx hyperframes`, check `npx hyperframes doctor`) and its skills `hyperframes-core`, `-animation`, `-creative`, `-keyframes`, `-cli` (read at brag step 3). Not installed by `/repo-skills`; install per https://hyperframes.heygen.com/ and measure its description cost first
- What: turns the current project's code (no live URL) into a 15–25s launch video via HeyGen Hyperframes, with music, SFX, share copy. Not `kammradt/brag-skill` (accomplishment reports; name collision)
- Signals: shipped web project wanting a launch/promo video; "launch video", "/brag", "brag about this"; `PRODUCT.md` at root; existing `hyperframes` dependency or `hyperframes-*` skills
- Global state: not installed globally, not vendored into this repo
- Source: https://github.com/latent-spaces/brag
- Pin: `1f8d9ade17d0ad4419cca9305fbc1398a4dd5b39`
- Vetted: 2026-09-07, skill-scout 2nd run, council `--quick`. Original call "skip, revisit at KraneticFitness v1 + launch-video request", user overrode to project-scope. SkillSpector 61/HIGH = 3 false positives + unpinned `npx hyperframes`; manual read clean; optional `scripts/analyze_music_cues.py` uses uv
- Enable: shallow-fetch Pin into a scratch dir, copy `skills/brag` to `<project>/.claude/skills/brag`, remove scratch (fast path: copy from `~/.cache/skill-scout/2026-09-07/D/latent-spaces-brag/skills/brag` if HEAD equals Pin and its tree is clean)
- Cost: 77 tok always-on when enabled; ~17.6–19.4k tok per invocation
- Refresh: re-run skill-scout on latent-spaces/brag, re-diff Pin, re-measure Hyperframes description cost

## obsidian-notes-creator

- Type: skill
- Path: `skills/obsidian-notes-creator`
- Depends: none (output is plain markdown; Obsidian-flavoured callouts/wikilinks/Mermaid render best in Obsidian)
- What: creates high-quality Obsidian study notes with analogies, diagrams, and structured explanations, for single notes or multi-file topic sets
- Signals: lecture slides/PDFs/course material in the repo; user asks for study notes, lecture summaries, exam prep notes, "study notes", "note from lecture", "note from PDF"
- Global state: not installed globally, not vendored into this repo
- Source: https://github.com/szeyu/vibe-study-skills
- Pin: `be514bd78b3b3285db061f5828ae26007466af1f`
- Vetted: 2026-09-11, skill-scout + council. SkillSpector 20/LOW, 1 finding (MP3 Memory Manipulation quoting "clear state" at `references/components/diagrams.md:13`, a Mermaid stateDiagram-v2 table entry) = false positive; manual read of all 13 files clean (no exec, network, credentials, anti-refusal); single maintainer consolidated 14 skills into this one 2026-06-11 (commit 169c958), skills.sh index still lists the deleted names; council `--quick` diversity LOW corrected draft global→project-scope
- Enable: shallow-fetch Pin into a scratch dir, copy `skills/obsidian-notes-creator` to `<project>/.claude/skills/obsidian-notes-creator`, remove scratch (fast path: copy from `~/.cache/skill-scout/2026-09-11/A/skills/obsidian-notes-creator` if HEAD equals Pin and tree is clean)
- Cost: 107 tok always-on when enabled; SKILL.md ≈0.9k tok + references/ ≈9.7k tok (≈10.6k total if all 12 refs load; loaded selectively)
- Refresh: re-run skill-scout on szeyu/vibe-study-skills, diff against Pin (note: upstream renames skills without notice — verify the skill dir still exists)

## hormozi-offer

- Type: skill
- Path: `skills/hormozi-offer`
- Depends: none (pure Markdown instructions, outputs `OFFER.md`)
- What: builds a Grand Slam Offer from a rough business idea/product/service through market selection, avatar, obstacle mapping, value stack, pricing, guarantee, positioning, and messaging
- Signals: `budget.yaml` + `playbook/` at repo root, repo `krane-solutions-business-orchestration`; user asks for offer work, "build an offer", "OFFER.md", "grand slam offer"
- Global state: not installed globally, not vendored into this repo
- Source: https://github.com/alexsmedile/hormozi-skills
- Pin: `25ec2b0789ae8c760b45f577024782ff399983a6`
- Vetted: 2026-09-25 re-vet by skill-scout + full council (supersedes the earlier "operator-approved" entry). SkillSpector 2.12.0 `--no-llm`: score 0, no findings. Full line-by-line manual read at Pin: single-file markdown, no scripts, network, credentials or anti-refusal; no instruction to initiate contact (§174 TKG). Intent: all aspects, this repo only
- Enable: shallow-fetch Pin into a scratch dir, copy `skills/hormozi-offer` to `<project>/.claude/skills/hormozi-offer`, remove scratch (fast path: copy `~/.cache/skill-scout/2026-09-25/hormozi-skills/skills/hormozi-offer` if its HEAD equals Pin and its tree is clean)
- Cost: 81 tok always-on when enabled (only in sessions inside that repo); ≈3.05k tok on invocation, single SKILL.md
- Refresh: re-run skill-scout on alexsmedile/hormozi-skills, diff against Pin, re-vet notes above, bump Pin; usage review 2026-10-16 — remove the entry if claude-mem shows zero invocations

## pricing-strategy

- Type: skill
- Path: `skills/pricing-strategy`
- Depends: none (pure Markdown instructions, outputs `PRICING.md`)
- What: anchors price to value rather than guesswork — outcome value, delivery model (DIY/DWY/DFY), pricing tiers, psychological pricing, price justification story
- Signals: `budget.yaml` + `playbook/` at repo root, repo `krane-solutions-business-orchestration`; user asks for pricing work, "pricing strategy", "PRICING.md", price tiers
- Global state: not installed globally, not vendored into this repo
- Source: https://github.com/alexsmedile/hormozi-skills
- Pin: `25ec2b0789ae8c760b45f577024782ff399983a6`
- Vetted: 2026-09-25 re-vet by skill-scout + full council (supersedes the earlier "operator-approved" entry). SkillSpector 2.12.0 `--no-llm`: score 0, no findings. Full line-by-line manual read at Pin: single-file markdown, no scripts, network, credentials or anti-refusal; no instruction to initiate contact (§174 TKG). Intent: all aspects, this repo only
- Enable: shallow-fetch Pin into a scratch dir, copy `skills/pricing-strategy` to `<project>/.claude/skills/pricing-strategy`, remove scratch (fast path: copy `~/.cache/skill-scout/2026-09-25/hormozi-skills/skills/pricing-strategy` if its HEAD equals Pin and its tree is clean)
- Cost: 86 tok always-on when enabled (only in sessions inside that repo); ≈1.39k tok on invocation, single SKILL.md
- Refresh: re-run skill-scout on alexsmedile/hormozi-skills, diff against Pin, re-vet notes above, bump Pin; usage review 2026-10-16 — remove the entry if claude-mem shows zero invocations

## business-model

- Type: skill
- Path: `skills/business-model`
- Depends: none (pure Markdown instructions, outputs `BUSINESS_MODEL.md`)
- What: designs the right monetization model (service/DFY, productized/DWY, digital product/DIY, subscription, high-ticket, hybrid) against the user's skills, assets, constraints, and goals
- Signals: `budget.yaml` + `playbook/` at repo root, repo `krane-solutions-business-orchestration`; user asks for business-model work, "which business model", "BUSINESS_MODEL.md", DFY/DWY/DIY comparison
- Global state: not installed globally, not vendored into this repo
- Source: https://github.com/alexsmedile/hormozi-skills
- Pin: `25ec2b0789ae8c760b45f577024782ff399983a6`
- Vetted: 2026-09-25 re-vet by skill-scout + full council (supersedes the earlier "operator-approved" entry). SkillSpector 2.12.0 `--no-llm`: score 0, no findings. Full line-by-line manual read at Pin: single-file markdown, no scripts, network, credentials or anti-refusal; no instruction to initiate contact (§174 TKG). Intent: all aspects, this repo only
- Enable: shallow-fetch Pin into a scratch dir, copy `skills/business-model` to `<project>/.claude/skills/business-model`, remove scratch (fast path: copy `~/.cache/skill-scout/2026-09-25/hormozi-skills/skills/business-model` if its HEAD equals Pin and its tree is clean)
- Cost: 67 tok always-on when enabled (only in sessions inside that repo); ≈1.38k tok on invocation, single SKILL.md
- Refresh: re-run skill-scout on alexsmedile/hormozi-skills, diff against Pin, re-vet notes above, bump Pin; usage review 2026-10-16 — remove the entry if claude-mem shows zero invocations

## objection-destroyer

- Type: skill
- Path: `skills/objection-destroyer`
- Depends: none (pure Markdown instructions, outputs `OBJECTIONS.md`)
- What: turns objections into reasons to buy — surfaces surface and hidden objections, maps belief shifts, attaches proof, generates reusable objection-handling statements for sales pages/pitches/FAQs
- Signals: `budget.yaml` + `playbook/` at repo root, repo `krane-solutions-business-orchestration`; user asks for objection-handling work, "objection destroyer", "OBJECTIONS.md", "why aren't they buying"
- Global state: not installed globally, not vendored into this repo
- Source: https://github.com/alexsmedile/hormozi-skills
- Pin: `25ec2b0789ae8c760b45f577024782ff399983a6`
- Vetted: 2026-09-25 re-vet by skill-scout + full council (supersedes the earlier "operator-approved" entry). SkillSpector 2.12.0 `--no-llm`: score 0, no findings. Full line-by-line manual read at Pin: single-file markdown, no scripts, network, credentials or anti-refusal; no instruction to initiate contact (§174 TKG). Intent: all aspects, this repo only
- Enable: shallow-fetch Pin into a scratch dir, copy `skills/objection-destroyer` to `<project>/.claude/skills/objection-destroyer`, remove scratch (fast path: copy `~/.cache/skill-scout/2026-09-25/hormozi-skills/skills/objection-destroyer` if its HEAD equals Pin and its tree is clean)
- Cost: 82 tok always-on when enabled (only in sessions inside that repo); ≈1.31k tok on invocation, single SKILL.md
- Refresh: re-run skill-scout on alexsmedile/hormozi-skills, diff against Pin, re-vet notes above, bump Pin; usage review 2026-10-16 — remove the entry if claude-mem shows zero invocations

## marketing-council

- Type: skill (subdir of a plugin/marketplace repo)
- Path: `skills/marketing-council`
- Depends: none required; optionally uses a `deep-research`, video-analysis, or recency skill if installed for its live research pass (falls back to built-in web search)
- What: convenes a simulated board of 12 legendary marketer personas (Godin, Ogilvy, Schwartz, Hopkins, Halbert, Brunson, Hormozi, Dunford, Sutherland, Sharp, Handley, Vaynerchuk) with a mandatory designated-dissenter rule, disagreement mapping, and a chair's synthesis; distinct from the installed `council-review` skill (domain-specific persona simulation vs. general reasoning-method debate)
- Signals: `budget.yaml` + `playbook/` at repo root, repo `krane-solutions-business-orchestration`; user asks for marketing-council work, "marketing council", "board of advisors", "what would Hormozi/Ogilvy/Godin say"
- Global state: not installed globally, not vendored into this repo
- Source: https://github.com/coreyhaines31/marketingskills
- Pin: `5b2c0007766c6a1cf1d53fd8fc73e979e0821022`
- Vetted: 2026-09-25 re-vet by skill-scout + full council (supersedes the earlier "operator-approved" entry, whose advisor dossiers were only grepped). SkillSpector 2.12.0 `--no-llm`: score 3/LOW, one finding EA3 on `evals/evals.json` with no line or message = false positive (test fixture, never loaded at runtime, read in full). Full line-by-line manual read of all 14 files at Pin: markdown only; only network use is the optional research pass via built-in web search; "cold outreach" appears only as a description of Hormozi's Core Four in `references/advisors/alex-hormozi.md:9`, never as an instruction (§174 TKG). Council: PARTIAL overlap with global council-review on "council" triggers → manual-only. Intent: council review aspect only, this repo only
- Enable: shallow-fetch Pin into a scratch dir, copy `skills/marketing-council` to `<project>/.claude/skills/marketing-council`, remove scratch (fast path: copy `~/.cache/skill-scout/2026-09-25/marketingskills/skills/marketing-council` if its HEAD equals Pin and its tree is clean). Never install the `marketing-skills` plugin: it pulls all 50 skills in the repo
- Cost: 0 always-on (manual-only via Setup); invoked: SKILL.md ≈3.1k tok + ≈1-1.2k per seated advisor (≈3-6k for a 3-5 advisor session; all 12 ≈12.7k)
- Refresh: re-run skill-scout on coreyhaines31/marketingskills, diff against Pin, re-vet notes above, bump Pin; usage review 2026-10-16 — remove the entry if claude-mem shows zero invocations
- Setup:
  - config: `{"skillOverrides": {"marketing-council": "user-invocable-only"}}` — hides it from the model so "council this" keeps reaching global council-review; `/marketing-council` still works when typed
  - manual: smoke test — in that repo, "council this" runs council-review; `/marketing-council should we raise prices?` seats 3-5 advisors and ends with a chair synthesis
