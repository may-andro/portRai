import { describe, expect, it } from 'vitest';

import { portfolioSkills } from '../../../src/job_opening/skill/portfolio_skills.js';

describe('portfolioSkills', () => {
  it('should collect expertise skills and project and experience technologies', () => {
    const skills = portfolioSkills({
      expertise: {
        experties: [
          { skills: [{ name: 'Flutter' }, { name: 'Kotlin' }, { level: 'x' }] },
        ],
      },
      projects: { projects: [{ technologies: ['Dart', 'Firebase'] }] },
      experiences: {
        experiences: [{ technologies: ['Jetpack Compose'] }],
      },
    });

    expect(skills).toEqual([
      'Flutter',
      'Kotlin',
      'Dart',
      'Firebase',
      'Jetpack Compose',
    ]);
  });

  it('should drop duplicates ignoring case when collections repeat skills', () => {
    const skills = portfolioSkills({
      expertise: {
        experties: [
          { skills: [{ name: 'Flutter' }] },
          { skills: [{ name: 'flutter' }] },
        ],
      },
      projects: { projects: [{ technologies: ['FLUTTER', ' Dart '] }] },
      experiences: { experiences: [{ technologies: ['dart'] }] },
    });

    expect(skills).toEqual(['Flutter', 'Dart']);
  });

  it('should ignore documents and items without the expected fields', () => {
    const skills = portfolioSkills({
      expertise: { skills: [{ name: 'Flutter' }] },
      projects: { projects: [null, 'text', { technologies: 'Dart' }] },
      experiences: 'text',
    });

    expect(skills).toEqual([]);
  });

  it('should return nothing when the documents do not exist', () => {
    expect(
      portfolioSkills({ expertise: null, projects: null, experiences: null }),
    ).toEqual([]);
  });
});
