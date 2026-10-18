# CV Export

The `cv_export` feature turns the portfolio data into a single-page PDF CV. It runs
locally on mobile, desktop and web: no data leaves the device and no AI is involved.

## Features

- Four templates: Sidebar, Classic, Minimal and Bold.
- Five accent colors: teal, indigo, crimson, forest and charcoal.
- Six sections that can be switched on or off: summary, experience, projects, skills, education
  and languages.
- Optional profile photo with an accent-colored border (off by default).
- Live preview, then download (web, desktop) or share (mobile).
- Every CV is exactly one page and uses as much of it as possible.

## How It Works

1. `BuildCvDocumentUseCase` composes the profile, experiences, projects and expertise into a
   `CvDocumentEntity`.
2. `GenerateCvPdfUseCase` renders that document for a `CvOptionsEntity` (template, accent,
   sections, photo) through `CvPdfRenderer`.
3. `ShareCvPdfUseCase` hands the bytes to the platform (save/share dialog, browser download).

### Fitting the page

`CvFitLevelEntity` defines a ladder of 32 content levels, from full content to compact. The
renderer binary-searches the ladder for the fullest level that still fits on one page, then enlarges
the font in small steps (up to 1.4x) while it still fits. It yields to the UI between renders.

Templates with a separate skills column (Sidebar, Bold) fit that column independently of the
main column and use the long experience description. Single-column templates (Classic, Minimal)
use the short description, and switch to the long one only when the whole CV still fits.

### Content rules

- Experience: ongoing entries first, then finished ones by start date (newest first). Only the
  first three are shown, followed by a link to the portfolio website.
- Each experience shows an overview paragraph (short or long description).
- Projects: non-deprecated projects with an App Store or Play Store link, one entry per distinct
  store listing. Each entry links to the website, App Store and Play Store with matching icons.
- When a project has several distinct listings, the title gets the country codes of its markets.
  The code is read from the App Store storefront (`apps.apple.com/<code>/`) or the Play Store
  `gl` parameter in the link.
- Languages are one contact entry of ISO codes (for example `EN, ES, NL`) taken from the `code`
  field of each language.
- Companies, contacts and projects are hyperlinks; contacts have icons.

## Structure

- `domain/`: entities, `BuildCvDocumentUseCase`, `GenerateCvPdfUseCase`, `ShareCvPdfUseCase`.
- `data/pdf/`: `CvPdfRenderer`, the shared blocks in `cv_pdf_blocks.dart`, contact icons, the
  photo loader and one file per template in `template/`.
- `presentation/`: the export screen (bloc, tracking delegate, widgets), the route and the
  `CvExportButtonWidget` shown in the portfolio header.

## Getting Started

Register `CvExportModuleConfigurator` in `module_configurators.dart`. The portfolio header shows
`CvExportButtonWidget`, which opens the `CvExportModuleRoute.cvExport` screen. Import
`cv_export.dart` from consumers, not private feature barrels.

## Technical Notes

- PDFs use the base-14 fonts, so text is normalized to Latin-1 (typographic dashes and quotes
  become plain ones). Non-Latin scripts are not supported.
- The photo is downloaded over HTTP from the profile image URL. If the download fails, the CV is
  rendered without it.

## Dependencies

`pdf` and `printing`, plus the `profile`, `experience`, `project` and `expertise` features.

## Testing

```bash
flutter test test/src/feature/cv_export
```
