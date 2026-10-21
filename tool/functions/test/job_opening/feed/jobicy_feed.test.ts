import { describe, expect, it, vi } from 'vitest';

import { JobicyFeed } from '../../../src/job_opening/feed/jobicy_feed.js';

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

    await new JobicyFeed(fetchJson).fetchJobs({
      terms: ['Android', 'Flutter'],
    });

    expect(fetchJson.mock.calls.map(([url]) => url)).toEqual([
      'https://jobicy.com/api/v2/remote-jobs?count=50&tag=android',
      'https://jobicy.com/api/v2/remote-jobs?count=50&tag=flutter',
    ]);
  });

  it('should map a job with Jobicy as its source', async () => {
    const [opening] = await new JobicyFeed(
      vi.fn().mockResolvedValue({ jobs: [jobicyJob] }),
    ).fetchJobs({ terms: ['Android'] });

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

  it('should return nothing when a tag has no jobs list', async () => {
    const openings = await new JobicyFeed(
      vi.fn().mockResolvedValue({ friendlyNotice: 'Thanks' }),
    ).fetchJobs({ terms: ['flutter'] });

    expect(openings).toEqual([]);
  });
});
