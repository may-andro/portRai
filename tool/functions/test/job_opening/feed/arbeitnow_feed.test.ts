import { describe, expect, it, vi } from 'vitest';

import { ArbeitnowFeed } from '../../../src/job_opening/feed/arbeitnow_feed.js';

function arbeitnowJob(slug: string, remote: boolean) {
  return {
    slug,
    company_name: 'Beta GmbH',
    title: `Flutter Developer ${slug}`,
    description: '<p>Flutter and Dart.</p>',
    remote,
    url: `https://www.arbeitnow.com/jobs/companies/beta/${slug}`,
    tags: ['Software Development'],
    job_types: ['Full Time'],
    location: 'Berlin',
    created_at: 1792524636,
  };
}

function page(jobs: unknown[], next: string | null) {
  return { data: jobs, links: { next } };
}

describe('ArbeitnowFeed', () => {
  it('should keep only remote jobs when a page has on-site jobs too', async () => {
    const feed = new ArbeitnowFeed(
      vi
        .fn()
        .mockResolvedValue(
          page([arbeitnowJob('a', true), arbeitnowJob('b', false)], null),
        ),
    );

    const openings = await feed.fetchJobs();

    expect(openings.map((opening) => opening.sourceId)).toEqual(['a']);
    expect(openings[0]).toMatchObject({
      source: 'arbeitnow',
      sourceName: 'Arbeitnow',
      company: 'Beta GmbH',
      url: 'https://www.arbeitnow.com/jobs/companies/beta/a',
      location: 'Berlin',
      jobTypes: ['Full Time'],
      description: 'Flutter and Dart.',
      publishedAt: new Date(1792524636 * 1000),
    });
  });

  it('should read the next page until there is none', async () => {
    const fetchJson = vi
      .fn()
      .mockResolvedValueOnce(page([arbeitnowJob('a', true)], 'page-2'))
      .mockResolvedValueOnce(page([arbeitnowJob('b', true)], null));

    const openings = await new ArbeitnowFeed(fetchJson).fetchJobs();

    expect(fetchJson.mock.calls).toEqual([
      ['https://www.arbeitnow.com/api/job-board-api?page=1'],
      ['https://www.arbeitnow.com/api/job-board-api?page=2'],
    ]);
    expect(openings.map((opening) => opening.sourceId)).toEqual(['a', 'b']);
  });

  it('should stop at the page limit when more pages exist', async () => {
    const fetchJson = vi
      .fn()
      .mockResolvedValue(page([arbeitnowJob('a', true)], 'more'));

    await new ArbeitnowFeed(fetchJson, 2).fetchJobs();

    expect(fetchJson).toHaveBeenCalledTimes(2);
  });

  it('should throw when a page has no data list', async () => {
    const feed = new ArbeitnowFeed(
      vi.fn().mockResolvedValue({ message: 'Too many requests' }),
    );

    await expect(feed.fetchJobs()).rejects.toThrow(
      'Arbeitnow page 1 has no data list',
    );
  });
});
