import { describe, expect, it } from 'vitest';

import {
  jobFitPrompt,
  parseJobFit,
} from '../../../src/job_opening/score/job_fit.js';
import { jobOpening, portfolioProfile } from '../fixture.js';

const skills = ['Flutter', 'Dart', 'Firebase'];

function reply(value: object): string {
  return JSON.stringify({
    score: 80,
    matchedSkills: [],
    missingSkills: [],
    reasons: [],
    ...value,
  });
}

describe('parseJobFit', () => {
  it('should read the fit when the reply is valid', () => {
    const fit = parseJobFit(
      reply({
        score: 82,
        matchedSkills: ['Flutter', 'Dart'],
        missingSkills: ['GraphQL'],
        reasons: ['The core stack is Flutter.'],
      }),
      skills,
    );

    expect(fit).toEqual({
      score: 82,
      matchedSkills: ['Flutter', 'Dart'],
      missingSkills: ['GraphQL'],
      reasons: ['The core stack is Flutter.'],
    });
  });

  it('should keep only portfolio skills in their portfolio spelling when the reply names others', () => {
    const fit = parseJobFit(
      reply({ matchedSkills: ['flutter', 'Kubernetes', 'FLUTTER', 'dart'] }),
      skills,
    );

    expect(fit.matchedSkills).toEqual(['Flutter', 'Dart']);
  });

  it('should drop portfolio skills from the missing skills when the reply lists them', () => {
    const fit = parseJobFit(
      reply({ missingSkills: ['firebase', 'GraphQL', 'graphql'] }),
      skills,
    );

    expect(fit.missingSkills).toEqual(['GraphQL']);
  });

  it('should clamp and round the score when it is out of range', () => {
    expect(parseJobFit(reply({ score: 140 }), skills).score).toBe(100);
    expect(parseJobFit(reply({ score: -3 }), skills).score).toBe(0);
    expect(parseJobFit(reply({ score: 71.6 }), skills).score).toBe(72);
  });

  it('should cap the lists and texts when the reply is too long', () => {
    const fit = parseJobFit(
      reply({
        missingSkills: Array.from({ length: 12 }, (_, i) => `Skill ${i}`),
        reasons: ['a'.repeat(400), 'b', 'c', 'd'],
      }),
      skills,
    );

    expect(fit.missingSkills).toHaveLength(8);
    expect(fit.reasons).toHaveLength(3);
    expect(fit.reasons[0]).toHaveLength(300);
  });

  it('should throw when the reply is not JSON', () => {
    expect(() => parseJobFit('Score: 80', skills)).toThrow(
      'The job fit reply is not JSON',
    );
  });

  it('should throw when the reply has no numeric score', () => {
    expect(() => parseJobFit(reply({ score: 'high' }), skills)).toThrow(
      'The job fit reply has no score',
    );
  });
});

describe('jobFitPrompt', () => {
  it('should hold the portfolio skills, roles and experience and the job fields but not the source links', () => {
    const opening = { ...jobOpening(), dedupeKey: 'key', matchedSkills: [] };
    const profile = portfolioProfile();

    const prompt = JSON.parse(jobFitPrompt(opening, profile));

    expect(prompt).toEqual({
      portfolioSkills: profile.skills,
      portfolioRoles: profile.roles,
      yearsOfExperience: 10,
      job: {
        title: opening.title,
        company: opening.company,
        location: opening.location,
        jobTypes: opening.jobTypes,
        tags: opening.tags,
        description: opening.description,
      },
    });
  });
});
