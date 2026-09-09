# Skills

Which skill for which situation. `/x` = you run it. Plain name = Claude picks it. Sources and install notes in `README.md`.

## Which skill when

| Situation | Run | Then |
|---|---|---|
| Plan anything new | `/superpowers:brainstorming` (spike, bounded, or architectural) | Architectural: `superpowers:writing-plans` → `superpowers:subagent-driven-development` (or `executing-plans` in a separate session) → `finishing-a-development-branch`. Bounded: implement. |
| New repo setup | `/setup-matt-pocock-skills` (issue tracker, `docs/agents/`) | `domain-modeling` as terms settle (`CONTEXT.md`, `docs/adr/`) |
| Work too big for one session | `/wayfinder` (needs setup above) | one ticket per session via `grilling`, `research`, `prototype` |
| Decision with stakes | `/council-review` (`--quick` for close calls) | |
| Stress-test own plan | `grilling` | |
| One design question | `prototype` | throwaway branch, merge the winner |
| Bug or test failure | `superpowers:systematic-debugging` | regression test via TDD |
| Implement anything | `superpowers:test-driven-development` | |
| Before claiming done or committing | `superpowers:verification-before-completion` | |
| Review diff | `/code-review` | `cavecrew-reviewer` for cheap pass |
| Receive review feedback | `superpowers:receiving-code-review` | |
| Prove change safe beyond diff | `/blast-radius` | unslop chained |
| Refactor, keep behavior | `caveman:safe-refactor` | |
| Schema, API, or dependency migration | `caveman:migration` | |
| Dead code cleanup | `/cleanup-session-codebase`, `/cleanup-whole-codebase` | |
| Docs, RFC, README, PR text | `/technical-writing` | unslop chained |
| Strip AI tells (explicit only) | `/unslop` | |
| Research a topic | `research` | cited `.md` in repo |
| Vet a skill or plugin before install | `/skill-scout` | `/dotfiles-release` |
| Author or edit a skill | `/skill-creator` | |
| Locate code | `codegraph explore` if `.codegraph/` exists, then `smart-explore`, then `cavecrew-investigator` or `caveman-explore` for broad sweeps | |
| Learn unfamiliar repo | `learn-codebase` (small repos only) | |
| Past sessions | `/mem-search` | `knowledge-agent` for a queryable knowledge base |
| Big issue backlog | `/oh-my-issues` | `/make-plan` → `/do` |
| Architecture duplication audit | `/pathfinder` (`PATHFINDER-<date>/`) | `/make-plan` → `/do` |
| Reconcile worktrees, branches, or PRs | `/standup` (`~/.claude-mem/STANDUP.md`) | `/do` |
| Watch PR to merge | `/babysit` | |
| UI build, audit, or polish | `/impeccable` | |
| Hand-editable mockup | `design` | |
| Audit finished design | `/design-is` (`DESIGN-IS-<date>/`) | `/make-plan` |
| Chart or graph | `dataviz` | |
| Setup token audit | `/context-audit` | |
| Commit message | `/caveman-commit` | |
| End session | `/handoff` | |
| Dotfiles | `/dotfiles-release` after edits. `/dotfiles-apply` after pull | |
| Project history | `/timeline-report` (one report), `/weekly-digests` (per week) | |
| Plain-English explanation | `/what-the` | |
| 2+ independent tasks | `superpowers:dispatching-parallel-agents` | |
| Isolate feature work | `superpowers:using-git-worktrees` or `EnterWorktree` | |

## Pick one

