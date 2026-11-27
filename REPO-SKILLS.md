# Repo-scoped skills registry

A repo-scoped skill is vetted and wanted, but deliberately never installed or
enabled globally: absent from `~/.claude/skills/`, or disabled in
`settings.json`. Zero always-on tokens in sessions that don't need it. It is
installed or enabled only in the projects that want it, one of two ways:

- **Skill install**: a pinned copy of the source's skill files lands at
  `<project>/.claude/skills/<name>/`, excluded via the project's own
  git exclude file (`git rev-parse --git-path info/exclude`) (never its tracked `.gitignore`, unless asked).
- **Plugin enable**: plugin (or a plugin's skill, or a skill in
  `~/.claude/skills/`) installed globally but disabled in `settings.json`
  (`enabledPlugins: false` or `skillOverrides: "off"`); a project re-enables
  it via `enabledPlugins` (or `skillOverrides: "on"`) in
  `<project>/.claude/settings.local.json`, which this repo never tracks.
  Local settings win over user settings, so the project's `"on"` beats the
  global `"off"`. Entries of this kind use Type `plugin` even when the skill
  lives in `~/.claude/skills/`, because enabling is a settings merge, not a
  file copy.

`/repo-skills` (`skills/repo-skills/SKILL.md`) reads this file, matches each
entry's Signals against the current project, and applies Enable for whatever
the user approves. `skill-scout` appends entries here whenever a candidate's
placement is **Repo skill** (its step 5) — vetted, wanted, never global.

