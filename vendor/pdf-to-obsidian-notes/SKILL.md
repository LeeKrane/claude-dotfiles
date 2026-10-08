---
name: pdf-to-obsidian-notes
description: Use when the user wants Obsidian study notes from a PDF (lecture slides, course script, paper), optionally combined with their own Markdown notes taken during the lecture, and gives a PDF path or file name, or runs /pdf-to-obsidian-notes.
argument-hint: "<PDF path or name> [lecture-notes .md path or name]"
---

<!-- Self-authored 2026-10-08 for REPO-SKILLS.md. Composes two repo-scoped skills that must be
     installed alongside: convert-documents-to-markdown (anydoc) and obsidian-notes-creator. -->

# PDF to Obsidian notes

Pipeline: PDF → `anydoc` Markdown → cleaned Markdown → Obsidian study notes.

**Core rule: read the PDF zero times.** `anydoc` exists so the raw PDF never enters context. After step 2, every step (yours and every subagent's) works from the Markdown only. Never pass the PDF to the Read tool, not to "check structure", not for one page.

Inputs:
1. Required: a PDF path or a bare file name.
2. Optional: a path or bare file name of a handwritten Markdown file with the user's notes taken during the lecture (`<lecture>`). It is source material for the study notes, read as-is and never cleaned or edited.

Nothing else is asked for.

Result layout (`<dir>` = the PDF's directory, `<orig>` = `<dir>/_original_`):
1. `<orig>/<stem>.pdf`: the original PDF, moved there.
2. `<orig>/<stem>.md`: the full cleaned Markdown conversion of the PDF.
3. `<orig>/<lecture name>`: the lecture notes file, if given, moved there unchanged. If its name is `<stem>.md`, it becomes `<orig>/<stem>.lecture-notes.md`.
4. Obsidian study notes from obsidian-notes-creator, directly in `<dir>` where the PDF was, in the source document's language: the single note or hub note is `<dir>/<stem>.md`; a multi-file set writes its other notes flat into `<dir>` too, no subfolders.

## 0. Preflight

Stop with the listed message if any check fails:

- `<root>/.claude/skills/convert-documents-to-markdown/SKILL.md` and `<root>/.claude/skills/obsidian-notes-creator/SKILL.md` exist (`<root>` = git toplevel, else cwd). Missing: "Run `/repo-skills pdf-to-obsidian-notes` to install its two required skills."
- `anydoc --version` succeeds. Missing: "Rebuild the dotfiles so `anydoc` is on PATH."

## 1. Resolve the PDF

- Argument is an existing path: use it.
- Otherwise search `<root>` (`find <root> -iname '*<arg>*.pdf' -not -path '*/.git/*' -not -path '*/_original_/*'`, add `.pdf` if absent). One hit: use it. Several: ask which. None: stop.
- A PDF that is already inside an `_original_` folder: stop, it was processed before.
- Second argument given: resolve it the same way (existing path, else `find <root> -iname '*<arg>*.md' -not -path '*/.git/*' -not -path '*/_original_/*' -not -path '*/.claude/*'`, add `.md` if absent). One hit: use it. Several: ask which. None: stop.

`<stem>` = file name without `.pdf`; `<dir>` = the PDF's directory; `<orig>` = `<dir>/_original_`.

If `<orig>/<stem>.pdf`, `<orig>/<stem>.md`, `<dir>/<stem>.md` or the lecture notes' target in `<orig>` already exists, ask before overwriting. In step 4, ask the same before writing any note file name that already exists in `<dir>`. The lecture notes file itself may be `<dir>/<stem>.md`: it moves to `<orig>` in step 2, before anything is written there.

## 2. Convert

Follow convert-documents-to-markdown:

```bash
mkdir -p "<orig>"
anydoc "<pdf>" -o "<orig>/<stem>.md"
mv "<pdf>" "<orig>/<stem>.pdf"                       # only after anydoc exits 0
mv "<lecture>" "<orig>/<lecture target>"             # if given; same condition
cp "<orig>/<stem>.md" "<scratchpad>/<stem>.raw.md"   # untouched backup for the word-count check
```

Exit 3 (scanned pages need OCR): stop and ask before `--ocr hosted`, naming the file that would be uploaded. Exit 1 or 2: report the `anydoc:` line and stop. On any stop, leave the PDF and the lecture notes where they were and remove `<orig>` if it is empty.

## 3. Clean (subagent, model sonnet)

Dispatch one `general-purpose` subagent with `model: sonnet` and this brief, filled in. Wait for its report before step 4.

> Rewrite `<orig>/<stem>.md` in place. Raw backup: `<scratchpad>/<stem>.raw.md`. Work from these two Markdown files only. Never read `<orig>/<stem>.pdf` or any PDF; where structure is ambiguous, decide from the text, else keep the text unchanged and list its line numbers.
> Helper scripts are allowed in `<scratchpad>` only.
> Preserve every piece of content verbatim in its original language: no translation, summary, rewording or added facts. Only restructure and remove noise.
> 1. Collapsed slides/pages packed into table rows or cells: unpack into normal sections. Keep a table only where the content is tabular.
> 2. Repeated page furniture (footers, headers, page/slide numbers, author emails, copyright lines, breadcrumbs), including fragments glued into words: remove; keep one author/source line under the title.
> 3. Glyph bullets (`u `, `•`, `▪`, `§`, Wingdings leftovers), several inline per line: one `- ` item per line, nested where the text implies it.
> 4. Headings: one `#` title; `##` per chapter (use breadcrumbs or section slides, then drop them); `###` per slide/page title. Keep source order; never merge sections that are not adjacent. A chapter name that recurs later gets the first slide title of that part as suffix. A slide with no recoverable title gets `### <first words of its text>…` and goes on the low-confidence list.
> 5. Line-wrap hyphenation ("Soft- ware", "Software- Entwicklung") joined; real compound hyphens kept.
> 6. Speaker notes or long prose under a slide: keep, as a `> **Notes:**` blockquote (label in the document's language), consistently.
> 7. Diagram text: a list of its labels under one line `Diagram labels:` (in the document's language); never invent their relations. Structural labels like this and the notes label are the only text you add.
> Done means: each removed footer pattern has 0 hits outside the byline; no glyph bullets remain; `wc -w` within about 10% of the backup.
> Report: changes; the exact grep commands for each footer pattern and the glyph bullets, with their counts; word counts before/after; line numbers (in the cleaned file) of content you could not reconstruct with confidence.

Re-run the grep commands and `wc -w` from the report yourself before going on.

## 4. Notes

Invoke obsidian-notes-creator with `<orig>/<stem>.md` as the source material, plus the lecture notes in `<orig>` if given; its Step 2 decides single or multi-file.

With lecture notes, read both files in its Step 1 and combine them this way:
- The slide conversion gives the structure and the complete content; every slide topic stays covered.
- Lecture notes add what the slides lack: the lecturer's explanations, examples, emphasis and exam hints. Merge each into the matching concept, not into a separate section. Lecture-only content that matches no slide goes into its own section at the end of the matching note.
- Mark content that comes only from the lecture notes with a `> [!note] From the lecture` callout (title in the document's language), so the reader can tell it from slide content.
- `!`, `exam`/`Prüfung`, `important`/`wichtig` and similar markers in the lecture notes become `> [!important]` callouts.
- Lecture notes contradict a slide: keep both, in a `> [!warning]` callout naming the conflict. Never pick one silently.
- Shorthand, abbreviations and fragments in the lecture notes: expand only where the slide text makes the meaning certain; otherwise quote them as written. Write the notes directly into `<dir>`, unless the user named a vault folder:
- Single note: `<dir>/<stem>.md`.
- Multi-file: hub note `<dir>/<stem>.md` (not `README.md`); every other note is a file directly in `<dir>`. Flatten the creator's folder layout: no subfolders; keep its ordering prefixes in the file names (e.g. `01 Was ist RE.md`). `<dir>` already is the lecture's own folder.

Write in the source document's language. Never write into `<orig>`. Its Step 1 reads the cleaned Markdown, never the PDF.

## 5. Report

Original PDF, cleaned Markdown and lecture notes paths (all in `<orig>`), note files created, lecture-note items that matched no slide, conflicts found, word counts, the cleanup's low-confidence line list (the user checks those against the slides), and the backup path.

## Common mistakes

| Mistake | Fix |
|---|---|
| Reading the PDF to "verify" a garbled slide | Keep the text, list the line; the user checks it |
| Brief tells the subagent to cross-check the PDF | Brief names only the two `.md` paths |
| Moving the PDF before `anydoc` succeeds | Convert first; `mv` only on exit 0 |
| Notes written into `_original_` | Notes go to `<dir>`; `_original_` holds only the PDF and its conversion |
| Cleaning or editing the lecture notes file | It is read as-is and only moved |
| Lecture notes dumped into one separate section | Merge each item into its matching concept |
| Summarizing during cleanup | Cleanup restructures; summarizing belongs to step 4 |
| Running `--ocr hosted` on exit 3 without asking | Ask first, name the file |
