# AI Guidelines for the English Cheatsheet Project

## 1. Purpose

This project contains a compact English grammar cheatsheet in Russian for A1–A2 learners.

Main requirements:

- explain grammar briefly and structurally;
- use formulas, tables, and short examples;
- preserve a readable print-ready PDF;
- do not add material unrelated to grammar;
- edit source sections rather than generated files.

Communicate with the project owner in Russian. Use absolute paths in all commands and messages.

## 2. Project structure

Source files:

```text
D:\vsprojects\ChatExport_2026-08-21\src\template.html
D:\vsprojects\ChatExport_2026-08-21\src\styles\cheatsheet.css
D:\vsprojects\ChatExport_2026-08-21\src\sections\00-cover.html
D:\vsprojects\ChatExport_2026-08-21\src\sections\01-sentence-frame.html
D:\vsprojects\ChatExport_2026-08-21\src\sections\02-to-be.html
D:\vsprojects\ChatExport_2026-08-21\src\sections\03-wh-questions.html
D:\vsprojects\ChatExport_2026-08-21\src\sections\04-tenses.html
D:\vsprojects\ChatExport_2026-08-21\src\sections\05-tense-signals.html
D:\vsprojects\ChatExport_2026-08-21\src\sections\06-verb-forms.html
D:\vsprojects\ChatExport_2026-08-21\src\sections\07-used-to-modals.html
D:\vsprojects\ChatExport_2026-08-21\src\sections\08-articles-quantity.html
D:\vsprojects\ChatExport_2026-08-21\src\sections\09-prepositions.html
D:\vsprojects\ChatExport_2026-08-21\src\sections\10-verb-preposition-patterns.html
D:\vsprojects\ChatExport_2026-08-21\src\sections\11-comparison.html
D:\vsprojects\ChatExport_2026-08-21\src\sections\12-adverbs.html
D:\vsprojects\ChatExport_2026-08-21\src\sections\13-additional-grammar.html
D:\vsprojects\ChatExport_2026-08-21\src\sections\14-tenses-table.html
D:\vsprojects\ChatExport_2026-08-21\src\sections\15-choice-tree.html
D:\vsprojects\ChatExport_2026-08-21\src\sections\16-compact-grammar.html
```

Section order: sentence basics and questions (1–3) → verbs (4–7) → nouns and prepositions (8–10) → description (11–13) → review pages (14–16). Keep review pages at the end; place a new topic next to related topics, not after the review pages.

Build and validation scripts:

```text
D:\vsprojects\ChatExport_2026-08-21\tools\build.ps1
D:\vsprojects\ChatExport_2026-08-21\tools\validate.ps1
```

Generated outputs:

```text
D:\vsprojects\ChatExport_2026-08-21\english_cheatsheet.html
D:\vsprojects\ChatExport_2026-08-21\english_cheatsheet.pdf
```

`english_cheatsheet.html` and `english_cheatsheet.pdf` are generated automatically. Never edit them manually; make changes in `src` and run the build afterwards.

Source images, OCR data, and chat exports are stored separately and are not part of the cheatsheet content:

```text
D:\vsprojects\ChatExport_2026-08-21\materials\
```

If the `materials` directory does not exist, do not create or populate it without a specific need. Do not inspect `result.json`, `ocr_results.json`, `files`, `photos`, or `voice_messages` during ordinary cheatsheet edits.

## 3. Section format

Each file in `src\sections` must contain exactly one independent `<section>` with metadata:

```html
<section
  class="sheet page-break"
  id="s6"
  data-order="6"
  data-slug="prepositions"
  data-title="6. Space and time"
>
  <div class="content">
    ...
  </div>
</section>
```

Rules:

- `data-order` is a unique numeric order; the cover uses `0`;
- `id` is a unique identifier in the form `s0`, `s1`, and so on;
- `data-slug` is a stable English identifier for the file and topic;
- `data-title` is the title used in the table of contents;
- regular sections contain one numbered `<h2>`;
- file order must match `data-order`;
- do not add footers manually: `tools\build.ps1` inserts them;
- do not edit the table of contents manually: the build script generates it.

File names must follow the `<order:02>-<slug>.html` pattern. A new section requires a unique `data-order`, `id`, and `data-slug`.

Prefer structuring a topic as a separate block:

```html
<article class="card" data-topic="topic-slug">
  <h3>Topic name</h3>
  <p class="rule">Short rule.</p>
  <div class="formula">SUBJECT + VERB + OBJECT</div>
  <div class="ex">
    <span class="en">I watch a film.</span><br>
    <span class="ru">Я смотрю фильм.</span>
  </div>
  <div class="note"><strong>Common mistake:</strong> Short explanation.</div>
</article>
```

`data-topic` must be stable and unique within the project. Do not create a separate file for each small `formula`, `ex`, or `note` block.

## 4. Allowed content

Only the following topics are allowed:

