import { describe, expect, it } from 'vitest';

import { SkillMatcher } from '../../../src/job_opening/match/skill_matcher.js';
import { jobOpening } from '../fixture.js';

describe('SkillMatcher', () => {
  it('should find skills in the title, tags and description ignoring case', () => {
    const matcher = new SkillMatcher(['Flutter', 'Firebase', 'Kotlin']);

    expect(matcher.matchedSkills(jobOpening())).toEqual([
      'Flutter',
      'Firebase',
    ]);
  });

  it('should not match a skill inside a longer word', () => {
    const matcher = new SkillMatcher(['Java']);

    expect(
      matcher.matchedSkills(
        jobOpening({ title: 'JavaScript Engineer', tags: [], description: '' }),
      ),
    ).toEqual([]);
  });

  it('should match skills that contain symbols', () => {
    const matcher = new SkillMatcher(['C++', '.NET', 'Node.js', 'CI/CD']);

    expect(
      matcher.matchedSkills(
        jobOpening({
          title: 'Engineer',
          tags: [],
          description: 'We use C++, .NET and node.js with CI/CD.',
        }),
      ),
    ).toEqual(['C++', '.NET', 'Node.js', 'CI/CD']);
  });

  it('should match a short skill only in the title or tags', () => {
    const matcher = new SkillMatcher(['Go']);

    expect(
      matcher.matchedSkills(
        jobOpening({
          title: 'Engineer',
          tags: [],
          description: 'Ready to go live.',
        }),
      ),
    ).toEqual([]);
    expect(
      matcher.matchedSkills(
        jobOpening({ title: 'Engineer', tags: ['go'], description: '' }),
      ),
    ).toEqual(['Go']);
  });

  it('should treat any whitespace between words of a skill the same', () => {
    const matcher = new SkillMatcher(['Jetpack Compose']);

    expect(
      matcher.matchedSkills(jobOpening({ description: 'Jetpack\nCompose UI' })),
    ).toEqual(['Jetpack Compose']);
  });

  it('should count as a match only from the minimum number of skills', () => {
    const matcher = new SkillMatcher(['Flutter'], { minMatchedSkills: 2 });

    expect(matcher.isMatch(['Flutter'])).toBe(false);
    expect(matcher.isMatch(['Flutter', 'Dart'])).toBe(true);
  });
});