- superpowers process skills are default. Caveman's `investigate-first`, `surgical-patch`, `lean-build`, `verify-and-stop` apply only when the matching superpowers process skill is too heavy. Never use both on one task.
- `caveman:migration` and `caveman:safe-refactor` have no superpowers analogue. Use them freely.
- `writing-plans` + `subagent-driven-development` default. `/make-plan` + `/do` only when arriving from `/design-is`, `/pathfinder`, `/oh-my-issues`.
- `/skill-creator` default. `superpowers:writing-skills` only inside a superpowers-driven repo.
- `/impeccable` = UI lifecycle with QA gate. `frontend-design` = passive guidance, fires on its own. `design` = mockup artifact, not code. `/design-is` = critique → plan.
- `/code-review` default. `cavecrew-reviewer` cheap pass. `/caveman-review` terse PR comments. `/council-review` never for diffs.
- `verify-and-stop` mid-task, validation-only asks. `verification-before-completion` at commit.
- `grilling` interviews you. `/council-review` has agents debate. `/superpowers:brainstorming` is the design gate.
- `/mem-search` on demand. Context injection is automatic.
- `codegraph` before grep when `.codegraph/` exists (CLAUDE.md rule).

## Runs automatically

- caveman mode on SessionStart. `/caveman off|lite|full|ultra`.
- claude-mem: observation capture on every tool use, context injection from 2nd session.
- security-guidance: pattern warnings on edit, LLM diff review on stop, agentic review on commit or push. `SECURITY_GUIDANCE_DISABLE=1` to disable.
- superpowers `using-superpowers` injected on start, clear, or compact.
- impeccable antipattern detector after UI edits.
- watermarks-remover auto-clean on Write or Edit.
- `unslop` NOT automatic (CLAUDE.md gate).

## Skip these

- `caveman-setup`, `caveman-discover`, `caveman-evidence-review`, `caveman-manage`, `caveman-optimize` — Caveman Cloud account.
- `caveman-learn` — local, run `caveman learn` first.
- `cloud-sync` — cmem.ai Pro.
- `wowerpoint` — NotebookLM login.
- `remove-ai-marks` — local service on `:8765`. `clean-user-facing-text` works offline.
- `version-bump` — plugin author only.
- `taste-skill` — disabled globally.
- `mode-creator` — only to change claude-mem taxonomy.
- `caveman-init` — other IDEs.

## Catalog

### Self-authored

- **/cleanup-session-codebase** — after a session. Removes dead code, debug logs, orphans in the diff.
- **/cleanup-whole-codebase** — same, whole repo, in reviewable batches.
- **/dotfiles-apply** — after `git pull` here. Applies pending `CHANGELOG.md` versions.
- **/dotfiles-release** — after editing here. Bumps version, changelog, README and SETUP sync, commits.
- **/skill-scout** — before installing a skill or plugin. Usage fit, overlap matrix, security gate. Asks before install.

### Standalone third-party

- **/blast-radius** (pstack) — change looks risky. Proves the one safety fact, ranks risks with `file:line`.
- **/context-audit** — setup feels slow. Health score, top fixes. Needs `/context` output pasted.
- **/council-review** (ngmeyer) — real tradeoff. 5 advisors, peer review, devil's advocate, verdict.
- **domain-modeling** (mattpocock) — vocabulary drifts. Edits `CONTEXT.md`, writes `docs/adr/` sparingly.
- **grilling** (mattpocock) — settle a design tree. Numbered question rounds until no question remains.
- **/handoff** (mattpocock) — session ending. Handoff doc in temp dir, suggested skills for next session.
- **prototype** (mattpocock) — one design question. HTML state-machine demo or `?variant=` UI branches.
- **research** (mattpocock) — need facts. Background agent, cited `.md` in repo.
- **/setup-matt-pocock-skills** (mattpocock) — once per repo. `docs/agents/issue-tracker.md`, `domain.md`, CLAUDE.md block.
- **/technical-writing** (pstack) — docs, RFCs, PR text. Diátaxis + Google style + STE. Chains unslop.
- **/unslop** (pstack) — explicit only. Strips 31 AI-tell patterns.
- **/wayfinder** (mattpocock) — multi-session effort. `wayfinder:map` issue + child tickets.

### superpowers

