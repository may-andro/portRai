import { termPattern } from './skill_matcher.js';

/** Titles naming one of these are engineering roles, whatever else they say. */
const engineeringPattern =
  /engineer|developer|programmer|architect|(?<![a-z])(dev|swe|sde)(?![a-z])|technical staff|tech lead/;

/**
 * Words of titles for roles other than building software, such as `Staff
 * Product Manager, Mobile`, which a role term like Mobile would otherwise
 * match.
 */
export const nonEngineeringRoleWords = [
  'product manager',
  'program manager',
  'project manager',
  'product owner',
  'marketing',
  'designer',
  'design lead',
  'strategist',
  'recruiter',
  'recruiting',
  'talent',
  'sales',
  'account executive',
  'account manager',
  'customer success',
  'support specialist',
  'writer',
  'copywriter',
  'content',
  'analyst',
  'partnerships',
  'partner manager',
  'counsel',
  'legal',
  'finance',
  'accountant',
  'people partner',
];

const nonEngineeringRolePatterns = nonEngineeringRoleWords.map((word) =>
  termPattern(word),
);

/**
 * Whether [title] can be the kind of role the portfolio holds. Titles that
 * name an engineering role are kept; titles naming a non-engineering role are
 * dropped, unless the portfolio's own [roles] name that kind of role too.
 */
export function isPortfolioKindOfRole(
  title: string,
  roles: readonly string[],
): boolean {
  const lowerTitle = title.toLowerCase();
  if (engineeringPattern.test(lowerTitle)) return true;
  const lowerRoles = roles.map((role) => role.toLowerCase());
  return !nonEngineeringRolePatterns.some(
    (pattern) =>
      pattern.test(lowerTitle) &&
      !lowerRoles.some((role) => pattern.test(role)),
  );
}
