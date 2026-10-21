import { describe, expect, it, vi } from 'vitest';

import type { JobFeed } from '../../src/job_opening/feed/job_feed.js';
import type {
  JobFit,
  JobOpening,
  JobSource,
} from '../../src/job_opening/job_opening.js';
import type { JobScorer } from '../../src/job_opening/score/job_scorer.js';
import {
  maxScoredOpenings,
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

function fit(overrides: Partial<JobFit> = {}): JobFit {
  return {
    score: 85,
    matchedSkills: [],
    missingSkills: ['GraphQL'],
    reasons: ['The core stack is Flutter.'],
    ...overrides,
  };
}

function scorer(score: JobScorer['score'] = async () => fit()): JobScorer {
  return { score: vi.fn(score) };
}

function dependencies(
  overrides: Partial<SyncDependencies> = {},
): SyncDependencies {
  return {
    feeds: [feed('remotive', [jobOpening()])],
    listUserIds: vi.fn().mockResolvedValue(['owner-uid']),
    loadSkills: vi.fn().mockResolvedValue(['Flutter', 'Dart', 'Firebase']),
    scorer: scorer(),
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
      scoredCount: 1,
      failedScoreCount: 0,
      keptCount: 1,
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
      loadSkills: vi
        .fn()
        .mockResolvedValue(['Flutter', 'Dart', 'Firebase', 'Kotlin']),
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
});
