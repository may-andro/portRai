import { isRecord, stringList, stringOrNull } from '../../shared/json_value.js';

/** Reads one document as plain data, or null when it does not exist. */
export type ReadDocument = (
  collection: string,
  documentId: string,
) => Promise<unknown>;

/**
 * The portfolio locale the skills come from. Both job feeds publish mostly in
 * English, and translated skill names would only add noise.
 */
export const skillLocale = 'en';

/**
 * Collects the portfolio's skills: expertise skill names plus the
 * technologies listed on projects and experiences.
 *
 * Each collection holds one document per locale, such as `projects/en`, with
 * the items in one array field, the same documents the app reads. Duplicates
 * are dropped ignoring case, keeping the first spelling.
 */
export async function loadPortfolioSkills(
  readDocument: ReadDocument,
): Promise<string[]> {
  const [expertise, projects, experiences] = await Promise.all([
    readDocument('expertise', skillLocale),
    readDocument('projects', skillLocale),
    readDocument('experiences', skillLocale),
  ]);

  const skills = [
    // The app's expertise documents spell the field `experties`.
    ...items(expertise, 'experties').flatMap((item) =>
      Array.isArray(item.skills)
        ? item.skills.flatMap((skill) => {
            const name = isRecord(skill) ? stringOrNull(skill.name) : null;
            return name ? [name] : [];
          })
        : [],
    ),
    ...items(projects, 'projects').flatMap((item) =>
      stringList(item.technologies),
    ),
    ...items(experiences, 'experiences').flatMap((item) =>
      stringList(item.technologies),
    ),
  ];

  const byLowerCase = new Map<string, string>();
  for (const skill of skills) {
    const key = skill.toLowerCase();
    if (!byLowerCase.has(key)) byLowerCase.set(key, skill);
  }
  return [...byLowerCase.values()];
}

/** The items in [field] of a locale document. */
function items(document: unknown, field: string): Record<string, unknown>[] {
  const list = isRecord(document) ? document[field] : undefined;
  return Array.isArray(list) ? list.filter(isRecord) : [];
}