Fields per entry, one per line: Type (skill | plugin | mcp), Path (subdir of
the source holding the installable skill; `.` = repo root), Depends, Requires (optional; other registry entries `/repo-skills` installs alongside, before this one), What,
Signals, Global state, Source, Pin, Vetted, Enable (for `plugin` type: a literal `enabledPlugins` or `skillOverrides` JSON fragment; otherwise prose naming the exact install action), Cost, Refresh, Setup (optional; integration items from skill-scout's step 5 as sub-bullets tagged `config:` — a literal JSON fragment `/repo-skills` merges into `<project>/.claude/settings.local.json`, hooks included — `claude-md:` — one line `/repo-skills` appends to `<project>/CLAUDE.md` — or `manual:` — dependencies, env var names, smoke test, shown as follow-ups, never run).

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

## replica-skill

- Type: skill (11 sibling skill dirs from a plugin repo, installed as a set)
- Path: `replica-*` (the 11 dirs `replica-recon`, `replica-architect`, `replica-design`, `replica-build`, `replica-backend`, `replica-test`, `replica-diff`, `replica-entrepreneur`, `replica-brand`, `replica-launch`, `replica-deploy`)
- Depends: python3 ≥3.8 (stdlib only) for the design, diff, entrepreneur, brand and launch scripts; node for build, backend, test and deploy; `@playwright/test` + `@axe-core/playwright` for test; `eas-cli` only for Expo mobile builds. No Stripe CLI or host CLI
- What: pipeline to rebuild an existing app as your own. Recon map (screens, flows, inferred data model, feature matrix), then stack/schema/API plan, design tokens + WCAG contrast check, screen-by-screen build, auth/DB/Stripe/email backend, Playwright e2e tests, feature-parity score + screenshot layout diff, public-review mining for gaps and positioning, naming/rebrand + leftover sweep, landing page/pricing/store-listing lint, deploy with preflight gate
- Signals: repo `KraneticFitness` (fitness and calorie-tracking app; repo not created at vet time); user asks to clone, reverse-engineer or rebuild an existing app there
- Global state: not installed globally, not vendored into this repo
- Source: https://github.com/Jakeschincariol/replica-skill
- Pin: `77c9436fb3d18c3d58169efb8caf4fe906b0dc51`
- Vetted: 2026-10-05, skill-scout, council `--quick` (diversity Low; devil's advocate conceded that registering costs nothing). SkillSpector `--no-llm`: 10 findings, all false positives — TR2 broad triggers on architect/diff (breadth, not malice), LP3 no declared tool scope on brand/entrepreneur, RP1 unpinned `npx playwright` in test/deploy (runs the project-local package), YR4 on `replica-launch/listing.py` (literal zero-width joiner used for grapheme counting), AE1 parse limit on `replica-test/e2e.example.spec.ts` (read in full, clean). Full manual read (opus): Python is stdlib only, no network/subprocess/exec, nothing phones home. Upstream behaviour kept as is by user decision: `replica-build` commits per screen, `replica-test` runs `npm i -D @playwright/test` unasked, `replica-entrepreneur` may read G2/Capterra/Trustpilot (ToS risk; official feeds also offered), `replica-deploy` has no explicit user-confirm line before Stripe live mode or `eas submit`. Intent: all four aspect groups, KraneticFitness only
- Enable: shallow-fetch Pin into a scratch dir, copy the 11 `replica-*` dirs as flat siblings to `<project>/.claude/skills/` (sibling layout is required: brand and deploy call `../replica-design/contrast.py`, `../replica-diff/parity.py`, `../replica-brand/sweep.py`, `../replica-launch/listing.py`), drop `.claude-plugin/`, `tests/`, README, LICENSE, remove scratch (fast path: copy from `~/.cache/skill-scout/2026-10-05/replica-skill` if its HEAD equals Pin and its tree is clean). Never install via the plugin manifest: it namespaces commands to `/replica-skill:replica-*` and changes the install root
- Cost: 0 always-on outside the repo; inside it ≈890 tok (7 model-invocable descriptions; recon, test, launch, deploy hidden via Setup); invoked: SKILL.md ≈0.8-1.4k tok each (≈11.7k for all 11), scripts only when run
- Refresh: re-run skill-scout on Jakeschincariol/replica-skill, diff against Pin, re-vet notes above, bump Pin; usage review 2026-11-05 — if KraneticFitness still does not exist, re-ask whether to keep the entry
- Setup:
  - config: `{"skillOverrides": {"replica-recon": "user-invocable-only", "replica-test": "user-invocable-only", "replica-launch": "user-invocable-only", "replica-deploy": "user-invocable-only"}}` — their descriptions claim "how does X work", "find bugs", "QA this", "does it work", "landing page", "pricing", "deploy it", "ship it"; hidden so those keep reaching superpowers/impeccable; `/replica-recon` etc. still work when typed
  - manual: dependencies — `! python3 --version` (≥3.8), `! node --version`, `! npm i -D @playwright/test @axe-core/playwright` (test aspect), `! npx eas-cli` only for Expo mobile builds
  - manual: env names depend on the stack replica-architect picks; upstream writes a value-free `.env.example`, the user fills `.env.local` and the host's env settings (default stack: `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_ROLE_KEY`, `STRIPE_SECRET_KEY`, `STRIPE_PUBLISHABLE_KEY`, `STRIPE_WEBHOOK_SECRET`, `RESEND_API_KEY`)
  - manual: NixOS — Playwright's own chromium download often fails; use nixpkgs `playwright-driver.browsers` with `PLAYWRIGHT_BROWSERS_PATH` instead of `npx playwright install chromium`; put python3/node in the project's devShell
  - manual: RTK compresses Bash output — check one real run of `parity.py`/`imgdiff.py`/`sweep.py` before trusting parsed numbers; caveman style must not leak into replica-brand voice or replica-launch landing/listing copy, so clean that copy before shipping
  - manual: smoke test — in that repo, `/replica-recon` loads and asks its three scoping questions (app + platform, which slice, who it is for); "find bugs" still routes to superpowers

## convert-documents-to-markdown

- Type: skill (vendored with local edits)
- Path: `skills/convert-documents-to-markdown`
- Depends: `anydoc` CLI on PATH, from the dotfiles package `pkgs/anydoc` (pinned 0.2.4, home-manager `dev.nix`); not installed by `/repo-skills`
- What: converts docx/pptx/xlsx/odt/ods/odp/rtf/epub and legacy doc/ppt/xls to Markdown with the local `anydoc` CLI; optional hosted OCR for scanned PDFs via Firecrawl Parse, ask-first
- Signals: office documents (`.docx`, `.pptx`, `.xlsx`, `.odt`, `.epub`, ...) or scanned PDFs in the repo; Obsidian study vault with lecture material; user asks to read or convert an office document
- Global state: not installed globally; adapted copy vendored at `~/.claude/vendor/convert-documents-to-markdown/SKILL.md`
- Source: https://github.com/firecrawl/anydoc
- Pin: `261fc257d17c3eab0f673be31c408fd9fdc2171a`
- Vetted: 2026-10-08, skill-scout (council skipped at user request), project-scope. SkillSpector `--no-llm`: 12/LOW, SAFE; only finding RP1 (MEDIUM) unpinned `npx -y @firecrawl/anydoc` at SKILL.md:14-16 = real, resolved by the local edit to the Nix-pinned `anydoc`. Manual read of the single 26-line SKILL.md: no exec beyond the CLI, no credential handling; rule 5 `--ocr hosted` uploads the whole document to Firecrawl, edited to ask the user first. Usage: 0 of 267 prompts mention office formats; user wants it anyway, repos chosen later
- Enable: copy `~/.claude/vendor/convert-documents-to-markdown/` to `<project>/.claude/skills/convert-documents-to-markdown/`. Upstream at Pin is the provenance reference only; its unedited SKILL.md calls unpinned npx and auto-suggests hosted OCR, so never install it directly
- Cost: ≈75 tok always-on when enabled (only in that repo); ≈550 tok on invocation, single SKILL.md, plus the converted Markdown
- Refresh: re-run skill-scout on firecrawl/anydoc, diff upstream SKILL.md against Pin, reapply the edits listed in the vendored copy's provenance comment, bump Pin; bump `pkgs/anydoc` alongside; usage review 2026-11-08 — remove the entry if claude-mem shows zero invocations
- Setup:
  - manual: rebuild the dotfiles (`/dotfiles-apply`) so `anydoc` is on PATH; check with `! anydoc --version` (expect 0.2.4)
  - manual: optional `FIRECRAWL_API_KEY` in the shell profile, only for higher hosted-OCR limits
  - manual: smoke test — in that repo, "what's in <file>.docx?" loads the skill and runs `anydoc`; a text PDF still goes through Read

## pdf-to-obsidian-notes

- Type: skill (self-authored, vendored)
- Path: `.`
- Depends: `anydoc` CLI on PATH (dotfiles `pkgs/anydoc`); not installed by `/repo-skills`
- Requires: `convert-documents-to-markdown`, `obsidian-notes-creator`
- What: one-argument pipeline (PDF path or name): converts the PDF with `anydoc`, cleans the conversion Markdown in a sonnet subagent (keeps all content, never reads the PDF), then makes Obsidian study notes from it with obsidian-notes-creator, optionally merged with the user's handwritten lecture notes (second argument, a `.md` file, read as-is). Moves the PDF, the cleaned `<stem>.md` and the lecture notes into `_original_/` beside the PDF, and writes all notes flat where the PDF was (hub or single note `<stem>.md`)
- Signals: PDFs of lecture slides or course material in the repo; user asks for study notes from a PDF, "/pdf-to-obsidian-notes"
- Global state: not installed globally; source vendored at `~/.claude/vendor/pdf-to-obsidian-notes/SKILL.md`
- Source: `~/.claude/vendor/pdf-to-obsidian-notes/`
- Pin: none (self-authored; versioned by the dotfiles repo)
- Vetted: 2026-10-08, self-authored, no external code. Runs only `anydoc`, `find`, `cp`, `wc`, `grep`; `--ocr hosted` (uploads the PDF to Firecrawl) only after asking, inherited from convert-documents-to-markdown rule 5. Written after a cleanup subagent was told to cross-check the raw PDF, which defeats anydoc's token saving; the skill forbids any PDF read after conversion
- Enable: install the Requires entries first, then copy `~/.claude/vendor/pdf-to-obsidian-notes/` to `<project>/.claude/skills/pdf-to-obsidian-notes/`
- Cost: about 45 tok always-on when enabled; about 1.8k tok SKILL.md on invocation, plus the two required skills, the cleanup subagent (about 100-150k subagent tokens for a 40-slide deck) and note writing
- Refresh: edit the vendored copy; re-check when either required skill's Pin changes (obsidian-notes-creator renames, anydoc exit codes)
- Setup:
  - manual: check `! anydoc --version` (expect 0.2.4); rebuild the dotfiles (`/dotfiles-apply`) if missing
  - manual: smoke test: in that repo, `/pdf-to-obsidian-notes <file>.pdf` leaves `_original_/<file>.pdf` and `_original_/<file>.md`, writes notes (`<file>.md` hub plus any others, no subfolders) where the PDF was, and makes no Read call on the PDF

## engineering-skills

- Type: plugin (own skills in `~/.claude/skills/`, disabled by `skillOverrides`)
- Path: `skills/wayfinder`, `skills/setup-matt-pocock-skills`, `skills/domain-modeling`, `skills/grilling`, `skills/prototype`
- Depends: an issue tracker for wayfinder (GitHub, GitLab or local, chosen by setup-matt-pocock-skills)
- What: multi-session planning with decision tickets (wayfinder), its one-time repo setup, domain glossary and ADR upkeep, plan grilling, throwaway prototypes
- Signals: work too big for one session or with open "X or Y?" decisions; `CONTEXT.md` or `docs/adr/` in the repo; issue tracker in use; user asks to grill a plan or prototype a design
- Global state: installed in `~/.claude/skills/`, `"off"` in `settings.json` `skillOverrides` since 2026-11-20 (doctor: 0 uses)
- Source: this dotfiles repo
- Pin: none (versioned by the dotfiles repo)
- Vetted: self-maintained copies already in use
- Enable: `{"skillOverrides": {"wayfinder": "on", "setup-matt-pocock-skills": "on", "domain-modeling": "on", "grilling": "on", "prototype": "on"}}`
- Cost: about 150 tok always-on when enabled (wayfinder and setup-matt-pocock-skills are slash-only, 0 tok)
- Refresh: edit the skills in this repo

## codebase-cleanup

- Type: plugin (own skills in `~/.claude/skills/`, disabled by `skillOverrides`)
- Path: `skills/cleanup-session-codebase`, `skills/cleanup-whole-codebase`, `skills/blast-radius`
- Depends: none
- What: slash-only dead-code and debug-logging cleanup for a session diff or a whole repo; blast-radius check of what a change could break beyond the diff
- Signals: code repo with active feature branches; user asks for cleanup or a pre-ship impact check
- Global state: installed in `~/.claude/skills/`, `"off"` in `settings.json` `skillOverrides` since 2026-11-20 (doctor: 0 uses)
- Source: this dotfiles repo
- Pin: none (versioned by the dotfiles repo)
- Vetted: self-maintained
- Enable: `{"skillOverrides": {"cleanup-session-codebase": "on", "cleanup-whole-codebase": "on", "blast-radius": "on"}}`
- Cost: 0 tok always-on (all slash-only)
- Refresh: edit the skills in this repo

## superpowers-extras

- Type: plugin (skills of `superpowers@superpowers-dev`, plugin itself stays enabled globally)
- Path: n/a
- Depends: superpowers plugin enabled
- What: inline plan execution (executing-plans), parallel agent fan-out (dispatching-parallel-agents), skill authoring with tests (writing-skills), post-mortem of a failed superpowers session (diagnosing-superpowers)
- Signals: implementation plans under `docs/superpowers/plans/`; repo with `skills/*/SKILL.md` or `.claude-plugin/plugin.json` (skill or plugin authoring); user wants a plan run inline instead of with subagents
- Global state: plugin enabled; these 4 skills `"off"` in `settings.json` `skillOverrides` since 2026-11-20 (doctor: 0 uses)
- Source: superpowers-dev marketplace
- Pin: plugin version 6.4.1 at time of entry
- Vetted: plugin already installed and in use
- Enable: `{"skillOverrides": {"superpowers:executing-plans": "on", "superpowers:dispatching-parallel-agents": "on", "superpowers:writing-skills": "on", "superpowers:diagnosing-superpowers": "on"}}`
- Cost: about 200 tok always-on when enabled
- Refresh: after a superpowers update, check the 4 skill names still exist

## frontend-design

- Type: plugin (skills of `impeccable@impeccable` and `claude-mem@thedotmack`, plugins stay enabled globally)
- Path: n/a
- Depends: impeccable and claude-mem plugins enabled
- What: UI design, critique, polish and design-system work (impeccable); Dieter Rams design audit that hands off a plan (claude-mem design-is)
- Signals: frontend deps in `package.json` (`react`, `vue`, `svelte`, `next`, `astro`, `tailwindcss`); `*.css`/`*.html`/component dirs; user asks to design, redesign or critique a UI
- Global state: plugins enabled (impeccable's hooks keep running); both skills `"off"` in `settings.json` `skillOverrides` since 2026-11-20 (doctor: 0 uses)
- Source: impeccable and thedotmack marketplaces
- Pin: impeccable 4.3.1, claude-mem 13.25.3 at time of entry
- Vetted: plugins already installed and in use
- Enable: `{"skillOverrides": {"impeccable:impeccable": "on", "claude-mem:design-is": "on"}}`
- Cost: about 300 tok always-on when enabled
- Refresh: after a plugin update, check the skill names still exist

## claude-mem-planning

- Type: plugin (skills of `claude-mem@thedotmack`, plugin stays enabled globally)
- Path: n/a
- Depends: claude-mem plugin enabled, worker running
- What: phased plan then subagent execution (make-plan, do), architecture unification map (pathfinder), full codebase priming (learn-codebase), AST-based structural search (smart-explore)
- Signals: large or unfamiliar codebase; refactor across duplicated subsystems; user asks to prime or map the codebase
- Global state: plugin enabled; these skills `"off"` in `settings.json` `skillOverrides` since 2026-11-20 (doctor: 0 uses)
- Source: thedotmack marketplace
- Pin: claude-mem 13.25.3 at time of entry
- Vetted: plugin already installed and in use
- Enable: `{"skillOverrides": {"claude-mem:make-plan": "on", "claude-mem:do": "on", "claude-mem:pathfinder": "on", "claude-mem:learn-codebase": "on", "claude-mem:smart-explore": "on"}}`
- Cost: about 370 tok always-on when enabled
- Refresh: after a claude-mem update, check the skill names still exist

## claude-mem-github

- Type: plugin (skills of `claude-mem@thedotmack`, plugin stays enabled globally)
- Path: n/a
- Depends: claude-mem plugin enabled; `gh` authenticated
- What: watch a PR until review and CI are clean (babysit); cluster an issue backlog by root cause into plan issues (oh-my-issues); version bump, tag and release for Claude Code plugins (version-bump)
- Signals: GitHub remote with open PRs or a large issue backlog; `.claude-plugin/plugin.json` or `marketplace.json` in the repo (version-bump)
- Global state: plugin enabled; these skills `"off"` in `settings.json` `skillOverrides` since 2026-11-20 (doctor: 0 uses)
- Source: thedotmack marketplace
- Pin: claude-mem 13.25.3 at time of entry
- Vetted: plugin already installed and in use
- Enable: `{"skillOverrides": {"claude-mem:babysit": "on", "claude-mem:oh-my-issues": "on", "claude-mem:version-bump": "on"}}`
- Cost: about 220 tok always-on when enabled
- Refresh: after a claude-mem update, check the skill names still exist

## caveman-workflows

- Type: plugin (skills of `caveman@caveman`, plugin and caveman mode stay enabled globally)
- Path: n/a
- Depends: caveman plugin enabled
- What: disciplined task modes: diagnose first (investigate-first), scoped feature build (lean-build), reversible migrations (migration), behavior-preserving refactors (safe-refactor), narrow bug fixes (surgical-patch), acceptance-only verification (verify-and-stop)
- Signals: schema/data/API migrations (`migrations/`, `prisma/`, `alembic/`); large refactor or intermittent bug in a code repo
- Global state: plugin enabled; these skills `"off"` in `settings.json` `skillOverrides` since 2026-11-20 (doctor: 0 uses)
- Source: caveman marketplace
- Pin: caveman 2.7.0 at time of entry
- Vetted: plugin already installed and in use
- Enable: `{"skillOverrides": {"caveman:investigate-first": "on", "caveman:lean-build": "on", "caveman:migration": "on", "caveman:safe-refactor": "on", "caveman:surgical-patch": "on", "caveman:verify-and-stop": "on"}}`
- Cost: about 300 tok always-on when enabled
- Refresh: after a caveman update, check the skill names still exist

## caveman-cloud

- Type: plugin (skills of `caveman@caveman`)
- Path: n/a
- Depends: caveman plugin enabled; a Caveman Cloud account
- What: route a repo's LLM calls through the Caveman Cloud gateway, label workflows, review spend evidence, run and manage optimization experiments
- Signals: LLM SDK in deps (`anthropic`, `@anthropic-ai/sdk`, `openai`, `langchain`, `ai`); user asks about LLM spend in that app
- Global state: plugin enabled; these skills `"off"` in `settings.json` `skillOverrides` since 2026-11-20 (doctor: 0 uses)
- Source: caveman marketplace
- Pin: caveman 2.7.0 at time of entry
- Vetted: plugin already installed and in use; `caveman-setup` rewires the app's LLM base URL, so review its diff before merging
- Enable: `{"skillOverrides": {"caveman:caveman-setup": "on", "caveman:caveman-discover": "on", "caveman:caveman-evidence-review": "on", "caveman:caveman-manage": "on", "caveman:caveman-optimize": "on", "caveman:caveman-learn": "on"}}`
- Cost: about 330 tok always-on when enabled
- Refresh: after a caveman update, check the skill names still exist

## writing-cleanup

- Type: plugin (skills of `watermarks-remover@watermarks-remover`, plugin and its PostToolUse hook stay enabled globally)
- Path: n/a
- Depends: watermarks-remover plugin enabled
- What: on-demand cleanup of reader-facing prose (clean-user-facing-text) and of provenance marks in PNG/JPEG/PDF/DOCX metadata and invisible Unicode (remove-ai-marks). The automatic hook already cleans files written with Write/Edit
- Signals: docs, manuscript, thesis or Obsidian vault repos; generated images, PDFs or DOCX meant for publication
- Global state: plugin enabled; both skills `"off"` in `settings.json` `skillOverrides` since 2026-11-20 (doctor: 0 uses)
- Source: watermarks-remover marketplace
- Pin: watermarks-remover 0.7.0 at time of entry
- Vetted: plugin already installed and in use
- Enable: `{"skillOverrides": {"watermarks-remover:clean-user-facing-text": "on", "watermarks-remover:remove-ai-marks": "on"}}`
- Cost: about 300 tok always-on when enabled
- Refresh: after a plugin update, check the skill names still exist

## office-documents

- Type: plugin (claude.ai account skills, synced as `anthropic-skills:*`)
- Path: n/a
- Depends: the skills still synced from the claude.ai account
- What: create and edit Word, PowerPoint, Excel and PDF files
- Signals: `.docx`, `.pptx`, `.xlsx` or PDF deliverables in the repo; user asks for an office file as output (for reading office files use convert-documents-to-markdown)
- Global state: `"off"` in `settings.json` `skillOverrides` since 2026-11-20 (doctor: 0 uses in the last month)
- Source: claude.ai account skills
- Pin: none (managed by claude.ai)
- Vetted: first-party
- Enable: `{"skillOverrides": {"anthropic-skills:docx": "on", "anthropic-skills:pptx": "on", "anthropic-skills:xlsx": "on", "anthropic-skills:pdf": "on"}}`
- Cost: about 400 tok always-on when enabled
- Refresh: none

## condom

- Type: skill
- Path: `.`
- Depends: none at install; its Find-it/Prove-it steps use `rg` and `curl`; optional `python3` only for the user-run `tools/check_quotes.py`
- What: pre-ship audit of your own app for the ways it gets hacked (107 security checks: leaked keys, open RLS/Firebase rules, prices trusted from the browser, unsigned webhooks, IDOR, SSRF) and the ways it gets sued (115 legal checks: privacy, cookies and pixels, email/SMS, subscriptions, children's data, accessibility, AI disclosure); writes `CONDOM-REPORT.md`; fixes one finding per commit only after the user says go. Built for Next.js, Supabase, Firebase, Stripe and Vercel apps
- Signals: repo `KraneticFitness` or `krane-solutions-business-orchestration`, and a backend route or deploy exists (`next`, `@supabase/supabase-js`, `firebase` or `stripe` in a `package.json`; `app/api/**/route.ts`; `vercel.json`; `supabase/migrations/`; `firestore.rules`); user asks to check the app before launch, "is my app secure", "can I get sued", or types `/condom`
- Global state: not installed globally, not vendored into this repo
- Source: https://github.com/murphyaidanbusiness-ux/condom
- Pin: `855995aa0f31e184068f84aab263b1444b48a4a1`
- Vetted: 2026-11-20, skill-scout + full council, project-scope. SkillSpector 2.12.0 `--no-llm`: 100/CRITICAL from 48 findings, all false positives (the reference files are a security-audit corpus that quotes the attacks it checks for, e.g. "169.254.169.254", "; rm -", a decompression-bomb test that says not to build one). Manual read: no phone-home, no credential reading, secrets masked to 4 chars; live-site probes are read-only, limited to the user's own site and asked for first; read-only until the user says fix. 26 legal entries are self-marked UNVERIFIED and the legal half is untested: treat legal output as leads, not law. Council: wait for backend code, since a run against docs-only repos gives false assurance. Intent: security audit + legal triage, these two repos only
- Enable: shallow-fetch Pin into `<project>/.claude/skills/condom` and drop `.git` (fast path: copy the vetted clone `~/.cache/skill-scout/2026-11-20/condom` if its HEAD equals Pin and its tree is clean)
- Cost: 0 always-on (manual-only via Setup); invoked: SKILL.md ≈3k tok, plus ≈40-60k tok of reference files per run, read by one subagent per reference file (`/condom security` or `/condom legal` roughly halves it)
- Refresh: re-run skill-scout on the source, diff against Pin, re-check the UNVERIFIED list in `VERIFICATION.md`, bump Pin
- Setup:
  - config: `{"skillOverrides": {"condom": "user-invocable-only"}}` — hides it from the model so "is my app secure" keeps reaching `/security-review` and the security-guidance hooks; `/condom` still works when typed
  - manual: `CONDOM-REPORT.md` lands at the project root with findings, masked key prefixes and file:line evidence; add it to the project's git exclude file (`git rev-parse --git-path info/exclude`) and do not commit it

## pocock-extras

- Type: plugin (own skills in `~/.claude/skills/`, disabled by `skillOverrides`)
- Path: `skills/wizard`, `skills/codebase-design`
- Depends: wizard writes `.env` files and sets GitHub secrets with `gh` (both from a script the user runs); codebase-design has none
- What: `wizard` generates an interactive bash script that walks the user through steps only a human can do (dashboards, credentials, CI secrets, cutovers); `codebase-design` is a deep-module vocabulary (module, interface, depth, seam, adapter, leverage, locality) with a design-it-twice pattern that runs parallel subagents
- Signals: repo `kranetic` (active there since 2026-11-24); design-first work on module structure; manual credential, signing-key or CI-secret setup; `improve-codebase-architecture` in use (it calls codebase-design)
- Global state: installed in `~/.claude/skills/`, `"off"` in `settings.json` `skillOverrides` since 2026-11-24
- Source: https://github.com/mattpocock/skills (`skills/engineering/wizard`, `skills/engineering/codebase-design`)
- Pin: `d65391149dbb5fe76478e76fa8d5122b2aa5a70e`
- Vetted: 2026-11-24, skill-scout + full council, project-scope. SkillSpector `--no-llm`: wizard 26/MEDIUM (credential access on `template.sh:106` is the `.env` upsert helper the user runs, false positive), codebase-design 0/LOW. Manual read: no phone-home, no credential reading by the agent, secrets entered hidden and written to a 0600 `.env`. Local edit: `DESIGN-IT-TWICE.md` says `CONTEXT.md` instead of `GLOSSARY.md`
- Enable: `{"skillOverrides": {"wizard": "on", "codebase-design": "on"}}`
- Cost: about 82 tok (wizard) + 70 tok (codebase-design) always-on when enabled; invoked: wizard ≈3.4k tok, codebase-design ≈1.6k tok plus ≈1.4k of reference files
- Refresh: re-run skill-scout on the source, diff against Pin, re-apply the local edit, bump Pin
- Setup:
  - manual: kranetic keeps secrets in SOPS; tell wizard where values go (SOPS file, not `.env`) before it writes stages. The `block-env-access` hook stops the agent from reading `.env` during scoping; point it at `.env.example` instead

## playwright-cli

- Type: skill (subdir of a CLI repo)
- Path: `skills/playwright-cli`
- Depends: `npm i -g @playwright/cli@latest` (provides `playwright-cli`), browsers via `playwright-cli install` or `npx playwright install chromium`
- What: drive a real browser from the shell (open, snapshot, click, fill, screenshot, network, sessions) so the agent can inspect and test a UI; token-leaner than Playwright MCP per its README
- Signals: frontend or web app (`package.json` with a UI framework, `index.html`, `vite.config.*`, `next.config.*`); user asks to check, test or screenshot the UI
- Global state: not installed globally, not vendored into this repo
- Source: https://github.com/microsoft/playwright-cli
- Pin: `dc5f4d5616ab5a28ded12fd7101a4d49bd59a820` (v0.1.25)
- Vetted: 2026-11-27, skill-scout. SkillSpector `--no-llm` 100/CRITICAL, 26 hits, all false positives (`.npmrc` strings in `.gitignore` and a test, YARA "info stealer" on extension prose, session-state docs, unpinned `npx` examples); scan covered 36 of 38 files. Manual read: no exfiltration, hidden exec or anti-refusal text
- Enable: shallow-fetch Pin and copy `skills/playwright-cli` into `<project>/.claude/skills/playwright-cli` (fast path: copy from the vetted clone `~/.cache/skill-scout/2026-11-27/playwright-cli` if its HEAD equals Pin and its tree is clean); alternative `playwright-cli install --skills` in the project installs the CLI's bundled, unpinned copy
- Cost: 0 always-on until enabled; on invocation SKILL.md ≈4k tok
- Refresh: re-run skill-scout on upstream, diff against Pin, bump Pin
- Setup:
  - manual: `npm i -g @playwright/cli@latest`, then smoke test `playwright-cli open https://example.com` and `playwright-cli snapshot`
  - manual: prefer Claude in Chrome instead for pages that need your logged-in session

## security-audit

- Type: skill (subdir of a skill repo)
- Path: `skills/security-audit`
- Depends: Node (validators `validate-findings.cjs`, `validate-coverage-ledger.cjs`); parallel sub-agents; an OS-enforced sandbox to execute target code, else leads end as `needs_validation`
- What: Cloudflare's multi-phase whole-repo security audit (recon, hunting across attack classes, fresh-agent validation, schema-checked `findings.json`, re-verification, reports); guidance-only unless a full audit is explicitly requested
- Signals: user asks for a security audit, pen-test or vulnerability sweep of a whole repo or subsystem; repos with auth, multi-tenant data, LLM/agent features, IaC or a release pipeline
- Global state: not installed globally, not vendored into this repo
- Source: https://github.com/cloudflare/security-audit-skill (blog: https://blog.cloudflare.com/build-your-own-vulnerability-harness); not in `cloudflare/skills`
- Pin: `c1c8a8c1471069fb0e188eeaff69b8e8db6564a8`
- Vetted: 2026-11-27, skill-scout. SkillSpector `--no-llm` 86, 13 hits, all false positives (defensive audit prose such as memory-poisoning hunting prompts, `/etc/passwd` strings in test fixtures). Validators grepped: no child_process or network use
- Enable: shallow-fetch Pin and copy `skills/security-audit` into `<project>/.claude/skills/security-audit` (fast path: copy from the vetted clone `~/.cache/skill-scout/2026-11-27/security-audit-skill` if its HEAD equals Pin and its tree is clean)
- Cost: 0 always-on until enabled; invocation SKILL.md ≈5.5k tok, reference files ≈150 KB loaded per phase; full audit is very token-heavy and Cloudflare recommends repeated runs
- Refresh: re-run skill-scout on upstream, diff against Pin, bump Pin
- Setup:
  - claude-md: Full security audit: use the security-audit skill only on explicit request, with opus for hunter and verifier sub-agents.
  - manual: reports land in `~/security-audit-skill/<repo>/run-N` by default; complements `security-guidance` hooks and `/security-review`, does not replace them

## create-formal-verification-skill

- Type: skill (subdir of a plugin repo)
- Path: `pstack/skills/create-formal-verification-skill`
- Depends: tool chosen per target; TLA+ default needs Java and TLC (the optional `statechart` skill installs them via mise on first run, needs network, Node 22.18+); Kani for Rust
- What: pstack skill that picks the highest-stakes promise in a repo, formally verifies it (TLA+, Kani/prover, or generated-input tests, saying which) and leaves a one-command project verify skill recording covered files and last-checked commit; manual only (`disable-model-invocation`), beta; optional companions `maintain-formal-verification-skill` (upkeep) and `statechart` (readable counterexamples)
- Signals: repo with concurrency, retries, payments, sync, state machines, parsers or unsafe code where tests miss the breaking case; user asks for proofs, model checking or formal verification
- Global state: not installed globally, not vendored into this repo
- Source: https://github.com/cursor/plugins (video: https://www.youtube.com/watch?v=bQCBfcZZj0Y)
- Pin: `b7b93c36be9bcc36a74db438e0fd385d660bc559`
- Vetted: 2026-11-27, skill-scout. SkillSpector `--no-llm` 0 issues, SAFE (skill dir only; companions not scanned); SKILL.md read: no network, exec, credentials or anti-refusal text
- Enable: shallow-fetch Pin and copy `pstack/skills/create-formal-verification-skill` into `<project>/.claude/skills/create-formal-verification-skill` (fast path: copy from the vetted clone `~/.cache/skill-scout/2026-11-27/plugins` if its HEAD equals Pin and its tree is clean); copy `maintain-formal-verification-skill` and `statechart` the same way only if wanted (scan them first)
- Cost: 0 always-on until enabled; SKILL.md ≈5.6 KB; running it is token-heavy and does one rule at a time
- Refresh: re-run skill-scout on upstream, diff against Pin, bump Pin
- Setup:
  - manual: run `/create-formal-verification-skill` aimed at the one promise where a bug costs most; keep existing tests
  - manual: after it generates a verify skill, add a project CLAUDE.md line: run that verify skill on changes to its covered paths
