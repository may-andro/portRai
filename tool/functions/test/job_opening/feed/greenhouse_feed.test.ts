import { describe, expect, it, vi } from 'vitest';

import { GreenhouseFeed } from '../../../src/job_opening/feed/greenhouse_feed.js';

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

    const openings = await new GreenhouseFeed(fetchJson, [board]).fetchJobs({
      terms: ['Android'],
    });

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

  it('should fail when the board returns no jobs list', async () => {
    await expect(
      new GreenhouseFeed(vi.fn().mockResolvedValue({}), [board]).fetchJobs({
        terms: ['Android'],
      }),
    ).rejects.toThrow('Every company board failed');
  });
});
