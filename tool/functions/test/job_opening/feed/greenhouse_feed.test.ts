import { describe, expect, it, vi } from 'vitest';

import { GreenhouseFeed } from '../../../src/job_opening/feed/greenhouse_feed.js';
import { searchQuery } from '../fixture.js';

const board = { system: 'greenhouse' as const, slug: 'reddit', name: 'Reddit' };

describe('GreenhouseFeed', () => {
  it('should read the kept postings in full and credit the company', async () => {
    const fetchJson = vi.fn(async (url: string) => {
      if (url.endsWith('/jobs')) {
        return {
          jobs: [
            {
              id: 1,
              title: 'Staff Android Engineer',
              absolute_url: 'https://job-boards.greenhouse.io/reddit/jobs/1',
              location: { name: 'Remote - United States' },
              first_published: '2026-10-12T10:00:00-04:00',
              updated_at: '2026-10-20T10:00:00-04:00',
            },
            {
              id: 2,
              title: 'Android Engineer',
              absolute_url: 'https://job-boards.greenhouse.io/reddit/jobs/2',
              location: { name: 'San Francisco, CA' },
              first_published: '2026-10-12T10:00:00-04:00',
            },
          ],
        };
      }
      return {
        content: '&lt;p&gt;Kotlin and &lt;b&gt;Compose&lt;/b&gt;.&lt;/p&gt;',
        departments: [{ name: 'Engineering' }],
      };
    });

    const openings = await new GreenhouseFeed(fetchJson, async () => [
      board,
    ]).fetchJobs(searchQuery({ terms: ['Android'] }));

    expect(fetchJson.mock.calls.map(([url]) => url)).toEqual([
      'https://boards-api.greenhouse.io/v1/boards/reddit/jobs',
      'https://boards-api.greenhouse.io/v1/boards/reddit/jobs/1',
    ]);
    expect(openings).toEqual([
      {
        source: 'greenhouse',
        sourceName: 'Reddit',
        sourceId: 'reddit:1',
        title: 'Staff Android Engineer',
        company: 'Reddit',
        url: 'https://job-boards.greenhouse.io/reddit/jobs/1',
        location: 'Remote - United States',
        tags: ['Engineering'],
        jobTypes: [],
        description: 'Kotlin and Compose.',
        publishedAt: new Date('2026-10-12T14:00:00Z'),
      },
    ]);
  });

  it('should read only the postings left after the date, region and role filters in full', async () => {
    const listedJob = {
      absolute_url: 'https://job-boards.greenhouse.io/reddit/jobs/1',
      location: { name: 'Remote - Spain' },
      first_published: '2026-10-12T10:00:00Z',
    };
    const fetchJson = vi.fn(async (url: string) =>
      url.endsWith('/jobs')
        ? {
            jobs: [
              { ...listedJob, id: 1, title: 'Android Engineer' },
              {
                ...listedJob,
                id: 2,
                title: 'Android Engineer, Payments',
                first_published: '2026-08-01T10:00:00Z',
              },
              {
                ...listedJob,
                id: 3,
                title: 'Android Engineer, Ads',
                first_published: undefined,
                updated_at: '2026-08-03T10:00:00Z',
              },
              {
                ...listedJob,
                id: 4,
                title: 'Android Engineer, Search',
                location: { name: 'Remote - United States' },
              },
              { ...listedJob, id: 5, title: 'Product Manager, Android' },
            ],
          }
        : { content: '', departments: [] },
    );

    const openings = await new GreenhouseFeed(fetchJson, async () => [
      board,
    ]).fetchJobs(
      searchQuery({
        terms: ['Android'],
        publishedAfter: new Date('2026-09-21T00:00:00Z'),
        regions: new Set(['europe']),
        roles: ['Senior Android Developer'],
      }),
    );

    expect(openings.map((opening) => opening.sourceId)).toEqual(['reddit:1']);
    expect(fetchJson.mock.calls.map(([url]) => url)).toEqual([
      'https://boards-api.greenhouse.io/v1/boards/reddit/jobs',
      'https://boards-api.greenhouse.io/v1/boards/reddit/jobs/1',
    ]);
  });

  it('should fail when the board returns no jobs list', async () => {
    await expect(
      new GreenhouseFeed(vi.fn().mockResolvedValue({}), async () => [
        board,
      ]).fetchJobs(searchQuery({ terms: ['Android'] })),
    ).rejects.toThrow('Every company board failed');
  });
});
