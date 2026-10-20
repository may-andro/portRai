import { isRecord, stringList, stringOrNull } from '../../shared/json_value.js';

/** Reads every document of a top-level collection as plain data. */
export type ReadCollection = (name: string) => Promise<unknown[]>;

/**
 * Collects the portfolio's skills: expertise skill names plus the
 * technologies listed on projects and experiences. Every locale is read and
 * duplicates are dropped ignoring case, keeping the first spelling.
 */
export async function loadPortfolioSkills(
  readCollection: ReadCollection,
): Promise<string[]> {
  const [expertise, projects, experiences] = await Promise.all([
    readCollection('expertise'),
    readCollection('projects'),
    readCollection('experiences'),
  ]);

  const skills = [
    ...expertise.flatMap((document) =>
      isRecord(document) && Array.isArray(document.skills)
        ? document.skills.flatMap((skill) => {
            const name = isRecord(skill) ? stringOrNull(skill.name) : null;
            return name ? [name] : [];
          })
        : [],
    ),
    ...[...projects, ...experiences].flatMap((document) =>
      isRecord(document) ? stringList(document.technologies) : [],
    ),
  ];

  const byLowerCase = new Map<string, string>();
  for (const skill of skills) {
    const key = skill.toLowerCase();
    if (!byLowerCase.has(key)) byLowerCase.set(key, skill);
  }
  return [...byLowerCase.values()];
}
