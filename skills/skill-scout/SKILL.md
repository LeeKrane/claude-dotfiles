---
name: skill-scout
description: "Research, evaluate, and vet Claude Code skills/plugins against the user's actual usage before installing anything. Use when the user says 'scout skills', 'evaluate this skill/plugin', 'audit my skills', 'compare skills against my usage', 'should I install <skill or plugin>', or asks whether a specific skill/plugin repo is worth adopting, or wants to search for skills on findskills.org / skills.sh / GitHub and vet the ones worth installing, or asks how to set up or integrate a skill it vetted. Do NOT trigger on general conversation about skills, on authoring new skills, or on plain installation requests where the user has already decided."
argument-hint: "[skill/plugin/repo URL(s), or a work area or search terms] [--no-discovery] [--no-council]"
---

# Skill Scout

Evaluate candidate skills/plugins the way a careful engineer evaluates a dependency: against real usage data, against what is already installed, and through a security gate — then report and let the user decide. The failure modes this skill exists to prevent: installing duplicates of things already owned, adopting tools that don't match how the user actually works, re-evaluating the same candidates repeatedly, installing unvetted third-party instructions, and trusting a single-pass overlap/fit call that nobody argued against.

The default run is **analyze, then ask**. Never install, modify settings, or write to the dotfiles repo before the user has seen the report and approved specific candidates.

## Pipeline

The pipeline runs in two stages. Stage 1 — Find is cheap: it searches findskills.org, skills.sh, and other sources for candidates and ends with the user picking which ones are worth a closer look. Stage 2 — Vet is the existing evaluate-and-install pipeline, and it runs only on those picks: a council debate and a security scan cost real agent calls per candidate, and that cost is worth spending once the user has already seen enough about a candidate to want it looked at closely — not on every hit a search happens to turn up.

**Stage 1 — Find** (cheap: no council, no security scan, no clones)

### 1. Scope

Modes decided by the input:
- **Targeted**: the input is a URL, `owner/repo`, `owner/repo@skill`, or a name matching an installed or marketplace skill — a product or topic word ("remotion", "seo") is Discovery, not Targeted. Named items are always listed first in Pick and enter Stage 2 unless the user unchecks them there; Search only adds alternatives from the same niche. `--no-discovery` skips Search and Pick entirely and vets exactly the named items (old behavior).
- **Discovery**: the user names a work area, gives search terms, or asks what would help. Search runs on those terms.
- **Integrate**: the user asks how to set up or integrate a skill that already has a vet record — a `~/.claude/REPO-SKILLS.md` entry, or a changelog entry from a scout run. Skip steps 2-9, reuse that record's Pin, verdict and security notes, run the step-6 intent check on its capabilities, then go straight to step 10's integration research. No vet record → it is Targeted.
- **Bare invocation** (no args): Search runs on terms derived from the usage profile.

If the request is ambiguous between modes, ask one clarifying question before burning research time.

### 2. Usage profile (what the user actually does)

A skill is only worth its context cost if it maps to recurring, evidenced work. Build the profile from data, not assumption:
- `~/.claude/history.jsonl` — prompt counts by project and task type.
- claude-mem DB (`~/.claude-mem/claude-mem.db`, sqlite3; tables `observations`, `session_summaries`, `user_prompts`, all FTS-indexed) — session themes, recurring workflows, repeated pain points.

Cite concrete numbers (prompt counts, session counts, repeated-request counts). Delegate this mining to subagents so the main context stays small. If claude-mem holds a scout run from the last 7 days, reuse its profile and cite that session's date; otherwise re-mine.

### 3. Search

List what is already installed before searching, once: enabled plugins (`settings.json` enabledPlugins + plugin cache), `~/.claude/skills/`, built-in commands, hook events and their commands from `settings.json` `hooks`, and the variable *names* in `settings.json` `env` — never their values. Step 5 reuses this inventory rather than rebuilding it.

Query terms, at most 3 per round:
- **Targeted**: read each named repo's SKILL.md description and tags, derive 2-3 niche terms.
- **Work area / explicit terms**: use the user's terms as given; more than 3 → the first 3 now, the rest queued for Pick's "refine terms".
- **Bare**: pull 3-5 gap terms from the usage profile — recurring workflows with no installed counterpart — and confirm with one AskUserQuestion (multiSelect, terms as options, an Other option), narrowed to 3.

