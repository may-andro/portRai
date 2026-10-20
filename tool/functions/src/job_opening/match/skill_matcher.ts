import type { JobOpening } from '../job_opening.js';

/**
 * Skills this short (such as Go, R or C) are common inside ordinary words and
 * sentences, so they only count when they appear in the title or tags.
 */
const shortSkillLength = 2;

export interface SkillMatcherOptions {
  minMatchedSkills: number;
}

export class SkillMatcher {
  private readonly patterns: Array<{
    skill: string;
    pattern: RegExp;
    isShort: boolean;
  }>;

  constructor(
    skills: string[],
    private readonly options: SkillMatcherOptions = { minMatchedSkills: 2 },
  ) {
    this.patterns = skills.map((skill) => ({
      skill,
      pattern: skillPattern(skill),
      isShort: skill.trim().length <= shortSkillLength,
    }));
  }

  /** The skills found in the opening, in the order they were given. */
  matchedSkills(opening: JobOpening): string[] {
    const headline = [opening.title, ...opening.tags].join('\n').toLowerCase();
    const fullText = `${headline}\n${opening.description.toLowerCase()}`;
    return this.patterns
      .filter(({ pattern, isShort }) =>
        pattern.test(isShort ? headline : fullText),
      )
      .map(({ skill }) => skill);
  }

  isMatch(matchedSkills: string[]): boolean {
    return matchedSkills.length >= this.options.minMatchedSkills;
  }
}

/**
 * Matches the skill as a whole term. Letters and digits may not touch it on
 * either side, so `Java` does not match `JavaScript`, while terms with
 * symbols such as `C++`, `.NET` or `Node.js` still match.
 */
function skillPattern(skill: string): RegExp {
  const escaped = skill
    .trim()
    .toLowerCase()
    .replace(/[.*+?^${}()|[\]\\]/g, '\\$&')
    .replace(/\s+/g, '\\s+');
  return new RegExp(`(?<![a-z0-9])${escaped}(?![a-z0-9])`);
}
