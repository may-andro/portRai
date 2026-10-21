# CV Export

The `cv_export` feature turns the portfolio data into a single-page PDF CV. It runs
locally on mobile, desktop and web. Only a tailored CV sends data to a cloud AI model.

## Features

- Four templates: Sidebar, Classic, Minimal and Bold.
- Five accent colors: teal, indigo, crimson, forest and charcoal.
- Six sections that can be switched on or off: summary, experience, projects, skills, education
  and languages.
- Optional profile photo with an accent-colored border (off by default).
- Live preview, then download (web, desktop) or share (mobile).
- Every CV is exactly one page and uses as much of it as possible.
- Optionally tailored for a job, behind the `feature_tailored_cv` flag.

## How It Works

1. `BuildCvDocumentUseCase` composes the profile, experiences, projects and expertise into a
   `CvDocumentEntity`.
2. `GenerateCvPdfUseCase` renders that document for a `CvOptionsEntity` (template, accent,
   sections, photo) through `CvPdfRenderer`.
3. `ShareCvPdfUseCase` hands the bytes to the platform (save/share dialog, browser download).

### Tailoring for a job

`CvExportScreen.navigate(context, tailoringTarget: ...)` opens the screen with a
`CvTailoringTargetEntity` (job title, company, description and skills), passed as the route's
`extra`. After building the document, `TailorCvDocumentUseCase`:

1. Checks `IsCvTailoringAvailableUseCase`: the `feature_tailored_cv` flag is on and the
   platform supports cloud AI requests (web, Android, iOS).
2. Reserves one request with `ConsumeAiRequestQuotaUseCase`.
3. Asks `CvTailoringRepository` for a `CvTailoringEntity`. `FirebaseCvTailoringRepository`
   sends the CV and the job as JSON data to the app config's `aiAssistantModel` and reads a
   JSON response with a fixed schema.
4. Applies it: the summary is replaced when it is non-empty and at most 700 characters;
   projects and skill groups are reordered by index, and the named skills move to the front of
   their group. Unknown or repeated indexes are skipped and nothing is dropped or duplicated.
   Experience, contacts and education are unchanged, so the CV holds no facts the portfolio
   lacks beyond the summary wording.

When tailoring fails, the screen shows the standard CV with the reason. A tailored CV's file name
includes the company, for example `Ada_Lovelace_Acme_CV.pdf`. Opening the route without
`extra`, such as after a browser refresh, shows the standard CV.

### Fitting the page

`CvFitLevelEntity` defines a ladder of 32 content levels, from full content to compact. The
renderer binary-searches the ladder for the fullest level that still fits on one page, then enlarges
the font in small steps (up to 1.4x) while it still fits. The search only lays the page out,
which is enough to count pages, and yields to the UI between layouts; the PDF is painted and
encoded once, for the chosen layout. `PrintingCvPdfRepository` keeps the last layout
(`CvPdfLayout`), so changing only the accent renders once without a new search.

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
- Companies, contacts and projects are hyperlinks; every contact has an icon. GitHub and LinkedIn
  contacts are shown as `GitHub` and `LinkedIn`, a personal website as the localized `Website`.

## Structure

- `domain/`: entities, the `tailoredCv` flag, `BuildCvDocumentUseCase`,
  `TailorCvDocumentUseCase`, `IsCvTailoringAvailableUseCase`, `GenerateCvPdfUseCase`,
  `ShareCvPdfUseCase`.
- `data/repository/`: `PrintingCvPdfRepository` and `FirebaseCvTailoringRepository`.
- `data/pdf/`: `CvPdfRenderer`, the shared blocks in `cv_pdf_blocks.dart`, contact icons, the
  photo loader and one file per template in `template/`.
- `presentation/`: the export screen (bloc, tracking delegate, widgets) and its route.

## Getting Started

Register `CvExportModuleConfigurator` in `module_configurators.dart`. The footer's Resume button
opens the `CvExportModuleRoute.cvExport` screen through `CvExportScreen.navigate`. Import
`cv_export.dart` from consumers, not private feature barrels.

## Technical Notes

- PDFs use the base-14 fonts, so text is normalized to Latin-1 (typographic dashes and quotes
  become plain ones). Non-Latin scripts are not supported.
- The photo is downloaded over HTTP from the profile image URL. If the download fails, the CV is
  rendered without it.

## Dependencies

`pdf` and `printing`, plus the `profile`, `experience`, `project` and `expertise` features.
Tailoring also uses the `firebase` layer's AI controller and the `app_config`, `ai_rate_limit`,
`feature_flag` and `remote_assistant` (platform support) features.

## Testing

```bash
flutter test test/src/feature/cv_export
```