Each round queries at most 3 terms, once each on findskills and skills.sh — 6 queries a round across tiers 1-2; tier 3 fallback adds at most one WebSearch per under-populated term. Each refine round (step 4) gets its own 3-term budget; at most 3 Search rounds per run in total, the initial round included.

Sources, tier order:
1. **findskills API**: `curl -sS -m 30 -H "Authorization: Bearer $FINDSKILLS_API_KEY" 'https://findskills.org/api/v1/search?q=<term>&limit=10'` → JSON `{"skills":[{id,name,description,tags,category,safety_label}], next, prev}`; a key returns full fields (url/author/stars) too. Get a free key with `npx findskills auth` or findskills.org/developers (GitHub sign-in) — without one, expect exactly one guest query before `401 {"error":"registration_required","reason":"quota_exhausted_fp"}`, then treat findskills as unavailable for the rest of the run. It fuzzy-matches (`remote-*` back for "remotion"); drop hits whose name or description doesn't contain the term as a whole word before pre-rank. Resolve a guest hit's repo URL with one GitHub API search — `curl -sS "https://api.github.com/search/repositories?q=<name>+in:name&per_page=3"` — else mark it "url unresolved".
2. **skills.sh**: `npx -y skills@latest find <term> 2>&1 | sed 's/\x1b\[[0-9;]*m//g'` → lines of `owner/repo@skill  N installs  URL`. The install path later is `npx skills add owner/repo@skill`.
3. **Existing sources** (WebSearch/WebFetch, GitHub skill collections, plugin marketplaces) — only when tiers 1-2 together return fewer than 4 unique hits for a term.

Delegate a round to one subagent (haiku-class), all its terms in one batch call — `npx skills find` runs ~100s/term, so batching and backgrounding matter — returning only one deduplicated list: `owner/repo@skill | one-line what | installs or stars | source(s) | url`. If a source errors or quota-locks mid-round, it skips that source for the rest of the run and says so for Pick's question text ("findskills locked after 1 query; 2 terms searched on skills.sh only"); partial results are always presented as partial.

Dedupe and suppress before Pick: drop anything already in `~/.claude/skills/`, in `enabledPlugins`, named on a do-not-re-evaluate list in memory (`~/.claude/projects/*/memory/skill-audit-verdict-*.md`, `skill-scout-verdict-*.md`), or covered by a claude-mem scout run from the last 30 days — suppressed items never become options; state the count and names in Pick's first question ("hidden: 4 installed, 6 skipped 2026-09-07 (hyperframes@*)"). User-named items in Targeted mode are exempt from suppression: always listed, with any prior verdict in the option description ("already project-scope, vetted 2026-09-07").

Cheap pre-rank for ordering only, not the Stage 2 score: term match, then installs/stars, then findskills' safety_label. No overlap analysis, no council, no cloning here — that's Stage 2's job.

If every source fails, or total resolvable hits land under 2: Targeted skips straight to Stage 2 with the named items and notes Search came back empty; Discovery and Bare invocation report the failure and stop — no Pick call.

### 4. Pick

Before asking, grep `~/.claude/REPO-SKILLS.md` headings and Signals for the round's terms; matching entries are named in the first question's text as "already registered, `/repo-skills` installs it" — not offered as options unless user-named.

Present hits with one AskUserQuestion call: up to 4 questions, 2-4 options each, grouped by query term (header = the term). Only hits with a resolved repo URL become options; unresolved ones are counted in the question text ("3 findskills hits unresolved, name one via Other with its URL to include it") — every pick ending up with a resolvable URL is a consequence of that, not an assumption going in. Terms with fewer than 2 resolvable hits merge into one "Other hits" question; more than 3 term groups push the extra groups to the next "show next 12" page. Option label is `owner/repo@skill` (or the plugin name); option description is one-line what + installs/stars + source. In Targeted mode the named items are the first options of the first question, so unchecking one drops it from the run.

A fourth question, single-select, header "Next": vet selected / show next 12 / refine terms / stop.

Loop the pick: "show next 12" re-asks with the next slice, including any term groups deferred for space; "refine terms" first offers any queued overflow terms as options, then asks for new ones via Other — each round gets its own 3-term budget — and re-runs Search; at most 3 Search rounds per run in total, the initial round included, then stop and ask in plain text what to do instead. "vet selected" with zero candidates checked: re-ask once, then stop. "stop": end the run with nothing vetted, and print the full hit list once so the search wasn't wasted.

