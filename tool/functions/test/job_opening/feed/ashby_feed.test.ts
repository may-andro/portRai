import { describe, expect, it, vi } from 'vitest';

import { AshbyFeed } from '../../../src/job_opening/feed/ashby_feed.js';
import { searchQuery } from '../fixture.js';

const board = { system: 'ashby' as const, slug: 'ramp', name: 'Ramp' };

const job = {
  id: 'abc',
  title: 'Mobile Engineer, Android',
  department: 'Engineering',
  team: 'Mobile',
  employmentType: 'FullTime',
  location: 'New York, NY',
  secondaryLocations: [{ location: 'Remote (US)' }],
  publishedAt: '2026-10-20T10:00:00.000+00:00',
  isListed: true,
  isRemote: true,
  workplaceType: 'Hybrid',
  jobUrl: 'https://jobs.ashbyhq.com/ramp/abc',
  descriptionHtml: '<p>Kotlin.</p>',
};

describe('AshbyFeed', () => {
  it('should map a posting with a remote location', async () => {
    const fetchJson = vi.fn().mockResolvedValue({ jobs: [job] });

    const openings = await new AshbyFeed(fetchJson, async () => [
      board,
    ]).fetchJobs(searchQuery({ terms: ['Android'] }));

    expect(fetchJson).toHaveBeenCalledWith(
      'https://api.ashbyhq.com/posting-api/job-board/ramp',
    );
    expect(openings).toEqual([
      {
        source: 'ashby',
        sourceName: 'Ramp',
        sourceId: 'ramp:abc',
        title: 'Mobile Engineer, Android',
        company: 'Ramp',
        url: 'https://jobs.ashbyhq.com/ramp/abc',
        location: 'New York, NY, Remote (US)',
        tags: ['Engineering', 'Mobile'],
        jobTypes: ['Full Time'],
        description: 'Kotlin.',
        publishedAt: new Date('2026-10-20T10:00:00Z'),
      },
    ]);
  });

  it('should skip office roles even when Ashby flags them remote', async () => {
    const fetchJson = vi.fn().mockResolvedValue({
      jobs: [
        { ...job, secondaryLocations: [], location: 'San Francisco' },
        { ...job, id: 'hidden', isListed: false },
      ],
    });

    const openings = await new AshbyFeed(fetchJson, async () => [
      board,
    ]).fetchJobs(searchQuery({ terms: ['Android'] }));

    expect(openings).toEqual([]);
  });

  it('should keep a posting whose workplace type is remote', async () => {
    const fetchJson = vi.fn().mockResolvedValue({
      jobs: [
        {
          ...job,
          secondaryLocations: [],
          location: 'Europe',
          workplaceType: 'Remote',
        },
      ],
    });

    const openings = await new AshbyFeed(fetchJson, async () => [
      board,
    ]).fetchJobs(searchQuery({ terms: ['Android'] }));

    expect(openings.map((opening) => opening.location)).toEqual(['Europe']);
  });
});
