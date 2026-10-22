import { describe, expect, it, vi } from 'vitest';

import { HimalayasFeed } from '../../../src/job_opening/feed/himalayas_feed.js';
import { searchQuery } from '../fixture.js';

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
    const fetchJson = vi.fn(async (url: string) =>
      url.endsWith('q=Flutter&sort=recent&page=1')
        ? { jobs: [himalayasJob] }
        : { jobs: [] },
    );

    const openings = await new HimalayasFeed(fetchJson).fetchJobs(
      searchQuery({ terms: ['Flutter', 'React Native'] }),
    );

    expect(openings).toHaveLength(1);
    expect(fetchJson.mock.calls.map(([url]) => url).sort()).toEqual([
      'https://himalayas.app/jobs/api/search?q=Flutter&sort=recent&page=1',
      'https://himalayas.app/jobs/api/search?q=Flutter&sort=recent&page=2',
      'https://himalayas.app/jobs/api/search?q=React%20Native&sort=recent&page=1',
    ]);
  });

  it('should keep the pages read when a later page fails', async () => {
    const fetchJson = vi.fn(async (url: string) => {
      if (url.endsWith('page=2')) throw new Error('HTTP 503');
      return { jobs: [{ ...himalayasJob, guid: url }] };
    });

    const openings = await new HimalayasFeed(fetchJson).fetchJobs(
      searchQuery({ terms: ['Flutter'] }),
    );

    expect(openings.map((opening) => opening.sourceId)).toEqual([
      'https://himalayas.app/jobs/api/search?q=Flutter&sort=recent&page=1',
    ]);
    expect(fetchJson).toHaveBeenCalledTimes(2);
  });

  it('should keep the other terms when the first page of one term fails', async () => {
    const fetchJson = vi.fn(async (url: string) => {
      if (url.includes('q=Kotlin')) throw new Error('HTTP 503');
      return url.endsWith('page=1') ? { jobs: [himalayasJob] } : { jobs: [] };
    });

    const openings = await new HimalayasFeed(fetchJson).fetchJobs(
      searchQuery({ terms: ['Kotlin', 'Flutter'] }),
    );

    expect(openings).toHaveLength(1);
  });

  it('should search two terms at a time', async () => {
    const pendingPages: Array<() => void> = [];
    const fetchJson = vi.fn(
      () =>
        new Promise((resolve) => {
          pendingPages.push(() => resolve({ jobs: [] }));
        }),
    );

    const fetching = new HimalayasFeed(fetchJson).fetchJobs(
      searchQuery({ terms: ['Flutter', 'Android', 'Kotlin'] }),
    );
    await vi.waitFor(() => expect(fetchJson).toHaveBeenCalledTimes(2));
    pendingPages.shift()?.();
    await vi.waitFor(() => expect(fetchJson).toHaveBeenCalledTimes(3));
    while (pendingPages.length > 0) pendingPages.shift()?.();

    expect(await fetching).toEqual([]);
  });

  it('should drop jobs the query does not keep', async () => {
    const fetchJson = vi
      .fn()
      .mockResolvedValueOnce({
        jobs: [
          { ...himalayasJob, guid: 'kept' },
          { ...himalayasJob, guid: 'old', pubDate: 1700000000 },
          {
            ...himalayasJob,
            guid: 'us-only',
            locationRestrictions: ['United States'],
          },
          { ...himalayasJob, guid: 'designer', title: 'Flutter Designer' },
        ],
      })
      .mockResolvedValue({ jobs: [] });

    const openings = await new HimalayasFeed(fetchJson).fetchJobs(
      searchQuery({
        terms: ['Flutter'],
        publishedAfter: new Date('2026-09-01T00:00:00Z'),
        regions: new Set(['europe']),
        roles: ['Senior Flutter Developer'],
      }),
    );

    expect(openings.map((opening) => opening.sourceId)).toEqual(['kept']);
  });

  it('should stop after the page limit for each term', async () => {
    const fetchJson = vi.fn().mockResolvedValue({ jobs: [himalayasJob] });

    await new HimalayasFeed(fetchJson, 2).fetchJobs(
      searchQuery({ terms: ['Flutter'] }),
    );

    expect(fetchJson).toHaveBeenCalledTimes(2);
  });

  it('should map a job with its apply link, dates and restrictions', async () => {
    const [opening] = await new HimalayasFeed(
      vi
        .fn()
        .mockResolvedValueOnce({ jobs: [himalayasJob] })
        .mockResolvedValue({ jobs: [] }),
    ).fetchJobs(searchQuery({ terms: ['Flutter'] }));

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

    const openings = await new HimalayasFeed(fetchJson).fetchJobs(
      searchQuery({ terms: ['Flutter'] }),
    );

    expect(openings.map((opening) => opening.location)).toEqual([
      'Worldwide',
      'Albania, Andorra, Belgium +2 more',
    ]);
  });

  it('should throw when a page has no jobs list', async () => {
    await expect(
      new HimalayasFeed(vi.fn().mockResolvedValue({ error: 'x' })).fetchJobs(
        searchQuery({ terms: ['Flutter'] }),
      ),
    ).rejects.toThrow('Himalayas search "Flutter" page 1 has no jobs list');
  });
});
