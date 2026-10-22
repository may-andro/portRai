import { describe, expect, it, vi } from 'vitest';

import { JobicyFeed } from '../../../src/job_opening/feed/jobicy_feed.js';
import { searchQuery } from '../fixture.js';

const jobicyJob = {
  id: 156179,
  url: 'https://jobicy.com/jobs/156179-android-engineer',
  jobTitle: 'Android Engineer',
  companyName: 'Acme',
  jobIndustry: ['Programming'],
  jobType: ['Full-Time'],
  jobGeo: 'Europe',
  jobLevel: 'Senior',
  jobDescription: '<p>Kotlin and <b>Compose</b>.</p>',
  pubDate: '2026-10-21T10:45:08+00:00',
};

describe('JobicyFeed', () => {
  it('should request each term as a lowercase tag', async () => {
    const fetchJson = vi.fn().mockResolvedValue({ jobs: [] });

    await new JobicyFeed(fetchJson).fetchJobs(
      searchQuery({ terms: ['Android', 'Flutter'] }),
    );

    expect(fetchJson.mock.calls.map(([url]) => url)).toEqual([
      'https://jobicy.com/api/v2/remote-jobs?count=50&tag=android',
      'https://jobicy.com/api/v2/remote-jobs?count=50&tag=flutter',
    ]);
  });

  it('should map a job with Jobicy as its source', async () => {
    const [opening] = await new JobicyFeed(
      vi.fn().mockResolvedValue({ jobs: [jobicyJob] }),
    ).fetchJobs(searchQuery({ terms: ['Android'] }));

    expect(opening).toEqual({
      source: 'jobicy',
      sourceName: 'Jobicy',
      sourceId: '156179',
      title: 'Android Engineer',
      company: 'Acme',
      url: jobicyJob.url,
      location: 'Europe',
      tags: ['Senior', 'Programming'],
      jobTypes: ['Full-Time'],
      description: 'Kotlin and Compose.',
      publishedAt: new Date('2026-10-21T10:45:08Z'),
    });
  });

  it('should keep the other tags when one tag fails', async () => {
    const fetchJson = vi.fn(async (url: string) => {
      if (url.endsWith('tag=kotlin')) throw new Error('HTTP 503');
      return { jobs: [jobicyJob] };
    });

    const openings = await new JobicyFeed(fetchJson).fetchJobs(
      searchQuery({ terms: ['Kotlin', 'Android'] }),
    );

    expect(openings).toHaveLength(1);
  });

  it('should fail when every tag fails', async () => {
    await expect(
      new JobicyFeed(
        vi.fn().mockRejectedValue(new Error('HTTP 503')),
      ).fetchJobs(searchQuery({ terms: ['Kotlin', 'Android'] })),
    ).rejects.toThrow('HTTP 503');
  });

  it('should drop jobs the query does not keep', async () => {
    const openings = await new JobicyFeed(
      vi.fn().mockResolvedValue({
        jobs: [
          jobicyJob,
          { ...jobicyJob, id: 2, pubDate: '2026-08-01T10:00:00+00:00' },
          { ...jobicyJob, id: 3, jobGeo: 'USA' },
          { ...jobicyJob, id: 4, jobTitle: 'Android Product Manager' },
        ],
      }),
    ).fetchJobs(
      searchQuery({
        terms: ['Android'],
        publishedAfter: new Date('2026-09-21T00:00:00Z'),
        regions: new Set(['europe']),
        roles: ['Senior Android Developer'],
      }),
    );

    expect(openings.map((opening) => opening.sourceId)).toEqual(['156179']);
  });

  it('should return nothing when a tag has no jobs list', async () => {
    const openings = await new JobicyFeed(
      vi.fn().mockResolvedValue({ friendlyNotice: 'Thanks' }),
    ).fetchJobs(searchQuery({ terms: ['flutter'] }));

    expect(openings).toEqual([]);
  });
});
