# Assistant Data Gaps

The on-device assistant answers only from the portfolio data stored in Firestore
(mirrored by `assets/dashboard/*.json` locally and `tool/firestore_export_import/.data`).
When a field is missing or a placeholder, the assistant has to answer "not in the portfolio".
This document tracks what is missing, what was already fixed, and what each fix unlocks.

## Resolved

| Area | Change |
|------|--------|
| `services` | Each service has an `id`, `deliverables`, `technologies`, linked `projectIds`, `engagementTypes`, `idealFor`, `process` steps and `faq`. |
| `profile.workingHours.timezone` | Placeholder (`Your/Timezone`) replaced with `Europe/Madrid`. |
| `profile.location.coordinates` | Set to Alicante (38.3452, -0.4810) instead of 0,0. |
| `profile.languages` | Spanish added (Proficient / Competente / Vaardig) next to English. |
| Technology names | Variants (`Github`, `MVVM Pattern`, `Sqlite` and similar) share one spelling across experiences and projects. |
| Availability | `availability.note` explains that freelance work runs next to the full-time role. |
| Testimonials | Each belongs to an experience (`experienceId`) and can list `projectIds` of projects under that same experience. |
| Projects, testimonials | Each now carries an `experienceId` pointing to its experience (employer). The assistant context resolves it to the company and position, and lists each experience's projects. |
| Projects | Swapped MediaMarkt Turkey Play Store and App Store links corrected. |

## Open data gaps

### Profile
- `educations[].image` and `educations[].url` still point to `example.com`; a real university logo is needed.
- `publishedAt` entries for Play Store and App Store have empty URLs.
- Hindi is not listed in `languages`; add it if it applies.
- The Spanish content uses "España", so country matching in the assistant treats it as a different
  country than "Spain" in English data. Country names should be normalized or the selector should map them.

### Availability
- `availability` says freelance and consulting, part-time (20 hrs/week), `$50-75/hour`. This is
  intentional (weekends and extra hours next to the full-time role), but the text should say so, so
  the assistant does not read it as contradicting the current full-time role.

### Skills (expertise)
Each skill is now `{ name, level, years, lastUsed }`. `level` is one of `expert`, `advanced`,
`intermediate` or `familiar`. Skills that map to technologies listed on experiences and projects were derived from those date ranges.
The remaining skills (for example profiling or TDD) use their category's level, years and last-used
year as an estimate. Review all of them.

### Projects
- The MediaMarkt country projects are one project with a `markets` list. Saturn and MediaWorld stay separate.
- Every project has at least one market. Store links (`appStore`, `playStore`, `website`) live only on the market, and are `null` when not found. `github` stays on the project.
- Several projects have three or fewer achievements, so "most complex project" has little to go on.
- `metrics` (`{ label, value }`) holds Google Play download counts (MediaMarkt is the sum of the seven
  country apps, as a lower bound) and the Play Store rating (MediaMarkt uses the German app).
  Seagate Tote, Spornado and Stuart (rating) have no public figures yet.

### Testimonials
- Only two testimonials. More would support questions about collaboration and working style.

### Missing sections
Questions the assistant cannot answer today because the data does not exist:

| Topic | Suggested field |
|-------|-----------------|
| Salary expectations | `availability.salaryExpectation` (or state that it is private) |
| Age / date of birth | Decide whether to expose it at all |
| Visa / work authorization | `availability.workAuthorization` (estimate, confirm the value) |
| Notice period | `availability.noticePeriod` (estimate, confirm the value) |
| Relocation reasons | `availability.relocationNotes` |
| Hobbies and interests | `profile.interests` |
| Soft skills | `profile.softSkills` |
| Certifications and courses | `profile.certifications` (field exists, list empty) |

## Behaviour for missing data
The assistant is instructed to say the information is not available in the portfolio instead of
guessing. The golden question tests in
`test/src/feature/assistant/data/repository/assistant_golden_questions_test.dart` cover the facts
that are computed in code (country totals, work modes, technology durations, gaps, leadership).
Add a golden question whenever a new computed fact or data field is added.
