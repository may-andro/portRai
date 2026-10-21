import type {
  JobOpening,
  PortfolioProfile,
} from '../../src/job_opening/job_opening.js';

export function jobOpening(overrides: Partial<JobOpening> = {}): JobOpening {
  return {
    source: 'remotive',
    sourceName: 'Remotive',
    sourceId: '1',
    title: 'Senior Flutter Developer',
    company: 'Acme',
    url: 'https://remotive.com/remote-jobs/software-development/senior-flutter-developer-1',
    location: 'Europe',
    tags: ['flutter', 'dart'],
    jobTypes: ['full_time'],
    description: 'Build mobile apps with Flutter and Firebase.',
    publishedAt: new Date('2026-10-17T16:04:29Z'),
    ...overrides,
  };
}

export function portfolioProfile(
  overrides: Partial<PortfolioProfile> = {},
): PortfolioProfile {
  return {
    skills: ['Flutter', 'Dart', 'Firebase'],
    roles: ['Tech Lead - Flutter Developer', 'Senior Android Developer'],
    searchTerms: ['Flutter', 'Android'],
    yearsOfExperience: 10,
    country: 'Spain',
    ...overrides,
  };
}
