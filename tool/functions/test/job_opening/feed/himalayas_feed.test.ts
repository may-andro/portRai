import { describe, expect, it, vi } from 'vitest';

import { HimalayasFeed } from '../../../src/job_opening/feed/himalayas_feed.js';

const himalayasJob = {
  guid: 'https://himalayas.app/companies/acme/jobs/flutter-developer',
  title: 'Flutter Developer',
  companyName: 'Acme',
  applicationLink:
    'https://himalayas.app/companies/acme/jobs/flutter-developer',
  employmentType: 'Full Time',
  seniority: ['Senior'],
  categories: ['Flutter-Developer', 'Mobile-Engineer'],
  locationRestrictions: ['Germany', 'Netherlands'],
  description: '<p>Build <b>Flutter</b> apps.</p>',
  pubDate: 1792087770,
  expiryDate: 1794679768,
};

describe('HimalayasFeed', () => {
  it('should search each term newest first until a page is empty', async () => {
    const fetchJson = vi
      .fn()
      .mockResolvedValueOnce({ jobs: [himalayasJob] })
      .mockResolvedValueOnce({ jobs: [] })
      .mockResolvedValueOnce({ jobs: [] });

    const openings = await new HimalayasFeed(fetchJson).fetchJobs({
      terms: ['Flutter', 'React Native'],
    });

    expect(openings).toHaveLength(1);
    expect(fetchJson.mock.calls.map(([url]) => url)).toEqual([
      'https://himalayas.app/jobs/api/search?q=Flutter&sort=recent&page=1',
      'https://himalayas.app/jobs/api/search?q=Flutter&sort=recent&page=2',
      'https://himalayas.app/jobs/api/search?q=React%20Native&sort=recent&page=1',
    ]);
  });

  it('should stop after the page limit for each term', async () => {
    const fetchJson = vi.fn().mockResolvedValue({ jobs: [himalayasJob] });

    await new HimalayasFeed(fetchJson, 2).fetchJobs({ terms: ['Flutter'] });

    expect(fetchJson).toHaveBeenCalledTimes(2);
  });

  it('should map a job with its apply link, dates and restrictions', async () => {
    const [opening] = await new HimalayasFeed(
      vi
        .fn()
        .mockResolvedValueOnce({ jobs: [himalayasJob] })
        .mockResolvedValue({ jobs: [] }),
    ).fetchJobs({ terms: ['Flutter'] });

    expect(opening).toEqual({
      source: 'himalayas',
      sourceName: 'Himalayas',
      sourceId: himalayasJob.guid,
      title: 'Flutter Developer',
      company: 'Acme',
      url: himalayasJob.applicationLink,
      location: 'Germany, Netherlands',
      tags: ['Senior', 'Flutter Developer', 'Mobile Engineer'],
      jobTypes: ['Full Time'],
      description: 'Build Flutter apps.',
      publishedAt: new Date(1792087770 * 1000),
      expiresAt: new Date(1794679768 * 1000),
    });
  });

  it('should describe the location as worldwide or shortened when long', async () => {
    const fetchJson = vi
      .fn()
      .mockResolvedValueOnce({
        jobs: [
          { ...himalayasJob, guid: 'a', locationRestrictions: [] },
          {
            ...himalayasJob,
            guid: 'b',
            locationRestrictions: [
              'Albania',
              'Andorra',
              'Belgium',
              'Brazil',
              'Chile',
            ],
          },
        ],
      })
      .mockResolvedValue({ jobs: [] });

    const openings = await new HimalayasFeed(fetchJson).fetchJobs({
      terms: ['Flutter'],
    });

    expect(openings.map((opening) => opening.location)).toEqual([
      'Worldwide',
      'Albania, Andorra, Belgium +2 more',
    ]);
  });

  it('should throw when a page has no jobs list', async () => {
    await expect(
      new HimalayasFeed(vi.fn().mockResolvedValue({ error: 'x' })).fetchJobs({
        terms: ['Flutter'],
      }),
    ).rejects.toThrow('Himalayas search "Flutter" page 1 has no jobs list');
  });
});
