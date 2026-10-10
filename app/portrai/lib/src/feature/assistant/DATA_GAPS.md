# Assistant Data Gaps

The on-device assistant answers only from the portfolio data stored in Firestore
(mirrored by `assets/dashboard/*.json` locally and `tool/firestore_export_import/.data`).
When a field is missing or a placeholder, the assistant has to answer "not in the portfolio".
This document tracks what is missing, what was already fixed, and what each fix unlocks.

## Resolved

| Area | Change |
|------|--------|
| `profile.workingHours.timezone` | Placeholder (`Your/Timezone`) replaced with `Europe/Madrid`. |
| `profile.location.coordinates` | Set to Alicante (38.3452, -0.4810) instead of 0,0. |
| `profile.languages` | Spanish added (Proficient / Competente / Vaardig) next to English. |
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
Today a skill is only a string inside an expertise group:

```json
{ "title": "Flutter Development", "skills": ["Flutter SDK", "State Management"] }
```

The assistant cannot answer "how good is he at X", "how many years of X" for non-listed technologies,
or "what is his strongest skill". Years per technology are currently derived from the
`technologies` of each experience, which only works when those are kept accurate.

Proposed structure (needs a data model, parser, mapper and assistant context change):

```json
{
  "title": "Flutter Development",
  "skills": [
    { "name": "Flutter SDK", "level": "expert", "years": 6, "lastUsed": "2026" }
  ]
}
```

Code changes: expertise entity and DTO, the mapper, the Firestore import/export templates, and a new
"Skill levels" overview line in `GetAssistantContextUseCase`.

### Projects
- The seven MediaMarkt country projects have identical descriptions and achievements; differentiate them
  (country, release date, specific features) or merge them into one project with a list of markets.
- Several projects have three or fewer achievements, so "most complex project" has little to go on.
- No impact metrics (downloads, ratings, users, revenue). Add a `metrics` field.

### Testimonials
- Only two testimonials. More would support questions about collaboration and working style.

### Missing sections
Questions the assistant cannot answer today because the data does not exist:

| Topic | Suggested field |
|-------|-----------------|
| Salary expectations | `availability.salaryExpectation` (or state that it is private) |
| Age / date of birth | Decide whether to expose it at all |
| Visa / work authorization | `availability.workAuthorization` |
| Notice period | `availability.noticePeriod` |
| Relocation reasons | `availability.relocationNotes` |
| Hobbies and interests | `profile.interests` |
| Soft skills | `profile.softSkills` |
| Certifications and courses | `profile.certifications` |

## Behaviour for missing data
The assistant is instructed to say the information is not available in the portfolio instead of
guessing. The golden question tests in
`test/src/feature/assistant/data/repository/assistant_golden_questions_test.dart` cover the facts
that are computed in code (country totals, work modes, technology durations, gaps, leadership).
Add a golden question whenever a new computed fact or data field is added.
