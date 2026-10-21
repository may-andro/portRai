import { describe, expect, it, vi } from 'vitest';

import { loadPortfolioSkills } from '../../../src/job_opening/skill/portfolio_skills.js';

function reader(documents: Record<string, unknown>) {
  return vi.fn(
    async (collection: string, documentId: string) =>
      documents[`${collection}/${documentId}`] ?? null,
  );
}

describe('loadPortfolioSkills', () => {
  it('should collect expertise skills and project and experience technologies', async () => {
    const readDocument = reader({
      'expertise/en': {
        experties: [
          { skills: [{ name: 'Flutter' }, { name: 'Kotlin' }, { level: 'x' }] },
        ],
      },
      'projects/en': { projects: [{ technologies: ['Dart', 'Firebase'] }] },
      'experiences/en': {
        experiences: [{ technologies: ['Jetpack Compose'] }],
      },
    });

    const skills = await loadPortfolioSkills(readDocument);

    expect(skills).toEqual([
      'Flutter',
      'Kotlin',
      'Dart',
      'Firebase',
      'Jetpack Compose',
    ]);
  });

  it('should read only the English documents when other locales exist', async () => {
    const readDocument = reader({
      'expertise/en': { experties: [{ skills: [{ name: 'Flutter' }] }] },
      'expertise/es': { experties: [{ skills: [{ name: 'Gestión' }] }] },
    });

    const skills = await loadPortfolioSkills(readDocument);

    expect(skills).toEqual(['Flutter']);
    expect(readDocument.mock.calls.map(([, documentId]) => documentId)).toEqual(
      ['en', 'en', 'en'],
    );
  });

  it('should drop duplicates ignoring case when collections repeat skills', async () => {
    const readDocument = reader({
      'expertise/en': {
        experties: [
          { skills: [{ name: 'Flutter' }] },
          { skills: [{ name: 'flutter' }] },
        ],
      },
      'projects/en': { projects: [{ technologies: ['FLUTTER', ' Dart '] }] },
      'experiences/en': { experiences: [{ technologies: ['dart'] }] },
    });

    const skills = await loadPortfolioSkills(readDocument);

    expect(skills).toEqual(['Flutter', 'Dart']);
  });

  it('should ignore documents and items without the expected fields', async () => {
    const readDocument = reader({
      'expertise/en': { skills: [{ name: 'Flutter' }] },
      'projects/en': { projects: [null, 'text', { technologies: 'Dart' }] },
      'experiences/en': 'text',
    });

    const skills = await loadPortfolioSkills(readDocument);

    expect(skills).toEqual([]);
  });
});
