import { describe, expect, it, vi } from 'vitest';

import {
  loadPortfolioProfile,
  roleSearchTerms,
} from '../../../src/job_opening/profile/portfolio_profile.js';

describe('roleSearchTerms', () => {
  it('should keep the kind of work, most frequent first, without generic words', () => {
    expect(
      roleSearchTerms([
        'Tech Lead - Flutter Developer',
        'Senior Flutter & Android Developer',
        'Mobile Architecture Specialist',
        'Senior Android Developer',
        'Android Developer',
      ]),
    ).toEqual(['Android', 'Flutter', 'Mobile']);
  });

  it('should keep terms with symbols and cap the list at four', () => {
    expect(
      roleSearchTerms([
        'C++ Engineer',
        'iOS Developer',
        'Node.js Developer',
        'Go Engineer',
        'Rust Engineer',
      ]),
    ).toEqual(['C++', 'iOS', 'Node.js', 'Go']);
  });

  it('should return nothing when the roles are only generic words', () => {
    expect(roleSearchTerms(['Senior Software Engineer'])).toEqual([]);
  });
});

describe('loadPortfolioProfile', () => {
  it('should read the skills, roles and experience from the English documents', async () => {
    const documents: Record<string, unknown> = {
      'profile/en': {
        profile: {
          title: 'Senior Flutter & Android Developer',
          subtitle: 'Mobile Architecture Specialist',
          currentRole: 'Tech Lead - Flutter Developer',
          yearsOfExperience: 10,
          location: { city: 'Alicante', country: 'Spain' },
        },
      },
      'experiences/en': {
        experiences: [
          { position: 'Tech Lead - Flutter Developer', technologies: ['Dart'] },
          { position: 'Senior Android Developer', technologies: ['Kotlin'] },
        ],
      },
      'expertise/en': { experties: [{ skills: [{ name: 'Flutter' }] }] },
    };
    const readDocument = vi.fn(
      async (collection: string, documentId: string) =>
        documents[`${collection}/${documentId}`] ?? null,
    );

    const profile = await loadPortfolioProfile(readDocument);

    expect(profile).toEqual({
      skills: ['Flutter', 'Dart', 'Kotlin'],
      roles: [
        'Tech Lead - Flutter Developer',
        'Senior Flutter & Android Developer',
        'Mobile Architecture Specialist',
        'Senior Android Developer',
      ],
      searchTerms: ['Flutter', 'Android', 'Mobile'],
      yearsOfExperience: 10,
      country: 'Spain',
    });
  });

  it('should return empty roles and no experience when the documents are missing', async () => {
    const profile = await loadPortfolioProfile(async () => null);

    expect(profile).toEqual({
      skills: [],
      roles: [],
      searchTerms: [],
      yearsOfExperience: null,
      country: null,
    });
  });
});
