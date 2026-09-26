# English Grammar Cheatsheet

Personal English grammar reference for A1–A2 learners. The cheatsheet uses short rules, formulas, examples, and common-error warnings to support lessons and speaking practice.

## Contents

- sentence structure, word order, questions, and negations;
- Present Simple, Present Continuous, Past Simple, Present Perfect;
- `will` and `be going to`;
- Past Simple speaking mode for completed stories;
- `to be`, `there is / there are`, and subject–verb agreement;
- articles, `some / any`, `much / many`, and `how much / how many`;
- `this / that / these / those` and `here / there`;
- time and movement prepositions;
- movement adverbs;
- `used to` and modal verbs;
- comparative and superlative adjectives;
- `like / love / hate + V-ing` and common `-ing`/`to` patterns;
- adverbs of frequency and manner;
- compact tense tables and a form-selection checklist.

The current PDF contains 17 A4 landscape pages, including the cover.

## Project structure

```text
src/template.html              HTML template
src/styles/cheatsheet.css      shared layout and print styles
src/sections/                  source grammar sections
tools/build.ps1                HTML/PDF build script
tools/validate.ps1             HTML/PDF validation script
english_cheatsheet.html        generated HTML output
english_cheatsheet.pdf         generated PDF output
```

Edit the files in `src/`. Do not edit the generated HTML or PDF manually.

## Build

Requirements:

- Windows PowerShell;
- Google Chrome or Microsoft Edge for PDF generation.

From the project root:

```powershell
& '.\tools\build.ps1' -Pdf
```

The build script validates the generated HTML before creating the PDF and validates the final PDF afterwards.

To run validation separately:

```powershell
& '.\tools\validate.ps1'
```

## Privacy

The repository contains only the grammar cheatsheet sources, build tools, and generated outputs. Private exports, OCR data, chat messages, media, audio, local notes, and editor backups are excluded by `.gitignore`.

Before committing, check the working tree:

```powershell
git status --short
git ls-files
```

Do not force-add ignored private files with `git add -f`.

## License

Personal study project. No public license is currently specified.