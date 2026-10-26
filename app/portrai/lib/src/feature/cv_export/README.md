# CV Export

The `cv_export` feature turns the portfolio data into a single-page A4 PDF CV. The PDF is built
on the device on mobile, desktop and web. Only a tailored CV sends data to a cloud AI model.

## Features

- Four templates: Sidebar, Classic, Minimal and Bold. Classic uses a serif font, the others a
  sans-serif one.
- Five accent colors: teal, indigo, crimson, forest and charcoal.
- Six sections that can be switched on or off: summary, experience, projects, skills, education
  and languages.
- Optional profile photo in a circle with an accent-colored border (white on Bold), off by
  default. When the profile has several images, the user picks one.
- A preview of the generated PDF and a download button that hands the file to the platform.
- The content is trimmed and the font scaled so the CV fills one page.
- Optionally tailored for a job, behind the `feature_tailored_cv` flag (off by default).

## How It Works

1. `BuildCvDocumentUseCase` reads the profile, experiences, projects and expertise and composes
   them into a `CvDocumentEntity`. It fails when any of the four cannot be read.
2. `GenerateCvPdfUseCase` renders that document for a `CvOptionsEntity` (template, accent,
   sections, photo) through `PrintingCvPdfRepository` and `CvPdfRenderer`.
3. `ShareCvPdfUseCase` passes the bytes to `Printing.sharePdf` from the `printing` package.

The screen regenerates the PDF after every option change; a result for an older option is
discarded.

### Tailoring for a job

`CvExportScreen.navigate(context, tailoringTarget: ...)` opens the screen with a
`CvTailoringTargetEntity` (job title, company, description and skills), passed as the route's
`extra`. After building the document, `TailorCvDocumentUseCase`:

1. Checks `IsCvTailoringAvailableUseCase`: the `feature_tailored_cv` flag is on and the
   platform supports cloud AI requests (web, Android, iOS).
2. Counts one request with `ConsumeAiRequestQuotaUseCase`. Only a used-up quota stops
   tailoring; a request log that cannot be read does not.
3. Asks `CvTailoringRepository` for a `CvTailoringEntity`. `FirebaseCvTailoringRepository`
   sends the CV and the job as JSON to the app config's `aiAssistantModel` (a built-in default
   when it is unset), with the job description cut to 8,000 characters, and reads a JSON
   response with a fixed schema into `CvTailoringModel`.
4. Applies it: the summary is replaced when it is non-empty and at most 700 characters;
   projects and skill groups are reordered by index, and the named skills move to the front of
   their group. Unknown or repeated indexes are skipped and nothing is dropped or duplicated.
   Experience, contacts and education are unchanged, so the CV holds no facts the portfolio
   lacks beyond the summary wording.

When tailoring fails, the screen shows the standard CV with the translated reason. A tailored
CV's file name includes the company, for example `Ada_Lovelace_Acme_CV.pdf`; otherwise it is
`Ada_Lovelace_CV.pdf`. Opening the route without `extra`, such as after a browser refresh, shows
the standard CV.

### Fitting the page

`CvFitLevelEntity.levels` is a ladder of 32 content levels, from full content to compact. Each
level caps the number of experiences (three, or two at the most compact levels), projects, skill
groups, skills per group and educations, the length of the summary and overviews, and the font
scale. The renderer binary-searches the ladder for the fullest level that lays out on one page,
then binary-searches font scales in steps of 0.02, up to 1.4x, for the largest that still fits.
When no level fits, generation fails with `CvPdfGenerationException`.

The search only lays the page out, which is enough to count pages; the PDF is painted and encoded
once, for the chosen layout. Rendering runs on a background isolate through `compute`, except on
the web, where it runs on the main thread and yields between layouts. `PrintingCvPdfRepository`
keeps the last layout (`CvPdfLayout`), so changing only the accent renders once without a new
search.

Templates with a separate skills column (Sidebar, Bold) fit the main column first, then fit the
skills and education column independently. They show an experience's long description when it
fits the level's overview length, and the short one otherwise. Single-column templates (Classic,
Minimal) use the short description, and switch to the long one only at the fullest level when the
whole CV still fits.

### Content rules

- Experience: ongoing entries first, then finished ones by start date (newest first). When some
  are left out and the profile has a website, a link to it follows. The website is the
  `publishedAt` entry named `website`, or else the social link named `portfolio`.
- Each experience shows one overview paragraph: the long or short description, truncated at a
  word boundary when needed. Without a short description, its achievements and
  responsibilities are joined instead.
- Projects: non-deprecated projects with an App Store or Play Store link, newest first, one entry
  per distinct store listing. Each entry links to the website, App Store and Play Store that it
  has, with matching icons.
- When a project has several distinct listings, the title gets the country codes of its markets.
  The code is read from the App Store storefront (`apps.apple.com/<code>/`) or the Play Store
  `gl` parameter in the link.
- Skills within a group are ordered by level: expert, advanced, intermediate, familiar, then the
  rest.
- Contacts: email, phone, location, languages and up to three social links. Languages are one
  entry of upper-cased ISO codes (for example `EN, ES, NL`) from the `code` field of each
  language; the languages toggle shows or hides it.
- Companies, contacts and projects are hyperlinks; every contact has an icon. GitHub and LinkedIn
  contacts are shown as `GitHub` and `LinkedIn`, a website as the localized `Website`.

## Structure

- `domain/`: entities, the `tailoredCv` flag, repository interfaces, exceptions,
  `BuildCvDocumentUseCase`, `TailorCvDocumentUseCase`, `IsCvTailoringAvailableUseCase`,
  `GenerateCvPdfUseCase` and `ShareCvPdfUseCase`.
- `data/repository/`: `PrintingCvPdfRepository` and `FirebaseCvTailoringRepository`.
- `data/model/` and `data/mapper/`: `CvTailoringModel` reads the tailoring JSON response and
  `CvTailoringMapper` maps it to `CvTailoringEntity`.
- `data/pdf/`: `CvPdfRenderer`, the shared blocks in `cv_pdf_blocks.dart`, the styles, contact
  icons, `CvPhotoLoader` and one file per template in `template/`.
- `presentation/`: the export screen (bloc, tracking delegate, widgets), its route and the option
  label extension.

## Getting Started

Register `CvExportModuleConfigurator` in `module_configurators.dart`; it registers the
`CvExportModuleRoute.cvExport` route (`/cv-export`) and the feature flag. The profile's footer and
social links open the standard CV with `CvExportScreen.navigate(context)`, and the job opening
screen passes a tailoring target. Import `cv_export.dart` from consumers, not private feature
barrels.

## Technical Notes

- PDFs use the built-in Helvetica and Times fonts, which cover Latin-1 only. Common typographic
  characters (dashes, curly quotes, ellipsis, bullets, non-breaking spaces) are replaced by plain
  ones; other characters outside Latin-1 are not supported.
- The photo is downloaded over HTTP from the chosen profile image URL, with an 8-second timeout,
  and reused for later renders. If the download fails, the CV is rendered without it.

## Dependencies

`pdf`, `printing` and `http`, plus the `profile`, `experience`, `project` and `expertise`
features. Tailoring also uses the `firebase` layer's AI controller and the `app_config`,
`ai_rate_limit`, `feature_flag` and `remote_assistant` (platform support) features.

## Testing

```bash
flutter test test/src/feature/cv_export
```
