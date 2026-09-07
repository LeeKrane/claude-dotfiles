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
verdict is **project-scope** (its step 8) — vetted, wanted, never global.

Fields per entry, one per line: Type (skill | plugin | mcp), Path (subdir of
the source holding the installable skill; `.` = repo root), Depends, What,
Signals, Global state, Source, Pin, Vetted, Enable (for `plugin` type: a literal `enabledPlugins` or `skillOverrides` JSON fragment; otherwise prose naming the exact install action), Cost, Refresh.

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
