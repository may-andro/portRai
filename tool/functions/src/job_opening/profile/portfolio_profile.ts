import { isRecord, stringOrNull } from '../../shared/json_value.js';
import type { PortfolioProfile } from '../job_opening.js';
import {
  portfolioSkills,
  type ReadDocument,
  skillLocale,
} from '../skill/portfolio_skills.js';

const maxSearchTerms = 4;

/**
 * Words in role titles that say nothing about the kind of work, so they are
 * not searched for: seniority, generic job words and filler.
 */
const genericRoleWords = new Set([
  'senior',
  'sr',
  'junior',
  'jr',
  'mid',
  'level',
  'lead',
  'tech',
  'technical',
  'principal',
  'staff',
  'head',
  'chief',
  'developer',
  'developers',
  'engineer',
  'engineers',
  'engineering',
  'programmer',
  'software',
  'specialist',
  'architect',
  'architecture',
  'consultant',
  'freelance',
  'freelancer',
  'intern',
  'manager',
  'team',
  'and',
  'the',
  'of',
  'for',
  'with',
  'at',
  'in',
  'a',
  'an',
]);

/**
 * Reads what the job search uses from the portfolio: the skills, the current
 * role, headline title and past positions, the years of experience and the
 * country.
 */
export async function loadPortfolioProfile(
  readDocument: ReadDocument,
): Promise<PortfolioProfile> {
  const [profileDocument, experiencesDocument, expertise, projects] =
    await Promise.all([
      readDocument('profile', skillLocale),
      readDocument('experiences', skillLocale),
      readDocument('expertise', skillLocale),
      readDocument('projects', skillLocale),
    ]);
  const skills = portfolioSkills({
    expertise,
    projects,
    experiences: experiencesDocument,
  });

  const profile =
    isRecord(profileDocument) && isRecord(profileDocument.profile)
      ? profileDocument.profile
      : {};
  const positions =
    isRecord(experiencesDocument) &&
    Array.isArray(experiencesDocument.experiences)
      ? experiencesDocument.experiences.map((experience) =>
          isRecord(experience) ? experience.position : null,
        )
      : [];
  const roles = uniqueIgnoringCase(
    [
      profile.currentRole,
      profile.title,
      profile.subtitle,
      ...positions,
    ].flatMap((role) => {
      const text = stringOrNull(role);
      return text ? [text] : [];
    }),
  );
  const years = profile.yearsOfExperience;
  const location = isRecord(profile.location) ? profile.location : {};

  return {
    skills,
    roles,
    searchTerms: roleSearchTerms(roles),
    yearsOfExperience:
      typeof years === 'number' && Number.isFinite(years) && years >= 0
        ? years
        : null,
    country: stringOrNull(location.country),
  };
}

/**
 * The words that describe the kind of work across [roles], most frequent
 * first, without seniority or generic job words: `Senior Flutter & Android
 * Developer` and `Android Developer` give `Android`, then `Flutter`.
 */
export function roleSearchTerms(roles: readonly string[]): string[] {
  const counts = new Map<
    string,
    { term: string; count: number; order: number }
  >();
  for (const role of roles) {
    for (const word of role.split(/[^\p{L}\p{N}+#.]+/u)) {
      const term = word.replace(/^\.+|\.+$/g, '');
      const key = term.toLowerCase();
      if (term.length < 2 || genericRoleWords.has(key)) continue;
      const entry = counts.get(key);
      if (entry) {
        entry.count += 1;
      } else {
        counts.set(key, { term, count: 1, order: counts.size });
      }
    }
  }
  return [...counts.values()]
    .sort(
      (first, second) =>
        second.count - first.count || first.order - second.order,
    )
    .slice(0, maxSearchTerms)
    .map(({ term }) => term);
}

function uniqueIgnoringCase(values: string[]): string[] {
  const seen = new Set<string>();
  return values.filter((value) => {
    const key = value.toLowerCase();
    if (seen.has(key)) return false;
    seen.add(key);
    return true;
  });
}
