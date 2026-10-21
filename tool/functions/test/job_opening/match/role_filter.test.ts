import { describe, expect, it } from 'vitest';

import { isPortfolioKindOfRole } from '../../../src/job_opening/match/role_filter.js';

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

  it('should keep a kind of role the portfolio holds', () => {
    expect(
      isPortfolioKindOfRole('Mobile Product Designer', ['Product Designer']),
    ).toBe(true);
  });
});
