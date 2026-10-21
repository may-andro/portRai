import { describe, expect, it, vi } from 'vitest';

import type { JobFeed } from '../../src/job_opening/feed/job_feed.js';
import type {
  JobOpening,
  JobSource,
} from '../../src/job_opening/job_opening.js';
import {
  type SyncDependencies,
  syncJobOpenings,
} from '../../src/job_opening/sync_job_openings.js';
import { jobOpening } from './fixture.js';

function feed(source: JobSource, result: JobOpening[] | Error): JobFeed {
  return {
    source,
    fetchJobs:
      result instanceof Error
        ? vi.fn().mockRejectedValue(result)
        : vi.fn().mockResolvedValue(result),
  };
}

function dependencies(
  overrides: Partial<SyncDependencies> = {},
): SyncDependencies {
  return {
    feeds: [feed('remotive', [jobOpening()])],
    listUserIds: vi.fn().mockResolvedValue(['owner-uid']),
    loadSkills: vi.fn().mockResolvedValue(['Flutter', 'Dart', 'Firebase']),
    writeJobOpenings: vi.fn().mockResolvedValue(undefined),
    now: () => new Date('2026-10-19T04:00:00Z'),
    logger: { info: vi.fn(), warn: vi.fn() },
    ...overrides,
  };
}

describe('syncJobOpenings', () => {
  it('should write the matching openings for every job-search user', async () => {
    const deps = dependencies({
      feeds: [
        feed('remotive', [
          jobOpening(),
          jobOpening({ title: 'Chef', tags: [], description: 'Cook.' }),
        ]),
      ],
      listUserIds: vi.fn().mockResolvedValue(['owner-uid', 'other-uid']),
    });

    const result = await syncJobOpenings(deps);

    expect(result).toEqual({
      userCount: 2,
      fetchedCount: 2,
      matchedCount: 1,
      failedSources: [],
    });
    expect(deps.writeJobOpenings).toHaveBeenCalledTimes(2);
    const [userId, openings, now] = vi.mocked(deps.writeJobOpenings).mock
      .calls[0];
    expect(userId).toBe('owner-uid');
    expect(openings).toHaveLength(1);
    expect(openings[0]).toMatchObject({
      title: 'Senior Flutter Developer',
      matchedSkills: ['Flutter', 'Dart', 'Firebase'],
    });
    expect(now).toEqual(new Date('2026-10-19T04:00:00Z'));
  });

  it('should write each job once when both feeds list it', async () => {
    const deps = dependencies({
      feeds: [
        feed('remotive', [jobOpening({ source: 'remotive' })]),
        feed('arbeitnow', [jobOpening({ source: 'arbeitnow' })]),
      ],
    });

    await syncJobOpenings(deps);

    const openings = vi.mocked(deps.writeJobOpenings).mock.calls[0][1];
    expect(openings.map((opening) => opening.source)).toEqual(['remotive']);
  });

  it('should skip the feeds when no user has job search on', async () => {
    const remotive = feed('remotive', [jobOpening()]);
    const deps = dependencies({
      feeds: [remotive],
      listUserIds: vi.fn().mockResolvedValue([]),
    });

    const result = await syncJobOpenings(deps);

    expect(result.userCount).toBe(0);
    expect(remotive.fetchJobs).not.toHaveBeenCalled();
    expect(deps.writeJobOpenings).not.toHaveBeenCalled();
  });

  it('should skip the feeds when the portfolio has no skills', async () => {
    const remotive = feed('remotive', [jobOpening()]);
    const deps = dependencies({
      feeds: [remotive],
      loadSkills: vi.fn().mockResolvedValue([]),
    });

    await syncJobOpenings(deps);

    expect(remotive.fetchJobs).not.toHaveBeenCalled();
    expect(deps.logger.warn).toHaveBeenCalled();
  });

  it('should keep the other feeds when one feed fails', async () => {
    const deps = dependencies({
      feeds: [
        feed('remotive', new Error('HTTP 429')),
        feed('arbeitnow', [jobOpening({ source: 'arbeitnow' })]),
      ],
    });

    const result = await syncJobOpenings(deps);

    expect(result.failedSources).toEqual(['remotive']);
    expect(result.matchedCount).toBe(1);
  });

  it('should fail when every feed fails', async () => {
    const deps = dependencies({
      feeds: [
        feed('remotive', new Error('down')),
        feed('arbeitnow', new Error('down')),
      ],
    });

    await expect(syncJobOpenings(deps)).rejects.toThrow(
      'Every job feed failed: remotive, arbeitnow',
    );
    expect(deps.writeJobOpenings).not.toHaveBeenCalled();
  });
});
