---
name: convert-documents-to-markdown
description: Convert Word (.doc, .docx), PowerPoint (.ppt, .pptx), Excel (.xls, .xlsx), OpenDocument (.odt, .ods, .odp), RTF, and EPUB files to GitHub-Flavored Markdown. Use when a task needs the contents of an office document, spreadsheet, presentation, or ebook, or of a scanned PDF the Read tool returns no text for.
license: MIT
metadata:
  author: firecrawl
---

<!-- Vendored from https://github.com/firecrawl/anydoc @ 261fc257d17c3eab0f673be31c408fd9fdc2171a
     (skills/convert-documents-to-markdown/SKILL.md), vetted 2026-10-08 by skill-scout.
     Local edits: description drops PDF and CSV (native Read handles them) except scanned
     PDFs; commands call the Nix-pinned `anydoc` (dotfiles pkgs/anydoc) instead of unpinned
     `npx -y @firecrawl/anydoc`; rule 1 notes native Read for PDF/CSV; rule 5 requires
     asking the user before `--ocr hosted`. -->

# Convert documents to Markdown

Run the anydoc CLI (installed via the dotfiles, `pkgs/anydoc`):

```bash
anydoc <file>              # Markdown to stdout
anydoc <file> -o out.md    # write to a file
anydoc - --format csv < f  # read stdin
```

Rules:

1. Supported inputs: `.doc`, `.docx`, `.docm`, `.odt`, `.rtf`, `.epub`, `.pdf`, `.ppt`, `.pps`, `.pot`, `.pptx`, `.pptm`, `.ppsx`, `.ppsm`, `.odp`, `.xls`, `.xlsx`, `.xlsm`, `.xlsb`, `.ods`, `.csv`. For text PDFs and CSV, prefer the Read tool; use anydoc for those only when asked to.
2. The format is detected from the file content. Pass `--format <name>` only when detection cannot work: CSV from stdin, or a missing or wrong extension.
3. Exit codes: 0 success, 1 the document could not be converted, 2 usage error, 3 pages of a PDF need OCR. Failures print one `anydoc: <message>` line to stderr. The CLI never prompts.
4. For a large document, write to a file with `-o` and read the parts you need instead of streaming everything into context.
5. Scanned and image-only pages need OCR, which anydoc does not do, so the document exits 3. `--ocr hosted` uploads the whole document to [Firecrawl Parse](https://firecrawl.dev/parse). Never pass it without asking the user first and naming the file that would be uploaded. With approval, `--api-key` or `FIRECRAWL_API_KEY` raises limits; no signup needed.
6. Inside a Node, Python, or Rust codebase, prefer the library over shelling out: `@firecrawl/anydoc` on npm, `firecrawl-anydoc` on PyPI, `anydoc` on crates.io. Each exposes the same `to_markdown` / `toMarkdown` API.
