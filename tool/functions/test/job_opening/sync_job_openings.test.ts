import { describe, expect, it, vi } from 'vitest';

import type { JobFeed } from '../../src/job_opening/feed/job_feed.js';
import type {
  JobFit,
  JobOpening,
  JobSource,
} from '../../src/job_opening/job_opening.js';
import type { JobScorer } from '../../src/job_opening/score/job_scorer.js';
import {
  feedTimeLimitMs,
  maxScoredOpenings,
  scoringDeadlineMs,
  type SyncDependencies,
  syncJobOpenings,
} from '../../src/job_opening/sync_job_openings.js';
import { jobOpening, portfolioProfile } from './fixture.js';

function feed(source: JobSource, result: JobOpening[] | Error): JobFeed {
  return {
    source,
    fetchJobs:
      result instanceof Error
        ? vi.fn().mockRejectedValue(result)
        : vi.fn().mockResolvedValue(result),
  };
}

function fit(overrides: Partial<JobFit> = {}): JobFit {
  return {
    score: 85,
    matchedSkills: [],
    missingSkills: ['GraphQL'],
    reasons: ['The core stack is Flutter.'],
    openToCandidate: true,
    ...overrides,
  };
}

function scorer(score: JobScorer['score'] = async () => fit()): JobScorer {
  return {
    score: vi.fn(score),
    fitKey: vi.fn((opening) => `fit-${opening.dedupeKey}`),
  };
}

