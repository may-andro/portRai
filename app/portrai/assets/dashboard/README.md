# Dashboard Assets

Bundled portfolio JSON that staging builds of the app read instead of Firestore. Each section
has a real file and a `*.template.json` file with fictional demo data for a sample profile, Nova
Lindqvist.

## Files

| File                | Top-level key per locale | Model                                                                                  |
| ------------------- | ------------------------ | -------------------------------------------------------------------------------------- |
| `profile.json`      | `profile` (object)       | [`ProfileModel`](../../lib/src/feature/profile/data/model/profile_model.dart)           |
| `experiences.json`  | `experiences` (array)    | [`ExperienceModel`](../../lib/src/feature/experience/data/model/experience_model.dart)  |
| `expertise.json`    | `experties` (array)      | [`ExpertiseModel`](../../lib/src/feature/expertise/data/model/expertise_model.dart)     |
| `projects.json`     | `projects` (array)       | [`ProjectModel`](../../lib/src/feature/project/data/model/project_model.dart)           |
| `services.json`     | `services` (array)       | [`ServiceModel`](../../lib/src/feature/service/data/model/service_model.dart)           |
| `testimonials.json` | `testimonials` (array)   | [`TestimonialModel`](../../lib/src/feature/testimonial/data/model/testimonial_model.dart) |

Each file also has a `.template.json` counterpart with the same structure. `.gitkeep.json` keeps
the directory in git and is not read by the app.

Git tracks only the `*.template.json` files, `.gitkeep.json` and this README. The root
`.gitignore` ignores `**/assets/dashboard/*.json` except `*.template.json`, so the real files stay
local.

## Format

Every file is a JSON object keyed by language code (`en`, `es`, `nl`). Each locale holds the
section's top-level key from the table above and an `updatedAt` string, which the app does not
read:

```json
{
  "en": { "projects": [{ "id": "...", "title": "..." }], "updatedAt": "..." },
  "es": { "projects": [], "updatedAt": "..." },
  "nl": { "projects": [], "updatedAt": "..." }
}
```

The expertise key is spelled `experties`, as the app reads it. The asset repositories load the
entry for the app's language, add a `locale` field to each record, and parse it with the
feature's `json_serializable` model, so the JSON fields are the model's constructor fields:

- **Profile**: identity and contact details (`fullName`, `title`, `subtitle`, `email`, `phone`),
  images, bio texts (`summary`, `detailedBio`, `elevatorPitch`, `uniqueValueProposition`),
  `publishedAt`, `resume`, `socialLinks`, `availability`, `workingHours`, `currentRole`,
  `currentCompany`, `yearsOfExperience`, `projectsDelivered`, `location`, `languages`,
  `educations` and an optional `certifications` list.
- **Experience**: `id`, `company`, `position`, `location`, `startDate`, `endDate`, `current`,
  `employmentType`, descriptions, `responsibilities`, `achievements`, `technologies`,
  `companyLogo`, and optional `url`, `latitude` and `longitude`.
- **Expertise**: `image`, `title`, optional `summary`, and `skills`, each with `name` and optional
  `description`, `level`, `years` and `lastUsed`.
- **Project**: `id`, `title`, descriptions, `image`, `technologies`, `category`, `status`,
  `startDate`, `features`, `achievements`, `teamSize`, `role`, and optional `endDate`,
  `experienceId`, `markets` (country, coordinates and store, website or GitHub links) and
  `metrics` (`label` and `value`).
- **Service**: `id`, `title`, `description`, `detail`, `image`, string lists such as
  `deliverables`, `technologies`, `process` and `projectIds`, and a `faq` list of `question` and
  `answer`.
- **Testimonial**: `id`, `name`, `position`, `company`, `testimonial`, `date`, images,
  `linkedinProfile`, `projectContext`, `experienceId` and `projectIds`.

The model files are the reference for types and which fields are optional. Firestore stores the
same shape: production builds read the document named after the locale in the collection of the
same name.

## Setup

`pubspec.yaml` lists both the real and the template files as assets, so all twelve must exist
for the app to analyze and build. To start from the demo data:

```bash
cd app/portrai/assets/dashboard
for template in *.template.json; do cp "$template" "${template%.template.json}.json"; done
```

Then replace the demo content in the `.json` files with real data.

In CI, the `setup-flutter-module` action copies every `*.template.json` to its `.json` name after
`flutter pub get`, so analysis, tests and builds run on the demo data.

## Firestore

Each file is an object keyed by document ID, which is one of the input shapes
[firestore_export_import](../../../../tool/firestore_export_import/README.md) accepts for
`export`. Copied to `tool/firestore_export_import/.data/<file>.json`, the files upload with
`melos run firestore_export`, writing one document per locale to the collection of the same name.
The `import` command saves the raw Firestore REST response, which is not in this format.

## Switching Data Source

The developer menu, available in staging builds from the settings screen, has a **Use demo data**
switch in its Data Source section. It stores the choice as an `AssetSource` (`real` or
`template`), and the asset repositories then read `<name>.json` or `<name>.template.json`. The
choice persists and applies after an app restart. With the template source the repositories read
the bundled files directly and skip the local cache, so real and demo data are never mixed.

## Demo Data

The template data gives answers that can be checked when testing the assistant:

- 6 experiences, two of them current and overlapping: full-time at Aurora Commerce and part-time
  Independent Consulting since 2021-06
- 11 projects, 6 services, 2 testimonials, 9 expertise groups and 2 certifications in each locale
- Projects in several markets: Aurora Marketplace in the Netherlands, Germany, Belgium and Spain;
  MoveIt in Sweden and Norway; Orbit Pay in the Netherlands and the United Kingdom
- Project statuses Ongoing, Completed and Deprecated (Pixel Puzzle is Deprecated)
- Metrics such as Aurora Assistant at 1M+ active users, Aurora Checkout at +18% conversion uplift
  and Orbit Pay at 150K+ downloads
- A GitHub link on the Aurora Design System market
- No salary expectations, age, hobbies or soft skills, so the assistant should say these are not
  available

`local_assistant_portfolio_evaluation_test.dart` runs the assistant over the `en` entries of the
real `.json` files and is skipped when `profile.json` is absent.