- **/superpowers:brainstorming** — before any creative work. Spike: answer. Bounded: chat design. Architectural: `docs/superpowers/specs/`.
- **writing-plans** — after approved spec. `docs/superpowers/plans/`, small TDD tasks.
- **subagent-driven-development** — execute plan in-session. `progress.md` log in `.superpowers/sdd/`, per-task review, fix loop ≤5.
- **executing-plans** — execute plan in separate session with checkpoints.
- **finishing-a-development-branch** — tests green. Merge, open a PR, keep, or discard.
- **systematic-debugging** — any bug. Root cause before fix. 3 failed fixes, then stop.
- **test-driven-development** — any code. Red, green, refactor. No test, no code.
- **verification-before-completion** — before "done". Run the verification, read the output, then claim.
- **requesting-code-review** — after task or feature. Dispatches reviewer subagent.
- **receiving-code-review** — feedback arrives. Verify before agreeing.
- **dispatching-parallel-agents** — independent tasks. One Agent call each, same response.
- **using-git-worktrees** — before plan execution. Native tool, else `.worktrees/`.
- **writing-skills** — authoring skills the superpowers way. TDD for docs.

### caveman

- **/caveman** — set terse level. `/caveman-help` reference, `/caveman-stats` real numbers.
- **/caveman-commit** — commit message. Conventional Commits, subject ≤50.
- **/caveman-compress FILE** — shrink prose memory file. Backup out of tree.
- **/caveman-review** — terse PR comments, one line per finding.
- **cavecrew** — when to spawn `cavecrew-investigator` (locate), `cavecrew-builder` (1–2 file edit), `cavecrew-reviewer` (diff).
- **caveman-explore** — broad localization, reads stay out of main context.
- **investigate-first** — ambiguous failure, terse variant of systematic-debugging.
- **surgical-patch** — narrow bug fix with regression proof.
- **lean-build** — new feature, strict scope, explicit stop.
- **safe-refactor** — restructure, same proof before and after.
- **migration** — expand, then migrate, then verify, then contract. Rollback path.
- **verify-and-stop** — prove acceptance, no edits.

### claude-mem

- **/mem-search** — "did we solve this before". Search, then timeline, then observations.
- **knowledge-agent** — a queryable knowledge base over an observation slice.
- **smart-explore** — tree-sitter outline or search of a file or symbol.
- **learn-codebase** — read every file once to seed memory. Expensive.
- **/make-plan** — phased plan with doc-discovery phase.
- **/do** — execute phased plan via subagents, verify before each commit.
- **/design-is** — Rams audit. `DESIGN-IS-<date>/`, verdict, `/make-plan` prompt.
- **/pathfinder** — feature flowcharts, duplication report, unified proposal.
- **/oh-my-issues** — cluster 20+ issues into plan-masters, `plans/0X-*.md`.
- **/standup** — read-only reconcile of worktrees, branches, or PRs.
- **/babysit** — poll PR CI + reviews until merge-ready.
- **/timeline-report** — `journey-into-<project>.md`.
- **/weekly-digests** — `docs/timeline-weeks/` chapters.
- **/what-the** — plain-English breakdown.
- **/how-it-works** — how claude-mem captures and injects.

### Other plugins

- **/impeccable** — frontend UI: shape, critique, audit, polish, live. 4 subagents, `DESIGN.md`.
- **frontend-design** — aesthetic guidance while writing UI. Fires on its own.
- **/skill-creator** — create, eval, benchmark, optimize a skill.
- **clean-user-facing-text** — polish prose, strip invisible Unicode. Offline.
- **security-guidance** — hooks only, nothing to invoke.

### Built-in

- **/code-review** — correctness review of diff, PR, branch. `--fix`, `--comment`, `ultra`.
- **/simplify** — reuse and simplification cleanups, applied.
- **/security-review** — security review of branch changes.
- **design** — Claude Design canvas artifact.
- **dataviz** — before any chart.
- **/loop**, **/schedule** — recurring runs, cloud routines.
- **/init**, **/run** — CLAUDE.md bootstrap, launch app.
- **update-config**, **keybindings-help**, **fewer-permission-prompts** — settings, keys, allowlist.
- **claude-api** — Anthropic API reference. Read before any Claude API work.