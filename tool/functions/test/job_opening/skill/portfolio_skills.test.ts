import { describe, expect, it } from 'vitest';

import { loadPortfolioSkills } from '../../../src/job_opening/skill/portfolio_skills.js';

describe('loadPortfolioSkills', () => {
  it('should collect expertise skills and project and experience technologies', async () => {
    const collections: Record<string, unknown[]> = {
      expertise: [
        { skills: [{ name: 'Flutter' }, { name: 'Kotlin' }, { level: 'x' }] },
      ],
      projects: [{ technologies: ['Dart', 'Firebase'] }],
      experiences: [{ technologies: ['Jetpack Compose'] }],
    };

    const skills = await loadPortfolioSkills(
      async (name) => collections[name] ?? [],
    );

    expect(skills).toEqual([
      'Flutter',
      'Kotlin',
      'Dart',
      'Firebase',
      'Jetpack Compose',
    ]);
  });

  it('should drop duplicates ignoring case and keep the first spelling', async () => {
    const collections: Record<string, unknown[]> = {
      expertise: [
        { skills: [{ name: 'Flutter' }] },
        { skills: [{ name: 'flutter' }] },
      ],
      projects: [{ technologies: ['FLUTTER', ' Dart '] }],
      experiences: [{ technologies: ['dart'] }],
    };

    const skills = await loadPortfolioSkills(
      async (name) => collections[name] ?? [],
    );

    expect(skills).toEqual(['Flutter', 'Dart']);
  });

  it('should ignore documents without the expected fields', async () => {
    const skills = await loadPortfolioSkills(async () => [
      null,
      'text',
      { skills: 'x' },
    ]);

    expect(skills).toEqual([]);
  });
});