function dependencies(
  overrides: Partial<SyncDependencies> = {},
): SyncDependencies {
  return {
    feeds: [feed('remotive', [jobOpening()])],
    listUserIds: vi.fn().mockResolvedValue(['owner-uid']),
    loadProfile: vi.fn().mockResolvedValue(portfolioProfile()),
    loadRegions: vi.fn().mockResolvedValue(new Set()),
    scorer: scorer(),
    loadJobFits: vi.fn().mockResolvedValue(new Map()),
    saveJobFits: vi.fn().mockResolvedValue(undefined),
    writeJobOpenings: vi.fn().mockResolvedValue(0),
    notifyNewJobOpenings: vi.fn().mockResolvedValue(true),
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
      staleCount: 0,
      otherRegionCount: 0,
      closedToRegionCount: 0,
      otherRoleCount: 0,
      matchedCount: 1,
      scoredCount: 1,
      reusedScoreCount: 0,
      failedScoreCount: 0,
      keptCount: 1,
      notifiedUserCount: 0,
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
      score: 85,
      missingSkills: ['GraphQL'],
      reasons: ['The core stack is Flutter.'],
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
      loadProfile: vi
        .fn()
        .mockResolvedValue(portfolioProfile({ skills: [], searchTerms: [] })),
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

  it('should keep only the openings scoring at least the threshold', async () => {
    const deps = dependencies({
      feeds: [
        feed('remotive', [
          jobOpening({ sourceId: '1', title: 'Flutter Developer' }),
          jobOpening({ sourceId: '2', title: 'Dart Engineer' }),
        ]),
      ],
      scorer: scorer(async (opening) =>
        fit({ score: opening.title === 'Flutter Developer' ? 60 : 59 }),
      ),
    });

    const result = await syncJobOpenings(deps);

    expect(result).toMatchObject({ scoredCount: 2, keptCount: 1 });
    const openings = vi.mocked(deps.writeJobOpenings).mock.calls[0][1];
    expect(openings.map((opening) => opening.title)).toEqual([
      'Flutter Developer',
    ]);
  });

  it('should add the skills Gemini found when the keywords missed them', async () => {
    const deps = dependencies({
      loadProfile: vi.fn().mockResolvedValue(
        portfolioProfile({
          skills: ['Flutter', 'Dart', 'Firebase', 'Kotlin'],
        }),
      ),
      scorer: scorer(async () => fit({ matchedSkills: ['Dart', 'Kotlin'] })),
    });

    await syncJobOpenings(deps);

    const openings = vi.mocked(deps.writeJobOpenings).mock.calls[0][1];
    expect(openings[0].matchedSkills).toEqual([
      'Flutter',
      'Dart',
      'Firebase',
      'Kotlin',
    ]);
  });

  it('should skip an opening when scoring it fails', async () => {
    const deps = dependencies({
      feeds: [
        feed('remotive', [
          jobOpening({ sourceId: '1', title: 'Flutter Developer' }),
          jobOpening({ sourceId: '2', title: 'Dart Engineer' }),
        ]),
      ],
      scorer: scorer(async (opening) => {
        if (opening.title === 'Dart Engineer') throw new Error('HTTP 429');
        return fit();
      }),
    });

    const result = await syncJobOpenings(deps);

    expect(result).toMatchObject({ failedScoreCount: 1, keptCount: 1 });
    expect(deps.logger.warn).toHaveBeenCalledWith(
      'Scoring a job opening failed',
      expect.objectContaining({ error: 'Error: HTTP 429' }),
    );
  });

  it('should fail without writing when every score fails', async () => {
    const deps = dependencies({
      scorer: scorer(async () => {
        throw new Error('PERMISSION_DENIED');
      }),
    });

    await expect(syncJobOpenings(deps)).rejects.toThrow(
      'Every job score failed (1 openings)',
    );
    expect(deps.writeJobOpenings).not.toHaveBeenCalled();
  });

  it('should score only the best keyword matches when there are many', async () => {
    const many = Array.from({ length: maxScoredOpenings + 1 }, (_, index) =>
      jobOpening({
        sourceId: String(index),
        title: `Flutter Developer ${index}`,
        // The first opening matches the fewest skills.
        tags: index === 0 ? [] : ['flutter', 'dart'],
        description:
          index === 0 ? 'Flutter and Dart.' : 'Flutter, Dart, Firebase.',
      }),
    );
    const deps = dependencies({ feeds: [feed('remotive', many)] });

    const result = await syncJobOpenings(deps);

    expect(result).toMatchObject({
      matchedCount: maxScoredOpenings + 1,
      scoredCount: maxScoredOpenings,
    });
    const scoredTitles = vi
      .mocked(deps.scorer.score)
      .mock.calls.map(([opening]) => opening.title);
    expect(scoredTitles).not.toContain('Flutter Developer 0');
  });

  it('should not score when no opening matches the keywords', async () => {
    const deps = dependencies({
      feeds: [
        feed('remotive', [
          jobOpening({ title: 'Chef', tags: [], description: 'Cook.' }),
        ]),
      ],
    });

    const result = await syncJobOpenings(deps);

    expect(result.keptCount).toBe(0);
    expect(deps.scorer.score).not.toHaveBeenCalled();
    expect(deps.writeJobOpenings).toHaveBeenCalledWith(
      'owner-uid',
      [],
      expect.any(Date),
    );
  });

  it('should skip the remaining openings when scoring reaches the time limit', async () => {
    const start = new Date('2026-10-19T04:00:00Z').getTime();
    let clock = start;
    const deps = dependencies({
      feeds: [
        feed('remotive', [
          jobOpening({ sourceId: '1', title: 'Flutter Developer 1' }),
          jobOpening({ sourceId: '2', title: 'Flutter Developer 2' }),
          jobOpening({ sourceId: '3', title: 'Flutter Developer 3' }),
        ]),
      ],
      now: () => new Date(clock),
      // Two openings score at once; the first to finish uses up the time.
      scorer: scorer(async () => {
        await Promise.resolve();
        clock = start + scoringDeadlineMs;
        return fit();
      }),
    });

    const result = await syncJobOpenings(deps);

    expect(result).toMatchObject({
      scoredCount: 2,
      failedScoreCount: 1,
      keptCount: 2,
    });
    expect(deps.scorer.score).toHaveBeenCalledTimes(2);
    expect(deps.logger.warn).toHaveBeenCalledWith(
      'Scoring a job opening failed',
      expect.objectContaining({
        error: 'Error: Skipped: the scoring time limit was reached',
      }),
    );
  });

  it('should search every feed for the portfolio role terms', async () => {
    const remotive = feed('remotive', [jobOpening()]);
    const deps = dependencies({ feeds: [remotive] });

    await syncJobOpenings(deps);

    expect(remotive.fetchJobs).toHaveBeenCalledWith({
      terms: ['Flutter', 'Android'],
      publishedAfter: new Date('2026-09-19T04:00:00Z'),
      regions: new Set(),
      roles: portfolioProfile().roles,
    });
  });

  it('should pass the preferred regions to the feeds', async () => {
    const remotive = feed('remotive', [jobOpening()]);
    const deps = dependencies({
      feeds: [remotive],
      loadRegions: vi.fn().mockResolvedValue(new Set(['europe'])),
    });

    await syncJobOpenings(deps);

    expect(vi.mocked(remotive.fetchJobs).mock.calls[0][0].regions).toEqual(
      new Set(['europe']),
    );
  });

  it('should read the users and the portfolio at the same time', async () => {
    let finishUsers: (userIds: string[]) => void = () => {};
    const deps = dependencies({
      listUserIds: vi.fn(
        () =>
          new Promise<string[]>((resolve) => {
            finishUsers = resolve;
          }),
      ),
    });

    const syncing = syncJobOpenings(deps);
    await vi.waitFor(() => expect(deps.loadProfile).toHaveBeenCalled());
    finishUsers(['owner-uid']);

    expect((await syncing).keptCount).toBe(1);
  });

  it("should write every user's openings at the same time", async () => {
    const pendingWrites: Array<() => void> = [];
    const deps = dependencies({
      listUserIds: vi.fn().mockResolvedValue(['owner-uid', 'other-uid']),
      writeJobOpenings: vi.fn(
        () =>
          new Promise<number>((resolve) => {
            pendingWrites.push(() => resolve(0));
          }),
      ),
    });

    const syncing = syncJobOpenings(deps);
    await vi.waitFor(() =>
      expect(deps.writeJobOpenings).toHaveBeenCalledTimes(2),
    );
    for (const finishWrite of pendingWrites) finishWrite();

    expect((await syncing).userCount).toBe(2);
  });

  it('should notify each user with new openings and count those with a device', async () => {
    const deps = dependencies({
      listUserIds: vi
        .fn()
        .mockResolvedValue(['owner-uid', 'other-uid', 'quiet-uid']),
      writeJobOpenings: vi.fn(async (userId: string) =>
        userId === 'quiet-uid' ? 0 : 1,
      ),
      notifyNewJobOpenings: vi.fn(
        async (userId: string) => userId === 'owner-uid',
      ),
    });

    const result = await syncJobOpenings(deps);

    expect(deps.notifyNewJobOpenings).toHaveBeenCalledTimes(2);
    expect(deps.notifyNewJobOpenings).toHaveBeenCalledWith('owner-uid', 1);
    expect(deps.notifyNewJobOpenings).toHaveBeenCalledWith('other-uid', 1);
    expect(result.notifiedUserCount).toBe(1);
  });

  it('should finish the run when a notification fails', async () => {
    const deps = dependencies({
      writeJobOpenings: vi.fn().mockResolvedValue(1),
      notifyNewJobOpenings: vi.fn().mockRejectedValue(new Error('FCM down')),
    });

    const result = await syncJobOpenings(deps);

    expect(result).toMatchObject({ keptCount: 1, notifiedUserCount: 0 });
    expect(deps.logger.warn).toHaveBeenCalledWith(
      'Notifying a user of new job openings failed',
      { userId: 'owner-uid', error: 'Error: FCM down' },
    );
  });

  it('should drop openings posted more than 30 days ago', async () => {
    const now = new Date('2026-10-19T04:00:00Z');
    const deps = dependencies({
      now: () => now,
      feeds: [
        feed('remotive', [
          jobOpening({
            sourceId: 'fresh',
            title: 'Fresh Flutter Developer',
            publishedAt: new Date(now.getTime() - 30 * 24 * 3600 * 1000),
          }),
          jobOpening({
            sourceId: 'stale',
            title: 'Old Flutter Developer',
            publishedAt: new Date(now.getTime() - 31 * 24 * 3600 * 1000),
          }),
        ]),
      ],
    });

    const result = await syncJobOpenings(deps);

    expect(result).toMatchObject({ fetchedCount: 2, staleCount: 1 });
    const openings = vi.mocked(deps.writeJobOpenings).mock.calls[0][1];
    expect(openings.map((opening) => opening.title)).toEqual([
      'Fresh Flutter Developer',
    ]);
  });

  it('should drop openings the source has already expired', async () => {
    const deps = dependencies({
      feeds: [
        feed('himalayas', [
          jobOpening({ expiresAt: new Date('2026-10-18T00:00:00Z') }),
        ]),
      ],
    });

    const result = await syncJobOpenings(deps);

    expect(result).toMatchObject({ staleCount: 1, matchedCount: 0 });
  });

  it('should keep an opening whose title names a role even with few skills', async () => {
    const deps = dependencies({
      feeds: [
        feed('remotive', [
          jobOpening({
            title: 'Senior Android Engineer',
            tags: [],
            description: 'Build apps.',
          }),
          jobOpening({
            sourceId: '2',
            title: 'Backend Engineer',
            tags: [],
            description: 'Build services.',
          }),
        ]),
      ],
    });

    const result = await syncJobOpenings(deps);

    expect(result.matchedCount).toBe(1);
    const scoredTitles = vi
      .mocked(deps.scorer.score)
      .mock.calls.map(([opening]) => opening.title);
    expect(scoredTitles).toEqual(['Senior Android Engineer']);
  });

  it('should score role matches before skill-only matches', async () => {
    const deps = dependencies({
      feeds: [
        feed('remotive', [
          jobOpening({
            sourceId: '1',
            title: 'Platform Engineer',
            tags: ['flutter', 'dart'],
            description: 'Flutter, Dart and Firebase.',
          }),
          jobOpening({
            sourceId: '2',
            title: 'Flutter Developer',
            tags: [],
            description: 'Apps.',
          }),
        ]),
      ],
    });

    await syncJobOpenings(deps);

    const scoredTitles = vi
      .mocked(deps.scorer.score)
      .mock.calls.map(([opening]) => opening.title);
    expect(scoredTitles[0]).toBe('Flutter Developer');
  });

  it('should hand the whole portfolio profile and the regions to the scorer', async () => {
    const regions = new Set(['europe']);
    const deps = dependencies({
      loadRegions: vi.fn().mockResolvedValue(regions),
    });

    await syncJobOpenings(deps);

    const [, profile, scoredRegions] = vi.mocked(deps.scorer.score).mock
      .calls[0];
    expect(profile).toEqual(portfolioProfile());
    expect(scoredRegions).toBe(regions);
    expect(vi.mocked(deps.scorer.fitKey).mock.calls[0][2]).toBe(regions);
  });

  it('should drop openings the scorer finds closed to the preferred regions', async () => {
    const deps = dependencies({
      feeds: [
        feed('remotive', [
          jobOpening({ title: 'Flutter Developer', sourceId: '1' }),
          jobOpening({ title: 'Senior Flutter Engineer', sourceId: '2' }),
        ]),
      ],
      scorer: scorer(async (opening) =>
        fit({ openToCandidate: opening.title === 'Flutter Developer' }),
      ),
    });

    const result = await syncJobOpenings(deps);

    expect(result).toMatchObject({
      scoredCount: 2,
      closedToRegionCount: 1,
      keptCount: 1,
    });
    const [, openings] = vi.mocked(deps.writeJobOpenings).mock.calls[0];
    expect(openings.map((opening) => opening.title)).toEqual([
      'Flutter Developer',
    ]);
  });

  it('should drop openings from other regions and other kinds of role before scoring', async () => {
    const deps = dependencies({
      feeds: [
        feed('greenhouse', [
          jobOpening({ title: 'Flutter Developer', location: 'Remote - USA' }),
          jobOpening({ title: 'Flutter Developer', location: 'Remote Spain' }),
          jobOpening({
            title: 'Flutter Contractor',
            location: 'Remote - USA',
            jobTypes: ['Contract'],
          }),
          jobOpening({
            title: 'Senior Flutter Engineer',
            location: 'Remote',
            description: 'Flutter role. You must be based in the US.',
          }),
          jobOpening({ title: 'Product Manager, Flutter', location: 'Remote' }),
        ]),
      ],
      loadRegions: vi.fn().mockResolvedValue(new Set(['europe'])),
    });

    const result = await syncJobOpenings(deps);

    expect(deps.loadRegions).toHaveBeenCalledWith(portfolioProfile());
    expect(result).toMatchObject({
      fetchedCount: 5,
      otherRegionCount: 2,
      otherRoleCount: 1,
      scoredCount: 2,
    });
    expect(deps.scorer.score).toHaveBeenCalledTimes(2);
  });

  it('should reuse a stored fit instead of scoring the opening again', async () => {
    const storedFit = fit({ score: 72, reasons: ['Scored last week.'] });
    const deps = dependencies({
      loadJobFits: vi.fn(
        async (keys: string[]) => new Map(keys.map((key) => [key, storedFit])),
      ),
    });

    const result = await syncJobOpenings(deps);

    expect(result).toMatchObject({
      scoredCount: 0,
      reusedScoreCount: 1,
      keptCount: 1,
    });
    expect(deps.scorer.score).not.toHaveBeenCalled();
    expect(deps.saveJobFits).not.toHaveBeenCalled();
    const [, openings] = vi.mocked(deps.writeJobOpenings).mock.calls[0];
    expect(openings[0]).toMatchObject({
      score: 72,
      reasons: ['Scored last week.'],
    });
  });

  it('should store each new fit under its fit key', async () => {
    const deps = dependencies();

    await syncJobOpenings(deps);

    expect(deps.saveJobFits).toHaveBeenCalledWith(
      new Map([[expect.stringMatching(/^fit-/), fit()]]),
      expect.any(Date),
    );
  });

  it('should not count reused fits towards the scoring limit', async () => {
    const reusedCount = 5;
    const many = Array.from(
      { length: maxScoredOpenings + reusedCount },
      (_, index) =>
        jobOpening({
          sourceId: String(index),
          title: `Flutter Developer ${index}`,
          // The first opening matches the fewest skills.
          tags: index === 0 ? [] : ['flutter', 'dart'],
          description:
            index === 0 ? 'Flutter and Dart.' : 'Flutter, Dart, Firebase.',
        }),
    );
    const deps = dependencies({
      feeds: [feed('remotive', many)],
      // Fits are stored for the best matches, which are asked for first.
      loadJobFits: vi.fn(
        async (keys: string[]) =>
          new Map(keys.slice(0, reusedCount).map((key) => [key, fit()])),
      ),
    });

    const result = await syncJobOpenings(deps);

    expect(result).toMatchObject({
      scoredCount: maxScoredOpenings,
      reusedScoreCount: reusedCount,
    });
    const scoredTitles = vi
      .mocked(deps.scorer.score)
      .mock.calls.map(([opening]) => opening.title);
    expect(scoredTitles).toContain('Flutter Developer 0');
  });

  it('should score every opening when reading the stored fits fails', async () => {
    const deps = dependencies({
      loadJobFits: vi.fn().mockRejectedValue(new Error('unavailable')),
    });

    const result = await syncJobOpenings(deps);

    expect(result).toMatchObject({ scoredCount: 1, reusedScoreCount: 0 });
    expect(deps.logger.warn).toHaveBeenCalledWith(
      'Reading stored job fits failed',
      { error: 'Error: unavailable' },
    );
  });

  it('should still write the openings when storing the fits fails', async () => {
    const deps = dependencies({
      saveJobFits: vi.fn().mockRejectedValue(new Error('unavailable')),
    });

    const result = await syncJobOpenings(deps);

    expect(result.keptCount).toBe(1);
    expect(deps.writeJobOpenings).toHaveBeenCalled();
    expect(deps.logger.warn).toHaveBeenCalledWith('Storing job fits failed', {
      error: 'Error: unavailable',
    });
  });

  it('should write the reused fits when every new score fails', async () => {
    const deps = dependencies({
      feeds: [
        feed('remotive', [
          jobOpening({ sourceId: '1', title: 'Flutter Developer 1' }),
          jobOpening({ sourceId: '2', title: 'Flutter Developer 2' }),
        ]),
      ],
      loadJobFits: vi.fn(async (keys: string[]) => new Map([[keys[0], fit()]])),
      scorer: scorer(async () => {
        throw new Error('HTTP 503');
      }),
    });

    const result = await syncJobOpenings(deps);

    expect(result).toMatchObject({
      reusedScoreCount: 1,
      failedScoreCount: 1,
      keptCount: 1,
    });
  });

  it('should count a feed that runs past the time limit as failed', async () => {
    vi.useFakeTimers();
    try {
      const deps = dependencies({
        feeds: [
          feed('remotive', [jobOpening()]),
          { source: 'himalayas', fetchJobs: () => new Promise(() => {}) },
        ],
      });

      const sync = syncJobOpenings(deps);
      await vi.advanceTimersByTimeAsync(feedTimeLimitMs);
      const result = await sync;

      expect(result).toMatchObject({
        failedSources: ['himalayas'],
        keptCount: 1,
      });
      expect(deps.logger.warn).toHaveBeenCalledWith('A job feed failed', {
        source: 'himalayas',
        error: `Error: Timed out after ${feedTimeLimitMs / 1000} s`,
      });
    } finally {
      vi.useRealTimers();
    }
  });

  it('should count the scoring deadline from the start of the run', async () => {
    const start = new Date('2026-10-19T04:00:00Z').getTime();
    let clock = start;
    const deps = dependencies({
      now: () => new Date(clock),
      // The feeds use up the whole run.
      feeds: [
        {
          source: 'remotive',
          fetchJobs: async () => {
            clock = start + scoringDeadlineMs;
            return [jobOpening({ publishedAt: new Date(start) })];
          },
        },
      ],
    });

    await expect(syncJobOpenings(deps)).rejects.toThrow(
      'Every job score failed (1 openings)',
    );
    expect(deps.scorer.score).not.toHaveBeenCalled();
  });
});