Why AskUserQuestion and not a printed list: the run is otherwise unattended, and this is the one point where the user's judgment is cheap and the vetting cost is not yet spent.

Output of this step: the picked candidates, each already carrying a resolvable repo URL. They enter Stage 2 exactly as Targeted candidates did before this split. Cloning into `~/.cache/skill-scout/<date>/` still happens in Stage 2 (the security gate), not here.

**Stage 2 — Vet** (existing pipeline, only on picked candidates)

### 5. Setup inventory + overlap matrix

Reuse the inventory step 3 builds. Then, for EVERY candidate, classify overlap as **FULL** (an installed tool already does this — name it), **PARTIAL** (name what's shared and what's not), or **NONE**. Overlap claims must name the specific counterpart; verify by reading descriptions, not by guessing from names — this session-type work has produced wrong FULL/PARTIAL calls from name-matching before.

**Replacement comparison.** Every FULL or PARTIAL candidate gets a head-to-head against its named counterpart — one row per measure, exactly three columns: measure | candidate | counterpart:

| Column | How to measure |
|---|---|
| Always-on cost | Skill: description chars ÷ 4, every session. Plugin: sum of every skill description it installs, wanted or not. Hook: zero description tokens; count injected output chars ÷ 4 × expected fires per session instead. MCP server: full tool-schema chars ÷ 4, every session. |
| On-invocation cost | SKILL.md body + every referenced file, chars ÷ 4 |
| Does that the other lacks | capability delta, each direction, from reading both bodies |
| Trigger quality | how precisely the description fires; known false-trigger history |
| Provenance | maintainer, last commit, install channel, update path |
| Security | Candidate: "pending step 8", filled in before the report. Counterpart: vet date from its provenance comment or changelog entry, else "installed, not re-vetted" |

End each comparison with one call: **keep**, **replace**, **alongside**, **skip**, or **project-scope** (vetted, wanted in one repo only — registered in REPO-SKILLS.md, never installed globally) — with the single decisive reason. "Replace" means the counterpart is removed on install; say what is lost.

### 6. Ranking + per-candidate briefing

