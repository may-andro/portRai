import { describe, expect, it, vi } from 'vitest';

import { RemotiveFeed } from '../../../src/job_opening/feed/remotive_feed.js';
import { searchQuery } from '../fixture.js';

const remotiveJob = {
  id: 2091158,
  url: 'https://remotive.com/remote-jobs/software-development/flutter-2091158',
  title: 'Flutter Engineer',
  company_name: 'Askable',
  tags: ['flutter', 'dart'],
  job_type: 'contract',
  publication_date: '2026-10-17T16:04:29',
  candidate_required_location: 'Worldwide',
  description: '<p>Ship <b>Flutter</b> apps.</p>',
};

describe('RemotiveFeed', () => {
  it('should request the software development category', async () => {
    const fetchJson = vi.fn().mockResolvedValue({ jobs: [] });

    await new RemotiveFeed(fetchJson).fetchJobs(searchQuery());

    expect(fetchJson).toHaveBeenCalledWith(
      'https://remotive.com/api/remote-jobs?category=software-development',
    );
  });

  it('should map a job with Remotive as its source when the response has jobs', async () => {
    const feed = new RemotiveFeed(
      vi.fn().mockResolvedValue({ jobs: [remotiveJob] }),
    );

    const openings = await feed.fetchJobs(searchQuery());

    expect(openings).toEqual([
      {
        source: 'remotive',
        sourceName: 'Remotive',
        sourceId: '2091158',
        title: 'Flutter Engineer',
        company: 'Askable',
        url: remotiveJob.url,
        location: 'Worldwide',
        tags: ['flutter', 'dart'],
        jobTypes: ['contract'],
        description: 'Ship Flutter apps.',
        publishedAt: new Date('2026-10-17T16:04:29Z'),
      },
    ]);
  });

  it('should skip a job when a required field is missing', async () => {
    const feed = new RemotiveFeed(
      vi.fn().mockResolvedValue({
        jobs: [
          { ...remotiveJob, url: '' },
          { ...remotiveJob, publication_date: 'soon' },
        ],
      }),
    );

    expect(await feed.fetchJobs(searchQuery())).toEqual([]);
  });

  it('should drop jobs the query does not keep', async () => {
    const feed = new RemotiveFeed(
      vi.fn().mockResolvedValue({
        jobs: [
          remotiveJob,
          { ...remotiveJob, id: 2, publication_date: '2026-08-01T10:00:00' },
          { ...remotiveJob, id: 3, candidate_required_location: 'USA' },
          { ...remotiveJob, id: 4, title: 'Flutter Content Writer' },
        ],
      }),
    );

    const openings = await feed.fetchJobs(
      searchQuery({
        publishedAfter: new Date('2026-09-21T00:00:00Z'),
        regions: new Set(['europe']),
        roles: ['Senior Flutter Developer'],
      }),
    );

    expect(openings.map((opening) => opening.sourceId)).toEqual(['2091158']);
  });

  it('should throw when the response has no jobs list', async () => {
    const feed = new RemotiveFeed(
      vi.fn().mockResolvedValue({ error: 'blocked' }),
    );

    await expect(feed.fetchJobs(searchQuery())).rejects.toThrow(
      'Remotive response has no jobs list',
    );
  });
});