- word order and parts of speech;
- `to be`, questions, and negations;
- Present Simple, Present Continuous, Past Simple, Present Perfect;
- future `will` and `be going to`;
- verb forms `V1 / V2 / V3 / V-ing` and irregular verbs;
- articles, `some / any / much / many`;
- `there is / there are`;
- `this / that / these / those`, `here / there`;
- `how much / how many`;
- prepositions of time and movement;
- movement adverbs;
- `used to`, `be used to / get used to`;
- modal verbs;
- adverbs of frequency and manner;
- comparative and superlative forms, `as ... as`;
- possessive case and `W/H-questions`;
- `have got`;
- `like / love / hate + V-ing`;
- choosing `-ing` or `to + V1` after common verbs;
- imperatives;
- tense signal words and misleading signals;
- tense tables, form-selection algorithms, and compact summary tables.

### `used to` rule

The complete standalone `used to` block exists only in `src\sections\07-used-to-modals.html`. Other sections may contain only short cross-references without repeating the rule.

## 5. Forbidden content and resources

Do not add:

- travel blocks, stories, reading, pronunciation, or vocabulary;
- thematic vocabulary, word lists, exercises, dialogues, or tasks that are not needed to explain a grammar rule;
- images, `<img>`, decorative SVG, or external fonts;
- external CSS/JS resources, CDNs, Google Fonts, or HTTP requests;
- `console.log`, `var_dump`, `debugger`, or temporary debugging code.

Before finishing, check both the generated HTML and the final PDF.

## 6. Style and printing

Text must be concise, practical, and suitable for A1–A2 learners. The preferred block order is: rule → formula → 2–4 examples → common mistake or limitation.

CSS is stored in `src\styles\cheatsheet.css`. Do not change global dimensions or print rules for a single topic. For overflow, use a local section class and be especially careful with sections 6 (`verb-forms`) and 8 (`articles-quantity`): they are nearly full. Add `dense-print` to a section's own `<section>` class when it needs the compact three-column layout.

Preserve:

- A4 landscape format;
- exactly one separate page for the cover and every section; no section may overflow onto another page;
- `.sheet`, `.page-break`, `.content`, `.footer`, and existing component classes;
- the PDF text layer;
- readable tables, formulas, and footers.

Do not reduce the global font size without a clear need. If a section does not fit on one page, remove repetition and compact that section; if it still does not fit, move a complete grammar topic to a new independently numbered section and page with a correct footer. Never leave a continuation-only page.

## 7. Change workflow

1. Find the specific section file by `data-slug` or `data-topic`.
2. Check whether the topic is already covered elsewhere.
3. Edit only the source section and, if necessary, local CSS.
4. Run the build:

```powershell
Set-Location 'D:\vsprojects\ChatExport_2026-08-21'
& '.\tools\build.ps1' -Pdf
```

5. The build script first generates and validates the HTML, then creates the PDF in a temporary directory and replaces the PDF only after a successful build.
6. If needed, run validation separately:

```powershell
& '.\tools\validate.ps1'
```

7. Check the Git diff. Do not include temporary files, OCR, media, or the original chat export in a commit.

If a source image is unreadable or ambiguous, do not guess its contents; ask for clarification about the specific location.

## 8. Required automated validation

`tools\validate.ps1` must check:

- that the final HTML exists and is not empty;
- 17 sections, 16 numbered `h2` headings, and one footer for each section;
- unique IDs, correct order, and the presence of sections `s1`–`s16`;
- no images or SVG;
- no `@import`, external URLs, or debugging code;
- no standalone `used to` rule in the prepositions section (`data-slug="prepositions"`);
- the presence of a valid PDF with a correct PDF header;
- PDF page objects and a text layer;
- no forbidden words or topics in the PDF.

Validation must fail for any required-condition violation. Do not hide build or validation errors.

## 9. PDF and temporary files

Build the PDF with headless Chrome or Edge through `tools\build.ps1 -Pdf`. The temporary browser profile and temporary PDF must be created only under `%TEMP%` and removed in the `finally` block.

Do not leave these files in the project:

- temporary PDF, HTML, browser profiles, screenshots, or logs;
- intermediate build files;
- manually added old footer fragments.

If the PDF build fails, do not replace the previous valid PDF and report the exact reason.

## 10. Git

The project uses Git. Before a major restructuring, preserve the current working state in a separate commit. Commits may include `src`, `tools`, `AGENTS.md`, `.gitignore`, and generated final outputs only after successful validation.

Recommended commit messages:

```text
baseline: current English cheatsheet
refactor: split sections and styles
build: add HTML and PDF validation
content: update grammar section
```

Check `git status --short` before finishing. Never commit secrets, media, OCR data, chat exports, or temporary files.

## 11. Final report

After completing the work, report:

1. changed files;
2. what was changed;
3. the PDF build result;
4. the number of PDF pages;
5. the number of images;
6. the forbidden-content validation result;
7. whether temporary files remain;
8. the Git commit or known limitations.