Score each candidate: **fit** (1–5, matches the usage profile's evidence) × **benefit** (1–5, fills a real gap) − **overlap penalty** (NONE 0, PARTIAL 2, FULL 4) − **token penalty** (net always-on tokens after subtracting a replaced counterpart: under 50 → 0, under 150 → 1, under 400 → 2, more → 3). Token cost is a real term, not a tiebreaker: an always-on description that fires rarely is a bad trade even with NONE overlap. Rank ALL candidates, none omitted. Every candidate appears in the step-9 per-candidate block; the full briefing below is only for NONE candidates and for FULL/PARTIAL candidates whose step-5 call is not **skip**.
- What it is (from its actual SKILL.md, not the repo's marketing blurb)
- Benefit mapped to specific usage evidence
- Session impact: work-wise (how day-to-day sessions change) and token-wise as measured numbers — always-on cost, on-invocation cost, model-invoked vs user-invoked, hooks or MCP servers added. FULL/PARTIAL candidates cite the step-5 table verbatim; measure fresh only for NONE.
- Dependencies and portability (Claude Code native? Cursor-coupled? needs trackers/CLIs/API keys?)
- Form check: does the candidate's behavior need model judgment, or is it a deterministic rule that must fire every time? Mark it **skill**, **hook candidate** (name the event: PreToolUse / PostToolUse / UserPromptSubmit / Stop / SessionStart), or **hybrid** (hook enforces, skill explains).
- Capabilities: 2-6 concrete aspects read from the SKILL.md body and its referenced files — each one line: what it produces + what it needs (API key, CLI, paid service). "Voice cloning — clones a voice from a 30s sample; ElevenLabs key" is an aspect; "powerful audio workflows" is not. A single-purpose skill has one aspect.

**Intent check.** Usage mining sees past work; it cannot see what the user plans next, and a multi-purpose candidate is usually wanted for one slice of what it does. So before scoring is final and before the council, ask: one question per candidate that got a full briefing, up to 4 questions per AskUserQuestion call:
- multiSelect, header = a short alias of the candidate, 12 characters or fewer ("voicestudio", "obj-destroy"), question "Which parts of <full name> would you actually use?", options = its aspects (label = aspect, description = what it produces + what it needs). More than 4 aspects: merge the least evidenced ones into one option. Single-aspect candidates: options "Yes, regularly" / "Occasionally" / "No".
- Then, only for candidates with at least one aspect picked, a second call: single-select "Where would you use <name>?" — "All or most projects" / "Specific repo(s) — name them via Other" / "Not sure".

Answers change the evaluation, not just the report:
- Rescore fit and benefit on the picked aspects only. The token cost stays whole — an unused aspect still costs its share of the description and body.
- Zero aspects picked → call **skip**, unless the user named the candidate in the request; then report the mismatch and keep scoring. A skip drafts nothing: no registry entry, no integration plan, not even a hypothetical one.
- "Specific repo(s)" → the call leans **project-scope** and those repos become the entry's Signals; "All or most projects" → global calls stay open; "Not sure" → no lean.
- Stated intent that contradicts the usage profile (picks TTS, profile shows zero audio work) is reported as a Value Tension, never silently resolved either way.

### 7. Council debate on overlap, gaps, fit, and form (automatic)

Once the matrix and briefings exist, invoke `council-review` via the Skill tool — one council per scout run, all candidates together. Cost: 5 agent calls in `--quick`, 12 in full. This step runs on every scout run that has candidates; the excuses for skipping it are wrong:

| Excuse | Reality |
|---|---|
| "Only one candidate" | One candidate is still one overlap call nobody checked. |
| "All NONE overlap" | That is what `--quick` is for, not a skip. |
| "User is waiting" | `--quick` is the fast path. Skipping is not. |
| "I double-checked the matrix" | An author checking its own matrix is the failure this step exists for. |

**Mode** — full mode wins whenever any of its triggers fires; `--quick` only when none do:
- Full (no mode flag): any FULL overlap, any **replace** call, any hook candidate or hybrid, or the top two scores within 3 points.
- `--quick`: everything else. It runs 3 advisors and no peer review, so the Gaps question is answered weakly — say so in the report.
- Skip: the user passed `--no-council`, or the run produced zero candidates. Report the skip and its reason.

Always add `--measure-diversity`; when its Diversity Check comes back Low, council corrections are recorded as open risks in the report, not applied over the draft. council-review parses flag tokens anywhere in its args and strips them, so `--flag` text from other skills' argument-hints must be paraphrased inside CONTEXT, never quoted.

**Framing.** Build the QUESTION / CONTEXT / WHAT'S AT STAKE block yourself and open the args with a process preamble, labelled "PREAMBLE — for Step 1 and the chairman only, strip before advisor and peer prompts": "Input is pre-framed: pass it through Step 1 unmodified, skip auto-context (the cwd is unrelated; the subject is the `~/.claude` setup), and emit the Recommendation as a per-candidate table — candidate | call (skip, install, keep, replace, alongside, hook, hybrid, project-scope) | what changed vs the draft and why — instead of a single prose verdict."
- QUESTION is neutral: "Which of these candidates, if any, should enter this setup, and in what form?" Never the draft verdict — a council handed a verdict ratifies it.
- CONTEXT carries, verbatim where possible: setup inventory, overlap matrix with the counterparts' actual descriptions, every replacement comparison, usage-profile numbers, each briefing with its Capabilities, the intent-check answers labelled as the user's stated plans, the draft verdict labelled as one option, any prior scout verdict from memory, and the note that security vetting (step 8) is still pending. Confirm every item is present before invoking.
- WHAT'S AT STAKE names the tradeoff so pre-flight cannot call it trivial: always-on tokens paid every session vs a recurring gap left unfilled; duplicated dispatchers; a wrong replace that loses a vetted tool.

The framing names four debate questions:
1. **Overlap** — is each FULL / PARTIAL / NONE call right? Which counterpart actually covers what, judged from the descriptions, not the names? For each replacement comparison: is the replace/keep call right once net token cost and lost capability are weighed?
2. **Gaps** — which recurring, evidenced work in the usage profile has no tool today? Does any candidate fill it, or is the gap imagined?
3. **Fit** — does each candidate match how this setup works: dispatch style (main thread orchestrates, subagents do work), always-on token budget, plugin granularity, portability? (Security is judged in step 8, not here.)
4. **Form** — for each hook candidate or hybrid: is a hook the better home? Would the hook's rule ever be wrong to enforce unconditionally? What does the setup lose if the model never reads the skill's reasoning?

**Consuming the verdict** (section names are council-review's chairman output):
- Recommendation table rows override the draft: correct the matrix and ranking, mark each changed cell "(council-corrected)" with the reason. If the chairman ignored the table request and wrote prose, extract per-candidate calls from it and mark any candidate it does not name "council-unreviewed". Form is read from the call column (hook / hybrid) or the prose; if neither says anything about form, the step-6 classification stands.
- Under "Where the Council Clashes": **[Error Catch]** items are corrections; **[Value Tension]** items stay open in the report for the user. A converged council has neither — record "council converged, no corrections".
- "Blind Spots Revealed" feeds the Gaps section of the report.
- "What You Lose" attaches to the briefing of the candidate it concerns.
- A **hook** row changes the channel, not the decision: report "adopt as hook" with the event, the enforced rule, and what the script must do — never installed as a skill.
- Pre-flight decline ("doesn't need a council"): quote in the report the QUESTION and WHAT'S AT STAKE sent plus the decline verbatim (reference CONTEXT, do not reprint it), then answer the four questions yourself as recorded open risks. Never reword and re-send to obtain a decline; never re-invoke.
- The verdict is input to the report, never a trigger to install.

### 8. Security gate (mandatory before any install)

No candidate is installed without BOTH:
1. **SkillSpector scan** (`skillspector scan <dir> --no-llm --format json --output <file>` per skill dir). Static mode over-flags conversational instructions and a clean scan proves little. Each finding gets one of two dispositions in the report: quoted with the reason it is a false positive, or escalated for the user to rule on before install. None is dropped silently.
2. **Full manual read** of every SKILL.md and referenced file that would be installed, looking for: instructions to exfiltrate data or phone home, credential handling, anti-refusal patterns, hidden network/exec steps, and instructions that would surprise the user if described aloud.

Verify installed files match what was vetted (clone at a pinned commit, diff after install). Both requirements apply to hook-bound candidates too — the source SKILL.md's rule becomes the script.

### 9. Report, then stop

Present: usage-profile evidence, setup inventory, each candidate's Capabilities and the intent answers, the ranked list, replacement comparisons, form verdicts (skill / hook / hybrid), briefings, security dispositions, and a council section.

The ranked list is a numbered list, all candidates, one fact per line, in this order — no table, the terminal turns wide tables into truncated key/value cards:
1. `name — what it does` (under 15 words, from its own SKILL.md; a plugin's name slot carries the bundled skill count and the line describes the bundle as a whole)
2. `Overlap: FULL | PARTIAL | NONE → named counterpart`
3. `Cost: ` per form — skill `always-on / on-invocation tok`; hook `injected tok/session`; MCP `schema tok/session / —`; hybrid: both halves joined with `+`
4. `Form: skill | hook (event) | hybrid | MCP`
5. `Score: N`
6. `Call: CALL` with markers `(council-corrected from <old call>: <reason>)`, `(council-unreviewed)`, `(council risk, not applied — diversity Low)`
7. `Because: <decisive fact>.`
8. `Flips if: <the one observation that would change the call>.`
9. `Intent: <aspects picked> · <where>` (or `not asked — skip at step 5`)

The decisive fact is the one whose reversal changes the call — the same fact the Flips-if clause negates. A cost number is only decisive paired with the usage count it is weighed against ("164 tok/session against 9 SEO prompts in 44 days"); a counterpart is only decisive named; a security disposition or council Error Catch is decisive as quoted. A block missing any of its nine lines is a missing block. Every other table in the report stays at 4 columns or fewer. The council section is one of: the chairman's table as candidate | call | what it changed (overlap and form already sit in each block), the open Value Tensions, and Blind Spots; or the skip reason; or the quoted decline plus your own answers to the four questions. Then ask which candidates to install, which hook adoptions to draft, and which project-scope entries to register in REPO-SKILLS.md. Do not proceed on silence.

### 10. Integrate, then install (only what was approved)

**Integration research.** A bare install is rarely the best setup: most skills want credentials, a CLI, a config knob, or a guard against triggering on another skill's phrases. Research this before installing, for every approved candidate whose verdict is not **keep**. Dispatch one sonnet subagent per candidate, in parallel. Give each one the vetted clone path, the candidate's picked aspects and scope answer, and the step-3 inventory: enabled plugins, `~/.claude/skills/`, hook events and commands, env variable names (never values), and the rules in `~/.claude/CLAUDE.md`. Each subagent reads the README, the SKILL.md, config or example files, scripts, and linked upstream docs. It returns this plan, one section per heading, "none" where a section is empty:
- **Placement**: global or project-scope, and for project-scope the repos named in the intent check.
- **Dependencies**: CLIs, packages, services. Give each one its exact install command for the user to run with `! <cmd>`, the version it was vetted against, and whether it is needed only for an unpicked aspect.
- **Credentials and env**: variable names, where each one belongs (`settings.json` `env`, shell profile, or project `.env`), and how to get the value. Record names only, never values.
- **Config**: literal fragments to apply. Examples: `settings.json` keys, `skillOverrides` that disable bundled sub-skills serving no picked aspect, the plugin's own config file.
- **Trigger interplay**: installed skills whose descriptions fire on the same phrases, and which of the two should win.
- **Stack fit**: how the candidate interacts with this setup. RTK rewrites Bash, so tools that parse raw Bash output can break. Caveman output style can affect generated text. Main-thread orchestration means subagent model routing matters. Tools that call the Anthropic API go through the teamclaude proxy via `ANTHROPIC_BASE_URL`. Existing hooks may overlap.
- **CLAUDE.md line**: at most one rule, only when behavior the user wants would otherwise not happen.
- **Smoke test**: one prompt or command that proves the picked aspects work after install.

Present the plans, then ask which items to apply: one multiSelect question per candidate, options = the plan's non-empty sections among Config, CLAUDE.md line and Trigger-interplay fixes (at most 4; Dependencies, Credentials and Smoke test are always user-run follow-ups, not options). AskUserQuestion takes at most 4 questions per call, so more than 4 candidates means more calls. Unpicked items stay in the report as notes.

Channel preference, in order — use the first that actually works for the candidate:
1. **Official Claude Code plugin marketplace** (`claude plugin marketplace add` + `claude plugin install`) — but check granularity first: plugins install whole; if that drags in unwanted skills (a second dispatcher, duplicates), prefer the next channel.
2. **`npx skills` CLI selective install** (`npx -y skills@latest add <repo> --skill <name> --agent claude-code --global --yes`) — per-skill, managed, updatable via `npx skills update`.
3. **Vendoring a copy** — last resort only, when the source needs local adaptation to work at all. Add a provenance comment after the frontmatter (source repo @ commit, vet date, exact local edits) and record it in the changelog.

Web summaries of install methods can be wrong — verify a marketplace manifest actually exists before promising that channel.

Per approved verdict:
For **install**, **alongside**, **replace** and **hybrid** verdicts, apply approved Config items together with the install, through the `update-config` skill for `settings.json`. **project-scope** writes them only into the registry entry's Setup field, and **hook** applies only its own hook entry. Dependencies are user-run and never run by this skill. Credentials are always follow-ups for the user: never write an env key without its value into `settings.json`, because an empty `env` entry overrides the value the user already exports in their shell. Run the smoke test after the new session starts, or give it to the user as a follow-up.

- **keep**: nothing is installed; record the comparison in the changelog.
- **alongside**: install the candidate, leave the counterpart, state in the report which trigger phrases now fire both.
- **replace**: uninstall or disable the counterpart in the same change; record both halves in the changelog.
- **hook**: do not install the skill. Draft the hook script and settings.json entry via the `update-config` skill, show both to the user before enabling, and keep the source SKILL.md only as a provenance reference in the changelog.
- **hybrid**: install the skill through the channel order above AND draft the hook per the hook bullet; the changelog records both halves, and the report states which half enforces the rule and which half only explains it.
- **project-scope**: never install anywhere in this run. Append one entry to `~/.claude/REPO-SKILLS.md` (Type, Path, Depends, What, Signals, Global state "not installed globally, not vendored", Source, Pin at the exact commit vetted in step 8, Vetted date/verdict/security notes, Enable, Cost, Refresh, Setup) from this run's step 5/6/8 data and the integration plan, record it in the changelog, and state in the report that `/repo-skills` installs it per project on request. Setup holds the approved integration items as sub-bullets, each tagged `config:` (a literal JSON fragment that `/repo-skills` merges into `<project>/.claude/settings.local.json`) or `manual:` (dependencies, credentials, CLAUDE.md line, smoke test, all shown to the user as follow-ups). Signals include the repos named in the intent check.

### 11. Afterwards

If any tracked file in `~/.claude` changed (install, removal, REPO-SKILLS.md entry), suggest running `/dotfiles-release` so the change is versioned — but never run it unasked.
