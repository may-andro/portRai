import { describe, expect, it, vi } from 'vitest';

import { isPortfolioKindOfRole } from '../../../src/job_opening/match/role_filter.js';
import { termPattern } from '../../../src/job_opening/match/skill_matcher.js';

vi.mock(
  '../../../src/job_opening/match/skill_matcher.js',
  async (importOriginal) => {
    const original =
      await importOriginal<
        typeof import('../../../src/job_opening/match/skill_matcher.js')
      >();
    return { ...original, termPattern: vi.fn(original.termPattern) };
  },
);

const roles = ['Tech Lead - Flutter Developer', 'Senior Android Developer'];

describe('isPortfolioKindOfRole', () => {
  it.each([
    ['Senior Android Engineer', true],
    ['Engineering Manager, Mobile Development Productivity', true],
    ['Staff Software Engineer, Android Design System', true],
    ['Member of Technical Staff (Android Engineer)', true],
    ['Head of Mobile', true],
    ['Staff Product Manager, Mobile', false],
    ['Mobile Product Designer', false],
    ['Creative Strategist, Mobile', false],
    ['Senior Performance Marketing Manager, Mobile UA', false],
  ])('should treat %s as the portfolio kind of role: %s', (title, expected) => {
    expect(isPortfolioKindOfRole(title, roles)).toBe(expected);
  });

  it('should not build patterns for each title', () => {
    vi.mocked(termPattern).mockClear();

    isPortfolioKindOfRole('Staff Product Manager, Mobile', roles);
    isPortfolioKindOfRole('Mobile Product Designer', roles);

    expect(termPattern).not.toHaveBeenCalled();
  });

  it('should keep a kind of role the portfolio holds', () => {
    expect(
      isPortfolioKindOfRole('Mobile Product Designer', ['Product Designer']),
    ).toBe(true);
  });
});
