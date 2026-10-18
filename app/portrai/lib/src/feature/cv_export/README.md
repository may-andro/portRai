# CV Export

The `cv_export` feature turns the portfolio data into a single-page, recruiter-friendly
PDF CV. Everything runs locally; no data leaves the device and no AI is involved.

## Features

- Four templates: Sidebar, Classic, Minimal and Bold.
- Five accent colors and a toggle for each content section.
- Optional profile photo, off by default.
- Live preview and download/share on mobile, desktop and web.
- Guaranteed single page: the renderer retries with progressively less content and
  smaller type until the CV fits.
- Fills the page: the full content is first rendered with enlarged type (up to 1.4x) and
  shrunk until it fits.
- Only the last three experiences are shown, followed by a link to the portfolio website
  for the rest.
- Companies, contacts and projects are hyperlinks; the projects section lists only the
  projects that have a link, as a compact list of clickable names.

## Getting Started

Register `CvExportModuleConfigurator` in `module_configurators.dart`. The portfolio header
shows `CvExportButtonWidget`, which opens the `CvExportModuleRoute.cvExport` screen.
Import `cv_export.dart` from consumers, not private feature barrels.

## Usage

`BuildCvDocumentUseCase` composes the profile, experiences, projects and expertise into a
`CvDocumentEntity`. `GenerateCvPdfUseCase` renders it for a `CvOptionsEntity` and
`ShareCvPdfUseCase` hands the bytes to the platform (save/share dialog, browser download).

## Key Concepts

- `CvDocumentEntity.fit(CvFitLevelEntity)` trims content; most recent items are kept first.
- Templates live in `data/pdf/template/` and share building blocks from `cv_pdf_blocks.dart`.
- PDFs use the base-14 fonts, so text is normalized to Latin-1 (typographic dashes and
  quotes become plain ones); non-Latin scripts are not supported.
- The photo is fetched over HTTP and silently omitted when unavailable (for example, CORS on web).

## Dependencies

`pdf` and `printing`, plus the `profile`, `experience`, `project` and `expertise` features.

## Testing

```bash
flutter test test/src/feature/cv_export
```
